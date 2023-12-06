;------------------------------------------------------------------------
;-  Escrito por Maxwel Olinda, aproveitando exemplos do Neviksti.
;- 
;-  A area "Action:" até "RTS" é onde você vai escrever seu codigo e brincar
;-  de ser programador de Super Nintendo.
;-  A area "RodaUMAvez" até "RTS" rodara apenas uma vez.
;------------------------------------------------------------------------

;==============================================================================
; Aqui é incluído arquivos de fora, isso inclui o "show.inc" que possui informacões
; da header.
; O "InitSNES.asm" prepara registros e zera todas as RAMs, pois o SNES inicia com valores
; aleatorios.
;==============================================================================


.p816
.smart
.include "../../framework/asm/includes/ca65/fans-library.asm"

.include "defines.asm"
.include "2input.asm"
.include "includes/macros.asm"

Ativaomedidor = $40
DesativaFastROM = $41



;==============================================================================
; E aqui que o codigo de verdade comeca... mas a parte legal eu deixei para depois do primeiro NMI.
; O que tem aqui é so um loop que dura até chegar na scanline 225, daí repete o que esta em "VBlank" e volta pro loop.
;==============================================================================

.segment "CODE"
main:
JML Faster

.INCLUDE "Sprite/Magician.asm"
.INCLUDE "Sprite/Inimigo.asm"
Faster:
	JSR IniciarSprites

	a8Bit
	ldaSta #$01, f:MEMSEL
	ldaSta #$ff, $E2 ;comeca pixelado	

	stz $E3   ;comeca com tela escura	

	LDA #$FF
	STA $0734 ; Comparador de animacão diferente da inicial para ativar DMA do player

	JSR MagicianDMA
	JSR RodaUMAvez ;$C00BED Seu codigo vai rodar nessa sub-rotina apenas uma vez.
	JSR JoyInit		;ativa os controles

	;==============
	setBGMode #BgModeConstants_MODE1

	setBG1TilemapAddress #$54
	setBG2TilemapAddress #$58
	setBG3TilemapAddress #$50

	setBG1And2CharacterAddress #$20
	setBG3And4CharacterAddress #$04

	enableMainScreenDesignation #%00010111 ;Turn on BG1
	enableSubScreenDesignation #$02 ;Turn on BG2
	
	setObjectAndCharacterSize #%00100011 ;Sprite VRAM = Sprites 16x16/32x32 e VRAM 6000

	ldaSta #%00100000, ColorMath1

    ldaSta #$FF, BG1Vlow
    ldaSta #$1c, BG2Vlow

;Gradiente HDMA 
	hdmaGradiente RedTable, #$3200, CHANNEL_3
	hdmaGradiente GreenTable, #$3200, CHANNEL_4
	hdmaGradiente BlueTable, #$3200, CHANNEL_5

	LDA #$38
	TSB $0D9F   ;canais 3, 4, 5 para cada R,G,B. 

;HDMA de cores para a BG3
	LDX #$0001

	axy8Bit
	hdmaBg3 Corslot, #$00, CHANNEL_6
	hdmaBg3 Corhdma, #$02, CHANNEL_7
	
	axy16Bit
	LDA #%11000000
	TSB $0D9F
	xy16Bit
	a8Bit
	
loop:
LDA Ativaomedidor
BEQ :+
lda #$08  ; Medidor de CPU 
sta f:INIDISP
:
wai
bra loop

.include "includes/color-tables.asm"

IniciarSprites:
    php             ; preserve P reg

    rep #$30        ; 16bit A/X/Y

    ldx #$0180
    lda #$0181        ; Prepare Loop 1
offscreen:
    sta $0180, X
    inx
    inx
    inx
    inx
    cpx #$0500
    bne offscreen
;------------------
    lda #$5555
xmsb:
    sta $0000, X
    inx
    inx
    cpx #$0520
    bne xmsb
;------------------

    xy16Bit
    a8Bit
	
lda #(256/2 - 16)
sta $0380           ; Sprite X-Coordinate

lda #(224/2 - 16)   ; Sprite Y-Coordinate
sta $0381

lda #$00
sta $0382           ; Starting tile #

lda #%00110000   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page
sta $0383

lda #%00110010   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page
sta $038B          ; seta apenas o que for 1 em A para a RAM

