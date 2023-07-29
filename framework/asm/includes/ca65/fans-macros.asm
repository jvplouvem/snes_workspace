;mesen-s can use wdm is as a breakpoint
;for debugging purposes
.macro WDM_BREAK number
	.byte $42, number
.endmacro


.macro a8Bit
	sep #$20
.endmacro

.macro a16Bit
	rep #$20
.endmacro

.macro axy8Bit
	sep #$30
.endmacro

.macro axy16Bit
	rep #$30
.endmacro

.macro xy8Bit
	sep #$10
.endmacro

.macro xy16Bit
	rep #$10
.endmacro


.macro ldaSta source, target
	lda source
	sta target
.endmacro

.macro ldxStx source, target
	ldx source
	stx target
.endmacro

.macro ldySty source, target
	ldy source
	sty target
.endmacro



; memcpy, block move
;for WRAM to WRAM data transfers (can't be done with DMA)
.macro blockMove length, src_addr, dst_addr
;mnv changes the data bank register, need to preserve it
	phb
.if .asize = 8
	axy16Bit
.elseif .isize = 8
	axy16Bit
.endif
	lda length-1
	ldx #.loword(src_addr)
	ldy #.loword(dst_addr)	
;	mvn src_bank, dst_bank
	.byte $54, ^dst_addr, ^src_addr

	a8Bit
	plb
.endmacro

.macro dmaToCgram source, address, length
	ldaSta address, CGADD
	dma source, CGDATA, length, #$00
.endmacro

.macro dmaToOam source, address, length
	ldxStx address, OAMADDL
	dma source, OAMDATA, length, #$00
.endmacro

.macro dmaToVram source, address, length
	ldxStx address, VMADDL
	dma source, VMDATAL, length, #$01
.endmacro

.macro sendToVramByLoop vramAddress, tilesLabel, tilesOffset, length
	ldxStx vramAddress, VMADDL
    
    ; sprites_tiles starts at $8120

    ldx tilesOffset
	:
		lda f:tilesLabel,x
        sta VMDATAL
		inx
		
		lda f:tilesLabel,x
        sta VMDATAH
		inx
		;cpx #(sprites_tiles_end - sprites_tiles)
        ;cpx #32*4 ; 4 blocos da vram
		cpx length
	    bne :-
.endmacro

.macro dma source, target, length, transferMode
	ldaSta transferMode, DMAPx
	ldaSta #.lobyte(target), BBADx ; target
	ldxStx #.loword(source), A1TxL ; source
	ldaSta #^source, A1Bx ; bank
	ldxStx length, DASxL
	ldaSta #%1, MDMAEN
.endmacro

.macro setObjectAndCharacterSize value
	ldaSta value, OBSEL
.endmacro

.macro setBGMode value
	ldaSta value, BGMODE
.endmacro


.macro setBG1TilemapAddress value
	ldaSta value, BG1SC
.endmacro

.macro setBG2TilemapAddress value
	ldaSta value, BG2SC
.endmacro

.macro setBG3TilemapAddress value
	ldaSta value, BG3SC
.endmacro


.macro setBG1And2CharacterAddress value
	ldaSta value, BG12NBA
.endmacro

.macro setBG3And4CharacterAddress value
	ldaSta value, BG34NBA
.endmacro

.macro enableMainScreenDesignation value
	ldaSta value, TM
.endmacro


.macro enableNmiAndAutoJoypadRead
	ldaSta #NMITIMENConstants_ENABLE_NMI_AND_AUTO_JOYPAD_READ, NMITIMEN
.endmacro

.macro initScreen
	ldaSta #INIDISPConstants_FULL_BRIGHT, INIDISP
.endmacro