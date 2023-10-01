

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



; .INCLUDE "show.inc"
.INCLUDE "defines.asm"
;=== Include Library Routines & Macros ===
;.INCLUDE "InitSNES.asm"
.INCLUDE "2input.asm"

;=== Espelhos para a RAM ===
;.ENUM $40                  ; Isso vai usar da RAM $D0 em sequencia para inserir essas variaveis. Uma funcão legal desse debugger. :)
;Ativaomedidor   db
;DesativaFastROM db
;.ENDE

Ativaomedidor = $40
DesativaFastROM = $41



;==============================================================================
; E aqui que o codigo de verdade comeca... mas a parte legal eu deixei para depois do primeiro NMI.
; O que tem aqui é so um loop que dura até chegar na scanline 225, daí repete o que esta em "VBlank" e volta pro loop.
;==============================================================================

.segment "CODE"
main:
JML Faster
;.BASE $C0        ; Pular para banco rapido
;.org $C0
.INCLUDE "Sprite/Magician.asm"
.INCLUDE "Sprite/Inimigo.asm"
Faster:
	;InitializeSNES
;main:
	JSR IniciarSprites

	a8Bit
	lda #$01
	;sta $420d ;FastROM
	sta f:MEMSEL

	lda #$ff
	sta $E2   ;comeca pixelado	

	stz $E3   ;comeca com tela escura	

	LDA #$FF
	STA $0734 ; Comparador de animacão diferente da inicial para ativar DMA do player

	JSR MagicianDMA
	JSR RodaUMAvez ;$C00BED Seu codigo vai rodar nessa sub-rotina apenas uma vez.
	JSR JoyInit		;ativa os controles

	;==============
	;BG config
	lda #$01		;Set video mode 1, 8x8 tiles
	sta f:$2105         

	lda #$54		;Set BG1's Tile Map VRAM offset
	sta f:$2107		;   and the Tile Map size to 32 tiles x 32 tiles

	lda #$58		;Set BG2's Tile Map VRAM offset
	sta f:$2108		;   and the Tile Map size to 32 tiles x 32 tiles

	lda #$50		;Set BG3's Tile Map VRAM offset
	sta f:$2109		;   and the Tile Map size to 32 tiles x 32 tiles

	lda #$20		;Set BG1's Character VRAM offset (word address)
	sta f:$210B		;Set BG2's Character VRAM offset (word address)
	lda #$04		;Set BG3's Character VRAM offset (word address)
	sta f:$210C		;Set BG4's Character VRAM offset (word address)

	lda #%00010111		;Turn on BG1
	sta f:$212C

	lda #$02		;Turn on BG2
	sta f:$212d

	lda #%00100011		;Sprite VRAM = Sprites 16x16/32x32 e VRAM 6000
	sta f:$2101

	LDA #%00100000
	STA ColorMath1

    LDA #$FF
    STA BG1Vlow
    LDA #$1c
    STA BG2Vlow

;Gradiente HDMA 
	LDX #$3200
	STX $4330
	LDX #.loword(RedTable) ; #$88F7
	STX $4332
	;LDA #$C0
	LDA #.BANKBYTE(RedTable)
	STA f:$4334
	LDX #$3200
	STX $4340
	LDX #.loword(GreenTable)
	STX $4342
	; LDA #$C0
	LDA #.BANKBYTE(GreenTable)
	STA f:$4344
	LDX #$3200
	STX $4350
	LDX #.loword(BlueTable)
	STX $4352
	; LDA #$C0
	LDA #.BANKBYTE(BlueTable)
	STA f:$4354
	LDA #$38
	TSB $0D9F   ;canais 3, 4, 5 para cada R,G,B. 

;HDMA de cores para a BG3
	LDX #$0001
	SEP #$30
	LDA #$00
	STA f:$4360
	LDA #$21
	STA f:$4361   ;Registro
	LDA #.BANKBYTE(Corslot)
	STA f:$4364  ;Source banco
	REP #$30
	LDA #.loword(Corslot)  ;Source
	STA $4362
	SEP #$30

	LDA #$02
	STA f:$4370
	LDA #$22
	STA f:$4371   ;Registro
	LDA #.BANKBYTE(Corhdma)
	STA f:$4374  ;Source banco
	REP #$30
	LDA #.loword(Corhdma)  ;Source
	STA f:$4372
	LDA #%11000000
	TSB $0D9F
	REP #$10
	SEP #$20

loop:
LDA Ativaomedidor
BEQ :+
lda #$08  ; Medidor de CPU 
sta f:$2100 ;
:
wai
bra loop

