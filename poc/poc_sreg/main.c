#include <avr/io.h>
#include <util/delay.h>
#include <stdlib.h>
#include "uart.h"

#define AVR_DATA        PORTA
#define AVR_DATA_DIR    DDRA
#define AVR_DATA_PIN    PINA

#define AVR             PORTB 
#define AVR_DIR         DDRB
#define AVR_CE          PB6
#define AVR_WE          PB5 
#define AVR_OE          PB4
#define AVR_SI          PB3
#define AVR_SREG_EN     PB2 
#define AVR_RESET       PB1
#define AVR_CLK         PB0


#define nop()               __asm volatile ("nop")
#define wait()              _delay_us(100)
#define halt()              uart_putstring("halt"); while(1)
#define clk_toogle()        (AVR ^= (1<< AVR_CLK));wait() 


#define BAUD_RATE 115200



uint8_t SRAM_read(uint32_t addr)
{
	uint8_t data;
    AVR_DATA_DIR = 0x00;
	AVR   &= ~(1<<AVR_CE);
	AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
	
    clk_toogle();
    clk_toogle();

	AVR &= ~(1<<AVR_OE);
    // clear bus buffers
    clk_toogle();
    clk_toogle();
    clk_toogle();
    clk_toogle();
    
    data = AVR_DATA_PIN;
    
    clk_toogle();
    clk_toogle();
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
    clk_toogle();

	AVR &= ~(1<<AVR_WE);
    // clear bus buffers
    clk_toogle();
    clk_toogle();
    clk_toogle();
    
    clk_toogle();
    
    AVR_DATA = data;
    
    clk_toogle();
    clk_toogle();
    clk_toogle();
    clk_toogle();
    clk_toogle();
    clk_toogle();
 
	AVR |= (1<< AVR_WE);
}



int main(void)
{


	uint8_t i,byte,buf[2];
	
    uart_init(BAUD_RATE);
    AVR_DIR=0xff;    
	AVR_DATA_DIR = 0xff;


	uart_putstring("Send reset\n\r");
	AVR   |=  (1 << AVR_RESET);
    wait();
    AVR   &= ~(1 << AVR_RESET);
   

	uart_putstring("Set data 0x55\n\r");
    AVR   &= ~(1<<AVR_CE);
	AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
    
	uart_putstring("Toggle clock\n\r");
    clk_toogle();
    clk_toogle();

	uart_putstring("WE low\n\r");
	AVR &= ~(1<<AVR_WE);
    
	uart_putstring("Toggle clock\n\r");
    clk_toogle();
    clk_toogle();
    clk_toogle();
    clk_toogle();
    
	uart_putstring("Write data to port\n\r");
    AVR_DATA = 0x55;
    
	uart_putstring("Toggle clock\n\r");
    clk_toogle();
    clk_toogle();
    clk_toogle();
    clk_toogle();
    clk_toogle();
    clk_toogle();

    while(0){
        _delay_us(1);
	    AVR   &= ~(1<<AVR_CE);
	    AVR   &= ~(1<<AVR_OE);
	    AVR   &= ~(1<<AVR_WE);
        _delay_us(1);
	    AVR   |= (1<<AVR_CE);
	    AVR   |= (1<<AVR_OE);
	    AVR   |= (1<<AVR_WE);
    }


	uart_putstring("start\n\r");
    for (i=0; i<0x10; i++){
	    itoa(i,buf,16);
	    uart_putstring(buf);
	    uart_putchar(' ');
	    SRAM_write(0x00000000,i);
	    byte = SRAM_read(0x00000000);
	    itoa(byte,buf,16);
	    uart_putstring(buf);
	    uart_putchar('\r');
	    uart_putchar('\n');
        uart_getchar();
    }
    for (i=0; i<0x10; i++){
	    itoa(i,buf,16);
	    uart_putstring(buf);
	    uart_putchar(' ');
	    byte = SRAM_read(0x00000000);
	    itoa(byte,buf,16);
	    uart_putstring(buf);
	    uart_putchar('\r');
	    uart_putchar('\n');
    }
	while(1);
	return 0;
}

