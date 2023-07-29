.p816
.smart


.include "fans-library.asm"

.include "includes/asm/variables.asm"

.segment "CODE"

CGRAM_ADDRESS = $00
VRAM_ADDRESS = $4000

main:
    a8Bit
    xy16Bit
    phk
    plb
    phb

    ; bg_palette -> palette_buffer
    blockMove (bg_palette_end-bg_palette), bg_palette, palette_buffer

    ; palette_buffer -> CGDATA
    dmaToCgram #CGRAM_ADDRESS, palette_buffer, (palette_buffer_end - palette_buffer)

    blockMove (sprites_end-sprites), sprites, oam_lo_buffer

    ldaSta #$6A, oam_hi_buffer

    stz OAMADDL
    ; oam_lo_buffer -> OAMDATA
    dmaToOam oam_lo_buffer, (oam_buffer_end - oam_lo_buffer)

    ldaSta #VMainConstants_INCREMENT_MODE_BY_1, VMAIN

    ; sprites_tiles -> VMDATAL
    dmaToVram #VRAM_ADDRESS, sprites_tiles, (sprites_tiles_end - sprites_tiles)

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
    dmaToOam oam_lo_buffer, (oam_buffer_end-oam_lo_buffer)
    
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
        inc oam_lo_buffer
        inc oam_lo_buffer+4
        inc oam_lo_buffer+8
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


sprites:
.byte $80, $80, $00, $20
.byte $80, $90, $20, $20
.byte $7c, $90, $22, $20
sprites_end:

.segment "RODATA1"
bg_palette:
.incbin "includes/gfx/default.pal"
.incbin "includes/gfx/sprite.pal"
bg_palette_end:


sprites_tiles:
.incbin "includes/gfx/sprite.chr"
sprites_tiles_end: