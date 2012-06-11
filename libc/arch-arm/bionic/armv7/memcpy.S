/* Copyright (c) 2010-2011, Linaro Limited
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

      * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

      * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

      * Neither the name of Linaro Limited nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   Written by Dave Gilbert <david.gilbert@linaro.org>
   Adapted to Bionic by Bernhard Rosenkraenzer <Bernhard.Rosenkranzer@linaro.org>

   This memcpy routine is optimised on a Cortex-A9 and should work on
   all ARMv7 processors. */

#include <machine/asm.h>

@ 2011-09-01 david.gilbert@linaro.org
@    Extracted from local git 2f11b436

	.syntax unified
	.arch armv7-a

@ this lets us check a flag in a 00/ff byte easily in either endianness
#ifdef __ARMEB__
#define CHARTSTMASK(c) 1<<(31-(c*8))
#else
#define CHARTSTMASK(c) 1<<(c*8)
#endif
	.thumb

#if defined(__ARM_NEON__)
@ ---------------------------------------------------------------------------
	.thumb_func
	.p2align 4,,15
ENTRY(memcpy)
	@ r0 = dest
	@ r1 = source
	@ r2 = count
	@ returns dest in r0
	@ Overlaps of source/dest not allowed according to spec
	@ Note this routine relies on v7 misaligned loads/stores
	pld	[r1]
	mov	r12, r0		@ stash original r0
	cmp	r2,#32
	blt	10f		@ take the small copy case separately

	@ test for either source or destination being misaligned
	@ (We only rely on word align)
	tst	r0,#3
	it	eq
	tsteq	r1,#3
	bne	30f		@ misaligned case

4:
	@ at this point we are word (or better) aligned and have at least
	@ 32 bytes to play with

	@ If it's a huge copy,  try Neon
	cmp	r2, #128*1024
	bge	35f		@ Sharing general non-aligned case here, aligned could be faster

	push	{r3,r4,r5,r6,r7,r8,r10,r11}