lda #%01011010  ; bit zero é o 9 bit (sprite fora da tela) e bit 1 é tamanho de sprite. 
sta $0508

lda #$01
sta SP1DMAframe
plp
RTS





;==========================================================================================
; Quando o NMI for ativado, isto é, chegar na scanline 225, tudo sera interrompido para rodar isso:
;==========================================================================================

.segment "LIBSFX"
VBlank:
JML FasterVBLANK

FasterVBLANK:
	rep #$30		;A/Mem=16bits, X/Y=16bits
	phb       ;preserva o banco de antes de chegar aqui
	pha       ;preserva o Acumulador de antes de chegar aqui
	phx       ;preserva o index X de antes de chegar aqui
	phy       ;preserva o index Y de antes de chegar aqui
	phd       ;preserva o direct page de antes de chegar aqui

	a8Bit

	lda #$00		;DataBank = $00
	pha       ;preserva o Acumulador de antes de chegar aqui
	plb       ;resgata o banco de antes de chegar aqui

JSR SetupVideo ;DMA primeiro

JSR GetInput  ;rotina dos controles

JSR RotinadeSprites

JSR Action    ;Seu codigo vai rodar nessa sub-rotina em todos os frames.


	lda f:$4210		;limpar flag NMI
	rep #$30		;A/Mem=16bits, X/Y=16bits
	
	pld        ; Recuperando 
	ply        ; tudo aquilo
	plx        ; que foi
	pla        ; preservado
	plb        ; anteriormente...
    rti      ; Retorna do interrupt (ele vai voltar la naquele loop ali em cima)


SetupVideo:
	xy16Bit
	a8Bit
	
INC Counter ; Counter Global	

INC $14
LDA $14
CMP #$05
BNE :+
STZ $14 ; Counter de 0 até 4 em loop
:

LDA #$00 ; limpar high byte 
XBA 


;HDMA registro
    ldaSta $0D9F, f:HDMAEN
;Mosaic
    LDA Mosaico          ;E2
    STA f:$2106
;Screen Brightness
    LDA Brilho           ;E3
    STA f:$2100 
;Espelho da Layer 1 H
	LDA BG1Hlow        ;1A
	STA f:$210D
	LDA BG1Hhigh       ;1B
	STA f:$210D
;Espelho da Layer 1 V	
	LDA BG1Vlow       ;$1C
	STA f:$210E
	LDA BG1Vhigh      ;$1D
	STA f:$210E
;Espelho da Layer 2 H
	LDA BG2Hlow        ;$10
	STA f:$210F
	LDA BG2Hhigh       ;$11
	STA f:$210F
;Espelho da Layer 2 V	
	LDA BG2Vlow        ;$17
	STA f:$2110
	LDA BG2Vhigh       ;$18
	STA f:$2110
;Espelho da Layer 3 H
	 LDA BG3Hlow      ;$1E
	 STA f:$2111
	 LDA BG3Hhigh     ;$1F
	 STA f:$2111 
;Espelho da Layer 3 V
	 LDA BG3Vlow      ;$28
	 STA f:$2112
	 LDA BG3Vhigh     ;$29
	 STA f:$2112
;Espelho de Color Math
	 LDA ColorMath0    ;$15
	 STA f:$2130
	 LDA ColorMath1    ;$16
	 STA f:$2131

; Layer 2 rola a 1/4 da velocidade da Layer 1
REP #$20       
LDA BG1Hlow
LSR A
LSR A
STA BG2Hlow
a8Bit

;====================;
; Dynamic DMA sprite ;
;====================;

JSR MagicianDMA

;lda $0748   ; Se o player teve DMA, não fazer outro DMA 
;BNE +
JSR Explosao
;+
;=================;
; DMA sprite data ;
;=================;
ldx #$6000
stx OAMADDL
;stz $2103
    ldy #$0400          ; Writes #$00 to $4300, #$04 to $4301
    sty $4300           ; CPU -> PPU, auto inc, $2104 (OAM write)
    ldx #$0300
    stx $4302
    lda #$7E
    sta f:$4304           ; CPU address 7E:0000 - Work RAM
    ldy #$0220
    sty $4305           ; #$220 bytes to transfer
    lda #%0000001
    sta f:$420B

   	RTS                       ;/  
;;;;;;;;;;;;;;;;