Corslot:
;primeiro byte: line counter / segundo e terceiro byte: contagem de quantos valores ir adicionando 
.byte $68, $80, $95
.byte $01, $02, $03
.byte $01, $02, $03
.byte $01, $02, $03
.byte $01, $02, $03
.byte $01, $02, $03
.byte $01, $02, $03
.byte $01, $02, $03
.byte $14, $80, $83
.byte $01, $02, $03
.byte $00
Corslot_end:


Corhdma:   ;16 bits
;primeiro e segundo byte: line counter / terceiro e quarto byte: contagem de quantos valores ir adicionando de 80 à 8F 
.byte $68, $00, $00, $95 ;Setup
.byte $AD, $45, $10, $56, $73, $5A
.byte $8C, $41, $EF, $51, $52, $56
.byte $6B, $3D, $CE, $4D, $31, $52
.byte $4A, $39, $AD, $4D, $10, $52
.byte $29, $35, $8C, $49, $EF, $4D
.byte $08, $35, $6B, $45, $CE, $49
.byte $08, $31, $6B, $3D, $AD, $45
.byte $14, $00, $00, $83 ;Setup
.byte $2B, $5A, $12, $73, $76, $7B
.byte $00
Corhdma_end:


RedTable:           ; 
.byte $3F,  $2A   ; 
.byte $01,  $2B   ; 
.byte $01,  $2A   ; 
.byte $01,  $2B   ; 
.byte $01,  $2A   ; 
.byte $0F,  $2B   ; 
.byte $05,  $2C   ; 
.byte $09,  $2D   ; 
.byte $06,  $2E   ; 
.byte $01,  $2F   ; 
.byte $02,  $31   ; 
.byte $02,  $32   ; 
.byte $02,  $33   ; 
.byte $02,  $34   ; 
.byte $01,  $35   ; 
.byte $04,  $36   ; 
.byte $05,  $37   ; 
.byte $69,  $27   ; 
.byte $00            ; 
RedTable_end:

GreenTable:         ; 
.byte $3F,  $50   ; 
.byte $01,  $51   ; 
.byte $01,  $50   ; 
.byte $01,  $51   ; 
.byte $01,  $50   ; 
.byte $06,  $51   ; 
.byte $06,  $50   ; 
.byte $02,  $4F   ; 
.byte $02,  $4E   ; 
.byte $01,  $4D   ; 
.byte $02,  $4C   ; 
.byte $01,  $4B   ; 
.byte $03,  $4A   ; 
.byte $07,  $49   ; 
.byte $09,  $48   ; 
.byte $04,  $49   ; 
.byte $05,  $4A   ; 
.byte $06,  $4B   ; 
.byte $69,  $47   ; 
.byte $00            ; 
GreenTable_end:

BlueTable:          ; 
.byte $3F,  $95   ; 
.byte $01,  $96   ; 
.byte $01,  $95   ; 
.byte $01,  $96   ; 
.byte $01,  $95   ; 
.byte $03,  $96   ; 
.byte $08,  $95   ; 
.byte $02,  $94   ; 
.byte $02,  $93   ; 
.byte $01,  $92   ; 
.byte $01,  $91   ; 
.byte $01,  $90   ; 
.byte $01,  $8F   ; 
.byte $02,  $8E   ; 
.byte $01,  $8D   ; 
.byte $03,  $8C   ; 
.byte $0B,  $8B   ; 
.byte $0C,  $8A   ; 
.byte $06,  $8B   ; 
.byte $69,  $8B   ; 
.byte $00         ; 
BlueTable_end:





;======================
;Iniciar Sprites
;======================
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

    rep #$10        ; 16bit A/X/Y
    sep #$20        ; 16bit A/X/Y
	
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
;.org $C0        ; Pular para banco rapido
.segment "CODE"
FasterVBLANK:
	rep #$30		;A/Mem=16bits, X/Y=16bits
	phb       ;preserva o banco de antes de chegar aqui
	pha       ;preserva o Acumulador de antes de chegar aqui
	phx       ;preserva o index X de antes de chegar aqui
	phy       ;preserva o index Y de antes de chegar aqui
	phd       ;preserva o direct page de antes de chegar aqui

	sep #$20		; mem/A = 8 bit, X/Y = 16 bit

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


	rep #$10		;A/mem = 8bit, X/Y=16bit
	sep #$20
	
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
    LDA $0D9F
    STA f:$420C
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
SEP #$20

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
stx $2102
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
ldaSta #$00, f:$436b
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
lda f:$436b
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
.byte $10, $18, $20, $28, $30, $38                         ; HP
.byte $A8, $B0, $B8, $C0, $C8, $D0, $D8, $E0, $E8           ; POW
.byte $10, $18, $20                                        ; 1UP
.byte $c0, $c8, $d0                                        ; VIDAS
.byte $e0, $e8, $e0, $e8                                    ; ITEM

