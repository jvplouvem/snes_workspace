/**
Now for 16x16 sprites you need to do two DMAs, one for the top half and one for the bottom half, and the tricky part is more about how your data is stored.


Well the only difference is that you DMA in the beginning of each frame (if needed). 
To do that have a queue for DMA requests that you loop through at the start of each frame and in your game logic add things to the queue if a frame needs to be updated.

Note, last entry in the queue has to have a length of zero. The loop stops if length is zero.



Para sprites 16x16, você precisa fazer dois DMAs, um para a metade superior e outro para a metade inferior, e a parte complicada é mais sobre como seus dados são armazenados.


Bem, a única diferença é que você tem que fazer DMA no início de cada quadro (se necessário).
Para fazer isso, precisa de uma fila de DMA que você percorre no início de cada quadro e, na lógica do jogo, adicione itens à fila se um quadro precisar ser atualizado.

Observe que a última entrada na fila deve ter um comprimento de zero. O loop para se o comprimento for zero.
*/



DMA_QUEUE_ENTRIES_MAX=40
DMA_QUEUE_SIZE_MAX=1024*4

.bss
; For length we add an extra entry, so we can the end of the queue
dmaQueueLength: .res (DMA_QUEUE_ENTRIES_MAX*2 + 2)
dmaQueueSource: .res (DMA_QUEUE_ENTRIES_MAX*2)
dmaQueueBank: .res (DMA_QUEUE_ENTRIES_MAX*2)
dmaQueueDest: .res (DMA_QUEUE_ENTRIES_MAX*2)
dmaQueueIndex: .res 2
dmaQueueSize: .res 2

.segment "CODE0"

.proc DmaInit
; Initialises DMA
; -
    .a8
    .i16
    A16
    stz dmaQueueIndex
    stz dmaQueueLength
    stz dmaQueueSize
    A8
    rts
.endproc

.proc DmaFlush
; Flushes the DMA queue. Should be called during forced VBLANK.
; Destroys: X
    .a8
    .i16
    php
    phd
    AXY8
    lda #V_INC_1
    sta VMAIN
    ldx #0
    A16
    lda #$4300
    tcd
    lda #$1801
    sta z:0
    loop:
    	lda dmaQueueSource, X
        sta z:2
        lda dmaQueueBank, X
        sta z:4
        lda dmaQueueLength, X
        beq done
        sta z:5
        lda dmaQueueDest, X
        sta VMADDL
        lda #1
        sta MDMAEN
        inx
        inx
        bra loop
    done:
    stz dmaQueueLength
    stz dmaQueueIndex
    stz dmaQueueSize
    pld
    plp
    rts
.endproc