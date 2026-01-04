#include "telas.h"
#include "LCD.h"


void Tela_inicio(){
	char msg[] = "A - INICIAR";
	char msg2[] = "B - INICIAR";
	write_tel(msg, msg2);

}

void Tela_forca(int tamanho_palavra){
	char msg[] = "TENTATIVA:    X0";
	char msg2[16];
	int i;
	for(i = 0; i < tamanho_palavra; i++){
		msg2[i] = '_';
	}
	msg2[i] = '\0';
	write_tel(msg, msg2);
}


void tela_vitoria(){
	char msg[] = "VVVVVVVVVVVVVVVV";
	char msg2[] = "V VOCE GANHOU! V";
	write_tel(msg, msg2);
}



void tela_derrota(){
	char msg[] = "XXXXXXXXXXXXXXXX";
	char msg2[] = "X !GAME OVER! X";
	write_tel(msg, msg2);
}

void load(){
	char msg[] = "carregando";
	LCD_clear();
	write_word(msg);
	HAL_Delay(300);
	write_letter('.');
	HAL_Delay(300);
	write_letter('.');
	HAL_Delay(300);
	write_letter('.');
}
