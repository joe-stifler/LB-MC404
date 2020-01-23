@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Codigo de exemplo para controle basico de um robo.
@ Este codigo le os valores de 2 sonares frontais para decidir se o
@ robo deve parar ou seguir em frente.
@ 2 syscalls serao utilizadas para controlar o robo:
@   write_motors  (syscall de numero 124)
@                 Parametros:
@                       r0 : velocidade para o motor 0  (valor de 6 bits)
@                       r1 : velocidade para o motor 1  (valor de 6 bits)
@
@  read_sonar (syscall de numero 125)
@                 Parametros:
@                       r0 : identificador do sonar   (valor de 4 bits)
@                 Retorno:
@                       r0 : distancia capturada pelo sonar consultado (valor de 12 bits)
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

        
.text
.align 4
.globl _start

_start:                         @ main
        
        mov r8, #20				@ velocidade inicial dos motores
        
        mov r0, r8              @ Carrega em r0 a velocidade do motor 0.
                                @ Lembre-se: apenas os 6 bits menos significativos
                                @ serao utilizados.
        mov r1, r8              @ Carrega em r1 a velocidade do motor 1.
        mov r7, #124            @ Identifica a syscall 124 (write_motors).
        svc 0x0                 @ Faz a chamada da syscall.

        ldr r6, =1200           @ r6 <- 1200 (Limiar para parar o robo)
		
loop:        
        mov r0, #3              @ Define em r0 o identificador do sonar a ser consultado.
        mov r7, #125            @ Identifica a syscall 125 (read_sonar).
        svc 0x0                 
        mov r5, r0              @ Armazena o retorno da syscall.

        mov r0, #4              @ Define em r0 o sonar.
        mov r7, #125
        svc 0x0

		cmp r5, r6
		blt gira_horario
	
	    sonar4_cmp:
		    cmp r0, r6              @ Compara r0 com r6
		    blt gira_antihorario    @ Se r0 menor que o limiar: Salta para gira_antihorario

        
        mov r0, r8	@ Senao define uma velocidade para os 2 motores
        mov r1, r8
        mov r7, #124        
        svc 0x0

        b loop                  @ Refaz toda a logica

gira_horario:
        mov r0, #20	@ travo motor 3
        mov r1, #0	@ seto velocidade de motor 4 pra 10
        mov r7, #124
        svc 0x0

		mov r0, #3              @ Define em r0 o identificador do sonar a ser consultado.
        mov r7, #125            @ Identifica a syscall 125 (read_sonar).
        svc 0x0                 
        mov r5, r0              @ Armazena o retorno da syscall.

        mov r0, #4              @ Define em r0 o sonar.
        mov r7, #125
        svc 0x0
        
        cmp r5, r6				@ se sensores retornarem valores menores que limiar: continua girando
        blt gira_horario
        
        cmp r0, r6				
        blt gira_horario
        
        b loop
        
gira_antihorario:
        mov r0, #0	@ seto velocidade de motor 3 pra 10
        mov r1, #20	@ travo motor 4
        mov r7, #124
        svc 0x0
        
        mov r0, #3              @ Define em r0 o identificador do sonar a ser consultado.
        mov r7, #125            @ Identifica a syscall 125 (read_sonar).
        svc 0x0                 
        mov r5, r0              @ Armazena o retorno da syscall.

        mov r0, #4              @ Define em r0 o sonar.
        mov r7, #125
        svc 0x0
        
        cmp r5, r6				@ se sensores retornarem valores menores que limiar: continua girando
        blt gira_antihorario
        
        cmp r0, r6
        blt gira_antihorario
               
        b loop

end:                            @ Parar o robo
        mov r0, #0              
        mov r1, #0
        mov r7, #124
        svc 0x0

        mov r7, #1              @ syscall exit
        svc 0x0


	        

