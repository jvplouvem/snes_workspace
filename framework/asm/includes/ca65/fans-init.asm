.segment "CODE"

NMI:
bit $4210 ;RDNMI
inc in_nmi
rti

IRQ:
bit $4211 ;TIMEUP

IRQ_end:
rti

reset:
sei
clc
xce
rep #$38
ldx #$1fff
txs
phk
plb
lda #$4200
tcd
lda #$FF00
sta $00
stz $00
stz $02
stz $04
stz $06
stz $08
stz $0A
stz $0C
lda #$2100
tcd
lda #$0080
sta $00
stz $02
stz $05
stz $07
stz $09
stz $0B
stz $16
stz $24
stz $26
stz $28
stz $2A
stz $2C
stz $2E
ldx #$0030
stx $30
ldy #$00E0
sty $32
sep #$20 ; A 8 BIT MODE
sta $15
stz $1A
stz $21
stz $23
.repeat 8, I
 stz $0D+I
 stz $0D+I
.endrepeat
lda #$01
stz $1B
sta $1B
stz $1C
stz $1C
stz $1D
stz $1D
stz $1E
stz $1E
stz $1F
stz $1F
stz $20
stz $20
rep #$30 ; A,X,Y 16 BIT MODE
lda #$0000
tcd

clear_wram:
rep #$20  ; A 16 BIT MODE
sep #$10 ; X,Y 8 BIT MODE
stz $2181 ;WMADDL
stz $2182 ;WMADDM
lda #$8008
sta $4300 ;DMAP0
lda #.loword(DMAZero)
sta $4302 ;A1T0L
ldx #^DMAZero
stx $4304 ;A1B0
stz $4305 ;DAS0L
ldx #1
stx $420B ;MDMAEN
stx $420B
sep #$20 ; A 8 BIT MODE
rep #$10 ; X,Y 16 BIT MODE
jsr clear_palette
jsr dma_palette
jsr clear_oam
jsr dma_oam
jsr clear_vram
sep #$20 ; A 8 BIT MODE
lda #1
sta $420D ;MEMSEL
rep #$30 ; A,X,Y 16 BIT MODE
jml main

clear_palette:
php
sep #$20 ; A 8 BIT MODE
rep #$10 ; X,Y 16 BIT MODE
ldx #.loword(palette_buffer)
stx $2181 ;WMADDL
stz $2183 ;WMADDH
ldx #$8008
stx $4300 ;DMAP0
ldx #.loword(DMAZero)
stx $4302 ;A1T0L
lda #^DMAZero
sta $4304 ;A1B0
ldx #$200
stx $4305 ;DAS0L
lda #%1
sta $420B ;MDMAEN
plp
rts

dma_palette:
php
sep #$20 ; A 8 BIT MODE
rep #$10 ; X,Y 16 BIT MODE
stz $2121 ;CGADD
ldx #$2200
stx $4300 ;DMAP0
ldx #.loword(palette_buffer)
stx $4302 ;A1T0L
lda #^palette_buffer
sta $4304 ;A1B0
ldx #$200
stx $4305 ;DAS0L
lda #%1
sta $420B ;MDMAEN
plp
rts

clear_oam:
php
sep #$20 ; A 8 BIT MODE
rep #$10 ; X,Y 16 BIT MODE
ldx #.loword(oam_lo_buffer)
stx $2181 ;WMADDL
stz $2183 ;WMADDH
ldx #$8008
stx $4300 ;DMAP0
ldx #.loword(SpriteEmptyVal)
stx $4302 ;A1T0L
lda #^SpriteEmptyVal
sta $4304 ;A1B0
ldx #$200
stx $4305 ;DAS0L
lda #%1
sta $420B ;MDMAEN
ldx #.loword(SpriteUpperEmpty)
stx $4302 ;A1T0L
lda #^SpriteUpperEmpty
sta $4304 ;A1B0
ldx #$0020
stx $4305 ;DAS0L
lda #%1
sta $420B ;MDMAEN
plp
rts

dma_oam:
php
sep #$20 ; A 8 BIT MODE
rep #$10 ; X,Y 16 BIT MODE
ldx #.loword(oam_lo_buffer)
stx $2181 ;WMADDL
stz $2183 ;WMADDH
ldx #$8008
stx $4300 ;DMAP0
ldx #.loword(SpriteEmptyVal)
stx $4302 ;A1T0L
lda #^SpriteEmptyVal
sta $4304 ;A1B0
ldx #$200
stx $4305 ;DAS0L
lda #%1
sta $420B ;MDMAEN
ldx #.loword(SpriteUpperEmpty)
stx $4302 ;A1T0L
lda #^SpriteUpperEmpty
sta $4304 ;A1B0
ldx #$0020
stx $4305 ;DAS0L
lda #%1
sta $420B ;MDMAEN
plp
rts

clear_vram:
php
sep #$20 ; A 8 BIT MODE
rep #$10 ; X,Y 16 BIT MODE
lda #$80
sta $2115 ;VMAIN
stz $2116 ;VMADDL
stz $4305 ;DAS0L
ldx #$1809
stx $4300 ;DMAP0
ldx #.loword(DMAZero)
stx $4302 ;A1T0L
lda #^DMAZero
sta $4304 ;A1B0
lda #%1
sta $420B ;MDMAEN
plp
rts

SpriteUpperEmpty:

DMAZero:
.word $0000

SpriteEmptyVal:
.byte 224
