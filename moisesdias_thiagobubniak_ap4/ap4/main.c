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
void Port_Output(uint32_t N, uint32_t F);
void Pisca_leds(void);
void InterruptInit(void);

char flag = 0;

typedef enum estSemaforo
{
	s_vm_vm_init,
	s_vm_vd,
	s_vm_am,
	s_vm_vm,
	s_vd_vm,
	s_am_vm,
	s_pisca
} estadosSemaforo;

estadosSemaforo estado = s_vm_vm_init;

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	InterruptInit();
	
	while (1)
	{
		
		
		switch(estado) {
			case s_vm_vm_init:
				if(flag){
					estado = s_pisca;
				}
				else {
					Port_Output(0x3, 0x11);
					SysTick_Wait1ms(1000);
					estado = s_vm_vd;
				}
				break;
			case s_vm_vd:
				Port_Output(0x3, 0x10);
				SysTick_Wait1ms(6000);
				estado = s_vm_am;
				break;
			case s_vm_am:
				Port_Output(0x3, 0x1);
				SysTick_Wait1ms(2000);
				estado = s_vm_vm; 
				break;
			case s_vm_vm:
				Port_Output(0x3, 0x11);
				SysTick_Wait1ms(1000);
				estado = s_vd_vm;
				break;
			case s_vd_vm:
				Port_Output(0x2, 0x11);
				SysTick_Wait1ms(6000);
				estado = s_am_vm;
				break;
			case s_am_vm:
				Port_Output(0x1, 0x11);
				SysTick_Wait1ms(2000);
				estado = s_vm_vm_init;
				break;
			case s_pisca:
				Pisca_leds();
				flag = 0;
				estado = s_vm_vd;
				break;
		}
 
	}
}

void Pisca_leds(void)
{
	//char i = 0;
	for(char i = 0; i < 10; i++) {
		Port_Output(0x1, 0x1);
		SysTick_Wait1ms(250);
		Port_Output(0x2, 0x10);
		SysTick_Wait1ms(250);
	}
}

void GPIOPortJ_Handler(void) 
{
	flag = 1;
	GPIO_PORTJ_AHB_ICR_R |= 0x3;
}



