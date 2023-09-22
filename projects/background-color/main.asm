.p816
.smart

.include "../../framework/asm/includes/ca65/fans-library.asm"

.segment "CODE"

main:
	.a16 ; just a standardized setting from init code
	.i16
	phk
	plb
	
	a8Bit
	ldaSta #$00, f:CGADD ; $2121 set color address to 0
	
	lda #$00
	sta f:CGDATA
	
	lda #$7c
	sta f:CGDATA
	
; -bbbbbgg gggrrrrr
; black = $0000
; red = $001f
; green = $03e0
; blue = $7c00
; white = $7fff

	lda #$0f ;FULL_BRIGHT
	sta f:$2100

; note, nothing is active on the main screen,
; so only the main background color will show.
; $212c is the main screen register	

InfiniteLoop:	
	jmp InfiniteLoop
	