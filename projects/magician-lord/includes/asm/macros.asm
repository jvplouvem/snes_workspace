.macro spriteOndaHandle valor1, valor2, valor3, valor4, valor5, valor6, valor7, valor8, valor9, valor10
    repetespriteonda:
        LDA valor1
        add $436B
        STA valor2,x ; Ir adicionando o valor de $436B em H a cada loop 
        add valor3,y
        STA valor2,x ; Ir adicionando o valor da tabela em H a cada loop (levemente a frente do Y)

        LDA valor4
        add valor5,y
        STA valor6,x           ; Adicionar o valor da tabela na posição Y e incrementar

        tya
        add valor7
        sta valor8,x           ; Starting tile #

        ldaSta #%00110100, valor9,x   ; vhoopppc    v: vertical flip h: horizontal flip  o: priority bits p: palette c:GFX page

        LDA $436B
        add #$08
        STA $436B           ; Adiciona 8 para o próximo loop

        INX
        INX
        INX           ; incrementar counters
        INX
        INY
        CPY valor10
        BNE repetespriteonda
.endmacro