hudVpos:
.byte $D0, $D0, $D0, $D0, $D0, $D0                         ; HP
.byte $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0           ; POW
.byte $10, $10, $10                                        ; 1UP
.byte $10, $10, $10                                        ; VIDAS
.byte $10, $10, $18, $18                                    ; ITEM

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
ldaSta #$00, f:$436B

PHD
rep #$20
LDA #$0400    ; DP no $0400
TCD           ; Transferir do A 16 bits ao Direct Page 
sep #$20

repetespriteonda:

LDA #$00
CLC
ADC f:$436B
STA $50,x           ; Ir adicionando o valor de $436B em H a cada loop 
CLC
ADC $1008,y
STA $50,x           ; Ir adicionando o valor da tabela em H a cada loop (levemente a frente do Y)
LDA #$AC
CLC
ADC $1000,y
STA $51,x           ; Adicionar o valor da tabela na posicão Y e incrementar
tya
clc
adc #$80
sta $52,x           ; Starting tile #
LDA #%00110100   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page
STA $53,x          ;
LDA f:$436B
CLC
ADC #$08
STA f:$436B           ; Adiciona 8 para o proximo loop
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
ldaSta #$00, f:$436B
repetespriteonda1:

LDA #$50
CLC
ADC f:$436B
STA $C8,x           ; Ir adicionando o valor de $436B em H a cada loop 
CLC
ADC $1018,y
STA $C8,x           ; Ir adicionando o valor da tabela em H a cada loop (levemente a frente do Y)
LDA #$BC
CLC
ADC $1020,y
STA $C9,x           ; Adicionar o valor da tabela na posicão Y e incrementar
tya
clc
adc #$A0
sta $CA,x           ; Starting tile #
LDA #%00110100   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page
STA $CB,x          ;
LDA f:$436B
CLC
ADC #$08
STA f:$436B           ; Adiciona 8 para o proximo loop
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
	LDA #$01
	STA DesativaFastROM
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
	SEP #$20
	dec $0380   ;parar sprite de ir pra direita
	dec $0384
	:
	lda $0380
	cmp #$68
	bpl :+
	REP #$20
	DEC BG1Hlow 
	SEP #$20
	inc $0380   ;parar sprite de ir pra esquerda
	inc $0384
	:

	; Animacão do offset de sprite 
	; Mover tabela da ROM para a RAM
	;
	REP #A_8BIT
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
Onda_end:

RodaUMAvez:
	JSL lanooutrobanco    ; Vamos mudar de banco e adicionar nossos arquivos grandes la.
	RTS                   ; Em HI-ROM cada banco tem 64 KB.
;.ENDS

