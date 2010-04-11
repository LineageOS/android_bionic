/*
 * Copyright (c) 2010 0xlab - http://0xlab.org/
 * Copyright (c) 2008 ARM Ltd
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the company may not be used to endorse or promote
 *    products derived from this software without specific prior written
 *    permission.
 *
 * THIS SOFTWARE IS PROVIDED BY ARM LTD ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL ARM LTD BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <machine/cpu-features.h>

	.text

	.global strlen
	.type strlen, %function
	.align 4

/* size_t strlen(const char *S)
 * entry: r0 -> string
 * exit: r0 = len
 */
strlen:
	.fnstart
	len .req r0
	data .req r3
	addr .req r1

	PLD(r0, #0)
       /* Word-align address */
	bic	addr, r0, #3
       /* Get adjustment for start ... */
	ands	len, r0, #3
	neg	len, len
       /* First word of data */
	ldr	data, [addr], #4
       /* Ensure bytes preceeding start ... */
	add	ip, len, #4
	mov	ip, ip, asl #3
	mvn	r2, #0
       /* ... are masked out */
	it	ne
#ifdef __ARMEB__
	orrne	data, data, r2, lsl ip
#else
	orrne	data, data, r2, lsr ip
#endif
       /* Magic const 0x01010101 */
#if __ARM_ARCH__ >= 7
	movw	ip, #0x101
#else
	mov	ip, #0x1
	orr	ip, ip, ip, lsl #8
#endif
	orr	ip, ip, ip, lsl #16

	/* This is the main loop.  We subtract one from each byte in
	   the word: the sign bit changes iff the byte was zero or
	   0x80 -- we eliminate the latter case by anding the result
	   with the 1-s complement of the data.  */
1:
       /* test (data - 0x01010101)  */
	sub	r2, data, ip
       /* ... & ~data */
	bic	r2, r2, data
       /* ... & 0x80808080 == 0? */
	ands	r2, r2, ip, lsl #7
#if __ARM_ARCH__ >= 7
       /* yes, get more data... */
	itt	eq
	ldreq	data, [addr], #4
       /* and 4 more bytes  */
	addeq	len, len, #4
	/* If we have PLD, then unroll the loop a bit.  */
	PLD(addr, #8)
       /*  test (data - 0x01010101)  */
	ittt	eq
	subeq	r2, data, ip
       /* ... & ~data */
	biceq	r2, r2, data
       /* ... & 0x80808080 == 0? */
	andeqs	r2, r2, ip, lsl #7
#endif
	itt	eq
       /* yes, get more data... */
	ldreq	data, [addr], #4
       /* and 4 more bytes  */
	addeq	len, len, #4
	beq	1b
#ifdef __ARMEB__
	tst	data, #0xff000000
	itttt	ne
	addne	len, len, #1
	tstne	data, #0xff0000
	addne	len, len, #1
	tstne	data, #0xff00
	it	ne
	addne	len, len, #1
#else
#if __ARM_ARCH__ >= 5
	/* R2 is the residual sign bits from the above test.  All we
	need to do now is establish the position of the first zero
	byte... */
	/* Little-endian is harder, we need the number of trailing
	zeros / 8 */
#if __ARM_ARCH__ >= 7
	rbit	r2, r2
	clz	r2, r2
#  else
	rsb	r1, r2, #0
	and	r2, r2, r1
	clz	r2, r2
	rsb	r2, r2, #31
#  endif
	add	len, len, r2, lsr #3
# else  /* No CLZ instruction */
	tst	data, #0xff
	itttt	ne
	addne	len, len, #1
	tstne	data, #0xff00
	addne	len, len, #1
	tstne	data, #0xff0000
	it	ne
	addne	len, len, #1
# endif
#endif
	bx	lr
	.fnend
