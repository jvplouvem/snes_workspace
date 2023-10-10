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