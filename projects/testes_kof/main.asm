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
    ;blockMove #(sprites_low_table_end-sprites_low_table), sprites_low_table, oam_lo_buffer
    ;blockMove #(sprites_high_table_end-sprites_high_table), sprites_high_table, oam_hi_buffer
    ; ========================================================================================

    ;ldaSta #$6A, oam_hi_buffer

    ; oam_lo_buffer -> OAMDATA
    ; dmaToOam #OAMRAM_ADDRESS, oam_lo_buffer, #(oam_buffer_end - oam_lo_buffer)

    ldaSta #VMainConstants_INCREMENT_MODE_BY_1, VMAIN
    
    ; === SPRITES TILES ========================================================
    ; sprites_tiles -> VMDATAL
    ;dmaToVram sprites_tiles, #VRAM_ADDRESS, #(sprites_tiles_end-sprites_tiles)
    ; ==========================================================================


    ;sendToVramByLoop #VRAM_ADDRESS, sprites_tiles, #$0000, #32*4
    ;sendToVramByLoop #VRAM_ADDRESS, sprites_tiles, #$0100, #32*4

   
    ; .repeat 8, I
    ;     teste2 #VRAM_ADDRESS, I, sprites_tiles
    ; .endrepeat


    ; .repeat 8, I
    ;     teste2 #VRAM_ADDRESS, I, sprites_tiles+128
    ; .endrepeat

    ; ldaSta #0, current_line
    ; loop_teste:
    ;     ;teste3 current_line
    ;     teste2 #VRAM_ADDRESS, current_line, sprites_tiles
    ;     inc
    ;     sta current_line
    ;     cmp #8
    ;     bmi loop_teste

    ldaSta #0, current_line

    setObjectAndCharacterSize #$02
    setBGMode #BgModeConstants_MODE1
    enableMainScreenDesignation #ScreenDesignationConstants_SPRITES_ON
    enableNmiAndAutoJoypadRead
    initScreen
    

infinite_loop:
    a8Bit
    xy16Bit
    jsr wait_nmi
    
    ; === V-BLANK BEGIN ===============================================================
    ; oam_lo_buffer -> OAMDATA
    ;dmaToOam oam_lo_buffer, #OAMRAM_ADDRESS, #(oam_buffer_end-oam_lo_buffer)

    ;dmaToVram #VRAM_ADDRESS, tiles_buffer, #(tiles_buffer_end - tiles_buffer)


    teste2 #VRAM_ADDRESS, current_line, sprites_tiles
    lda current_line    ; a = current_line
    inc                 ; a++
    sta current_line    ; current_line = a
    cmp #4
    beq reset_current_line

    

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

reset_current_line:
    ldaSta #0, current_line
    rts


wait_nmi:
    .a8
    .i16
    lda in_nmi

    @check_again:
        wai
        cmp in_nmi
        beq @check_again
    rts

.include "includes/asm/joypad.asm"

.segment "RODATA1"
bg_palette:
    .incbin "includes/gfx/default.pal"
    .incbin "includes/gfx/bin/running.pal"
bg_palette_end:

sprites_tiles:
    ; 4 colunas X 8 linhas
    .incbin "includes/gfx/bin/running_tiles.chr"
sprites_tiles_end:


.include "includes/gfx/asm/meta_sprites.asm"