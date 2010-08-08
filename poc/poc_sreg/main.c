#include <avr/io.h>
#include <util/delay.h>
#include <stdlib.h>
#include "uart.h"

#define AVR_DATA        PORTA
#define AVR_DATA_DIR    DDRA
#define AVR_DATA_PIN    PINA



#define CLOCK           PORTC
#define CLOCK_DIR       DDRC
#define CLOCK_PIN       PINC
#define CLOCK_CLK       PC7

#define AVR             PORTB 
#define AVR_DIR         DDRB
#define AVR_COUNTER     PB6
#define AVR_WE          PB5 
#define AVR_OE          PB4
#define AVR_SI          PB3
#define AVR_SREG_EN     PB2 
#define AVR_RESET       PB1
#define AVR_CLK         PB0


#define nop()               __asm volatile ("nop")
#define wait()              _delay_us(1)
#define halt()              uart_putstring("halt"); while(1)
#define clk_toogle()        (CLOCK ^= (1<< CLOCK_CLK)) 


#define BAUD_RATE 115200


void sreg_set(uint32_t addr);

inline static void tick()
{
    clk_toogle();
    clk_toogle();
}


uint8_t SRAM_read(uint32_t addr)
{
	uint8_t data;
    sreg_set(addr);
    AVR_DATA_DIR = 0x00;
	AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
    //tick();
	AVR &= ~(1<<AVR_OE);
    // clear bus buffers
    //tick();
    //tick();
    data = AVR_DATA_PIN;
    //tick();
    //tick();
 
	AVR |= (1<< AVR_OE);
    return data;
}

void SRAM_write(uint32_t addr, uint8_t data)
{
    sreg_set(addr);
	AVR_DATA_DIR = 0xff;
	AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
    //tick();
	AVR &= ~(1<<AVR_WE);
    // clear bus buffers
    //tick();
    //tick();
    AVR_DATA = data;
    //tick();
    //tick();
    AVR |= (1<< AVR_WE);
}


inline void SRAM_burst_start(uint8_t addr){
    sreg_set(addr);
	AVR_DATA_DIR = 0xff;
	AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
    //tick();
	//tick();
    AVR &= ~(1<<AVR_WE);
	//tick();
}

inline void SRAM_burst_write(uint8_t data)
{
    AVR_DATA = data;
    //tick();
    //tick();
}


inline void SRAM_burst_inc(void)
{	
    AVR &= ~(1<<AVR_COUNTER);
    //tick();
	AVR |= (1<<AVR_COUNTER);
}

inline void SRAM_burst_end()
{
	AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
    //tick();
    //tick();
}

void toggle_ctrl(void){

    while(1){
        _delay_us(1);
	    AVR   &= ~(1<<AVR_OE);
	    AVR   &= ~(1<<AVR_WE);
        _delay_us(1);
	    AVR   |= (1<<AVR_OE);
	    AVR   |= (1<<AVR_WE);
    }
}

void read_back(void)
{

	uint8_t i,byte,buf[2];
    uart_putstring("read_back\n\r");
	AVR   |=  (1 << AVR_SREG_EN);
    SRAM_write(0x00000000,0xaa);
	byte = SRAM_read(0x00000000);
	itoa(byte,buf,16);
	uart_putstring(buf);
	uart_putchar('\r');
	uart_putchar('\n');
    AVR   &= ~(1 << AVR_SREG_EN);
    wait();
    SRAM_write(0x00000000,0xbb);
	byte = SRAM_read(0x00000000);
	itoa(byte,buf,16);
	uart_putstring(buf);
	uart_putchar('\r');
	uart_putchar('\n');

	AVR   |=  (1 << AVR_SREG_EN);
	wait();
    byte = SRAM_read(0x00000000);
	itoa(byte,buf,16);
	uart_putstring(buf);
	uart_putchar('\r');
	uart_putchar('\n');
    
    AVR   &= ~(1 << AVR_SREG_EN);
	wait();
    byte = SRAM_read(0x00000000);
	itoa(byte,buf,16);
	uart_putstring(buf);
	uart_putchar('\r');
	uart_putchar('\n');

}
void write_loop(void)
{
	
	uint8_t i,byte,buf[3];
    uart_putstring("write_loop\n\r");
    for (i=0; i<0x10; i++){
	    itoa(i,buf,16);
	    uart_putstring(buf);
	    uart_putchar(':');
	    SRAM_write(i,i);
	    byte = SRAM_read(i);
	    itoa(byte,buf,16);
	    uart_putstring(buf);
        uart_putstring("\n\r");
    }
    uart_putstring("Read\n");
    for (i=0; i<0x10; i++){
	    byte = SRAM_read(i);
	    itoa(byte,buf,16);
	    uart_putstring(buf);
	    uart_putchar(' ');
    }
    uart_putstring("\n\r");
}

