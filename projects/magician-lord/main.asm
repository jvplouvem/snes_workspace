.p816
.smart


.include "../../framework/asm/includes/ca65/fans-library.asm"

.include "includes/asm/2input.asm"
.include "includes/asm/defines.asm"



;=== Espelhos para a RAM ===
; Isso vai usar da RAM $D0 em sequencia para inserir essas variáveis. Uma função legal desse debugger. :)
Ativaomedidor = $40
DesativaFastROM = $41



;==============================================================================
; É aqui que o código de verdade começa... mas a parte legal eu deixei para depois do primeiro NMI.
; O que tem aqui é só um loop que dura até chegar na scanline 225, daí repete o que está em "VBlank" e volta pro loop.
;==============================================================================
main:
; JML Faster
; .BASE $C0        ; Pular para banco rápido
.INCLUDE "includes/asm/sprites/magician.asm"
.INCLUDE "includes/asm/sprite/inimigo.asm"

; Faster:
	;InitializeSNES

JSR IniciarSprites
	
ldaSta #$01, MEMSEL ;FastROM
ldaSta #$ff, Mosaico   ;começa pixelado	

stz Brilho   ;começa com tela escura	

ldaSta #$FF, $0734 ; Comparador de animação diferente da inicial para ativar DMA do player

JSR MagicianDMA

JSR RodaUMAvez ;Seu código vai rodar nessa sub-rotina apenas uma vez.
JSR JoyInit		;ativa os controles

;==============
;BG config
	setBGMode #BgModeConstants_MODE1

	setBG1TilemapAddress #$54 ; tiles 32 x 32
	setBG2TilemapAddress #$58 ; tiles 32 x 32
	setBG3TilemapAddress #$50 ; tiles 32 x 32

	setBG1And2CharacterAddress #$20
	setBG3And4CharacterAddress #$04

	ldaSta #%00010111, TM ;Turn on BG1
	ldaSta #$02, TS		  ;Turn on BG2

	setObjectAndCharacterSize #%00100011 ; Sprite VRAM = Sprites 16x16/32x32 e VRAM 6000

    ldaSta #%00100000, ColorMath1
    ldaSta #$FF, BG1Vlow
    ldaSta #$1c, BG2Vlow

;Gradiente HDMA 
LDX #$3200
STX $4330
LDX.w #RedTable
STX $4332
LDA #$C0
STA $4334
LDX #$3200
STX $4340
LDX #GreenTable
STX $4342
LDA #$C0
STA $4344
LDX #$3200
STX $4350
LDX #BlueTable
STX $4352
LDA #$C0
STA $4354
LDA #$38
TSB $0D9F   ;canais 3, 4, 5 para cada R,G,B. 

;HDMA de cores para a BG3
LDX #$0001
axy8Bit
LDA #$00
STA $4360
LDA #$21
STA $4361   ;Registro
LDA #$C0
STA $4364  ;Source banco
axy16Bit
LDA #Corslot  ;Source
STA $4362
axy8Bit

LDA #$02
STA $4370
LDA #$22
STA $4371   ;Registro
LDA #$C0
STA $4374  ;Source banco
axy16Bit
LDA #Corhdma  ;Source
STA $4372
LDA #%11000000
TSB $0D9F
xy16Bit
a8Bit

loop:
LDA Ativaomedidor
BEQ +
lda #$08  ; Medidor de CPU 
sta INIDISP ;
+
wai
bra loop

Corslot:
	.INCLUDE "tables/cor_slot.asm"

Corhdma:   ;16 bits
	.INCLUDE "tables/cor_hdma.asm"

RedTable:
	.INCLUDE "tables/red_table.asm"
  
GreenTable:
   .INCLUDE "tables/green_table.asm"

BlueTable:
	.INCLUDE "tables/blue_table.asm"


;======================
;Iniciar Sprites
;======================
IniciarSprites:
    php             ; preserve P reg
	axy16Bit

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

    xy16Bit        ; 16bit A/X/Y
    a8Bit        ; 16bit A/X/Y
	
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
; Quando o NMI for ativado, isto é, chegar na scanline 225, tudo será interrompido para rodar isso:
;==========================================================================================

VBlank:
JML FasterVBLANK
.BASE $C0        ; Pular para banco rápido
FasterVBLANK:
	axy16Bit
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

