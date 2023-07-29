
MagicianSprite:

PHD
a16Bit
LDA #$0300    ; DP no $0300
TCD           ; Transferir do A 16 bits ao Direct Page 
a8Bit


;direita
lda $7E0021 ;Joy1Press ... DP está no 0300 agora, vamos ter que ser diretos ao usar RAM de 1 só byte fora da DP
and #$02
beq :+
lda #%01000000   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page
TSB $83          ; seta apenas o que for 1 em A para a RAM
dec $80

:
;esquerda
lda $7E0021 ;Joy1Press
and #$01
beq :+
lda #%01000000   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page
TRB $83          ; zera apenas o que for 1 em A para a RAM
inc $80

:
lda #$30
sta $82           ; Starting tile #

lda #%01011010  ; bit zero é o 9 bit (sprite fora da tela) e bit 1 é tamanho de sprite. 
sta $0508

;reseta obj extra 2 se não usado
lda #%01010101  ; bit zero é o 9 bit (sprite fora da tela) e bit 1 é tamanho de sprite. 
sta $0509
;--------------------------------------------------
;obj extra
;------------------
LDA $80
STA $84

LDA $81
CLC
ADC #$20
STA $85

LDA $83
STA $87

lda #$34
sta $86           ; Starting tile #

;===========;
;;;Colisão;;;
;===========;
STZ $074A
; horizontal
LDA $050C   ; Inimigo está em tela?
and #%0000001
BNE :+

lda $84   ; Posição horizontal do player
SEC
sbc $C0   ; Posição horizontal do inimigo
sbc #$14    ; Tamanho horizontal do player (- C)
clc
adc #$20+10 ; Soma do tamanho do player com o inimigo (- 10). O Carry ativará se colidirem.
BCC :+       ;Pula se carry não for ativado

; vertical
lda $85   ; Posição vertical do player
SEC
sbc $C1   ; Posição vertical do inimigo
sbc #$30    ; Tamanho vertical do player (- 10)
clc
adc #$30+10 ; Soma do tamanho do player (- 10) com o inimigo (- 10). O Carry ativará se colidirem.
BCC :+       ;Pula se carry não for ativado
LDA #$01
STA $074A   ; Player está levando dano 

:
; chamar projétil
lda $0742
CMP #$00
BNE label_4_magician
a16Bit
LDA $0722
CMP #$2100
bne label_4_magician
a8Bit

LDA $83
BIT #%01000000
BNE label_2_magician
LDA $80
CLC 
ADC #$1C
STA $0745 ;horizontal temporário
LDA #$01
STA $0749
BRA label_3_magician

label_2_magician:
STZ $0749
LDA $80
STA $0745 ;horizontal temporário espelhado

label_3_magician:
LDA $81
CLC 
ADC #$0E
STA $0746 ;vertical temporário

LDA #$01
STA $0742

label_4_magician:
PLD     ; DP = 0000

a8Bit
RTS

MagicianMETA1h:
.byte $1c, $24, $1c, $24

MagicianMETA1v:
.byte $0e, $0e, $16, $16

MagicianMETA1hESPELHO:
.byte $Fc, $f4, $Fc, $f4



;======================================
;Sprite projétil 
;======================================
Projectile:

LDA $0742
BNE :+
LDA #$80
STA $03A0
STA $03A4
STA $03A8
STA $03AC
lda #%01010101  ; bit zero é o 9 bit (sprite fora da tela) e bit 1 é tamanho de sprite. 
sta $050A         ; PROJÉTIL NÃO UTILIZADO
RTS

:
ldy #$0000
ldx #$0000

PHD
LDA #$07
XBA
LDA #$00
TCD        ; DP é 0700
;;;;;;
LDA $49
BEQ projetilespelhado

label_1_menos_magician:
LDA projetilh,y      ;Endereço horizontal temporário do projétil 
clc
adc $45
STA $43

LDA $43
clc
adc $44
STA $03A0,x ;horizontal 

LDA projetilv,y
clc
adc $46
STA $03A1,x ;vertical

LDA $14
CMP #$03
BEQ :+
TYA
CLC 
ADC #$20
STA $03A2,x
BRA label_2_magician_2

:
TYA
CLC 
ADC #$24
STA $03A2,x

label_2_magician_2:
lda #%00110000   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page
sta $03A3,x          ; zera apenas o que for 1 em A para a RAM
INX
INX
INX
INX
INY
CPY #$0004
BNE label_1_menos_magician

INC $44
INC $44
INC $44
INC $44

BRA projetilnaoespelhado
;;;;;;
projetilespelhado:
label_1_menos_magician_2:
LDA projetilhESPELHO,y      ;Endereço horizontal temporário do projétil 
CLC
ADC $45
STA $43

LDA $43
CLC 
ADC $44
STA $03A0,x ;horizontal 

LDA projetilv,y
CLC 
ADC $46
STA $03A1,x ;vertical

LDA $14
CMP #$03
BEQ :+
TYA
CLC 
ADC #$20
STA $03A2,x
BRA label_2_magician_3

:
TYA
CLC 
ADC #$24
STA $03A2,x

label_2_magician_3:
lda #%01110000   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page
sta $03A3,x          ; zera apenas o que for 1 em A para a RAM
INX
INX
INX
INX
INY
CPY #$0004
BNE label_1_menos_magician

DEC $44
DEC $44
DEC $44
DEC $44
projetilnaoespelhado:
;;;;;;
PLD

lda #%00000000  ; bit zero é o 9 bit (sprite fora da tela) e bit 1 é tamanho de sprite. 
sta $050A

LDA $03A4        ;Checa se chegou nas bordas da tela, se sim, esconder sprite.
CMP #$01 
beq projetilmorto
CMP #$02
beq projetilmorto
CMP #$03
beq projetilmorto
CMP #$04
beq projetilmorto
CMP #$F4 
beq projetilmorto
CMP #$F5 
beq projetilmorto
CMP #$F6 
beq projetilmorto
CMP #$F7 
bne :+
projetilmorto:
LDA #$80
STA $03A0
STA $03A4
STA $03A8
STA $03AC
lda #%01010101  ; bit zero é o 9 bit (sprite fora da tela) e bit 1 é tamanho de sprite. 
sta $050A
STZ $0742
STZ $0744
RTS 

:
;===========;
;;;Colisão;;;
;===========;

; horizontal
LDA $050C   ; Inimigo está em tela?
and #%0000001
Bne label_4_magician_1
LDA $0749   ; O projétil está espelhado?
beq :+
lda $03A0   ; Posição horizontal do projétil normal
BRA label_2_magician_4

:
lda $03A4   ; Posição horizontal do projétil espelhado

label_2_magician_4:
SEC
sbc $03C0   ; Posição horizontal do inimigo
sbc #$18    ; Tamanho horizontal do projétil (+ 8)
CLC
adc #$18+10 ; Soma do tamanho do projétil (+ 8) com o inimigo (- 10). O Carry ativará se colidirem.
BCC label_4_magician_1       ;Pula se carry não for ativado

; vertical
lda $03A1   ; Posição horizontal do projétil espelhado
SEC
sbc $03C1   ; Posição horizontal do inimigo
sbc #$18    ; Tamanho horizontal do projétil (+ 8)
CLC
adc #$18+10 ; Soma do tamanho do projétil (+ 8) com o inimigo (- 10). O Carry ativará se colidirem.
BCC label_4_magician_1       ;Pula se carry não for ativado
LDA #$02
STA $07C0   ; Inimigo fica no modo morto
BRL projetilmorto

label_4_magician_1:
	rts


RTS 

projetilh:
.byte $00, $08, $00, $08

projetilhESPELHO:
.byte $Fc, $f4, $Fc, $f4

projetilv:
.byte $00, $00, $08, $08

;;=======================================================================================================
;
;;=======================================================================================================
MagicianDMA:

;====================
;Controles = animação
;====================

LDA $074A     ;Player levando dano
CMP #$01
BNE :+
lda #$05
sta $00
JMP Animation

:
LDA $073e     ;TIMER ATÉ ACABAR A ANIMAÇÃO, NÃO TOCAR OUTRA ANIMAÇÃO
CMP #$01
BNE :+
lda #$03
sta $00
JMP Animation

:
LDA $073e     ;TIMER ATÉ ACABAR A ANIMAÇÃO, NÃO TOCAR OUTRA ANIMAÇÃO
CMP #$02
BNE :+
lda #$02
sta $00
JMP Animation

:
;direita/esquerda
lda $21 ;Joy1Press ... DP está no 0300 agora, vamos ter que ser diretos ao usar RAM de 1 só byte fora da DP
bit #%00000011
beq :+
LDA #$01
STA $00
JMP Animation

:
;ataque cima
lda $21 ;Joy1Press ... DP está no 0300 agora, vamos ter que ser diretos ao usar RAM de 1 só byte fora da DP
AND #$08
bEQ :+
lda $21 ;Joy1Press ... DP está no 0300 agora, vamos ter que ser diretos ao usar RAM de 1 só byte fora da DP
AND #$40
bEQ :+
lda #$02
sta $073e     ;TIMER ATÉ ACABAR A ANIMAÇÃO, NÃO TOCAR OUTRA ANIMAÇÃO
lda #$02
sta $00
JMP Animation

:
;ataque terreo
lda $21 ;Joy1Press ... DP está no 0300 agora, vamos ter que ser diretos ao usar RAM de 1 só byte fora da DP
bit #$40
beq :+
lda #$01
sta $073e     ;TIMER ATÉ ACABAR A ANIMAÇÃO, NÃO TOCAR OUTRA ANIMAÇÃO
lda #$03
sta $00
JMP Animation

:
;abaixado
lda $21 ;Joy1Press ... DP está no 0300 agora, vamos ter que ser diretos ao usar RAM de 1 só byte fora da DP
bit #$04
beq :+
lda #$04
sta $00
JMP Animation

:
;nada
lda $21 ;Joy1Press
cmp #$00
bne :+
STZ $00
JMP Animation
:
RTS

;====================
;Animação
;====================
Animation:
LDA $14
CMP #$04
Beq :+
BRL Animeframerate

:
LDA #$00
XBA 
LDA $00
ASL A
TAX
JMP (PointersANISTATE,x)

PointersANISTATE:
.word PARADO
.word ANDAR
.word ATACARCIMA
.word ATACARTERREO
.word ABAIXADO
.word DANO

PARADO:
a16Bit
STZ $0740
LDA #$1800
STA $0722
a8Bit
BRL DyRAM

ANDAR:
a16Bit
LDX $0740
LDA Andaranimation,x
STA $0722
INX
INX
STX $0740

LDA $0740
CMP #$000c
BMI label_2_magician_5
STZ $0740

label_2_magician_5:
a8Bit
+
BRL DyRAM

ATACARTERREO:
a16Bit
LDX $0740
LDA Ataqueanimation,x
STA $0722
INX
INX
STX $0740

LDA $0740
CMP #$0006
BMI ++
STZ $0740
STZ $0725
STZ $073e 
++
a8Bit
+
BRA DyRAM

ATACARCIMA:
a16Bit
LDX $0740
LDA AtaqueCimaanimation,x
STA $0722
INX
INX
STX $0740

LDA $0740
CMP #$0006
BMI ++
STZ $0740
STZ $073e 
++
a8Bit
+
BRA DyRAM

ABAIXADO:
a16Bit
STZ $0740
LDA #$3800
STA $0722
a8Bit
BRA DyRAM

DANO:
a16Bit
STZ $0740
LDA #$7900
STA $0722
a8Bit
BRA DyRAM

;======================
; Setup para DMA de sprite de 32 pixels verticais.
; Aqui há uma tabela que será mandada para a RAM e depois usada pelo DMA.
;======================
DyRAM:

LDA #$07
XBA
LDA #$00
TCD        ; DP é 0700

LDA $23
CMP $34
BNE +
BRL Animeframerate
+

LDA #$C2
STA $30  ; Banco de origem

lda #$08
sta $31  ; Quantas vezes repetir DMA 

a16Bit
LDA #$0100
STA $20   ; Tamanho das transferências

LDY #$0000
LDX #$0008
loopsprite32:
LDA Sprite32dmaVRAM,x
clc
ADC #$6300       ; Inserir local da VRAM para escrever
STA $00,x ; VRAM
INY
INY
DEX
DEX
BPL loopsprite32

LDY #$0000
LDX #$0008
Graficosdeandar:
LDA Sprite32dmaORIGEM,x
CLC
ADC #DMAMagician
CLC 
ADC $22
STA $10,x ; Adress where our data is.
INY
INY
DEX
DEX
BPL Graficosdeandar
a8Bit
+
  
;======================
; DMA em 4 passos para completar um sprite com 32 pixels verticais
;======================

a16Bit
LDA #$4300   ; Direct page agora são os registros de DMA  
TCD
a8Bit

LDA #$80            ; \ Increase on $2119 write.
STA $2115           ; /
	
LDX $0731   ; Counter de repetições + número de offset dos endereços 
DEX
DEX 

LDA #$01
STA $00    ; ...2 regs write once. (4300)
LDA #$18
STA $01    ; Writing to $2118 AND $2119. (4301)
LDA $0730
STA $04      ; Bank where our data is. (4304)

-

LDY $0700,x
STY $2116    ; Local da VRAM
LDY $0710,x
STY $02      ; Endereço dos nossos dados. (4302)
LDY $0720
STY $05      ; Tamanho dos nossos dados. (4305)
LDA #$01
STA $420B    ; Iniciar DMA canal 0
DEX
DEX
BPL -

LDX $0722    ; Registrar frame que foi feito DMA
STX $0733
;LDA #$01
;STA $0748  ; sinalizar que o sprite teve DMA nesse frame
;BRA +
Animeframerate:

;STZ $0748 
;+


;--------------------------------------------------
;obj extra 2
; Checando se a animação processada é a que necessita da OBJExtra2 
;------------------
LDA #$03
XBA
LDA #$00
TCD           ; Transferir do A 16 bits ao Direct Page 
;manter off-screen se não utilizado
LDA #$80
STA $88
STA $8C
STA $90
STA $94
;----
a16Bit
LDA $0722
CMP #$2100
Beq +
brl ++++
+
a8Bit

ldy #$0000
ldx #$0000
-

LDA $83
BIT #%01000000
BNE +
LDA MagicianMETA1h,y
CLC
ADC $80
STA $88,x
BRA ++
+
LDA MagicianMETA1hESPELHO,y
CLC
ADC $80
STA $88,x
++

LDA MagicianMETA1v,y
CLC
ADC $81
STA $89,x

LDA $83
STA $8B,x
TYA
CLC
ADC #$70
sta $8A,x           ; Starting tile #
INX
INX
INX
INX
INY
CPY #$0004
BNE -

lda #%00001010  ; bit zero é o 9 bit (sprite fora da tela) e bit 1 é tamanho de sprite. 
sta $0508
lda #%01010000  ; bit zero é o 9 bit (sprite fora da tela) e bit 1 é tamanho de sprite. 
sta $0509
++++

a8Bit
LDA #$00      ; DP no $0000
XBA
LDA #$00
TCD           ; Transferir do A 16 bits ao Direct Page 

RTS
	
Sprite32dmaORIGEM:
.dw $0600, $0400, $0200, $0000, $FE00, $FC00
Sprite32dmaVRAM:
.dw $0300, $0200, $0100, $0000, $FF00, $FE00

Andaranimation:
.dw $0000, $0100, $0800, $0900, $1000, $1100

Ataqueanimation:
.dw $2000, $2100, $2800, $0000, $0000, $0000

AtaqueCimaanimation:
.dw $2900, $3000, $3100, $0000, $0000, $0000
