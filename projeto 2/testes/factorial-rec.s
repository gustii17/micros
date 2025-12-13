.global _start
_start:
	MOV r0, #5
	BL factorial
stop:
	B stop

factorial:
	PUSH {r4, lr}
	MOV r4, r0
	CMP r4, #1
	BNE else
	MOV r0, #1
loop:
	POP {r4, pc}
else:
	SUB r0, r4, #1
	BL factorial
	MUL r0, r4, r0
	B loop