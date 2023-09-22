.segment "ZEROPAGE"
in_nmi: .res 2
teste_variavel: .res 2

.segment "BSS"
palette_buffer: .res 512 ;palette
palette_buffer_end:

oam_lo_buffer: .res 512 ;low table
oam_hi_buffer: .res 32 ;high table
oam_buffer_end:

