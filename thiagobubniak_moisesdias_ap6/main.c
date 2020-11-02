// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>
#include "tm4c1294ncpdt.h"

void GPIO_Init(void);
void Port_Output(void);
void InterruptInit(void);
void TimerInit(void);

float dutycycle = 0.6;
int ticksFor1ms = 1000;

int main(void)
{
	GPIO_Init();
	InterruptInit();
	TimerInit();
	TIMER0_TAILR_R = ticksFor1ms / dutycycle;
	
	while (1)
	{
		
	/*if(tem coisa pra ler)
		{
			// Desliga o timer
			TIMER2_CTL_R = 0;
				
			// Reconfigura Load do Timer
			TIMER0_TAILR_R = ticksFor1ms / dutycycle;
				
			// Liga o timer
			TIMER2_CTL_R = 1;
			
			// Imprimir na saida o duty cycle atual
			
		}			*/
		
	}
}

void Timer2A_Handler(void)
{
	// Desliga o timer
	TIMER2_CTL_R = 0;
	
	// Reconfigura Load do Timer
	TIMER0_TAILR_R = (ticksFor1ms - TIMER0_TAILR_R);
	
	// Liga o timer
	TIMER2_CTL_R = 1;
	
	
	Port_Output();
	TIMER2_ICR_R |= 0x1;
}


