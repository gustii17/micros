.global _start
_start:
	MOV r0, #233 //word a verificar
	MOV r1, #1 //verificador
	MOV r4, #0
	
	MOV r2, #0
	
	//for(int  i = 0; i < 32; i++)
loop: 
	CMP r2, #32
	BGE exit
	
	//codigo do for
	AND r3, r1, r0
	CMP r3, r1
	ADDEQ r4, #1
	
	LSL r1, #1
	ADD r2, #1
	BAL loop
exit:
	b exit