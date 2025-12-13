.global _start
.equ endlist, #0xaaaaaaaa // definição de constante

_start:
	//BAL - sempre
	//BGT - maior que,
	//BGE - maior ou igual
	//BLT - menor que
	//BLE - menor ou igual
	//BEQ - igual 
	//BNE - não igual
	MOV r0, #1
	MOV r1, #1
	CMP r0, r1 //comparando
	
	//diz qual a condição do if
	BGT greater
	BEQ equal
	BLT lower
	BAL defalt
	
//operações do if
greater:
	MOV r2, #1
	BAL defalt
equal:
	MOV r2, #2
	BAL defalt
lower:
	MOV r2, #3
	BAL defalt
defalt:
	MOV r3, #4