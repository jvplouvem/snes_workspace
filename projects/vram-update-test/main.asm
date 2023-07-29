.p816
.smart


.include "../../framework/asm/includes/ca65/fans-library.asm"

.include "includes/asm/variables.asm"

.bss
tiles_buffer: .res 2000
tiles_buffer_end:


DMA_QUEUE_ENTRIES_MAX=40
DMA_QUEUE_SIZE_MAX=1024*4

; For length we add an extra entry, so we can the end of the queue
dmaQueueLength: .res (DMA_QUEUE_ENTRIES_MAX*2 + 2)
dmaQueueSource: .res (DMA_QUEUE_ENTRIES_MAX*2)
dmaQueueBank: .res (DMA_QUEUE_ENTRIES_MAX*2)
dmaQueueDest: .res (DMA_QUEUE_ENTRIES_MAX*2)
dmaQueueIndex: .res 2
dmaQueueSize: .res 2

.segment "CODE"
CGRAM_ADDRESS = $00
VRAM_ADDRESS = $4000
OAMRAM_ADDRESS = $00

main:
    a8Bit
    xy16Bit
    phk
    plb
    phb

    ; bg_palette -> palette_buffer
    blockMove #(bg_palette_end-bg_palette), bg_palette, palette_buffer

    ;blockMove #1024, sprites_tiles, tiles_buffer

    ; palette_buffer -> CGDATA
    dmaToCgram #CGRAM_ADDRESS, palette_buffer, #(palette_buffer_end - palette_buffer)

    ; blockMove #(sprites_low_table_end-sprites_low_table), sprites_low_table, oam_lo_buffer

    ;ldaSta #$6A, oam_hi_buffer

    ; oam_lo_buffer -> OAMDATA
    ; dmaToOam #OAMRAM_ADDRESS, oam_lo_buffer, #(oam_buffer_end - oam_lo_buffer)

    ldaSta #VMainConstants_INCREMENT_MODE_BY_1, VMAIN

    ; sprites_tiles -> VMDATAL
    ;dmaToVram #VRAM_ADDRESS, tiles_buffer, #(tiles_buffer_end - tiles_buffer)
    ;dmaToVram #VRAM_ADDRESS, $808120, #(tiles_buffer_end - tiles_buffer)

    ; === send to vram by loop =========================================
    ; VRAM address
    ; ldxStx #VRAM_ADDRESS, VMADDL
    
    ; ; sprites_tiles starts at $8120

    ; ldx #$0000
	; @charset_loop:
	; 	lda f:sprites_tiles,x
    ;     sta VMDATAL
	; 	inx
		
	; 	lda f:sprites_tiles,x
    ;     sta VMDATAH
	; 	inx
	; 	;cpx #(sprites_tiles_end - sprites_tiles)
    ;     cpx #32*4 ; 4 blocos da vram
	;     bne @charset_loop


    ; ldxStx #VRAM_ADDRESS+256, VMADDL

    ; ; segunda linha
    ; ldx #512 ; cada linha tem 16 blocos, entao 32 * 16 = 512
	; @charset_loop_2:
	; 	lda f:sprites_tiles,x
    ;     sta VMDATAL
	; 	inx
		
	; 	lda f:sprites_tiles,x
    ;     sta VMDATAH
	; 	inx
	; 	;cpx #(sprites_tiles_end - sprites_tiles)
    ;     cpx #512+(32*4) ; 4 blocos da segunda linha
	;     bne @charset_loop_2


    ; ; terceira linha
    ; ldxStx #VRAM_ADDRESS+(256*2), VMADDL
    ; ldx #1024 ; cada linha tem 16 blocos, entao 32 * 16 = 512
	; @charset_loop_3:
	; 	lda f:sprites_tiles,x
    ;     sta VMDATAL
	; 	inx
		
	; 	lda f:sprites_tiles,x
    ;     sta VMDATAH
	; 	inx
	; 	;cpx #(sprites_tiles_end - sprites_tiles)
    ;     cpx #512+512+(32*4) ; 4 blocos da segunda linha
	;     bne @charset_loop_3


    ; vramAddress, tilesLabel, tilesOffset, length
    sendToVramByLoop #VRAM_ADDRESS, sprites_tiles, #$0000, #32*4 ; line 1
    sendToVramByLoop #VRAM_ADDRESS+256, sprites_tiles, #512, #512+(32*4) ; line 2
    sendToVramByLoop #VRAM_ADDRESS+(256*2), sprites_tiles, #(512*2), #512+512+(32*4) ; line 3
    ; ==================================================================


    ; jsr DmaInit
    ; ldxStx sprites_tiles, dmaQueueSource
    ; ldxStx ^sprites_tiles, dmaQueueBank
    ; ldxStx #(sprites_tiles_end - sprites_tiles), dmaQueueLength
    ; ldxStx #VRAM_ADDRESS, dmaQueueDest
    ;jsr DmaFlush


    setObjectAndCharacterSize #$02
    setBGMode #BgModeConstants_MODE1
    enableMainScreenDesignation #ScreenDesignationConstants_SPRITES_ON
    enableNmiAndAutoJoypadRead
    initScreen

