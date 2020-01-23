
@ Secao de constantes

@ Constante para os ciclos do relógio de periféricos
.set TIME_SZ,                       0x00000064

@ Constantes para os enderecos do TZIC
.set TZIC_BASE,		                0x0FFFC000
.set TZIC_INTCTRL,	                0x00000000
.set TZIC_INTSEC1,	                0x00000084
.set TZIC_ENSET1,	                0x00000104
.set TZIC_PRIOMASK,	                0x0000000C
.set TZIC_PRIORITY9,                0x00000424

@ Constantes para os enderecos do GPT
.set GPT_CR,		                0x53FA0000
.set GPT_PR,		                0x53FA0004
.set GPT_SR,		                0x53FA0008
.set GPT_IR,		                0x53FA000C
.set GPT_OCR1,		                0x53FA0010

.section .iv,"a"

_start:

INTERRUPT_VECTOR:
    .org 0x0
        b RESET_HANDLER
    .org 0x18
        b IRQ_HANDLER

.org 0x100
.text

RESET_HANDLER:
    ldr r1, =CONTADOR
    mov r0, #0                      @ Zera o contador
    str r0, [r1]

    ldr r0, =INTERRUPT_VECTOR       @ Ajusta valor do registrador que mantem
    mcr p15, 0, r0, c12, c0, 0      @   o endereco da tabela de interrupcoes

    bl SET_TZIC                     @ Configura TZIC
    bl SET_GPT                      @ Configura GPT

    ldr sp, =INICIO_PILHA_SVC

    msr CPSR_c, #0x12               @ Muda para o modo IRQ
    ldr sp, =INICIO_PILHA_IRQ       @ Configura inicio da pilha do modo IRQ

    msr CPSR_c, #0x11               @ Muda para o modo FIQ
    ldr sp, =INICIO_PILHA_FIQ       @ Configura inicio da pilha do modo IRQ

    msr CPSR_c, #0x10	            @ Muda para o modo usuario, habilitando interrupcoes

    @ldr r0, =0x77802000             @ .text do codigo usuario deve comecar em 0x77802000
    @blx r0

    laco:
        b laco                      @ Apos termino de execucao do codigo do usuario,
                                    @   entra em laco infinito e espera por uma interrupcao

SET_TZIC:
    ldr r1, =TZIC_BASE              @ Liga o controlador de interrupcoes

    mov r0, #(1 << 7)               @ Configura interrupcao 39 do GPT como nao segura
    str r0, [r1, #TZIC_INTSEC1]

    mov r0, #(1 << 7)               @ Habilita interrupcao 39 (GPT)
    str r0, [r1, #TZIC_ENSET1]

    ldr r0, [r1, #TZIC_PRIORITY9]
    bic r0, r0, #0xFF000000
    mov r2, #1                      @ Configure interrupt39 priority como 1
    orr r0, r0, r2, lsl #24
    str r0, [r1, #TZIC_PRIORITY9]

    eor r0, r0, r0                  @ Configure PRIOMASK as 0
    str r0, [r1, #TZIC_PRIOMASK]

    mov r0, #1                      @ Habilita o controlador de interrupcoes
    str r0, [r1, #TZIC_INTCTRL]

    mov pc, lr

SET_GPT:
    ldr r1, =GPT_CR
    mov r0, #0x41                   @ Inicializo o control register com 0x41
    str r0, [r1]

    ldr r1, =GPT_PR
    mov r0, #0                      @ Inicializo o prescaler register com 0x0
    str r0, [r1]

    ldr r1, =GPT_IR
    mov r0, #1                      @ Demonstra interesse na interrupcao
    str r0, [r1]                    @   do tipo Output Compare Channel 1

    ldr r1, =GPT_OCR1
    ldr r0, =TIME_SZ                @ Configura o GPT para contar ateh TIME_SZ
    str r0, [r1]

    mov pc, lr

IRQ_HANDLER:
    sub	lr, lr, #4                  @ Recupera valor correto de pc
    push {r0, r1, lr}

    ldr r1, =GPT_SR
    mov r0, #1                      @ Indica para o GPT, pelo registrador de status,
    str r0, [r1]                    @   que o processador estah ciente da interrupcao

    ldr r1, =CONTADOR
    ldr r0, [r1]
    add r0, r0, #1                  @ Incrementa no registrador
    str r0, [r1]

    pop {r0, r1, lr}
    movs pc, lr                     @ retorna ao estado antigo

@ Secao de dados

.data
    CONTADOR: .skip 4

    INICIO_PILHA_SVC: .skip 4096
    INICIO_PILHA_IRQ: .skip 4096    @ espaco para 4 Kb, ou 1024 posicoes de registradores
    INICIO_PILHA_FIQ: .skip 4096
