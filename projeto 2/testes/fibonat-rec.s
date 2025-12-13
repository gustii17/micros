.global _start
_start:
	MOV r0, #5
	MOV r1, #1
	MOV r2, #1
	BL fib
stop:
	BAL stop

fib:
	CMP r0, #1
    SUB r0, #1
	BGT cont
	BX lr
cont:
	PUSH {r1, lr}
	ADD r1, r1, r2
	POP {r2}
	BL fib
	POP {lr}
	BX lr