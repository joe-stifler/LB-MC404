.global ajudaORobinson

.data   @ secao de dados

xlocal: .skip 4
ylocal: .skip 4

string:  .asciz "Não existe um caminho!\n"  @ saida caso a dfs nao encontre um caminho
output_buffer: .skip 4

.text
.align 4
ajudaORobinson:
    push {r0, r1, lr}

    bl posicaoXLocal
    ldr r1, =xlocal
    str r0, [r1]     @ captura posicao x de destino

    bl posicaoYLocal
    ldr r1, =ylocal
    str r0, [r1]     @ captura posicao y de destino

    bl inicializaVisitados

    bl posicaoYRobinson     @ captura posicao y inicial
    mov r1, r0

    push {r1}
    bl posicaoXRobinson     @ captura posical x inicial
    pop {r1}

    bl dfs

    cmp r0, #0
    ldreq r0, =string
    moveq r1, #23
    bleq write  @ caso a dfs nao tenha encontrado caminho, printa a string

    pop {r0, r1, pc}

@ Verifica a existencia de um caminho nas celulas vizinhas
@ parametros:
@   r0: posicao x atual do robinson
@   r1: posicao y atual do robinson
@ retorno:
@   r0: 1 caso tenha encontrado um caminho e 0 do contrario
dfs:
    push {r2-r4, lr}

    push {r0, r1}
    bl visitaCelula   @ pinta a celula atual, indicando que a mesma esta sendo visitada
    pop {r0, r1}

    ldr r4, =xlocal
    ldr r2, [r4]
    ldr r4, =ylocal
    ldr r3, [r4]

    cmp r0, r2
    bne saltoFrente   @ caso xAtual != xlocal, continua com a dfs
    cmp r1, r3
    moveq r0, #1    @ caso xAtual == xLocal e yAtual == yLocal, sai da dfs retornando 1
    beq printCoordenadas

    saltoFrente:
        mov r2, r0
        mov r3, r1
        add r0, #1  @ atualizo celula (x + 1, y)

        push {r2, r3}
        bl daParaPassar @ e verifico a existencia de caminho
        pop {r2, r3}
        cmp r0, #0
        beq saltoBaixo  @ pula pra proxima celula caso a atual esteja bloqueada

        mov r0, r2
        mov r1, r3
        add r0, #1  @ atualizo celula (x + 1, y)

        push {r2, r3}
        bl foiVisitado
        pop {r2, r3}
        cmp r0, #1
        beq saltoBaixo  @ pula pra proxima celula caso a atual jah tenha sido visitada

        mov r0, r2
        mov r1, r3
        add r0, #1  @ atualizo celula (x + 1, y)

        bl dfs  @ caso tenha caminho e celula nao foi visitada, tenta visita-la
        cmp r0, #1
        beq printCoordenadas @ caso o retorno de dfs seja 1, pula pro fim pois um caminho foi encontrado

    saltoBaixo:
        mov r0, r2
        mov r1, r3
        add r1, #1  @ atualizo celula (x, y + 1)

        push {r2, r3}
        bl daParaPassar @ e verifico a existencia de caminho
        pop {r2, r3}
        cmp r0, #0
        beq saltoCima  @ pula pra proxima celula caso a atual esteja bloqueada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        add r1, #1  @ atualizo celula (x, y + 1)

        push {r2, r3}
        bl foiVisitado
        pop {r2, r3}
        cmp r0, #1
        beq saltoCima  @ pula pra proxima celula caso a atual jah tenha sido visitada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        add r1, #1  @ atualizo celula (x, y + 1)

        bl dfs  @ caso tenha caminho e celula nao foi visitada, tenta visita-la
        cmp r0, #1
        beq printCoordenadas @ caso o retorno de dfs seja 1, pula pro fim pois um caminho foi encontrado

    saltoCima:
        mov r0, r2
        mov r1, r3
        sub r1, #1  @ atualizo celula (x, y - 1)

        push {r2, r3}
        bl daParaPassar @ e verifico a existencia de caminho
        pop {r2, r3}
        cmp r0, #0
        beq saltoTras  @ pula pra proxima celula caso a atual esteja bloqueada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        sub r1, #1  @ atualizo celula (x, y - 1)

        push {r2, r3}
        bl foiVisitado
        pop {r2, r3}
        cmp r0, #1
        beq saltoTras  @ pula pra proxima celula caso a atual jah tenha sido visitada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        sub r1, #1  @ atualizo celula (x, y - 1)

        bl dfs  @ caso tenha caminho e celula nao foi visitada, tenta visita-la
        cmp r0, #1
        beq printCoordenadas @ caso o retorno de dfs seja 1, pula pro fim pois um caminho foi encontrado

    saltoTras:
        mov r0, r2
        mov r1, r3
        sub r0, #1  @ atualizo celula (x - 1, y)

        push {r2, r3}
        bl daParaPassar @ e verifico a existencia de caminho
        pop {r2, r3}
        cmp r0, #0
        beq saltoDiagonalCimaTras  @ pula pra proxima celula caso a atual esteja bloqueada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        sub r0, #1  @ atualizo celula (x - 1, y)

        push {r2, r3}
        bl foiVisitado
        pop {r2, r3}
        cmp r0, #1
        beq saltoDiagonalCimaTras  @ pula pra proxima celula caso a atual jah tenha sido visitada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        sub r0, #1  @ atualizo celula (x - 1, y)

        push {r2, r3}
        bl dfs  @ caso tenha caminho e celula nao foi visitada, tenta visita-la
        pop {r2, r3}
        cmp r0, #1
        beq printCoordenadas @ caso o retorno de dfs seja 1, pula pro fim pois um caminho foi encontrado

    saltoDiagonalCimaTras:
        mov r0, r2
        mov r1, r3
        sub r0, #1  @ atualizo celula (x - 1, y)
        sub r1, #1  @ atualizo celula (x - 1, y - 1)

        push {r2, r3}
        bl daParaPassar @ e verifico a existencia de caminho
        pop {r2, r3}
        cmp r0, #0
        beq saltoDiagonalCimaFrente  @ pula pra proxima celula caso a atual esteja bloqueada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        sub r0, #1  @ atualizo celula (x - 1, y)
        sub r1, #1  @ atualizo celula (x - 1, y - 1)

        push {r2, r3}
        bl foiVisitado
        pop {r2, r3}
        cmp r0, #1
        beq saltoDiagonalCimaFrente  @ pula pra proxima celula caso a atual jah tenha sido visitada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        sub r0, #1  @ atualizo celula (x - 1, y)
        sub r1, #1  @ atualizo celula (x - 1, y - 1)

        bl dfs  @ caso tenha caminho e celula nao foi visitada, tenta visita-la
        cmp r0, #1
        beq printCoordenadas @ caso o retorno de dfs seja 1, pula pro fim pois um caminho foi encontrado

    saltoDiagonalCimaFrente:
        mov r0, r2
        mov r1, r3
        sub r0, #1  @ atualizo celula (x - 1, y)
        add r1, #1  @ atualizo celula (x - 1, y + 1)

        push {r2, r3}
        bl daParaPassar @ e verifico a existencia de caminho
        pop {r2, r3}
        cmp r0, #0
        beq saltoDiagonalBaixoTras  @ pula pra proxima celula caso a atual esteja bloqueada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        sub r0, #1  @ atualizo celula (x - 1, y)
        add r1, #1  @ atualizo celula (x - 1, y + 1)

        push {r2, r3}
        bl foiVisitado
        pop {r2, r3}
        cmp r0, #1
        beq saltoDiagonalBaixoTras  @ pula pra proxima celula caso a atual jah tenha sido visitada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        sub r0, #1  @ atualizo celula (x - 1, y)
        add r1, #1  @ atualizo celula (x - 1, y + 1)

        bl dfs  @ caso tenha caminho e celula nao foi visitada, tenta visita-la
        cmp r0, #1
        beq printCoordenadas @ caso o retorno de dfs seja 1, pula pro fim pois um caminho foi encontrado

    saltoDiagonalBaixoTras:
        mov r0, r2
        mov r1, r3
        add r0, #1  @ atualizo celula (x + 1, y)
        sub r1, #1  @ atualizo celula (x + 1, y - 1)

        push {r2, r3}
        bl daParaPassar @ e verifico a existencia de caminho
        pop {r2, r3}
        cmp r0, #0
        beq saltoDiagonalBaixoFrente  @ pula pra proxima celula caso a atual esteja bloqueada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        add r0, #1  @ atualizo celula (x + 1, y)
        sub r1, #1  @ atualizo celula (x + 1, y - 1)

        push {r2, r3}
        bl foiVisitado
        pop {r2, r3}
        cmp r0, #1
        beq saltoDiagonalBaixoFrente  @ pula pra proxima celula caso a atual jah tenha sido visitada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        add r0, #1  @ atualizo celula (x + 1, y)
        sub r1, #1  @ atualizo celula (x + 1, y - 1)

        bl dfs  @ caso tenha caminho e celula nao foi visitada, tenta visita-la
        cmp r0, #1
        beq printCoordenadas @ caso o retorno de dfs seja 1, pula pro fim pois um caminho foi encontrado

    saltoDiagonalBaixoFrente:
        mov r0, r2
        mov r1, r3
        add r0, #1  @ atualizo celula (x + 1, y)
        add r1, #1  @ atualizo celula (x + 1, y + 1)

        push {r2, r3}
        bl daParaPassar @ e verifico a existencia de caminho
        pop {r2, r3}
        cmp r0, #0
        beq printCoordenadas  @ pula pra proxima celula caso a atual esteja bloqueada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        add r0, #1  @ atualizo celula (x + 1, y)
        add r1, #1  @ atualizo celula (x + 1, y + 1)

        push {r2, r3}
        bl foiVisitado
        pop {r2, r3}
        cmp r0, #1
        moveq r0, #0
        beq fimDfs  @ pula pra proxima celula caso a atual jah tenha sido visitada

        @ recupera valores perdidos apos chamada de funcao
        mov r0, r2
        mov r1, r3
        add r0, #1  @ atualizo celula (x + 1, y)
        add r1, #1  @ atualizo celula (x + 1, y + 1)

        bl dfs  @ caso tenha caminho e celula nao foi visitada, tenta visita-la
        cmp r0, #1
        beq fimDfs @ caso o retorno de dfs seja 1, pula pro fim pois um caminho foi encontrado

        mov r0, #0

    printCoordenadas:
        cmp r0, #1
        bne fimDfs

        ldr r0, =output_buffer

        mov r1, #'\n'
        strb r1, [r0, #3]   @ adiciona '\n' ao final da sequencia

        mov r1, #' '
        strb r1, [r0, #1]   @ adicona ' ' no meio da sequencia

        add r2, r2, #'0'
        add r3, r3, #'0'

        strb r2, [r0, #0]   @ adiciona o valor de x na primeira posicao
        strb r3, [r0, #2]   @ adiciona o valor de y na segunda posicao

        @ Chama a funcao write para escrever a string resultante na saida padrao
        mov r1, #4
        bl  write

        mov r0, #1

    fimDfs: pop {r2-r4, pc}

@ Escreve uma sequencia de bytes na saida padrao.
@ parametros:
@  r0: endereco do buffer de memoria que contem a sequencia de bytes.
@  r1: numero de bytes a serem escritos
write:
    push {r2, r7, lr}

    mov r2, r1      @ tamanho do dado
    mov r1, r0      @ inicio do dado
    mov r0, #1      @ carrega o valor 1 em r0, indicando que a saída da
	                @ syscall write sera em stdout
    mov r7, #4      @ carrega o valor 4 para r7, indica o tipo da syscall
    svc 0x0         @ realiza uma chamada de sistema (syscall)

    pop {r2, r7, pc}
