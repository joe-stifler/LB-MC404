.globl _start

.data

input_buffer:   .skip 32
output_buffer:  .skip 32

.text
.align 4

@ Funcao inicial
_start:
    @ Chama a funcao "read" para ler 4 caracteres da entrada padrao
    ldr r0, =input_buffer
    mov r1, #5             @ 4 caracteres + '\n'
    bl  read
    mov r4, r0             @ copia o retorno para r4.

    @ Chama a funcao "atoi" para converter a string para um numero
    ldr r0, =input_buffer
    mov r1, r4
    bl  atoi

    @ Chama a funcao "encode" para codificar o valor de r0 usando
    @ o codigo de hamming.
    bl  encode
    mov r4, r0             @ copia o retorno para r4.

    @ Chama a funcao "itoa" para converter o valor codificado
    @ para uma sequencia de caracteres '0's e '1's
    ldr r0, =output_buffer
    mov r1, #7
    mov r2, r4
    bl  itoa

    @ Adiciona o caractere '\n' ao final da sequencia (byte 7)
    ldr r0, =output_buffer
    mov r1, #'\n'
    strb r1, [r0, #7]

    @ Chama a funcao write para escrever os 7 caracteres e
    @ o '\n' na saida padrao.
    ldr r0, =output_buffer
    mov r1, #8         @ 7 caracteres + '\n'
    bl  write

    @ <<<<< decode >>>>>
    @ Chama a funcao "read" para ler 7 caracteres da entrada padrao
    ldr r0, =input_buffer
    mov r1, #8             @ 7 caracteres + '\n'
    bl  read
    mov r4, r0             @ copia o retorno para r4.

    @ Chama a funcao "atoi" para converter a string para um numero
    ldr r0, =input_buffer
    mov r1, r4
    bl  atoi

    @ Chama a funcao "decode" para codificar o valor de r0 usando
    @ o codigo de hamming.
    bl  decode
    mov r4, r0             @ copia o retorno r0 para r4.
    mov r5, r1		   @ copia o retorno r1 para r5.

    @ Chama a funcao "itoa" para converter o valor codificado
    @ para uma sequencia de caracteres '0's e '1's
    ldr r0, =output_buffer
    mov r1, #4
    mov r2, r4
    bl  itoa

    @ Adiciona o caractere '\n' ao final da sequencia (byte 4)
    ldr r0, =output_buffer
    mov r1, #'\n'
    strb r1, [r0, #4]

    @ <<<<< escreve r0 na saida >>>>>
    @ Chama a funcao write para escrever os 4 caracteres e
    @ o '\n' na saida padrao.
    ldr r0, =output_buffer
    mov r1, #5         @ 4 caracteres + '\n'
    bl  write

    @ <<<<< escreve r1 na saida >>>>>
    @ Chama a funcao "itoa" para converter o valor codificado
    @ para uma sequencia de caracteres '0's e '1's
    ldr r0, =output_buffer
    mov r1, #1
    mov r2, r5
    bl  itoa

    @ Adiciona o caractere '\n' ao final da sequencia (byte 1)
    ldr r0, =output_buffer
    mov r1, #'\n'
    strb r1, [r0, #1]

    @ Chama a funcao write para escrever o 1 caractere e
    @ o '\n' na saida padrao.
    ldr r0, =output_buffer
    mov r1, #2         @ 1 caracteres + '\n'
    bl  write

    @ Chama a funcao exit para finalizar processo.
    mov r0, #0
    bl  exit

@ Codifica o valor de entrada usando o codigo de hamming.
@ parametros:
@  r0: valor de entrada (4 bits menos significativos)
@ retorno:
@  r0: valor codificado (7 bits como especificado no enunciado).
encode:
       push {r4-r11, lr}

       and r8, r0, #1   @ captura bit d4

       and r7, r0, #2	@ captura bit d3
       mov r7, r7, lsr #1	@ move d3 um bit pra direita

       and r6, r0, #4	@ captura bit d2
       mov r6, r6, lsr #2	@ move d2 dois bits pra direita

       and r5, r0, #8   @ captura bit d1
       mov r5, r5, lsr #3	@ move d1 tres bits pra direita

       mov r0, #0	@ limpa r0

       eor r9, r5, r6	@ d1 xor d2
       eor r9, r9, r8 	@ d1 xor d2 xor d4

       mov r9, r9, lsl #6	@ move possivel bit pra setima posicao

       orr r0, r0, r9	@ seta possivel setimo bit na resposta

       eor r9, r5, r7 @ d1 xor d3
       eor r9, r9, r8 @ d1 xor d3 xor d4

       mov r9, r9, lsl #5	@ move possivel bit pra sexta posicao

       orr r0, r0, r9	@ seta possivel sexto bit na resposta

       eor r9, r6, r7	@ d2 xor d3
       eor r9, r9, r8	@ d2 xor d3 xor d4

       mov r9, r9, lsl #3	@ move possivel bit pra quarta posicao

       orr r0, r0, r9	@ seta possivel quarto bit na resposta

       orr r0, r0, r5, lsl #4	@ seta d1 na resposta
       orr r0, r0, r6, lsl #2	@ seta d2 na resposta
       orr r0, r0, r7, lsl #1	@ seta d3 na resposta
       orr r0, r0, r8	@ seta d4 na resposta

       @ mov r0, #7

       pop  {r4-r11, lr}
       mov  pc, lr

@ Decodifica o valor de entrada usando o codigo de hamming.
@ parametros:
@  r0: valor de entrada (7 bits menos significativos)
@ retorno:
@  r0: valor decodificado (4 bits como especificado no enunciado).
@  r1: 1 se houve erro e 0 se nao houve.
decode:
       push {r4-r11, lr}

       and r8, r0, #1   @ captura bit d4

       and r7, r0, #2	@ captura bit d3
       mov r7, r7, lsr #1	@ move d3 um bit pra direita

       and r6, r0, #4	@ captura bit d2
       mov r6, r6, lsr #2	@ move d2 dois bits pra direita

       and r5, r0, #16   @ captura bit d1
       mov r5, r5, lsr #4	@ move d1 quatro bits pra direita

       @ isola p1
       and r9, r0, #64
       @ em seguida, reconstroi o p1 a partir de d1,d2,d3
       eor r10, r5, r6	@ d1 xor d2
       eor r10, r10, r8 	@ d1 xor d2 xor d4
       mov r10, r10, lsl #6	@ move possivel bit pra setima posicao

       @ caso r9 seja diferente de r10, houve erro
       eor r1, r9, r10

       @ isola p2
       and r9, r0, #32
       @ em seguida, reconstroi o p2 a partir de d1,d3,d4
       eor r10, r5, r7	@ d1 xor d3
       eor r10, r10, r8 	@ d1 xor d3 xor d4
       mov r10, r10, lsl #5	@ move possivel bit pra sexta posicao

       @ caso r9 seja diferente de r10, houve erro
       eor r9, r9, r10
       orr r1, r9

       @ isola p3
       and r9, r0, #16
       @ em seguida, reconstroi o p3 a partir de d2,d3,d4
       eor r10, r6, r7	@ d2 xor d3
       eor r10, r10, r8 	@ d2 xor d3 xor d4
       mov r10, r10, lsl #3	@ move possivel bit pra quarta posicao

       @ caso r9 seja diferente de r10, houve erro
       eor r9, r9, r10
       orr r1, r9

       @ reconstroi r0, com 4 bits: d1 d2 d3 d4
       mov r0, #0		@ limpa r0
       mov r0, r8		@ seta d4 na resposta
       orr r0, r0, r7, lsl #1	@ seta d3 na resposta
       orr r0, r0, r6, lsl #2	@ seta d2 na resposta
       orr r0, r0, r5, lsl #3	@ seta d1 na resposta

       pop  {r4-r11, lr}
       mov  pc, lr

@ Le uma sequencia de bytes da entrada padrao.
@ parametros:
@  r0: endereco do buffer de memoria que recebera a sequencia de bytes.
@  r1: numero maximo de bytes que pode ser lido (tamanho do buffer).
@ retorno:
@  r0: numero de bytes lidos.
read:
    push {r4,r5, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #0         @ stdin file descriptor = 0
    mov r1, r4         @ endereco do buffer
    mov r2, r5         @ tamanho maximo.
    mov r7, #3         @ read
    svc 0x0
    pop {r4, r5, lr}
    mov pc, lr

@ Escreve uma sequencia de bytes na saida padrao.
@ parametros:
@  r0: endereco do buffer de memoria que contem a sequencia de bytes.
@  r1: numero de bytes a serem escritos
write:
    push {r4,r5, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #1         @ stdout file descriptor = 1
    mov r1, r4         @ endereco do buffer
    mov r2, r5         @ tamanho do buffer.
    mov r7, #4         @ write
    svc 0x0
    pop {r4, r5, lr}
    mov pc, lr

@ Finaliza a execucao de um processo.
@  r0: codigo de finalizacao (Zero para finalizacao correta)
exit:
    mov r7, #1         @ syscall number for exit
    svc 0x0

@ Converte uma sequencia de caracteres '0' e '1' em um numero binario
@ parametros:
@  r0: endereco do buffer de memoria que armazena a sequencia de caracteres.
@  r1: numero de caracteres a ser considerado na conversao
@ retorno:
@  r0: numero binario
atoi:
    push {r4, r5, lr}
    mov r4, r0         @ r4 == endereco do buffer de caracteres
    mov r5, r1         @ r5 == numero de caracteres a ser considerado
    mov r0, #0         @ number = 0
    mov r1, #0         @ loop indice
atoi_loop:
    cmp r1, r5         @ se indice == tamanho maximo
    beq atoi_end       @ finaliza conversao
    mov r0, r0, lsl #1
    ldrb r2, [r4, r1]
    cmp r2, #'0'       @ identifica bit
    orrne r0, r0, #1
    add r1, r1, #1     @ indice++
    b atoi_loop
atoi_end:
    pop {r4, r5, lr}
    mov pc, lr

@ Converte um numero binario em uma sequencia de caracteres '0' e '1'
@ parametros:
@  r0: endereco do buffer de memoria que recebera a sequencia de caracteres.
@  r1: numero de caracteres a ser considerado na conversao
@  r2: numero binario
itoa:
    push {r4, r5, lr}
    mov r4, r0
itoa_loop:
    sub r1, r1, #1         @ decremento do indice
    cmp r1, #0          @ verifica se ainda ha bits a serem lidos
    blt itoa_end
    and r3, r2, #1
    cmp r3, #0
    moveq r3, #'0'      @ identifica o bit
    movne r3, #'1'
    mov r2, r2, lsr #1  @ prepara o proximo bit
    strb r3, [r4, r1]   @ escreve caractere na memoria
    b itoa_loop
itoa_end:
    pop {r4, r5, lr}
    mov pc, lr
