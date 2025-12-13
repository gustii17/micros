.global _start
_start:
	MOV r0, #9
	LSL r0, #1 //deslocamento para a esquerda
	LSR r0, #2 //deslocamento para a direita
	MOV r1, r0, LSL #1
	MOV r0, #9
	ROR r0, #1 //rotação para a direita
	ROR r0, #31 //rotação para a esquerda (32-n)
	
	