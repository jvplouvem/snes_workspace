.p816
.smart


.include "../../framework/asm/includes/ca65/fans-library.asm"

.include "includes/asm/variables.asm"

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

    ; === PALETTE ================================================================
    ; bg_palette -> palette_buffer
    blockMove #(bg_palette_end-bg_palette), bg_palette, palette_buffer

    ;blockMove #1024, sprites_tiles, tiles_buffer

    ; palette_buffer -> CGDATA
    dmaToCgram palette_buffer, #CGRAM_ADDRESS, #(palette_buffer_end-palette_buffer)
    ; =============================================================================

    ; === SPRITES TABLE ======================================================================
    blockMove #(sprites_low_table_end-sprites_low_table), sprites_low_table, oam_lo_buffer
    blockMove #(sprites_high_table_end-sprites_high_table), sprites_high_table, oam_hi_buffer
    ; ========================================================================================

    ;ldaSta #$6A, oam_hi_buffer

    ; oam_lo_buffer -> OAMDATA
    ; dmaToOam #OAMRAM_ADDRESS, oam_lo_buffer, #(oam_buffer_end - oam_lo_buffer)

    ldaSta #VMainConstants_INCREMENT_MODE_BY_1, VMAIN
    
    ; === SPRITES TILES ========================================================
    ; sprites_tiles -> VMDATAL
    dmaToVram sprites_tiles, #VRAM_ADDRESS, #(sprites_tiles_end - sprites_tiles)
    ; ==========================================================================

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
    dmaToOam oam_lo_buffer, #OAMRAM_ADDRESS, #(oam_buffer_end-oam_lo_buffer)

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



sprites_low_table:
    .byte $68, $01, $0c, $20
    .byte $78, $01, $0e, $20
    .byte $20, $09, $13, $20
    .byte $30, $09, $15, $20
    .byte $40, $09, $17, $20
    .byte $60, $09, $1b, $20
    .byte $18, $11, $22, $20
    .byte $58, $11, $2a, $20
    .byte $70, $11, $2d, $20
    .byte $80, $11, $2f, $20
    .byte $28, $19, $34, $20
    .byte $38, $19, $36, $20
    .byte $68, $19, $3c, $20
    .byte $18, $21, $42, $20
    .byte $58, $21, $4a, $20
    .byte $78, $21, $4e, $20
    .byte $30, $29, $55, $20
    .byte $40, $29, $57, $20
    .byte $10, $31, $61, $20
    .byte $20, $31, $63, $20
    .byte $50, $31, $69, $20
    .byte $60, $31, $6b, $20
    .byte $78, $31, $6e, $20
sprites_low_table_end:

sprites_high_table:
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
    .byte $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA
sprites_high_table_end:


.segment "RODATA1"
bg_palette:
    .incbin "includes/gfx/default.pal"
    ;.incbin "includes/gfx/0_1.clr"
    ;.incbin "includes/gfx/0_1.pal"
    .incbin "includes/gfx/0_1.palette"
bg_palette_end:

sprites_tiles:
    ;.incbin "includes/gfx/0_1.pic"
    ;.incbin "includes/gfx/0_1.spr"
    .incbin "includes/gfx/0_1.tiles"
sprites_tiles_end: