;==================================================
; Definir nomes para os espelhamento de registros.
; Nada necessário, mas facilita a leitura do código.
;==================================================

 XY_8BIT  = $10
 A_8BIT   = $20
 Counter  = $13

 BG1Hlow  = $1A
 BG1Hhigh  = $1B
 BG1Vlow  = $1C
 BG1Vhigh  = $1D

 BG2Hlow  = $10
 BG2Hhigh  = $11
 BG2Vlow  = $17
 BG2Vhigh  = $18

 BG3Hlow  = $1E
 BG3Hhigh  = $1F
 BG3Vlow  = $28
 BG3Vhigh  = $29

 ColorMath0  = $15
 ColorMath1  = $16
 Mosaico  = $E2
 Brilho  = $E3

 M7Rotation  = $36
 M7ScallingX  = $38
 M7ScallingY  = $3A
 M7LayerX  = $44
 M7LayerY  = $46

; DMA SPRITE 
;
; sta  = $60  = Qual frame carregar - 8 bits
 SP1DMAframe  = $60
; sta  = $61 = Loop para carregar todas as tiles - 8 bits
 SP1DMAloadingloop  = $61
; sty  = $62 = Offset de onde iniciar a leitura de tiles para enviar - 16 bits
 SP1DMAsourceOffset  = $62
; stx  = $64 = Tamanho do DMA por passos (quantas tiles) - 16 bits
 SP1DMAtilestotransfer  = $64
; stx  = $66 = Local do destino para os gráficos enviados - 16 bits
 SP1DMAdestinoOffset  = $66







