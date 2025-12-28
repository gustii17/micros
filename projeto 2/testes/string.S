.global _start
_start:
	LDR r1, =string
	LDR r2, =len
	LDR r3, [r1]
	LDR r4, [r2]
	



	
.data
string:
	.asciz "hello world \0"
len = .-string
		
	//.ascis, .asciz, .string