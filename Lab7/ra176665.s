.globl _start

.data

input_buffer:   .skip 32
output_buffer:  .skip 32

vec:	.skip 2458624

.text
.align 4

@ Funcao inicial
_start:
    @ Chama a funcao "read" para ler 3 caracteres da entrada padrao
    ldr r0, =input_buffer
    mov r1, #4             @ 3 caracteres + '\n'
    bl  read
    mov r4, r0             @ copia o retorno para r4.

    @ Chama a funcao "atoi" para converter a string para um numero
    ldr r0, =input_buffer
    mov r1, r4
    bl  atoi
    mov r4, r0             @ copia o retorno para r4.

    @ r6 = i, r7 = j
    ldr r3, =vec	@ base
    mov r6, #0		@ i = 0
    loop_i:
        cmp r6, r4	@ i < n
        bge fim_i
	mov r7, #0	@ j = 0
        loop_j:
            cmp r7, r4	@ j < n
            bge fim_j
            mla r8, r6, r4, r7	@ r8 = i * n + j
	    mov r9, #1
	    str r9, [r3, r8, lsl #2]	@ vec[i][j] = 1
	    add r7, r7, #1
            b loop_j
        fim_j:
        add r6, r6, #1
        b loop_i
    fim_i:

    mov r6, #0	@ i = 0
    loop_i2:
        cmp r6, r4	@ i < n
        bge fim_i2
        mov r7, #0	@ j = 0
        loop_j2:
        cmp r7, r6	@ j <= i
	    bgt fim_j2

        mov r5, #1

	    cmp r7, #0
        beq print	@ if (j == 0) bl print

        cmp r7, r6
        beq print	@ if (j == i) bl print

        sub r8, r6, #1	@ r8 = i-1
	    sub r9, r7, #1	@ r9 = j-1
	    mla r9, r8, r4, r9	@ r9 = (i-1) * n + (j-1)

        ldr r5, [r3, r9, lsl #2]	@ r5 = vec[i-1][j-1]

	    mla r8, r8, r4, r7  @ r8 = (i-1) * n + j

	    ldr r9, [r3, r8, lsl #2]   @ r9 = vec[i-1][j]

	    add r5, r5, r9	@ r5 = vec[i-1][j-1] + vec[i-1][j]

        mla r8, r6, r4, r7  @ r8 = i * n + j
        str r5, [r3, r8, lsl #2]    @ vec[i][j] = r5

	    print:
            cmp r7, #0
            beq print2	@ if (r7 == 0)

            @ Adiciona o caractere ' '
            ldr r0, =output_buffer
            mov r1, #' '
            strb r1, [r0, #0]

            @ Chama a funcao write para escrever o caractere ' ' na saida padrao
            mov r1, #1
            bl  write

	    print2:
	        @ Chama a funcao "itoa" para converter o valor de r5
    	    @ para uma sequencia de caracteres
            ldr r0, =output_buffer
            mov r1, #7
            mov r2, r5
            bl  itoa

	        @ Chama a funcao write para escrever os 8 caracteres e o '\n' na saida padrao
            mov r1, #8         @ 8 caracteres
            bl  write

            add r7, r7, #1
            b loop_j2
        fim_j2:

	    @ Adiciona o caractere '\n' ou ' '
        ldr r0, =output_buffer
        mov r1, #'\n'
        strb r1, [r0, #0]

        @ Chama a funcao write para escrever o caractere '\n' na saida padrao
        mov r1, #1
        bl  write

        add r6, r6, #1
        b loop_i2
    fim_i2:

    @ Chama a funcao exit para finalizar processo.
    mov r0, #0
    bl  exit

@ Le uma sequencia de bytes da entrada padrao.
@ parametros:
@  r0: endereco do buffer de memoria que recebera a sequencia de bytes.
@  r1: numero maximo de bytes que pode ser lido (tamanho do buffer).
@ retorno:
@  r0: numero de bytes lidos.
read:
    push {r2-r9, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #0         @ stdin file descriptor = 0
    mov r1, r4         @ endereco do buffer
    mov r2, r5         @ tamanho maximo.
    mov r7, #3         @ read
    svc 0x0
    pop {r2-r9, lr}
    mov pc, lr

@ Escreve uma sequencia de bytes na saida padrao.
@ parametros:
@  r0: endereco do buffer de memoria que contem a sequencia de bytes.
@  r1: numero de bytes a serem escritos
write:
    push {r2-r9, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #1         @ stdout file descriptor = 1
    mov r1, r4         @ endereco do buffer
    mov r2, r5         @ tamanho do buffer.
    mov r7, #4         @ write
    svc 0x0
    pop {r2-r9, lr}
    mov pc, lr

@ Finaliza a execucao de um processo.
@  r0: codigo de finalizacao (Zero para finalizacao correta)
exit:
    mov r7, #1
    svc 0x0

@ Converte uma sequencia de caracteres em um numero inteiro
@ parametros:
@  r0: endereco do buffer de memoria que armazena a sequencia de caracteres.
@  r1: numero de caracteres a ser considerado na conversao
@ retorno:
@  r0: numero inteiro
atoi:
    push {r2-r9, lr}
    mov r4, r0         @ r4 == endereco do buffer de caracteres
    mov r5, r1         @ r5 == numero de caracteres a ser considerado
    mov r0, #0         @ number = 0
    mov r1, #2         @ loop indice
    mov r3, #1         @ armazenador das potencias de 16
atoi_loop:
    cmp r1, #0         @ se indice == 0
    blt atoi_end       @ finaliza conversao
    ldrb r2, [r4, r1]  @ captura caracter na posicao do indice
    cmp r2, #'9'
    suble r2, r2, #'0' @ converte para inteiro o caracter r2
    subgt r2, r2, #'A'
    addgt r2, r2, #10
    mla r0, r2, r3, r0 @ soma valor convertido ao resultado final
    mov r3, r3, lsl #4    @ atualiza valor de r3 = r3 * 16
    sub r1, r1, #1     @ indice--
    b atoi_loop
atoi_end:
    pop {r2-r9, lr}
    mov pc, lr

@ Converte um numero inteiro em uma sequencia de caracteres
@ parametros:
@  r0: endereco do buffer de memoria que recebera a sequencia de caracteres.
@  r1: numero de caracteres a ser considerado na conversao
@  r2: numero inteiro
itoa:
    push {r3-r9, lr}
    mov r4, r0
itoa_loop:
    cmp r1, #0         @ verifica se r2 pode ser divido novamente por 16
    blt itoa_end
    and r3, r2, #15    @ r3 = r2 % 16
    cmp r3, #9
    addls r3, r3, #'0' @ converte para caractere o inteiro r3
    addhi r3, r3, #'A'
    subhi r3, r3, #10
    mov r2, r2, lsr #4
    strb r3, [r4, r1]  @ escreve caractere na memoria
    sub r1, r1, #1
    b itoa_loop
itoa_end:
    pop {r3-r9, lr}
    mov pc, lr
