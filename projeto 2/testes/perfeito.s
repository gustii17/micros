.global _start
_start:
	MOV r1, #24 //word a verificar
	MOV r0, #0 // soma
	MOV r2, #1 // i no for
	MOV r3, #0 // 
	
	//for(int  i = 1; i < 32; i++)
loop: 
	CMP r2, r1
	BGE exit
	
	//codigo do for
	UDIV r3, r1, r2
	
	
	ADD r2, #1
	BAL loop
exit:
	b exit