;.BANK 1 SLOT 0
;.ORG 0
;.SECTION "BancodosGraficos" SEMIFREE
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
	SEP #$20

	;DMA DE CORES PARA A CGRAM
	lda #$20
	sta f:$2121	;start at XX color
	;stz $420B	;Clear the DMA control register
	ldaSta #$00, f:$420B	;Clear the DMA control register
	ldx #.loword(grafico7CORES)
	stx $02	;Store the data offset into DMA source offset
	ldx #$0080
	stx $05   ;Store the size of the data block
	;lda #$C1
	;sta $04	;Store the data bank holding the tile data
	ldaSta #.BANKBYTE(grafico7CORES), $04

	lda #$00	;Set the DMA mode (byte, normal increment)
	sta $00       
	lda #$22    ;Set the destination register ( $2122: CG-RAM Write )
	sta $01      
	lda #$01    ;Initiate the DMA transfer
	sta f:$420B


	;BG2
	lda #$60
	sta f:$2121	;start at XX color
	;stz  $420B	;Clear the DMA control register
	ldaSta #$00, f:$420B	;Clear the DMA control register
	ldx #.loword(bg2CORES)
	stx $02	;Store the data offset into DMA source offset
	ldx #$0060
	stx $05   ;Store the size of the data block
	; lda #$C1
	; sta $04	;Store the data bank holding the tile data
	ldaSta #.BANKBYTE(bg2CORES), $04
	lda #$00	;Set the DMA mode (byte, normal increment)
	sta $00       
	lda #$22    ;Set the destination register ( $2122: CG-RAM Write )
	sta $01      
	lda #$01    ;Initiate the DMA transfer
	sta f:$420B

	;BG3
	lda #$00
	sta f:$2121	;start at XX color
	; stz $420B	;Clear the DMA control register
	ldaSta #$00, f:$420B	;Clear the DMA control register
	ldx #.loword(graficosbg3CORES)
	stx $02	;Store the data offset into DMA source offset
	ldx #$0040
	stx $05   ;Store the size of the data block
	; lda #$C1
	; sta $04	;Store the data bank holding the tile data
	ldaSta #.BANKBYTE(graficosbg3CORES), $04
	lda #$00	;Set the DMA mode (byte, normal increment)
	sta $00       
	lda #$22    ;Set the destination register ( $2122: CG-RAM Write )
	sta $01      
	lda #$01    ;Initiate the DMA transfer
	sta f:$420B

	;---
	;sprite
	lda #$80
	sta f:$2121	;start at XX color
	;stz $420B	;Clear the DMA control register
	ldaSta #$00, f:$420B	;Clear the DMA control register
	ldx #.loword(dmaCORESsprite2)
	stx $02	;Store the data offset into DMA source offset
	ldx #$0020
	stx $05   ;Store the size of the data block
	; lda #$C1
	; sta $04	;Store the data bank holding the tile data
	ldaSta #.BANKBYTE(dmaCORESsprite2), $04
	lda #$00	;Set the DMA mode (byte, normal increment)
	sta $00       
	lda #$22    ;Set the destination register ( $2122: CG-RAM Write )
	sta $01      
	lda #$01    ;Initiate the DMA transfer
	sta f:$420B

	;HUD
	lda #$90
	sta f:$2121	;start at XX color
	;stz $420B	;Clear the DMA control register
	ldaSta #$00, f:$420B	;Clear the DMA control register
	ldx #.loword(spriteHUDcor)
	stx $02	;Store the data offset into DMA source offset
	ldx #$0080
	stx $05   ;Store the size of the data block
	; lda #$C1
	; sta $04	;Store the data bank holding the tile data
	ldaSta #.BANKBYTE(spriteHUDcor), $04
	lda #$00	;Set the DMA mode (byte, normal increment)
	sta $00       
	lda #$22    ;Set the destination register ( $2122: CG-RAM Write )
	sta $01      
	lda #$01    ;Initiate the DMA transfer
	sta f:$420B


	;----------------------------
	;DMA DE GRÁFICOS PARA A VRAM
	;BG1
	LDA #$80            ; \ Increase on $2119 write.
	STA f:$2115           ; /
	LDX #$0000			; \ Set where to write in VRAM...
	STX $2116			; /
	LDA #$01            ;\ Set mode to...
	STA $00           ;/ ...2 regs write once.
	LDA #$18            ;\ 
	STA $01           ;/ Writing to $2118 AND $2119.
	LDX #.loword(graficos7)       ;\  Adress where our data is.
	STX $02          				 ; | 
	; LDA #$C1   ; | Bank where our data is.
	; STA $04          				 ;/
	ldaSta #.BANKBYTE(graficos7), $04
	LDX #$3800          ;\ Size of our data.
	STX $05           ;/
	LDA #$01	   ;\ Start DMA transfer on channel 0.
	STA f:$420B	   ;/

	;BG2
	LDA #$80            ; \ Increase on $2119 write.
	STA f:$2115           ; /
	LDX #$2000			; \ Set where to write in VRAM...
	STX $2116			; /
	LDA #$01            ;\ Set mode to...
	STA $00           ;/ ...2 regs write once.
	LDA #$18            ;\ 
	STA $01           ;/ Writing to $2118 AND $2119.
	LDX #.loword(bg2tiles)       ;\  Adress where our data is.
	STX $02          				 ; | 
	; LDA #$C1   ; | Bank where our data is.
	; STA $04          				 ;/
	ldaSta #.BANKBYTE(bg2tiles), $04
	LDX #$3800          ;\ Size of our data.
	STX $05           ;/
	LDA #$01	   ;\ Start DMA transfer on channel 0.
	STA f:$420B	   ;/	

	;BG3 + tilemap
	LDA #$80            ; \ Increase on $2119 write.
	STA f:$2115           ; /
	LDX #$4000			; \ Set where to write in VRAM...
	STX $2116			; /
	LDA #$01            ;\ Set mode to...
	STA $00           ;/ ...2 regs write once.
	LDA #$18            ;\ 
	STA $01           ;/ Writing to $2118 AND $2119.
	LDX #.loword(graficosbg3)       ;\  Adress where our data is.
	STX $02          				 ; | 
	; LDA #$C1   ; | Bank where our data is.
	; STA $04          				 ;/
	ldaSta #.BANKBYTE(graficosbg3), $04
	LDX #$2800          ;\ Size of our data.
	STX $05           ;/
	LDA #$01	   ;\ Start DMA transfer on channel 0.
	STA f:$420B	   ;/

	;sprite 
	LDA #$80            ; \ Increase on $2119 write.
	STA f:$2115           ; /
	LDX #$6000			; \ Set where to write in VRAM...
	STX $2116			; /
	LDA #$01            ;\ Set mode to...
	STA $00           ;/ ...2 regs write once.
	LDA #$18            ;\ 
	STA $01           ;/ Writing to $2118 AND $2119.
	LDX #.loword(graficosprite1)       ;\  Adress where our data is.
	STX $02          				 ; | 
	; LDA #$C1   ; | Bank where our data is.
	; STA $04          				 ;/
	ldaSta #.BANKBYTE(graficosprite1), $04
	LDX #$3000          ;\ Size of our data.
	STX $05           ;/
	LDA #$01	   ;\ Start DMA transfer on channel 0.
	STA f:$420B	   ;/

	;----------------------------
	;DMA DA TILEMAP PARA A VRAM
	LDA #$80            ; \ Increase on $2119 write.
	STA f:$2115           ; /
	LDX #$5400			; \ Set where to write in VRAM...
	STX $2116			; /
	LDA #$01            ;\ Set mode to...
	STA $00           ;/ ...2 regs write once.
	LDA #$18            ;\ 
	STA $01           ;/ Writing to $2118 AND $2119.
	LDX #.loword(graficos1tilemap)       ;\  Adress where our data is.
	STX $02          				 ; | 
	; LDA #$C1   ; | Bank where our data is.
	; STA $04          				 ;/
	ldaSta #.BANKBYTE(graficos1tilemap), $04
	LDX #$0800          ;\ Size of our data.
	STX $05           ;/
	LDA #$01	   ;\ Start DMA transfer on channel 0.
	STA f:$420B	   ;/

	;DMA BG2
	LDA #$80            ; \ Increase on $2119 write.
	STA f:$2115           ; /
	LDX #$5800			; \ Set where to write in VRAM...
	STX $2116			; /
	LDA #$01            ;\ Set mode to...
	STA $00           ;/ ...2 regs write once.
	LDA #$18            ;\ 
	STA $01           ;/ Writing to $2118 AND $2119.
	LDX #.loword(bg2tilemap)       ;\  Adress where our data is.
	STX $02          				 ; | 
	; LDA #$C1   ; | Bank where our data is.
	; STA $04          				 ;/
	ldaSta #.BANKBYTE(bg2tilemap), $04
	LDX #$0800          ;\ Size of our data.
	STX $05           ;/
	LDA #$01	   ;\ Start DMA transfer on channel 0.
	STA f:$420B	   ;/
	PLD
	RTL                ; Retorna da sub-rotina para o banco anterior

