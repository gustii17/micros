# ifndef LCD_H
# define LCD_H

#include "stm32f1xx_hal.h"

void LCD_init();
void pulse();
void set_zero();
void set_pin(GPIO_PinState pin_7, GPIO_PinState pin_6, GPIO_PinState pin_5,
		GPIO_PinState pin_4, GPIO_PinState pin_3,GPIO_PinState pin_2,
		GPIO_PinState pin_1, GPIO_PinState pin_0, GPIO_PinState pin_11, int var);
void get_ascii(char letter, GPIO_PinState *ascii);
void write_letter(char letter);
void write_word(char* word);
void LCD_clear();
void traduzir_binario(int k, GPIO_PinState *ascii);
void set_adress(int line, int colun);
void write_tel(char* msg, char* msg2);


# endif
