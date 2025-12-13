.model small
;--------------------------------------------------------
;		Memória RAM
;--------------------------------------------------------
fixo	SEGMENT at 0000h
		ASSUME ds:fixo
	; variavel_da_RAM	equ	ds:[endereço_na_RAM]
fixo 	ENDS
.data
COUNTER_0			EQU		080H 
TIMER_PROGRAM		EQU		0B0H
PORTA_PARALELA 		EQU 	000H 
CONTROLPORTA 		EQU 	030H
.code
    ORG 0000h							; FE000h					
codigo:			
    ORG 0100h							; FE100h

; 8254		
	;Inicialização do Timer 
		; configura o timer - counter 0
			mov al, 00110110b ; 00 (contador 0) 11 (rw 1. LSB 2. MSB) 011 (modo 3 gera onda quadrada) 0 (não usa BCD)
			out TIMER_PROGRAM, al ; out da palavra de controle para o endereço 0B0H
		; end  configura timer - counter 0
		; Divide o pclock por 20 decimal ou 14H 
			;ENVIA O LSB
			mov al, 04H
			out COUNTER_0, al
			;ENVIA O MSB
			mov al, 01H
			out COUNTER_0, al
		; end Divide o pclock por 20 decimal ou 14H
	; end inicialização do timer
; end 8254

; 8255 RAM
	; Inicialização da 8255
		           ; MSB               LSB  
		mov al,82h ; 1  seta tip A     0 PC7 - PC4 saída
		           ; 0  seta modo 0    0 modo 0
				   ; 0  seta modo 0    1 porta B entrada
                   ; 0  porta A saída  0 PC3 - PC0 saída
		out CONTROLPORTA,al
	; end inicialização de 8255
	
	of_the_cat:	
		mov al,55h
		out PORTA_PARALELA,al 
		
		mov cx, 0FFFFh
		atraso:
			mov al,00H		;endereço de um dispositivo inexistente
			out 0FFH,al		;apenas para pulsar MIO
		loop atraso
	  
		mov ax, 0
		mov ds, ax
		mov dl, 0AAH     
		mov ds:[00000H] , dl
		mov al, ds:[00000H]
		out  PORTA_PARALELA, al
						
		mov cx, 0FFFFh
		atraso2:
			mov al,00H		;endereço de um dispositivo inexistente
			out 0FFH,al		;apenas para pulsar MIO
		loop atraso2
		
	jmp of_the_cat
; end 8255 RAM

;-------------------------------
;	JUMP DO ENDEREÇO DE RESET	
;-------------------------------

ORG 7FF0h ; FFFF0h
    nop
	jmp far ptr codigo
end codigo	