infinite_loop:
    a8Bit
    xy16Bit
    jsr wait_nmi
    
    ; V-Blank begin
    ; oam_lo_buffer -> OAMDATA
    ;dmaToOam #OAMRAM_ADDRESS, oam_lo_buffer, #(oam_buffer_end-oam_lo_buffer)

    ;dmaToVram #VRAM_ADDRESS, tiles_buffer, #(tiles_buffer_end - tiles_buffer)


    ; ; === send to vram by loop =========================================
    ; ; VRAM address
    ; ldxStx address, VMADDL
    ; ldx #$0000
	
	; @charset_loop:
	; 	ldaSta TILES_LABEL,x,  VMDATAL
	; 	inx
		
	; 	ldaSta TILES_LABEL,x,  VMDATAH
	; 	inx
	; 	cpx TILES_LENGTH;
	;     bne @charset_loop
    ; ; ==================================================================

    ; stx VMADDL
    ;dma tiles_buffer, VMDATAL, #(tiles_buffer_end - tiles_buffer), #$01

    jsr pad_poll
    jsr read_joypad1

    a8Bit
    jmp infinite_loop

wait_nmi:
    .a8
    .i16
    lda in_nmi

    @check_again:
        wai
        cmp in_nmi
        beq @check_again
    rts

pad_poll:
    .a8
    .i16
    php
    a8Bit

    @wait:
        lda HVBJOY
        lsr a ; a / 2
        bcs @wait ; if HVBJOY >= (a / 2)

        a16Bit
        ldaSta pad1, temp1
        ldaSta JOY1L, pad1
        eor temp1
        and pad1
        sta pad1_new
        
        ldaSta pad2, temp1
        ldaSta JOY2L, pad2
        eor temp1
        and pad2
        sta pad2_new
        plp
    rts


read_joypad1:
    axy16Bit
    a16Bit
    lda pad1
    and #$0200
    a8Bit
    beq joy1_not_left

    joy1_left:
        a8Bit
        dec oam_lo_buffer
        dec oam_lo_buffer+4
        dec oam_lo_buffer+8
        a16Bit

    joy1_not_left:
        a16Bit
        a16Bit
        lda pad1
        and #$0100
        a8Bit
        beq joy1_not_right

    joy1_right:
        a8Bit
        ; inc tiles_buffer
        ; inc tiles_buffer+4
        ; inc tiles_buffer+8
        a16Bit

    joy1_not_right:
        a16Bit
        a16Bit
        lda pad1
        and #$0800
        a8Bit
        beq joy1_not_up

    joy1_up:
        a8Bit
        dec oam_lo_buffer+1
        dec oam_lo_buffer+5
        dec oam_lo_buffer+9
        a16Bit

    joy1_not_up:
        a16Bit
        a16Bit
        lda pad1
        and #$0400
        a8Bit
        beq joy1_not_down

    joy1_down:
        a8Bit
        inc oam_lo_buffer+1
        inc oam_lo_buffer+5
        inc oam_lo_buffer+9
        a16Bit

    joy1_not_down:





.proc DmaInit
; Initialises DMA
; -
    .a8
    .i16
    a16Bit
    stz dmaQueueIndex
    stz dmaQueueLength
    stz dmaQueueSize
    a8Bit
    rts
.endproc

.proc DmaFlush
; Flushes the DMA queue. Should be called during forced VBLANK.
; Destroys: X
    .a8
    .i16
    php
    phd
    axy16Bit
    lda #V_INC_1
    sta VMAIN
    ldx #0
    a16Bit
    lda #$4300
    tcd
    lda #$1801
    sta z:0
    loop:
      	lda f:sprites_tiles, X
        sta z:2
        lda ^sprites_tiles, X
        sta z:4
        lda $2000, X
        beq done
        sta z:5
        lda VRAM_ADDRESS, X
        sta VMADDL
        lda #1
        sta MDMAEN
        inx
        inx
        bra loop
    done:
    stz dmaQueueLength
    stz dmaQueueIndex
    stz dmaQueueSize
    pld
    plp
    rts
.endproc

;vram_sprite_table:
;    .word $4000, $4010, $4100, $4110
;vram_sprite_table_end:

sprites_low_table:
    ; 4 bytes per sprite = x, y, tile #, attribute
    .byte $80, $80, $00, $20 ; X = 128, y = 128, tile # = 0
    .byte $80, $90, $20, $20 ; X = 128, y = 144, tile # = 32
    .byte $7c, $90, $22, $20 ; X = 124, y = 144, tile # = 34
sprites_low_table_end:

.segment "RODATA1"
; bg_palette:
;     .incbin "includes/gfx/default.pal"
;     .incbin "includes/gfx/sprite.pal"
; bg_palette_end:

bg_palette:
    .incbin "includes/gfx/default.pal"
    .incbin "includes/gfx/metalslug.pal"
bg_palette_end:


; sprites_tiles:
;     .incbin "includes/gfx/sprite.chr"
; sprites_tiles_end:

; sprites_tiles starts at $8120
; length = $2000
sprites_tiles:
    .incbin "includes/gfx/metalslug.chr"
sprites_tiles_end: