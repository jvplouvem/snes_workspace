.p816
.smart

; === DEFAULT ZEROPAGE SECTION ===
.segment "ZEROPAGE"
in_nmi: .res 2
temp1: .res 2
pad1: .res 2
pad1_new: .res 2
pad2: .res 2
pad2_new: .res 2
; === END DEFAULT ZEROPAGE SECTION ===

; === DEFAULT BSS SECTION ===
.segment "BSS"
palette_buffer: .res 512

palette_buffer_end:
oam_lo_buffer: .res 512
oam_hi_buffer: .res 32

oam_buffer_end:
; === END DEFAULT BSS SECTION ===

.segment "BSS"
tiles_buffer: .res 1800
.include "../framework/asm/includes/ca65/init.asm"
.include "../framework/asm/includes/ca65/header.asm"
.segment "CODE"

main:
sep #$20 ; A 8 BIT MODE
rep #$10 ; X,Y 16 BIT MODE
phk
plb
phb
rep #$30 ; A,X,Y 16 BIT MODE
lda #880
ldx #.loword(tiles)
ldy #.loword(tiles_buffer)
.byte $54, ^tiles_buffer, ^tiles
plb
lda #$80
sta $2115 ;VMAIN
stz $2116 ;VMADDL

; === DMA START  === 
lda #$01
sta $4300 ;DMAP0
lda #$18
sta $4301 ;BBAD0
ldx #.loword(tiles_buffer)
stx $4302 ;A1T0L
lda #^tiles_buffer
sta $4304 ;A1B0
ldx #440
stx $4305 ;DAS0L
lda #%1
sta $420B ;MDMAEN
; === DMA END  === 

stz $2101 ;OBSEL
lda #$01
sta $2105 ;BGMODE
lda #$1f
sta $212C ;TM
lda #$80|01
sta $4200 ;NMITIMEN
lda #$0f
sta $2100 ;INIDISP

infinite_loop:
sep #$20 ; A 8 BIT MODE
rep #$10 ; X,Y 16 BIT MODE
jsr wait_nmi
jsr pad_poll
rep #$30 ; A,X,Y 16 BIT MODE
rep #$20  ; A 16 BIT MODE
lda pad1
and #$0200
sep #$20 ; A 8 BIT MODE
beq joy1_not_left

joy1_left:
sep #$20 ; A 8 BIT MODE
jsr clear_vram
rep #$20  ; A 16 BIT MODE

joy1_not_left:
rep #$20  ; A 16 BIT MODE
rep #$20  ; A 16 BIT MODE
lda pad1
and #$0100
sep #$20 ; A 8 BIT MODE
beq joy1_not_right

joy1_right:
sep #$20 ; A 8 BIT MODE
jsr clear_vram
lda #$80
sta $2115 ;VMAIN
stz $2116 ;VMADDL

; === DMA START  === 
lda #$01
sta $4300 ;DMAP0
lda #$18
sta $4301 ;BBAD0
ldx #.loword(tiles_buffer)
stx $4302 ;A1T0L
lda #^tiles_buffer
sta $4304 ;A1B0
ldx #880
stx $4305 ;DAS0L
lda #%1
sta $420B ;MDMAEN
; === DMA END  === 

rep #$20  ; A 16 BIT MODE

joy1_not_right:
rep #$20  ; A 16 BIT MODE
rep #$20  ; A 16 BIT MODE
lda pad1
and #$0800
sep #$20 ; A 8 BIT MODE
beq joy1_not_up

joy1_up:
sep #$20 ; A 8 BIT MODE
rep #$20  ; A 16 BIT MODE

joy1_not_up:
rep #$20  ; A 16 BIT MODE
rep #$20  ; A 16 BIT MODE
lda pad1
and #$0400
sep #$20 ; A 8 BIT MODE
beq joy1_not_down

joy1_down:
sep #$20 ; A 8 BIT MODE
rep #$20  ; A 16 BIT MODE

joy1_not_down:
sep #$20 ; A 8 BIT MODE
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
sep #$20 ; A 8 BIT MODE

@wait:
lda $4212
lsr a
bcs @wait
rep #$20  ; A 16 BIT MODE
lda pad1
sta temp1
lda $4218 ;JOY1L
sta pad1
eor temp1
and pad1
sta pad1_new
lda pad2
sta temp1
lda $421A ;JOY2L
sta pad2
eor temp1
and pad2
sta pad2_new
plp
rts
.segment "RODATA"

tiles:
.incbin "C:/ambiente_desenvolvimento/test/fans/fans-devkit/projects/fans-examples/home/includes/graphics/teste/mago_2.tiles"
tiles_end:


Sprite32dmaVRAM:
.dword $0300, $0200, $0100, $0000, $FF00, $FE00
