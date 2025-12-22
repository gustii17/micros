.global _start
_start:
	LDR r0, =list // posicao inicial da lista/tamanho
	MOV r1, r0  // acessar a posicao atual da lista
	MOV r2, #0 // indice atual da lista
	LDR r3, [r0] //tamanho da lista
	LDR r4, [r1] // valor atual
	MOV r5, #-1
	
	
loop:
	//for (int i = 0; i < n; i++)
	CMP r2, r3
	BGE exit
	
	LDR r4, [r1, #4]! // acessando o proximo elemento
	CMP r4, r5
	MOVGT r5, r4
	
	//i++
	ADD r2, #1
	BAL loop
	
exit:
	B exit
	
	


.data
list:
	.word 6, 10, 24, 3, 4, 17, -3