#include "LCD.h"


void LCD_init(){
	  /* configuração do sisplay
	  *inicializando em low
	  */
	  set_zero();


	  //Modo 4 bits
	  set_pin(0, 0, 1, 1, 0, 0 ,0 ,0 ,0, 1);
	  set_pin(0, 0, 1, 1, 0, 0 ,1 ,0 ,0, 1);

	  //limpar LCD
	  set_pin(0, 0, 0, 0, 0, 0 ,0 ,1 ,0, 1);

	    //modo 8 bits
	  set_pin(0, 0, 1, 0, 1, 0 ,0 ,0 ,0, 1);

	    //Liga LCD, Liga cursor, desliga, blink
	  set_pin(0, 0, 0, 0, 1, 1 ,1 ,0 ,0, 1);

	    // Habilita incremento, desliga scroll
	    //modo 8 bits
	  set_pin(0, 0, 0, 0, 0, 1 ,1 ,0 ,0, 1);
}

void write_word(char* word){
	if(word == NULL) return;
	int i = 0;
	while((char)*(word+i)  != '\0' && i < 16){
		write_letter(*(word+i));
		i++;
	}
}

void write_tel(char* msg, char* msg2){
	LCD_clear();
	set_adress(0, 0);
	write_word(msg);
	set_adress(0, 1);
	write_word(msg2);
}

void write_letter(char letter){
	GPIO_PinState ascii[8];
	get_ascii(letter, ascii);
	set_pin(ascii[0], ascii[1], ascii[2], ascii[3], ascii[4], ascii[5], ascii[6], ascii[7], 1, 1);
	HAL_Delay(10);
}

void get_ascii(char letter, GPIO_PinState *ascii){

	if(letter >= 'a' && letter <= 'z'){
		letter = (char)letter - 32;

	}
	if(letter == 'W') {

	}


	int k = (int)letter;
	traduzir_binario(k, ascii);
	return;
}

void traduzir_binario(int k, GPIO_PinState *ascii){
	int i = 7;

		for(int j = 0; j < 8; j++){
			ascii[j] = 0;
		}


		while(k != 0){
			if(k % 2 == 1) {
				ascii[i] = 1;
			}
			k = k / 2;
			i--;
		}
		return;
}


void set_adress(int colun, int line){
	int adress = colun;
	if(line == 1){
		adress = adress + 64;
	}
	GPIO_PinState ascii[8];
	traduzir_binario(adress, ascii);
	set_pin(1, ascii[1], ascii[2], ascii[3], ascii[4], ascii[5], ascii[6], ascii[7], 0, 1);
	HAL_Delay(100);


}


void LCD_clear(){
	//limpa o lcd e coloca o cursor no inico
	set_pin(0, 0, 0, 0, 0, 0 ,0 ,1 ,0, 1);
	//possivelmente vou precisar do 00
	set_zero();
}






void set_zero(){

	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 0);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 0);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_0, 0);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_1, 0);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_10, 0);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_11, 0);
	HAL_Delay(2);
}

// d8-d1 + rs
void set_pin(GPIO_PinState pin_7, GPIO_PinState pin_6, GPIO_PinState pin_5,
		GPIO_PinState pin_4, GPIO_PinState pin_3, GPIO_PinState pin_2,
		GPIO_PinState pin_1, GPIO_PinState pin_0, GPIO_PinState pin_11, int var){
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_11, pin_11);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_1, pin_4);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_0, pin_5);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, pin_6);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, pin_7);
	HAL_Delay(2);
	pulse();
	if(var == 0) return;
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_1, pin_0);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_0, pin_1);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, pin_2);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, pin_3);
	HAL_Delay(2);
	pulse();



}

void pulse(){
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_10, 1);
	HAL_Delay(2);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_10, 0);
	HAL_Delay(2);
}