JSR Action    ;Seu código vai rodar nessa sub-rotina em todos os frames.


	lda RDNMI		;limpar flag NMI
	axy16Bit
	
	pld        ; Recuperando 
	ply        ; tudo aquilo
	plx        ; que foi
	pla        ; preservado
	plb        ; anteriormente...
      rti      ; Retorna do interrupt (ele vai voltar lá naquele loop ali em cima)


SetupVideo:


	xy16Bit		;A/mem = 8bit, X/Y=16bit
	a8Bit
	
INC Counter ; Counter Global	

INC $14
LDA $14
CMP #$05
BNE +
STZ $14 ; Counter de 0 até 4 em loop
+

LDA #$00 ; limpar high byte 
XBA 


;HDMA registro
    ldaSta $0D9F, HDMAEN
;Mosaic
    ldaSta Mosaico, MOSAIC          ;E2
;Screen Brightness
    ldaSta Brilho, INIDISP ;E3
     
;Espelho da Layer 1 H
	LDA BG1Hlow        ;1A
	STA $210D
	LDA BG1Hhigh       ;1B
	STA $210D
;Espelho da Layer 1 V	
	LDA BG1Vlow       ;$1C
	STA $210E
	LDA BG1Vhigh      ;$1D
	STA $210E
;Espelho da Layer 2 H
	LDA BG2Hlow        ;$10
	STA $210F
	LDA BG2Hhigh       ;$11
	STA $210F
;Espelho da Layer 2 V	
	LDA BG2Vlow        ;$17
	STA $2110
	LDA BG2Vhigh       ;$18
	STA $2110
;Espelho da Layer 3 H
	 LDA BG3Hlow      ;$1E
	 STA $2111
	 LDA BG3Hhigh     ;$1F
	 STA $2111 
;Espelho da Layer 3 V
	 LDA BG3Vlow      ;$28
	 STA $2112
	 LDA BG3Vhigh     ;$29
	 STA $2112
;Espelho de Color Math
	 LDA ColorMath0    ;$15
	 STA $2130
	 LDA ColorMath1    ;$16
	 STA $2131

; Layer 2 rola a 1/4 da velocidade da Layer 1
a16Bit       
LDA BG1Hlow
LSR A
LSR A
STA BG2Hlow
a8Bit

;====================;
; Dynamic DMA sprite ;
;====================;

JSR MagicianDMA
JSR Explosao
;+
;=================;
; DMA sprite data ;
;=================;
oamSource = $0300
dmaToOam #$6000, #oamSource, #$0220
RTS                       ;/  
;;;;;;;;;;;;;;;;


RotinadeSprites:

;==============================
;HUD
;==============================
stz $436b
ldx #$0000
ldy #$0000

PHD
LDA #$03
XBA
LDA #$00
TCD        ; DP é 0300
-
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
BNE -
stz $436b
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

hudHpos:
	.include "tables/hud_hpos.asm"

hudVpos:
	.include "tables/hud_vpos.asm"

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
STZ $436B            ; 43xB podem ser usados como FastRAM

PHD
a16Bit
LDA #$0400    ; DP no $0400
TCD           ; Transferir do A 16 bits ao Direct Page 
a8Bit

spriteOndaHandle #$00, $50, $1008, #$AC, $1000, $51, #$80, $52, $53, #$001E

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
STZ $436B            ; 43xB podem ser usados como FastRAM

spriteOndaHandle #$50, $C8, $1018, #$BC, $1020, $C9, #$A0, $CA, $CB, #$000C

;zerando segunda tabela da OAM para usar sprites pequenos e dentro da tela  
STZ $051C        ; sprites faltantes do texto
STZ $051D
STZ $051E
LDA #%01010000
STA $051F        ; sprites faltantes do texto
;---------------------------------------------------

PLD

rts


;============================================================================
; AQUI ESTÁ!
;----------------------------------------------------------------------------
Action:
PHP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;transição mosaico com brilho
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lda Counter
and #$03  ;dividir frames
beq +
ldx Brilho
lda Mosaico
cmp #$0f
beq +
sec
sbc #$10
sta Mosaico
inx
stx Brilho
+

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Reviver inimigo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lda $20
and #$20 
beq +
STZ $07C0
+

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Medidor de CPU
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lda $21
bit #%00100000
beq +
LDA #$01
STA Ativaomedidor
+

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Modo SlowROM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lda $20
bit #$10
beq +
ldaSta #$01, DesativaFastROM
+
lda DesativaFastROM
BEQ +
STZ MEMSEL
+


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Movimento de câmera ligada ao sprite jogável
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lda $0380
cmp #$78
bmi +
a16Bit
inc BG1Hlow 
a8Bit
dec $0380   ;parar sprite de ir pra direita
dec $0384
+
lda $0380
cmp #$68
bpl +
a16Bit
DEC BG1Hlow 
a8Bit
inc $0380   ;parar sprite de ir pra esquerda
inc $0384
+