void write_big_block(void)
{
	
	uint8_t byte,buf[8];
    uint32_t i;
    uart_putstring("write_big_loop\n\r");
    for (i=0; i < 0x1000; i++){
        if (i%0x100==0) 
	        uart_putchar('.');
        SRAM_write(i,i&0xff);
    }
    uart_putstring("done\n\r");
    for (i=0; i < 0x1000; i++){
        byte = SRAM_read(i);
	    itoa(byte,buf,16);
	    uart_putstring(buf);
	    uart_putchar(' ');
        if (i && i%32==0) 
            uart_putstring("\n\r");
    }
    uart_putstring("done\n\r");
}
void write_burst_big_block(void)
{
	
	uint8_t byte,buf[8];
    uint32_t i;
    uart_putstring("write_big_loop\n\r");
    SRAM_burst_start(0x000000);
    for (i=0; i < 0x100000; i++){
        if (i%0x10000==0) 
	        uart_putchar('.');
        SRAM_burst_write(0xff - (i&0xff));
        SRAM_burst_inc();
    }
    SRAM_burst_end();
    uart_putstring("done\n\r");
    for (i=0; i < 0x100000; i++){
        byte = SRAM_read(i);
	    itoa(byte,buf,16);
	    uart_putstring(buf);
	    uart_putchar(' ');
        if (i && i%32==0) 
            uart_putstring("\n\r");
    }
    uart_putstring("done\n\r");
}
void sreg_feed(void)
{
    uart_putstring("feed_sreg\n\r");
	AVR   &=  ~(1 << AVR_SREG_EN);
    AVR   |=  (1 << AVR_SI);
    //tick();
    AVR   &=  ~(1 << AVR_SI);
    //tick();
    AVR   |=  (1 << AVR_SI);
    //tick();
    AVR   &=  ~(1 << AVR_SI);
    //tick();
}


void sreg_set(uint32_t addr)
{
    uint8_t i = 21;
    //uart_putstring("sreg_set\n\r");
	AVR   &=  ~(1 << AVR_SREG_EN);
    while(i--) {
        if ((addr & ( 1L << i))){
            AVR   |=  (1 << AVR_SI);
            //uart_putchar('1');
        } else {
            AVR   &=  ~(1 << AVR_SI);
            //uart_putchar('0');
        }
        //tick();
    }
	AVR   |=  (1 << AVR_SREG_EN);
}

void init(void)
{
	uart_putstring("init\n\r");
    // output ports
    AVR_DIR=0xff;    
	AVR_DATA_DIR = 0xff;
    // 
    //CLOCK_DIR = 0xff;
    // reset sreg
    AVR   |=  (1 << AVR_RESET);
    wait();
    AVR   &= ~(1 << AVR_RESET);
    wait();
    // disable counter
	AVR   |=  (1 << AVR_COUNTER);
}

int main(void)
{
	uint8_t i,byte,buf[2];
    uart_init(BAUD_RATE);
    init();
    write_loop();
    //write_burst_big_block();
    halt();
	
    return 0;
}

