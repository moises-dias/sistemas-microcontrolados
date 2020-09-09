; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>

; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		
; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2
;NUMEROS	DCB		19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
;NUMEROS		DCB		203,237,193,43,211,3,203,5,127,157,237,241,19,0
		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s								
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>

; -------------------------------------------------------------------------------
; Função main()
INICIO_LISTA EQU 0x20000000
INICIO_LISTA_PRIMOS EQU 0x20000100
Start  
; Comece o código aqui <======================================================
	LDR R0, =NUMEROS				; R0 aponta para o início da lista desordenada
	MOV R1, #INICIO_LISTA			; R1 aponta para o endereço inicial para armazenar os primos
	MOV R3, #0						; R3 vai apontar para o fim da lista de numeros na RAM
	MOV R7, #0						; R7 vai apontar para o fim da lista de primos
	
popular_ram
	LDRB R2, [R0], #1				; carrega um elemento da lista desordenada em R2 e itera o ponteiro da lista
	CMP R2, #0						; compara o numero que veio da lista desordenada com zero
	BEQ fim_popular_ram				; se R2 = 0, o ultimo elemento, termina de popular a RAM
	MOV R3, R1						; guarda o endereço do ultimo numero salvo na RAM
	STRB R2, [R1], #1				; salva o numero da lista desordenada numa posição da RAM e itera o ponteiro da RAM
	B popular_ram
	
fim_popular_ram
	MOV R0, #INICIO_LISTA			; R0 guarda a posição inicial dos numeros na RAM
	;MOV R1, #INICIO_LISTA_PRIMOS	; R1 guarda a posição inicial dos numeros primos que serão salvos
	ADD R1, R0, #0x100				; R1 guarda a posição inicial dos numeros primos que serão salvos
	CMP R3, #0						; se R3 for zero, nenhum numero foi colocado na lista inicial na RAM
	BEQ fim
	
filtrar_primos
	CMP R0, R3						; se R0, que aponta para a fila for maior que R3, que é o fim da fila, vai para o sort
	BHI fim_filtrar_primos
	LDRB R2, [R0], #1				; coloca em R2 o primeiro elemento da lista de numeros e itera o ponteiro
	CMP R2, #2						; se o numero for <= 2, não é primo, escolher o próximo
	BLS filtrar_primos
	MOV R5, #2						; R5 vai ser usado para dividir o candidato a primo, até R5 ser maior que R4/2
	UDIV R4, R2, R5					; R4 guarda metade do numero que vai ser checado se é primo

checar_primo
	UDIV R6, R2, R5
	MLS R6, R6, R5, R2				; R6 guarda o resto da divisão do candidato a primo (R2) por R5
	CMP R6, #0		
	BEQ filtrar_primos				; se o resto da divisão por R5 for zero, não é primo
	ADD R5, R5, #1					; itera R5 até R5 > R4
	CMP R4, R5
	BHI checar_primo
	MOV R7, R1						; guarda o endereço do ultimo primo armazenado na lista de primos
	STRB R2, [R1], #1				; se R2 não é divisível por qualquer numero entre 2 e R2/2, ele é primo
	B filtrar_primos
	
fim_filtrar_primos
	;MOV R0, #INICIO_LISTA_PRIMOS	; R0 guarda a posição inicial da lista de primos
	MOV R0, #INICIO_LISTA			; R0 guarda a posição inicial da lista de primos
	ADD R0, R0, #0x100
	MOV R1, R0						; R1 vai guardar uma referência para o início da lista de primos

bubble_sort
	CMP R0, R7						; compara se R7 já chegou no começo da lista
	BEQ fim
	MOV R2, R0						; guarda uma referência para o primeiro elemento da comparação
	LDRB R3, [R0], #1				; pega um elemento da lista de primos e itera o ponteiro
	LDRB R4, [R0]					; pega o proximo elemento sem iterar
	
	CMP R3, R4
	
	ITTE HI							; se R3 for maior que R4:
		STRBHI R3, [R0]				; troca a posição de R3 e R4, os dois elementos da comparação do bubble sort
		STRBHI R4, [R2]
		NOPLS
		
	CMP R0, R7						; checa se R0 já chegou no fim da fila de primos
	
	ITTE EQ							; se R0 chegou no fim da fila:
		MOVEQ R0, R1				; reseta o início da fila
		SUBEQ R7, R7, #1			; remove um índice do ponteiro do fim da fila
		NOPNE
	B bubble_sort
		
fim
	NOP
NUMEROS		DCB		193,63,176,127,43,19,211,3,203,5,21,127,206,245,157,237,241,105,252,19,0

    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