5:
	ldmia	r1!,{r3,r4,r5,r6,r7,r8,r10,r11}
	sub	r2,r2,#32
	pld	[r1,#96]
	cmp	r2,#32
	stmia	r0!,{r3,r4,r5,r6,r7,r8,r10,r11}
	bge	5b

	pop	{r3,r4,r5,r6,r7,r8,r10,r11}
	@ We are now down to less than 32 bytes
	cbz	r2,15f		@ quick exit for the case where we copied a multiple of 32

10:  @ small copies (not necessarily aligned - note might be slightly more than 32bytes)
	cmp	r2,#4
	blt	12f
11:
	sub	r2,r2,#4
	cmp	r2,#4
	ldr	r3, [r1],#4
	str	r3, [r0],#4
	bge	11b
12:
	tst	r2,#2
	itt	ne
	ldrhne	r3, [r1],#2
	strhne	r3, [r0],#2

	tst	r2,#1
	itt	ne
	ldrbne	r3, [r1],#1
	strbne	r3, [r0],#1

15:  @ exit
	mov	r0,r12		@ restore r0
	bx	lr

	.align 2
	.p2align 4,,15
30:  @ non-aligned - at least 32 bytes to play with
	@ Test for co-misalignment
	eor	r3, r0, r1
	tst	r3,#3
	beq	50f

	@ Use Neon for misaligned
35:
	vld1.8	{d0,d1,d2,d3}, [r1]!
	sub	r2,r2,#32
	cmp	r2,#32
	pld	[r1,#96]
	vst1.8	{d0,d1,d2,d3}, [r0]!
	bge	35b
	b	10b		@ TODO: Probably a bad idea to switch to ARM at this point

	.align 2
	.p2align 4,,15
50: @ Co-misaligned
	@ At this point we've got at least 32 bytes
51:
	ldrb	r3,[r1],#1
	sub	r2,r2,#1
	strb	r3,[r0],#1
	tst	r0,#7
	bne	51b

	cmp	r2,#32
	blt	10b
	b	4b
END(memcpy)
#else /* __ARM_NEON__ */

	.thumb

@ ---------------------------------------------------------------------------
	.thumb_func
	.p2align 4,,15
ENTRY(memcpy)
	@ r0 = dest
	@ r1 = source
	@ r2 = count
	@ returns dest in r0
	@ Overlaps of source/dest not allowed according to spec
	@ Note this routine relies on v7 misaligned loads/stores
	pld	[r1]
	mov	r12, r0		@ stash original r0
	cmp	r2,#32
	blt	10f		@ take the small copy case separately

	@ test for either source or destination being misaligned
	@ (We only rely on word align)
	@ TODO: Test for co-misalignment
	tst	r0,#3
	it	eq
	tsteq	r1,#3
	bne	30f		@ misaligned case

4:
	@ at this point we are word (or better) aligned and have at least
	@ 32 bytes to play with
	push	{r3,r4,r5,r6,r7,r8,r10,r11}
5:
	ldmia	r1!,{r3,r4,r5,r6,r7,r8,r10,r11}
	pld	[r1,#96]
	sub	r2,r2,#32
	cmp	r2,#32
	stmia	r0!,{r3,r4,r5,r6,r7,r8,r10,r11}
	bge	5b

	pop	{r3,r4,r5,r6,r7,r8,r10,r11}
	@ We are now down to less than 32 bytes
	cbz	r2,15f		@ quick exit for the case where we copied a multiple of 32

10:  @ small copies (not necessarily aligned - note might be slightly more than 32bytes)
	cmp	r2,#4
	blt	12f
11:
	sub	r2,r2,#4
	cmp	r2,#4
	ldr	r3, [r1],#4
	str	r3, [r0],#4
	bge	11b
12:
	tst	r2,#2
	itt	ne
	ldrhne	r3, [r1],#2
	strhne	r3, [r0],#2

	tst	r2,#1
	itt	ne
	ldrbne	r3, [r1],#1
	strbne	r3, [r0],#1

15:  @ exit
	mov	r0,r12		@ restore r0
	bx	lr

30:  @ non-aligned - at least 32 bytes to play with
	@ On v7 we're allowed to do ldr's and str's from arbitrary alignments
	@ but not ldrd/strd or ldm/stm
	@ Note Neon is often a better choice misaligned using vld1

	@ copy a byte at a time until the point where we have an aligned destination
	@ we know we have enough bytes to go to know we won't run out in this phase
	tst	r0,#7
	beq	35f

31:
	ldrb	r3,[r1],#1
	sub	r2,r2,#1
	strb	r3,[r0],#1
	tst	r0,#7
	bne	31b

	cmp	r2,#32		@ Lets get back to knowing we have 32 bytes to play with
	blt	11b

	@ Now the store address is aligned
35:
	push	{r3,r4,r5,r6,r7,r8,r10,r11,r12,r14}
	and	r6,r1,#3	@ how misaligned we are
	cmp	r6,#2
	cbz	r6, 100f	@ Go there if we're actually aligned
	bge	120f		@ And here if it's aligned on 2 or 3 byte
		@ Note might be worth splitting to bgt and a separate beq
		@ if the branches are well separated

	@ At this point dest is aligned, source is 1 byte forward
110:
	ldr	r3,[r1]		@ Misaligned load - but it gives the first 4 bytes to store
	sub	r2,r2,#3	@ Number of bytes left in whole words we can load
	add	r1,r1,#3	@ To aligned load address
	bic	r3,r3,#0xff000000

112:
	ldmia	r1!,{r5,r6,r7,r8}
	sub	r2,r2,#32
	cmp	r2,#32
	pld	[r1,#96]

	orr	r3,r3,r5,lsl#24
	mov	r4,r5,lsr#8
	mov	r5,r6,lsr#8
	orr	r4,r4,r6,lsl#24
	mov	r6,r7,lsr#8
	ldmia	r1!,{r10,r11,r12,r14}
	orr	r5,r5,r7,lsl#24
	mov	r7,r8,lsr#8
	orr	r6,r6,r8,lsl#24
	mov	r8,r10,lsr#8
	orr	r7,r7,r10,lsl#24
	mov	r10,r11,lsr#8
	orr	r8,r8,r11,lsl#24
	orr	r10,r10,r12,lsl#24
	mov	r11,r12,lsr#8
	orr	r11,r11,r14,lsl#24
	stmia	r0!,{r3,r4,r5,r6,r7,r8,r10,r11}
	mov	r3,r14,lsr#8

	bge	112b

	@ Deal with the stragglers
	add	r2,r2,#3
	sub	r1,r1,#3
	pop	{r3,r4,r5,r6,r7,r8,r10,r11,r12,r14}
	b	10b

100:  @ Dest and source aligned - must have been originally co-misaligned
	@ Fallback to main aligned case if still big enough
	pop	{r3,r4,r5,r6,r7,r8,r10,r11,r12,r14}
	b	4b		@ Big copies (32 bytes or more)

120:  @ Dest is aligned, source is align+2 or 3
	bgt	130f		@ Now split off for 3 byte offset

	ldrh	r3,[r1]
	sub	r2,r2,#2	@ Number of bytes left in whole words we can load
	add	r1,r1,#2	@ To aligned load address

122:
	ldmia	r1!,{r5,r6,r7,r8}
	sub	r2,r2,#32
	cmp	r2,#32
	pld	[r1,#96]

	orr	r3,r3,r5,lsl#16
	mov	r4,r5,lsr#16
	mov	r5,r6,lsr#16
	orr	r4,r4,r6,lsl#16
	mov	r6,r7,lsr#16
	ldmia	r1!,{r10,r11,r12,r14}
	orr	r5,r5,r7,lsl#16
	orr	r6,r6,r8,lsl#16
	mov	r7,r8,lsr#16
	orr	r7,r7,r10,lsl#16
	mov	r8,r10,lsr#16
	orr	r8,r8,r11,lsl#16
	mov	r10,r11,lsr#16
	orr	r10,r10,r12,lsl#16
	mov	r11,r12,lsr#16
	orr	r11,r11,r14,lsl#16
	stmia	r0!,{r3,r4,r5,r6,r7,r8,r10,r11}
	mov	r3,r14,lsr#16

	bge	122b

	@ Deal with the stragglers
	add	r2,r2,#2
	sub	r1,r1,#2
	pop	{r3,r4,r5,r6,r7,r8,r10,r11,r12,r14}
	b	10b

130:  @ Dest is aligned, source is align+3
	ldrb	r3,[r1]
	sub	r2,r2,#1	@ Number of bytes left in whole words we can load
	add	r1,r1,#1	@ To aligned load address

132:
	ldmia	r1!,{r5,r6,r7,r8}
	sub	r2,r2,#32
	cmp	r2,#32
	pld	[r1,#96]

	orr	r3,r3,r5,lsl#8
	mov	r4,r5,lsr#24
	mov	r5,r6,lsr#24
	orr	r4,r4,r6,lsl#8
	mov	r6,r7,lsr#24
	ldmia	r1!,{r10,r11,r12,r14}
	orr	r5,r5,r7,lsl#8
	mov	r7,r8,lsr#24
	orr	r6,r6,r8,lsl#8
	mov	r8,r10,lsr#24
	orr	r7,r7,r10,lsl#8
	orr	r8,r8,r11,lsl#8
	mov	r10,r11,lsr#24
	orr	r10,r10,r12,lsl#8
	mov	r11,r12,lsr#24
	orr	r11,r11,r14,lsl#8
	stmia	r0!,{r3,r4,r5,r6,r7,r8,r10,r11}
	mov	r3,r14,lsr#24

	bge	132b

	@ Deal with the stragglers
	add	r2,r2,#1
	sub	r1,r1,#1
	pop	{r3,r4,r5,r6,r7,r8,r10,r11,r12,r14}
	b	10b
END(memcpy)
#endif
