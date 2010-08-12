#include <avr/io.h>
#include <util/delay.h>
#include <stdlib.h>
#include "uart.h"

#define nop()               __asm volatile ("nop")
#define wait()              _delay_us(1)
#define halt()              uart_putstring("halt"); while(1)

#define BAUD_RATE 115200

// Ports
#define AVR_DATA        PORTA
#define AVR_DATA_DIR    DDRA
#define AVR_DATA_PIN    PINA

// definiton for the clock to the CPLD
// not used , because the CLOCK signal
// is done by AVR_CTRL thru the fuse seeting
// Clock Output on PORTC7
#define CLOCK           PORTC
#define CLOCK_DIR       DDRC
#define CLOCK_PIN       PINC
#define CLOCK_CLK       PC7
#define clk_toggle()        (CLOCK ^= (1<< CLOCK_CLK)) 

// AVR CTRL Port
#define AVR_CTRL        PORTB 
#define AVR_CTRL_DIR    DDRB


#define IDLE              0x01  
#define AVR_RESET_LO      0x02  
#define AVR_RESET_HI      0x03  
#define AVR_SREG_EN_LO    0x04  
#define AVR_SREG_EN_HI    0x05  
#define AVR_SI_LO         0x06  
#define AVR_SI_HI         0x07  
#define AVR_OE_LO         0x08  
#define AVR_OE_HI         0x09  
#define AVR_WE_LO         0x0a  
#define AVR_WE_HI         0x0b  
#define AVR_COUNTER_LO    0x0c  
#define AVR_COUNTER_HI    0x0d  
#define AVR_SNES_MODE_LO  0x0e  
#define AVR_SNES_MODE_HI  0x0f  


#define SET_IDLE()                AVR_CTRL = IDLE; nop()
#define SET_AVR_RESET_LO()        AVR_CTRL = AVR_SREG_EN_LO; nop()
#define SET_AVR_RESET_HI()        AVR_CTRL = AVR_RESET_HI; nop()
#define SET_AVR_SREG_EN_LO()      AVR_CTRL = AVR_SREG_EN_LO; nop()
#define SET_AVR_SREG_EN_HI()      AVR_CTRL = AVR_SREG_EN_HI; nop()
#define SET_AVR_SI_LO()           AVR_CTRL = AVR_SI_LO; nop()
#define SET_AVR_SI_HI()           AVR_CTRL = AVR_SI_HI; nop()
#define SET_AVR_OE_LO()           AVR_CTRL = AVR_OE_LO; nop()
#define SET_AVR_OE_HI()           AVR_CTRL = AVR_OE_HI; nop()
#define SET_AVR_WE_LO()           AVR_CTRL = AVR_WE_LO; nop()
#define SET_AVR_WE_HI()           AVR_CTRL = AVR_OE_HI; nop()
#define SET_AVR_COUNTER_LO()      AVR_CTRL = AVR_COUNTER_LO; nop()
#define SET_AVR_COUNTER_HI()      AVR_CTRL = AVR_COUNTER_HI; nop()
#define SET_AVR_SNES_MODE_LO()    AVR_CTRL = AVR_SNES_MODE_LO; nop()
#define SET_AVR_SNES_MODE_HI()    AVR_CTRL = AVR_SNES_MODE_HI; nop()


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
    //AVR   |=  (1 << AVR_OE);
    SET_AVR_OE_HI();
    //AVR   |=  (1 << AVR_WE);
    SET_AVR_WE_HI();
    // wait for FSM to go into IDLE state
    nop();
    nop();
    // enable OE
    //AVR &= ~(1<<AVR_OE);
    SET_AVR_OE_LO();
    // wait for FSM to go into OE state
    nop();
    nop();
    nop();
    nop();
    nop();
    // read data
    data = AVR_DATA_PIN;
    // disable OE
    //AVR |= (1<< AVR_OE);
    SET_AVR_OE_HI();
    return data;
}

