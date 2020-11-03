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

float dutycycle = 50.0;
int ticksFor1ms = 79999;

void UARTinit()
{
	// CONFIGURANDO A UART 0
	SYSCTL_RCGCUART_R |= (1 << 0); 	// Ativa o clock da uart 0
	while(!(SYSCTL_PRUART_R && (1<<0))); // Le bit 0 do PRUART até o UART ficar pronto (1)
	UART0_CTL_R &= ~(1 << 0);  // Desativa UART 0 para configuração
	
	UART0_IBRD_R = 260; // Configurando BaudRate de 19200
	UART0_FBRD_R = 27;
	
	UART0_LCRH_R &= ~0xFF; //~0b11111111;
	UART0_LCRH_R |= 0x72; //0b01110010; // 8-bits word lenght (6:5), FIFO Enable (4), Bit parity enable (1)
	
	UART0_CC_R &= 0xF; //~0b1111; // Bit clear para setar clock como clock do processador
	
	UART0_CTL_R |= (1 << 9) & (1 << 8) & (1 << 0);  // Setar RXE, TXE e UARTEN
	
	
	// Configurar GPIO PA0 e PA1 Pois são os pinos de read e send da UART
	SYSCTL_RCGCGPIO_R |= (1 << 0); // Ligando clk para o GPIO Port A
	
	while(SYSCTL_PRGPIO_R & (1 << 0)); // Espera enquanto a UART Port A não fica pronto
	
	GPIO_PORTA_AHB_AMSEL_R = 0x00; // Limpa o AMSEL para desabilitar modo analógico
	
	GPIO_PORTA_AHB_PCTL_R = 0x11; // Seta esses 2 pinos como U0Rx e U0Tx
	
	GPIO_PORTA_AHB_AFSEL_R =  0x03; // Seta pino 0 (PA0) e pino 1 (PA1) associados à periféricos
	
	GPIO_PORTA_AHB_DEN_R = 0x03; // Seta PA0 e PA1 como digitais
	
}
// #define UART0_FR_R              (*((volatile uint32_t *)0x4000C018))
// #define UART0_DR_R              (*((volatile uint32_t *)0x4000C000))
char receive_char(void) {
	while((UART0_FR_R & 0x10) == 1);
	return UART0_DR_R & 0xFF;
}

void send_char(char c) {
	while((UART0_FR_R & 0x20) == 1);
	UART0_DR_R &= ~0xFF;
	UART0_DR_R |= c;
}

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	InterruptInit();
	TimerInit();
	
	// Desliga, configura o load e liga
	TIMER2_CTL_R &= ~(1 << 0); // BIT CLEAR
	TIMER2_TAILR_R = ticksFor1ms * (dutycycle / 100.0);
	TIMER2_CTL_R |= (1 << 0); // BIT SET
	
	
	char test = 'a';
	send_char(test);
	while (1)
	{
			
	}
}


void Timer2A_Handler(void)
{
	// Desliga o timer
	TIMER2_CTL_R &= ~(1 << 0); // BIT CLEAR
	
	// Reconfigura Load do Timer
	TIMER2_TAILR_R = (ticksFor1ms - TIMER2_TAILR_R);
	
	// Liga o timer
	TIMER2_CTL_R |= (1 << 0); // BIT SET
	
	
	Port_Output();
	TIMER2_ICR_R |= 0x1;
}

