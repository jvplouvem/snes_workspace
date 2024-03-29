;mesen-s can use wdm is as a breakpoint
;for debugging purposes
.macro WDM_BREAK number
	.byte $42, number
.endmacro


.macro a8Bit
	sep #$20 ; a8Bit
.endmacro

.macro a16Bit
	rep #$20 ; a16Bit
.endmacro

.macro axy8Bit
	sep #$30 ; axy8Bit
.endmacro

.macro axy16Bit
	rep #$30 ; axy16Bit
.endmacro

.macro xy8Bit
	sep #$10 ; xy8Bit
.endmacro

.macro xy16Bit
	rep #$10 ; xy16Bit
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

.macro dmaToCgram source, address, length, channel
	ldaSta address, f:CGADD
	dma source, CGDATA, length, #$00, channel
.endmacro

.macro dmaToOam source, address, length, channel
	ldxStx address, a:OAMADDL
	dma source, OAMDATA, length, #$00, channel
.endmacro

.macro dmaToVram source, address, length, channel
	ldxStx address, a:VMADDL
	dma source, VMDATAL, length, #$01, channel
.endmacro

.macro dma source, target, length, transferMode, channel
	ldaSta transferMode, f:DMAPx+channel
	ldaSta #.lobyte(target), f:BBADx+channel ; TARGET
	ldxStx #.loword(source), a:A1TxL+channel ; SOURCE
	ldaSta #^source, f:A1Bx+channel ; BANK
	ldxStx length, a:DASxL+channel ; LENGTH
	ldaSta #%1, f:MDMAEN
.endmacro

.macro dma2 source, target, length, transferMode, channel
	ldaSta transferMode, f:DMAPx+channel
	ldaSta #.lobyte(target), f:BBADx+channel ; TARGET
	ldxStx #.loword(source), a:A1TxL+channel ; SOURCE
	ldaSta #^source, f:A1Bx+channel ; BANK
	ldxStx length, a:DASxL+channel ; LENGTH
	ldaSta #%1, f:MDMAEN
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

; OBJSEL - Object size and Character address ($2101 write)
; 7  bit  0
; ---- ----
; SSSN NbBB
; |||| ||||
; |||| |+++- Name base address (word address = bBB << 13)
; |||+-+---- Name select (word offset = (NN+1) << 12)
; +++------- Object size:
;             0:  8x8  and 16x16
;             1:  8x8  and 32x32
;             2:  8x8  and 64x64
;             3: 16x16 and 32x32
;             4: 16x16 and 64x64
;             5: 32x32 and 64x64
;             6: 16x32 and 32x64
;             7: 16x32 and 32x32
; Name base address selects a 16 KiB-aligned quarter of VRAM for the first 8 KiB of available sprite tiles. Bit 2 was reserved for a planned but never implemented expansion to 128 KiB VRAM, so is normally 0.
; Name select controls a relative offset from the name base address in NN+1 8 KiB increments, selecting a second 8 KiB of available sprite tiles. With name select of 0, the second half follows the base 8 KiB contiguously.
; Object size controls the sizes available for sprites. The two modes featuring rectangular sizes (6, 7) were not documented by the SNES development manual.
; Fullsnes refers to this register as OBSEL.
.macro setObjectSizeAndCharacterAddress value
	ldaSta value, f:OBSEL
.endmacro

.macro setBGMode value
	ldaSta value, f:BGMODE
.endmacro


.macro setBG1TilemapAddress value
	ldaSta value, f:BG1SC
.endmacro

.macro setBG2TilemapAddress value
	ldaSta value, f:BG2SC
.endmacro

.macro setBG3TilemapAddress value
	ldaSta value, f:BG3SC
.endmacro


.macro setBG1And2CharacterAddress value
	ldaSta value, f:BG12NBA
.endmacro

.macro setBG3And4CharacterAddress value
	ldaSta value, f:BG34NBA
.endmacro

.macro enableMainScreenDesignation value
	ldaSta value, f:TM
.endmacro


.macro enableSubScreenDesignation value
	ldaSta value, f:TS
.endmacro

.macro enableNmiAndAutoJoypadRead
	ldaSta #NMITIMENConstants_ENABLE_NMI_AND_AUTO_JOYPAD_READ, f:NMITIMEN
.endmacro

.macro initScreen
	ldaSta #INIDISPConstants_FULL_BRIGHT, f:INIDISP
.endmacro



; multiplies the accumulator by various constant values
; <= 255 works with both 8-bit and 16-bit accumulator
; >= 256 requires 16-bit accumulator
.macro multiplyBy by
	.if by = 0
		sta #0
	.elseif by = 1
		; do nothing
	.elseif by = 2
		asl
	.elseif by = 3
		pha ; put current accumulator value on stack
		asl ; value = value * 2
		add {$01,s} ; value = value + stack_value
		;sta $01,s
		pla
	.elseif by == 4
		asl #2
	.elseif by == 256
		and #$00ff
		xba
	.endif
.endmacro


.macro add by
	clc
	adc by
.endmacro

.macro addSta by, to
	add by
	sta to
.endmacro

TOTAL_BYSTES_LINHA_VRAM = 512 ; total de bytes de cada linha da VRAM
_5_BLOCOS_VRAM = 32*5
OFFSET_LINHA_VRAM = 256 ; 100 em hex

.macro teste vramAddress, linhaVram
	ldxStx vramAddress+(OFFSET_LINHA_VRAM*linhaVram), VMADDL

    ldx #TOTAL_BYSTES_LINHA_VRAM*linhaVram
	:
		lda f:sprites_tiles,x
		sta VMDATAL
		inx
	
		lda f:sprites_tiles,x
		sta VMDATAH
		inx
		cpx #((TOTAL_BYSTES_LINHA_VRAM*linhaVram)+_5_BLOCOS_VRAM) ; 4 blocos na VRAM, 128 bytes
		bne :-
.endmacro


.macro teste2 vramAddress, linhaVram, tilesLabel
	ldxStx vramAddress+(OFFSET_LINHA_VRAM*linhaVram), VMADDL

    ldx #TOTAL_BYSTES_LINHA_VRAM*linhaVram
	:
		lda f:tilesLabel,x
		sta VMDATAL
		inx
	
		lda f:tilesLabel,x
		sta VMDATAH
		inx
		cpx #((TOTAL_BYSTES_LINHA_VRAM*linhaVram)+_5_BLOCOS_VRAM) ; 4 blocos na VRAM, 128 bytes
		bne :-
.endmacro


.macro teste3 paramTeste
	ldx paramTeste
.endmacro

.macro incrementX manyTimes
	.repeat manyTimes, I
		inx
	.endrep
.endmacro