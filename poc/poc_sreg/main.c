#include <avr/io.h>
#include <util/delay.h>
#include <stdlib.h>

#include "uart.h"

#define AVR_DATA        PORTA
#define AVR_DATA_DIR    DDRA

#define AVR             PORTB 
#define AVR_DIR         DDRB
#define AVR_CE          PB6
#define AVR_WE          PB5 
#define AVR_OE          PB4
#define AVR_SI          PB3
#define AVR_SREG_EN     PB2 
#define AVR_RESET       PB1
#define AVR_CLK         PB0


#define clk_toogle()      (AVR ^= (1<< AVR_CLK)) 



#define BAUD_RATE 115200



uint8_t SRAM_read(uint32_t addr)
{
	uint8_t data;
    AVR_DATA_DIR = 0x00;
	AVR   &= ~(1<<AVR_CE);
	AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
	
    clk_toogle();

	AVR &= ~(1<<AVR_OE);
    // clear bus buffers
    clk_toogle();
    clk_toogle();
    
    data = AVR_DATA;
    
    clk_toogle();
    clk_toogle();
    clk_toogle();
 
	AVR |= (1<< AVR_OE);
    return data;
}

void SRAM_write(uint32_t addr, uint8_t data)
{
	AVR_DATA_DIR = 0xff;
	AVR   &= ~(1<<AVR_CE);
	AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
	
    clk_toogle();

	AVR &= ~(1<<AVR_WE);
    // clear bus buffers
    clk_toogle();
    clk_toogle();
    
    AVR_DATA = data;
    
    clk_toogle();
    clk_toogle();
    clk_toogle();
 
	AVR |= (1<< AVR_WE);
}



int main(void)
{

	uint8_t byte,buf[2];
	uart_init(BAUD_RATE);


	SRAM_write(0x00000000,0x23);
	byte = SRAM_read(0x00000000);
	itoa(byte,buf,16);
	uart_putstring("reads: ");
	uart_putstring(buf);
	uart_putchar(0x20);
	while(1);
	return 0;
}

