#include <avr/io.h>
#include <util/delay.h>
#include <stdlib.h>
#include "uart.h"

#define AVR_DATA        PORTA
#define AVR_DATA_DIR    DDRA
#define AVR_DATA_PIN    PINA

// definiton for the clock to the CPLD
// not used , because the CLOCK signal
// is done by AVR thru the fuse seeting
// Clock Output on PORTC7
#define CLOCK           PORTC
#define CLOCK_DIR       DDRC
#define CLOCK_PIN       PINC
#define CLOCK_CLK       PC7
#define clk_toggle()        (CLOCK ^= (1<< CLOCK_CLK)) 

// AVR CTRL Port
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


#define BAUD_RATE 115200


void sreg_set(uint32_t addr);

#if 0
inline static void tick()
{
    clk_toggle();
    clk_toggle();
}
#endif



uint8_t SRAM_read(uint32_t addr)
{
	uint8_t data;
    // set direction of data port
    AVR_DATA_DIR = 0x00;
    // load address
    sreg_set(addr);
    // disable OE and WE
    AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
    // wait for FSM to go into IDLE state
    nop();
    nop();
    // enable OE
    AVR &= ~(1<<AVR_OE);
    // wait for FSM to go into OE state
    nop();
    nop();
    nop();
    nop();
    nop();
    // read data
    data = AVR_DATA_PIN;
    // disable OE
	AVR |= (1<< AVR_OE);
    return data;
}

void SRAM_write(uint32_t addr, uint8_t data)
{
    
    // set direction of data port
    AVR_DATA_DIR = 0xff;
    // load address
    sreg_set(addr);
    // disable OE and WE
    AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
    // wait for FSM to go into IDLE state
    nop();
    nop();
    // write data
    AVR_DATA = data;
    // enable WE
    AVR   &= ~(1<<AVR_WE);
    // wait for FSM to go into WE state
    nop();
    nop();
    nop();
    nop();
    // disable WE
    AVR |= (1<< AVR_WE);
}


inline void SRAM_burst_start(uint8_t addr){
	AVR_DATA_DIR = 0xff;
    sreg_set(addr);
	AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
    nop();
    nop();
    AVR &= ~(1<<AVR_WE);
}

inline void SRAM_burst_write(uint8_t data)
{
    AVR_DATA = data;
    nop();
    nop();
    nop();
    nop();
    nop();
}

inline void SRAM_burst_inc(void)
{	
    // toggle counter line with triggers address inc in the SREG
    AVR &= ~(1<<AVR_COUNTER);
    AVR |= (1<<AVR_COUNTER);
}

inline void SRAM_burst_end()
{
	AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
}

void read_back(void)
{
    // simple 2 byte read
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
    // write from address 0x00 to 0x0f the values 
    // 0x00 to 0x0f and read it back

	uint8_t i,j,byte,buf[3];
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
    uart_putstring("Read\n\r");
    for (j=0; j<10; j++){
        for (i=0; i<0x10; i++){
            nop();
            byte = SRAM_read(i);
            itoa(byte,buf,16);
            uart_putstring(buf);
            uart_putchar(' ');
        }
        uart_putstring("\n\r");
    }
   
}

void write_big_block(void)
{
	// write from address 0x0000 to 0x1000
    // an incrementing pattern and read it back
    
    #define BLOCK_SIZE 0x1000

    uint8_t byte,buf[8];
    uint32_t i;
    uart_putstring("write_big_loop\n\r");
    for (i=0; i < BLOCK_SIZE ; i++){
        if (i%(BLOCK_SIZE/10)==0) 
	        uart_putchar('.');
        SRAM_write(i,i&0xff);
    }
    uart_putstring("done\n\r");
    for (i=0; i < BLOCK_SIZE ; i++){
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
	
	// using the burst function writing from address 0x0000 to 0x1000
    // an incrementing pattern and read it back

	uint8_t byte,buf[8];
    uint32_t i;
    uart_putstring("write_big_loop\n\r");
    SRAM_burst_start(0x000000);
    for (i=0; i < BLOCK_SIZE; i++){
        if (i%(BLOCK_SIZE/10)==0) 
	        uart_putchar('.');
        SRAM_burst_write(0xff - i);
        SRAM_burst_inc();
    }
    SRAM_burst_end();
    uart_putstring("done\n\r");
    for (i=0; i < BLOCK_SIZE; i++){
        byte = SRAM_read(i);
	    itoa(byte,buf,16);
	    uart_putstring(buf);
	    uart_putchar(' ');
        if (i && i%32==0) 
            uart_putstring("\n\r");
    }
    uart_putstring("done\n\r");
}

#define SREG_DEBUG 0
void sreg_set(uint32_t addr)
{
    
    
    uint8_t i = 21;
    #if SREG_DEBUG 
    uart_putstring("sreg_set\n\r");
    #endif
    AVR   |=  (1 << AVR_SREG_EN);
    while(i--) {
        if ((addr & ( 1L << i))){
            AVR   |=  (1 << AVR_SI);
    #if SREG_DEBUG 
            uart_putchar('1');
    #endif
        } else {
            AVR   &=  ~(1 << AVR_SI);
    #if SREG_DEBUG 
            uart_putchar('0');
    #endif
        }
        AVR   &=  ~(1 << AVR_SREG_EN);
	    AVR   |=  (1 << AVR_SREG_EN);
    }
    #if SREG_DEBUG 
    uart_putstring("\n\r");
    #endif
}

void toggle_sreg_pattern(void){
    
    // write test patterns to SREG
    // for LA debugging via the debug lines
    while(1){
	    uart_putstring("sreg: 0x5555\n\r");
        sreg_set(0x5555);
        uart_getchar();
	    uart_putstring("sreg: 0xaaaa\n\r");
        sreg_set(0xaaaa);   
        uart_getchar();
	    uart_putstring("sreg: 0x0000\n\r");
        sreg_set(0x0000);   
        uart_getchar();
	    uart_putstring("sreg: 0x000f\n\r");
        sreg_set(0x000f);   
        uart_getchar();
    }
}

void init(void)
{
    // set port direction
    AVR_DIR=0xff;    
	AVR_DATA_DIR = 0xff;

    // disable SRAM OE and WE
    AVR   |=  (1 << AVR_OE);
	AVR   |=  (1 << AVR_WE);
    // disable SREG
    AVR   |=  (1 << AVR_SREG_EN);
    // disable SREG COUNTER
	AVR   |=  (1 << AVR_COUNTER);
    
    // send reset high to SREG and DCM
    AVR   |=  (1 << AVR_RESET);
    wait();
    AVR   &= ~(1 << AVR_RESET);
    wait();
	uart_putstring("init\n\r");

}


int main(void)
{
	uint8_t i,byte,buf[2];
    uart_init(BAUD_RATE);
    init();
    toggle_sreg_pattern();
    write_burst_big_block();
    halt();
    return 0;
}

