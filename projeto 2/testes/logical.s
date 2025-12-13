.global _start
_start:
	MOV r0, #0xFF
	MVN r1, r0 //move o negativo
	ANDS r2, r1, r0 //and com flag
	ORR r2, r1, r0
	