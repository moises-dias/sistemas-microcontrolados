


		AREA    |.text|, CODE, READONLY, ALIGN=2
	    THUMB                        ; Instruções do tipo Thumb-2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT InterruptInit            ; Permite chamar GPIO_Init de outro arquivo
		EXPORT GPIOPortJ_Handler
			
		IMPORT Port_Output
			
InterruptInit
	
		LDR R0, =0x40060410					; GPIO_PORTJ_AHB_IM_R
		LDR R1, [R0]
		BIC R1, R1, #2_11					; DESATIVANDO INTERRUPT NAS PORTAS J0 E J1
		STR R1, [R0]
		
		LDR R0, =0x40060404					; SETANDO AS PORTAS J0 E J1 SENSIVEIS A BORDA - GPIO_PORTJ_AHB_IS_R
		LDR R1, [R0]
		BIC R1, R1, #2_11
		STR R1, [R0]
		
		LDR R0, =0x40060408					; SETANDO 1 BORDA DE INTERRUPT PARA PORTAS J0 E J1 - GPIO_PORTJ_AHB_IBE_R
		LDR R1, [R0]
		BIC R1, R1, #2_11
		STR R1, [R0]
		
		LDR R0, =0x4006040C					; SETANDO AS PORTAS J0 COMO BORDA DE SUBIDA E J1 COMO BORDA DE DESCIDA - GPIO_PORTJ_AHB_IEV_R
		LDR R1, [R0]
		BIC R1, R1, #2_11
		ORR R1, R1, #2_10
		STR R1, [R0]
		
		LDR R0, =0x4006041C					; LIMPANDO INTERRUPTS DAS PORTAS J0 E J1 - GPIO_PORTJ_AHB_ICR_R
		LDR R1, [R0]
		ORR R1, R1, #2_11
		STR R1, [R0]
		
		LDR R0, =0x40060410					; ATIVANDO INTERRUPT NAS PORTAS J0 E J1 - GPIO_PORTJ_AHB_IM_R
		LDR R1, [R0]
		ORR R1, R1, #2_11						
		STR R1, [R0]
		
		LDR R0, =0xE000E104        			; ATIVAR FONTE DE INTERRUPT NA PORTA J
        LDR R1, [R0]
		MOV R2, #1
        ORR R1, R1, R2, LSL#19
        STR R1, [R0]
		
		LDR R0, =0xE000E430					; SETANDO PRIORIDADE - NVIC_EN1_R
		LDR R1, [R0]
		MOV R2, #3
		ORR R1, R1, R2, LSL#29
		STR R1, [R0]
		
		BX LR

GPIOPortJ_Handler
			
		LDR R0, =0x40060414					; LENDO GPIORIS - GPIO_PORTJ_AHB_RIS_R
		LDR R1, [R0]
		ANDS R0, R1, #2_001					; LENDO SE A PORTA J0 TEVE INTERRUPT, SE NÃO, DA BRANCH
		
		PUSH{LR}
		BL Port_Output
		POP{LR}
		
		LDR R0, =0x4006041C					; LIMPANDO INTERRUPTS DAS PORTAS J0 E J1 - GPIO_PORTJ_AHB_ICR_R
		LDR R1, [R0]
		ORR R1, R1, #2_11
		MOV R1, #2_11
		STR R1, [R0]
		
		BX LR
		
		ALIGN                        ;Garante que o fim da seção está alinhada 
		END                          ;Fim do arquivo