RotinadeSprites:

	;==============================
	;HUD
	;==============================
	;stz $436b
	ldaSta #$00, $436b
	ldx #$0000
	ldy #$0000

	PHD
	LDA #$03
	XBA
	LDA #$00
	TCD        ; DP é 0300
	:
	LDA hudHpos,y
	STA $00,x
	LDA hudVpos,y
	STA $01,x
	lda $436b
	sta $02,x           ; Starting tile #
	lda #%00110010   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page
	STA $03,x          ; zera apenas o que for 1 em A para a RAM
	inc $436b
	INX
	INX
	INX
	INX
	INY
	CPY #$0019
	BNE :-
	;stz $436b
	ldaSta #$00, $436b
	PLD 

	STZ $0500
	STZ $0501
	STZ $0502
	STZ $0503
	STZ $0504
	STZ $0505
	lda #%01010100  ; bit zero é o 9 bit (sprite fora da tela) e bit 1 é tamanho de sprite. 
	sta $0506

	BRA sprite0
	RTS

.include "includes/hud-tables.asm"

sprite0:
;==============================
;Sprite PLAYER
;==============================

JSR MagicianSprite

JSR Projectile

;==============================
;Inimigo
;==============================

JSR Inimigo1

;================================
;Onda de sprites
;================================

LDX #$0000           ; 
LDY #$0000           ; Zerar counters
;STZ $436B            ; 43xB podem ser usados como FastRAM
ldaSta #$00, $436b

PHD
rep #$20
LDA #$0400    ; DP no $0400
TCD           ; Transferir do A 16 bits ao Direct Page 
a8Bit

repetespriteonda:
LDA #$00
addSta $436b, {$50,x}

CLC
ADC $1008,y
STA $50,x           ; Ir adicionando o valor da tabela em H a cada loop (levemente a frente do Y)

LDA #$AC
CLC
ADC $1000,y
STA $51,x           ; Adicionar o valor da tabela na posicão Y e incrementar
tya

addSta #$80, {$52,x} ; Starting tile #
ldaSta #%00110100, {$53,x}   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page

LDA $436b
addSta #$08, $436b ; Adiciona 8 para o proximo loop

INX
INX
INX           ; incrementar counters
INX
INY
CPY #$001E
BNE repetespriteonda

;zerando segunda tabela da OAM para usar sprites pequenos e dentro da tela  
STZ $0515
STZ $0516
STZ $0517
STZ $0518
STZ $0519
STZ $051A
STZ $051B        ; sprites faltantes do texto
;---------------------------------------------------


;================================
;Onda de sprites 2
;================================
LDX #$0000           ; 
LDY #$0000           ; Zerar counters
;STZ $436B            ; 43xB podem ser usados como FastRAM
ldaSta #$00, $436b
repetespriteonda1:

LDA #$50
addSta $436b, {$C8,x}; Ir adicionando o valor de $436B em H a cada loop 

CLC
ADC $1018,y
STA $C8,x           ; Ir adicionando o valor da tabela em H a cada loop (levemente a frente do Y)
LDA #$BC

CLC
ADC $1020,y
STA $C9,x           ; Adicionar o valor da tabela na posicão Y e incrementar
tya

addSta #$A0, {$CA,x} ; Starting tile #
LDA #%00110100   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page
STA $CB,x          ;

LDA $436b
addSta #$08, $436b ; Adiciona 8 para o proximo loop
INX
INX
INX           ; incrementar counters
INX
INY
CPY #$000C
BNE repetespriteonda1

;zerando segunda tabela da OAM para usar sprites pequenos e dentro da tela  
STZ $051C        ; sprites faltantes do texto
STZ $051D
STZ $051E
ldaSta #%01010000, $051F ; sprites faltantes do texto
;---------------------------------------------------

PLD
rts