;Background 1
graficos7:
.incbin "GFX/maglordBG188.pic"

grafico7CORES:
.incbin "GFX/maglordBG188.clr"

graficos1tilemap:
.incbin "GFX/maglordBG188.map"


;Background 2
bg2tiles:
.incbin "GFX/BG2Magician.bin"

bg2CORES:
.incbin "GFX/BG2Magiciancor.bin"

bg2tilemap:
.incbin "GFX/BG2Magicianmap.bin"


;Background 3
graficosbg3:
.incbin "GFX/BG3magician.bin"

graficosbg3CORES:
.incbin "GFX/BG3magicianCORES.mw3"

;Sprite
graficosprite1:
.incbin "GFX/sotnSP.bin"
spriteHUDcor:
.incbin "GFX/magicianHUD.mw3"

;DMA Sprite
dmaCORESsprite2:
.incbin "GFX/MLmago.mw3"
;.ENDS





;Muito grande esse aqui meo, precisa de um banco pra ele.

;.BANK 2 SLOT 0
;.ORG 0
;.SECTION "BancodosGraficos2" SEMIFREE
.segment "RODATA2"
DMAMagician:
.incbin "GFX/MLmagocompacto.bin"

DMAExplosao:
.incbin "GFX/Explosao.bin"
DMAExplosao_end:
;.ENDS