; Animação do offset de sprite 
; Mover tabela da ROM para a RAM
;
REP #A_8BIT
LDA #Onda
CLC
ADC $F1            ; Adicionar valor à tabela
STA $F3            ; Colocar valor da tabela + adição em RAM 

PHB                ; Preservar data bank
LDA #$002F         ;Counter (-1)
LDX $F3            ;Source
LDY #$1000           ;Destino
MVN $c0, $7e       ;Banco da Source/Banco do Destino
PLB                ; Recuperar data bank

INC $F1            ; Incrementa para o próximo frame
LDA $F1 
CMP #$0020         ; Quantas vezes incrementar tabela até zerar
BNE +
STZ $f1
+
SEP #A_8BIT


	PLP
RTS                  ;/  

Onda:
	.include "tables/onda.asm"

RodaUMAvez:


JSL lanooutrobanco    ; Vamos mudar de banco e adicionar nossos arquivos grandes lá.
RTS                   ; Em HI-ROM cada banco tem 64 KB.
/*
.ENDS
*/

/*
.BANK 1 SLOT 0
.ORG 0
.SECTION "BancodosGraficos" SEMIFREE
*/
lanooutrobanco:

;===========================
; Vou botar meus DMA e HDMA aqui hihi
; -------------------------------------
;----------------------------
PHD
a16Bit
LDA #$4300 ; DP é 4200
TCD 
a8Bit

;DMA DE CORES PARA A CGRAM
stz MDMAEN	;Clear the DMA control register
dmaToCgram #$20, #grafico7CORES, #$0080

;BG2
stz MDMAEN	;Clear the DMA control register
dmaToCgram #$60, #bg2CORES, #$0060

;BG3
stz MDMAEN	;Clear the DMA control register
dmaToCgram #$00, #graficosbg3CORES, #$0040

;---
;sprite
stz MDMAEN	;Clear the DMA control register
dmaToCgram #$80, #dmaCORESsprite2, #$0020

;HUD
stz MDMAEN	;Clear the DMA control register
dmaToCgram #$90, #spriteHUDcor, #$0080


;----------------------------
;DMA DE GRÁFICOS PARA A VRAM

ldaSta #VMainConstants_INCREMENT_MODE_BY_1, VMAIN

;BG1
dmaToVram #$0000, graficos7, #$3800

;BG2
dmaToVram #$2000, bg2tiles, #$3800
	
;BG3 + tilemap
dmaToVram #$4000, graficosbg3, #$2800

;sprite 
dmaToVram #$6000, graficosprite1, #$3000

;----------------------------
;DMA DA TILEMAP PARA A VRAM
dmaToVram #$5400, graficos1tilemap, #$0800

;DMA BG2
dmaToVram #$5800, bg2tilemap, #$0800
PLD


RTL                ; Retorna da sub-rotina para o banco anterior
;Background 1
graficos7:
	.incbin "includes/gfx/maglordBG188.pic"

grafico7CORES:
	.incbin "includes/gfx/maglordBG188.clr"

graficos1tilemap:
	.incbin "includes/gfx/maglordBG188.map"


;Background 2
bg2tiles:
	.incbin "includes/gfx/BG2Magician.bin"

bg2CORES:
	.incbin "includes/gfx/BG2Magiciancor.bin"

bg2tilemap:
	.incbin "includes/gfx/BG2Magicianmap.bin"


;Background 3
graficosbg3:
	.incbin "includes/gfx/BG3magician.bin"

graficosbg3CORES:
	.incbin "includes/gfx/BG3magicianCORES.mw3"

;Sprite
graficosprite1:
	.incbin "includes/gfx/sotnSP.bin"
spriteHUDcor:
	.incbin "includes/gfx/magicianHUD.mw3"

;DMA Sprite
dmaCORESsprite2:
	.incbin "includes/gfx/MLmago.mw3"
.ENDS





;Muito grande esse aqui meo, precisa de um banco pra ele.
/*
.BANK 2 SLOT 0
.ORG 0
.SECTION "BancodosGraficos2" SEMIFREE
*/

DMAMagician:
	.incbin "includes/gfx/MLmagocompacto.bin"

DMAExplosao:
	.incbin "includes/gfx/Explosao.bin"
/*
.ENDS
*/
