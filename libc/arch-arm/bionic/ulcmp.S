.global __aeabi_ulcmp
.type __aeabi_ulcmp, %function

__aeabi_ulcmp:
	cmp r1, r3
	cmpeq	r0, r2
	movlo	r0, #-1
	moveq	r0, #0
	movhi	r0, #1
	mov	pc, lr
