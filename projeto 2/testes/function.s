.global _start
_start:
	MOV r0, #2
	MOV r1, #3
	PUSH {r0, r1}
	BL soma
	POP {r3}
	POP {r0, r1}
	B end
	
soma:
	MOV r0, #4
	MOV r1, #30
	ADD r2, r0, r1
	PUSH {r2}
	BX lr
	
end: