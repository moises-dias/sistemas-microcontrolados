// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>
#include "tm4c1294ncpdt.h"

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);
uint32_t PortJ_Input(void);
void Port_Output(void);
void Pisca_leds(void);
void InterruptInit(void);
void TimerInit(void);

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	InterruptInit();
	TimerInit();
	
	while (1)
	{

	}
}

void GPIOPortJ_Handler(void) 
{
	GPIO_PORTJ_AHB_ICR_R |= 0x3;
	TIMER2_CTL_R ^= (0x1);
}

void Timer2A_Handler(void)
{
	Port_Output();
	TIMER2_ICR_R |= 0x1;
}


