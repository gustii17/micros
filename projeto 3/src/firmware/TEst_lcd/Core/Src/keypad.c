#include "Keypad.h"
#include "GPIO.h"
#include "LCD.h"

/* Definicoes do Teclado Matricial */
#define ROW1_PIN 5    // PA5 - Linha 1
#define ROW2_PIN 4    // PA4 - Linha 2
#define ROW3_PIN 3    // PA3 - Linha 3
#define ROW4_PIN 2   // PA2 - Linha 4
#define COL1_PIN 1   // PA1 - Coluna 1
#define COL2_PIN 0   // PA0 - Coluna 2
#define COL3_PIN 8   // PB8 - Coluna 3
#define COL4_PIN 9   // PB9 - Coluna 4

GPIO_PinState state = GPIO_PIN_RESET;

void keypad_init(){
	 GPIO_SetPin(GPIOA, PIN_MASK(ROW1_PIN));
	 GPIO_SetPin(GPIOA, PIN_MASK(ROW2_PIN));
	 GPIO_SetPin(GPIOA, PIN_MASK(ROW3_PIN));
	 GPIO_SetPin(GPIOA, PIN_MASK(ROW4_PIN));
	 write_letter('k');
}


char Keypad_Scan(){
	Botton_swap();
	uint8_t rows[] = {ROW1_PIN, ROW2_PIN, ROW3_PIN, ROW4_PIN};
	uint8_t cols[] = {COL1_PIN, COL2_PIN, COL3_PIN, COL4_PIN};
	    char keymap[8][4] = {
	        {'A', 'B', 'C', 'D'},
	        {'E', 'F', 'G', '-'},
	        {'H', 'I', 'J', '/'},
	        {'K', 'L', 'M', '*'},
			{'N', 'O', 'P', 'Q'},
			{'R', 'S', 'T', ' '},
			{'U', 'V', 'W', '/'},
			{'X', 'Y', 'Z', '*'}
	    };
	    /*
	    char keymap2[4][4] = {
	    	{'N', 'O', 'P', 'Q'},
	    	{'R', 'S', 'T', ' '},
	    	{'U', 'V', 'W', '/'},
	    	{'X', 'Y', 'Z', '*'}
	   };
	   */

	    //write_letter('s');
	    for(uint8_t i = 0; i < 4; i++) {
	        GPIO_SetPin(GPIOA, PIN_MASK(ROW1_PIN));
	        GPIO_SetPin(GPIOA, PIN_MASK(ROW2_PIN));
	        GPIO_SetPin(GPIOA, PIN_MASK(ROW3_PIN));
	        GPIO_SetPin(GPIOA, PIN_MASK(ROW4_PIN));

	        GPIO_ResetPin(GPIOA, PIN_MASK(rows[i]));
	        //write_letter('1');
	        HAL_Delay(10);

	        for(uint8_t j = 0; j < 4; j++) {
	        	//write_letter('2');
	        	if(j > 1){
	        		//write_letter('3');
					if(GPIO_ReadPin(GPIOB, PIN_MASK(cols[j])) == 0) {
						//write_letter('4');
						HAL_Delay(20);
						if(GPIO_ReadPin(GPIOB, PIN_MASK(cols[j])) == 0) {
							//write_letter('5');
							while(GPIO_ReadPin(GPIOB, PIN_MASK(cols[j])) == 0){

								HAL_Delay(1);
							}
							//write_letter('6');

							return keymap[i+(int)(4*state)][j];
						}
					}
	        	}
				else{
					//write_letter('7');
					if(GPIO_ReadPin(GPIOA, PIN_MASK(cols[j])) == 0) {
						//write_letter('8');
						HAL_Delay(20);
						if(GPIO_ReadPin(GPIOA, PIN_MASK(cols[j])) == 0) {
							//write_letter('9');
						    while(GPIO_ReadPin(GPIOA, PIN_MASK(cols[j])) == 0){
						    	HAL_Delay(1);
						    }
						    //write_letter('p');
							return keymap[i+(int)(4*state)][j];
						}
					}
				}
	        }
	    }



	    return 0;
}

void Botton_swap(){
	 if(HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_8) == GPIO_PIN_RESET){
		 HAL_Delay(20);

		 if(HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_8) == GPIO_PIN_RESET){
			 while(HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_8) == GPIO_PIN_RESET){
			    HAL_Delay(1);
			 }
			 if(state == GPIO_PIN_SET)	 state = GPIO_PIN_RESET;
			 else state = GPIO_PIN_SET;
			 HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, state);
		 }
	 }
}