;============================================================================
; AQUI ESTÁ!
;----------------------------------------------------------------------------
Action:
	PHP
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;transicão mosaico com brilho
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda Counter
	and #$03  ;dividir frames
	beq :+
	ldx $E3
	lda $E2
	cmp #$0f
	beq :+
	sec
	sbc #$10
	sta $E2
	inx
	stx $E3
	:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Reviver inimigo
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda $20
	and #$20 
	beq :+
	STZ $07C0
	:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Medidor de CPU
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda $21
	bit #%00100000
	beq :+
	LDA #$01
	STA Ativaomedidor
	:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Modo SlowROM
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda $20
	bit #$10
	beq :+
	ldaSta #$01, DesativaFastROM
	:
	LDA DesativaFastROM
	BEQ :+
	;STZ $420D
	ldaSta #$00, f:MEMSEL
	:


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Movimento de câmera ligada ao sprite jogavel
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda $0380
	cmp #$78
	bmi :+
	REP #$20
	inc BG1Hlow 
	a8Bit
	dec $0380   ;parar sprite de ir pra direita
	dec $0384
	:
	lda $0380
	cmp #$68
	bpl :+
	REP #$20
	DEC BG1Hlow 
	a8Bit
	inc $0380   ;parar sprite de ir pra esquerda
	inc $0384
	:

	; Animacão do offset de sprite 
	; Mover tabela da ROM para a RAM
	;
	REP #A_8BIT ; A 16 BIT
	LDA #.loword(Onda)
	CLC
	ADC $F1            ; Adicionar valor à tabela
	STA $F3            ; Colocar valor da tabela + adicão em RAM 

	PHB                ; Preservar data bank
	LDA #$002F         ;Counter (-1)
	LDX $F3            ;Source
	LDY #$1000           ;Destino
	;MVN $c0, $7e       ;Banco da Source/Banco do Destino
	MVN #.BANKBYTE(Onda), $7e       ;Banco da Source/Banco do Destino
	PLB                ; Recuperar data bank

	INC $F1            ; Incrementa para o proximo frame
	LDA $F1 
	CMP #$0020         ; Quantas vezes incrementar tabela até zerar
	BNE :+
	STZ $f1
	:
	SEP #A_8BIT
	PLP
	RTS

Onda:
.byte $01, $02, $02, $03, $04, $05, $06, $07
.byte $08, $09, $0A, $0B, $0C, $0C, $0D, $0D
.byte $0D, $0C, $0C, $0B, $0A, $09, $08, $07
.byte $06, $05, $04, $03, $02, $02, $01, $01
.byte $01, $02, $02, $03, $04, $05, $06, $07
.byte $08, $09, $0A, $0B, $0C, $0C, $0D, $0D
.byte $0D, $0C, $0C, $0B, $0A, $09, $08, $07
.byte $06, $05, $04, $03, $02, $02, $01, $01
.byte $01, $02, $02, $03, $04, $05, $06, $07
.byte $08, $09, $0A, $0B, $0C, $0C, $0D, $0D

RodaUMAvez:
	JSL lanooutrobanco    ; Vamos mudar de banco e adicionar nossos arquivos grandes la.
	RTS                   ; Em HI-ROM cada banco tem 64 KB.

.segment "RODATA1"
lanooutrobanco:
	;===========================
	; Vou botar meus DMA e HDMA aqui hihi
	; -------------------------------------
	;----------------------------
	PHD
	REP #$20
	LDA #$4300 ; DP é 4200
	TCD 
	a8Bit

	;DMA DE CORES PARA A CGRAM
	dmaToCgram grafico7CORES, #$20, #$0080, CHANNEL_0

	;BG2
	dmaToCgram bg2CORES, #$60, #$0060, CHANNEL_0

	;BG3
	dmaToCgram graficosbg3CORES, #$00, #$0040, CHANNEL_0

	;---
	;sprite
	dmaToCgram dmaCORESsprite2, #$80, #$0020, CHANNEL_0

	;HUD
	dmaToCgram spriteHUDcor, #$90, #$0080, CHANNEL_0


	;----------------------------
	;DMA DE GRÁFICOS PARA A VRAM
	;BG1
	dmaToVram graficos7, #$0000, #$3800, CHANNEL_0

	;BG2
	dmaToVram bg2tiles, #$2000, #$3800, CHANNEL_0

	;BG3 + tilemap
	dmaToVram graficosbg3, #$4000, #$2800, CHANNEL_0

	;sprite 
	dmaToVram graficosprite1, #$6000, #$3000, CHANNEL_0

	;----------------------------
	;DMA DA TILEMAP PARA A VRAM
	dmaToVram graficos1tilemap, #$5400, #$0800, CHANNEL_0

	;DMA BG2
	dmaToVram bg2tilemap, #$5800, #$0800, CHANNEL_0

	PLD
	RTL                ; Retorna da sub-rotina para o banco anterior

.include "includes/gfx-references.asm"