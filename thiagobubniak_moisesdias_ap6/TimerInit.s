


		AREA    |.text|, CODE, READONLY, ALIGN=2
	    THUMB                        ; Instruções do tipo Thumb-2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT TimerInit            ; Permite chamar GPIO_Init de outro arquivo
			
TimerInit
		LDR R0, =0x400FE604			; SYSCTL_RCGCTIMER_R
		LDR R1, [R0]
		ORR R1, #2_100
		STR R1, [R0]
		
		LDR R0, =0x400FEA04			; SYSCTL_PRTIMER_R
		LDR R1, [R0]

conferir		
		ANDS R1, #2_100
		BEQ conferir
		
		LDR R0, =0x4003200C			; TIMER2_CTL_R
		LDR R1, [R0]
		BIC R1, #2_1						; DESATIVA TIMER
		STR R1, [R0]

		LDR R0, =0x40032000			; TIMER2_CFG_R
		LDR R1, [R0]
		BIC R1, #2_111						; SETA PRA 32 BITS
		STR R1, [R0]

		LDR R0, =0x40032004 		; TIMER2_TAMR_R
		LDR R1, [R0]
		ORR R1, #2_10						; EDGE-TIME MODE
		STR R1, [R0]
	
		LDR R0, =0x40032028			; TIMER2_TAILR_R
		LDR R1, [R0]
		LDR R1, =0x039386FF					; CARREGA VALOR PARA O COUNTER
		STR R1, [R0]

		LDR R0, =0x40032038			; TIMER2_TAPR_R
		MOV R1, #0							; CARREGA VALOR NO PRESCALE
		STR R1, [R0]

		LDR R0, =0x40032024			; TIMER2_ICR_R
		LDR R1, [R0]
		ORR R1, #2_1						; INTERRUPT CLEAR
		STR R1, [R0]

		LDR R0, =0x40032018			; TIMER2_IMR_R
		LDR R1, [R0]
		ORR R1, #2_1						; INTERRUPT ENABLE
		STR R1, [R0]
		
		LDR R0, =0xE000E414			; NVIC_PRI5_R
		LDR R1, [R0]
		MOV R2, #2_111						; LIGA INTERRUPT DO TIMER NO NVIC
		BIC R1, R2, LSL #29
		MOV R2, #2_100
		ORR R1, R2, LSL #29
		STR R1, [R0]

		LDR R0, =0xE000E100			; NVIC_EN0_R
		LDR R1, [R0]
		MOV R2, #2_1						; SETA INTERRUPT DO TIMER NO NVIC
		ORR R1, R2, LSL #23
		STR R1, [R0]

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
			
			
		BX LR
	
		ALIGN                        ;Garante que o fim da seção está alinhada 
		END                          ;Fim do arquivo