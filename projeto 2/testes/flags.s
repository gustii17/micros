.global _start
_start:
	MOV r0, #0xFFFFFFFF  //negativo ou positivo?
	MOV r1, #2 
	ADDS r2, r0, r1 //aciona a flag de carry
	MOV r3, #0
	ADC r3, r3, #0 //r3=r3+0+carry
	SUBS r4, r3, r1 //aciona a flag negative


	