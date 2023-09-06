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
        ;a8Bit
        ; dec oam_lo_buffer
        ; dec oam_lo_buffer+4
        ; dec oam_lo_buffer+8
        ; .repeat 8, I
        ;     teste2 #VRAM_ADDRESS, I, sprites_tiles
        ; .endrepeat
        ;a16Bit

        teste2 #VRAM_ADDRESS, 0, sprites_tiles

    joy1_not_left:
        a16Bit
        a16Bit
        lda pad1
        and #$0100
        a8Bit
        beq joy1_not_right

    joy1_right:
        ;a8Bit
        ; inc tiles_buffer
        ; inc tiles_buffer+4
        ; inc tiles_buffer+8
        ;a16Bit
        teste2 #VRAM_ADDRESS, 1, sprites_tiles

    joy1_not_right:
        a16Bit
        a16Bit
        lda pad1
        and #$0800
        a8Bit
        beq joy1_not_up

    joy1_up:
        a8Bit
        ; dec oam_lo_buffer+1
        ; dec oam_lo_buffer+5
        ; dec oam_lo_buffer+9
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
        ; inc oam_lo_buffer+1
        ; inc oam_lo_buffer+5
        ; inc oam_lo_buffer+9
        a16Bit

    joy1_not_down: