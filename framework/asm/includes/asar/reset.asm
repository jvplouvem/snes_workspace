; Disable interrupts and enable native mode
_reset:
	sei
	clc
	xce
	cld

	rep #$30 ; A,X,Y 16 bit

	; ZeroCPU registers NMITIMEN through MEMSEL
	stz $4200
	stz $4202
	stz $4204
	stz $4206
	stz $4208
	stz $420A
	stz $420C

	lda #$0080
	sta $2100; INIDISP ; Turn off screen ("forced blank")

	; Zero some registers used for rendering
	stz $2102 ; OAMADDL
	stz $2105 ; BGMODE
	stz $2107 ; BG1SC
	stz $2109 ; BG3SC
	stz $210B ; BG12NBA
	stz $2116 ; VMADDL
	stz $2123 ; W12SEL
	stz $2126 ; WH0
	stz $2128 ; WH2
	stz $212A ; WBGLOG
	stz $212C ; TM
	stz $212E ; TMW

	; Disable color math / etc
	ldx #$0030
	stx $2130 ; CGWSEL
	ldy #$00E0
	sty $2132 ; COLDATA

	sep #$20 ; A 8 bit

	; Zero window masks
	stz $2125 ; WOBJSEL
	rts