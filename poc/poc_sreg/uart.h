#ifndef _uart_included_h_
#define _uart_included_h_

#include <stdint.h>

#define uart_print(s) uart_print_P(PSTR(s))
void uart_init(uint32_t baud);
void uart_putchar(uint8_t c);
void uart_putstring(uint8_t *str);
uint8_t uart_getchar(void);
uint8_t uart_available(void);
void uart_print_P(const uint8_t *str);

#endif
