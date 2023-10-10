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

;Muito grande esse aqui meo, precisa de um banco pra ele.

;.BANK 2 SLOT 0
;.ORG 0
;.SECTION "BancodosGraficos2" SEMIFREE
.segment "RODATA2"
DMAMagician:
.incbin "GFX/MLmagocompacto.bin"

DMAExplosao:
.incbin "GFX/Explosao.bin"