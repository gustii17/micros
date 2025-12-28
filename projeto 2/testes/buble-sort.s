.global _start
_start:
	LDR r0, =list // posicao inicial da lista/tamanho
	LDR r4, [r0] //tamanho da lista
	
	MOV r1, r0  // acessar a posicao atual do laço 1
	MOV r2, #0 // indice atual do laço 1
	
	MOV r5, r1 //acessar a posicao atual do laço 2
	MOV r6, #0 // indice do 2 laço
	
	LDR r7, [r5] // valor atual do laço 2
	LDR r8, [r5]
	
	
loop:
	//for (int i = 0; i < n; i++)
	CMP r2, r4
	BGE exit
	ADD r1, #4
	
	SUB r5, r1, #4
	SUB r6, r2, #1
	
loop2:
		//for(int j = i; j >= 0; j++)
		CMP r6, #0
		BLT exit2
		
		//código dentro do loop
		LDR r7, [r5]
		LDR r8, [r5, #4]
		CMP r7, r8
		STRGT r8, [r5]
		STRGT r7, [r5, #4] 
		
		//j--
		SUB r5, #4
		SUB r6, #1
		BAL loop2
exit2:
	//i++
	ADD r2, #1
	BAL loop
	//saida do loop
exit:
	B exit
	
	


.data
list:
	.word 6, 10, 30, 20, 40, 25, 15