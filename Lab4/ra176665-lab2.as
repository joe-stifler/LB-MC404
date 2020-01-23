.org 0x000
    LOAD MQ,M(gravidade)
    MUL M(var_x)
    LOAD MQ
    RSH
    STOR M(resposta)
laco:
    LOAD MQ, M(gravidade)
    MUL M(var_x)
    LOAD MQ
    DIV M(resposta)
    LOAD MQ
    ADD M(resposta)
    RSH
    STOR M(resposta)
    LOAD M(contador)
    SUB M(constante)
    STOR M(contador)
    JUMP+ M(laco)

    LOAD M(resposta)
    JUMP M(0x400)

.org 0x101
contador:
    .word 0x09
constante:
    .word 0x01
gravidade:
    .word 0x0A
resposta:
    .skip 0x01
var_x:
    .skip 0x01
