.global _start
_start:
	MOV r0, #10
	MOV r1, #0
loop:
	CMP r0, #0
	beq exit
	
	ADD r1, r1, r0
	SUB r0, r0, #1
	
	b loop
exit:
_end: