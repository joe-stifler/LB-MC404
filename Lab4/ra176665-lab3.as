.org 0x000
    LOAD M(contador)
    SUB M(constante)
    STOR M(contador)
    JUMP M(0x002)
    LOAD M(vetor1)
    STA M(end_var_vet1)
    LOAD M(vetor2)
    STA M(end_var_vet2)
    end_var_vet1:
        LOAD MQ, M(0x000)
    end_var_vet2:
        MUL M(0x000)
    LOAD MQ
    ADD M(resposta)
    STOR M(resposta)
    LOAD M(contador)
    SUB M(constante)
    STOR M(contador)
    LOAD M(vetor1)
    ADD M(constante)
    STOR M(vetor1)
    LOAD M(vetor2)
    ADD M(constante)
    STOR M(vetor2)
    LOAD M(contador)
    JUMP+ M(0x002)
    LOAD M(resposta)
    JUMP M(0x400)

.org 0x022
constante:
    .word 0x001

.org 0x025
resposta:
    .word 0x000

.org 0x3FD
vetor1:
    .skip 0x001
vetor2:
    .skip 0x001
contador:
    .skip 0x001