void SRAM_write(uint32_t addr, uint8_t data)
{
    
    // set direction of data port
    AVR_DATA_DIR = 0xff;
    // load address
    sreg_set(addr);
    // disable OE and WE
    SET_AVR_OE_HI();
    //AVR   |=  (1 << AVR_WE);
    SET_AVR_WE_HI();
    // wait for FSM to go into IDLE state
    nop();
    nop();
    // write data
    AVR_DATA = data;
    // enable WE
    //AVR   &= ~(1<<AVR_WE);
    SET_AVR_WE_LO();
    // wait for FSM to go into WE state
    nop();
    nop();
    nop();
    nop();
    // disable WE
    //AVR |= (1<< AVR_WE);
    SET_AVR_WE_HI();
}


inline void SRAM_burst_start(uint8_t addr){
	AVR_DATA_DIR = 0xff;
    sreg_set(addr);
    SET_AVR_OE_HI();
    SET_AVR_WE_HI();
    nop();
    nop();
    SET_AVR_WE_LO();
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
    SET_AVR_COUNTER_LO();
    SET_AVR_COUNTER_HI();

}

inline void SRAM_burst_end(void)
{
    SET_AVR_OE_HI();
    SET_AVR_WE_HI();
}

void read_back(void)
{
    // simple 2 byte read
	uint8_t byte,buf[2];
    uart_putstring("read_back\n\r");
    SRAM_write(0x00000000,0xaa);
	byte = SRAM_read(0x00000000);
	itoa(byte,(char*)buf,16);
	uart_putstring((char*)buf);
	uart_putchar('\r');
	uart_putchar('\n');
    wait();
    SRAM_write(0x00000001,0xbb);
	byte = SRAM_read(0x00000001);
	itoa(byte,(char*)buf,16);
	uart_putstring((char*)buf);
	uart_putchar('\r');
	uart_putchar('\n');

	wait();
    byte = SRAM_read(0x00000000);
	itoa(byte,(char*)buf,16);
	uart_putstring((char*)buf);
	uart_putchar('\r');
	uart_putchar('\n');
    
	wait();
    byte = SRAM_read(0x00000001);
	itoa(byte,(char*)buf,16);
	uart_putstring((char*)buf);
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
	    itoa(i,(char*)buf,16);
	    uart_putstring((char*)buf);
	    uart_putchar(':');
	    SRAM_write(i,i);
	    byte = SRAM_read(i);
	    itoa(byte,(char*)buf,16);
	    uart_putstring((char*)buf);
        uart_putstring("\n\r");
    }
    uart_putstring("Read\n\r");
    for (j=0; j<10; j++){
        for (i=0; i<0x10; i++){
            nop();
            byte = SRAM_read(i);
            itoa(byte,(char*)buf,16);
            uart_putstring((char*)buf);
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
	    itoa(byte,(char*)buf,16);
	    uart_putstring((char*)buf);
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
	    itoa(byte,(char*)buf,16);
	    uart_putstring((char*)buf);
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
    SET_AVR_WE_HI();
    //AVR   |=  (1 << AVR_SREG_EN);
    while(i--) {
        if ((addr & ( 1L << i))){
            SET_AVR_SI_HI();
            //AVR   |=  (1 << AVR_SI);
    #if SREG_DEBUG 
            uart_putchar('1');
    #endif
        } else {
            SET_AVR_SI_LO();
            //AVR   &=  ~(1 << AVR_SI);
    #if SREG_DEBUG 
            uart_putchar('0');
    #endif
        }
        SET_AVR_WE_LO();
        SET_AVR_WE_HI();

        //AVR   &=  ~(1 << AVR_SREG_EN);
	    //AVR   |=  (1 << AVR_SREG_EN);
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
    AVR_CTRL_DIR=0xff;    
	AVR_DATA_DIR = 0xff;

    // disable SRAM OE and WE
    SET_AVR_OE_HI();
    SET_AVR_WE_HI();
    // disable SREG
    SET_AVR_WE_HI();
    // disable SREG COUNTER
    SET_AVR_COUNTER_HI();
    // send reset high to SREG and DCM
    SET_AVR_RESET_HI();
    wait();
    SET_AVR_RESET_LO();
    wait();
	uart_putstring("init\n\r");

}


int main(void)
{
    uart_init(BAUD_RATE);
    init();
    toggle_sreg_pattern();        
    halt();
    return 0;
}

