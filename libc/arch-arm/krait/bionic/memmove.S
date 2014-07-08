/***************************************************************************
 Copyright (c) 2009-2014 The Linux Foundation. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of The Linux Foundation nor the names of its contributors may
       be used to endorse or promote products derived from this software
       without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
  ***************************************************************************/

/***************************************************************************
 *  Neon memmove: Attempts to do a memmove with Neon registers if possible,
 *     Inputs:
 *        dest: The destination buffer
 *        src: The source buffer
 *        n: The size of the buffer to transfer
 *     Outputs:
 *
 ***************************************************************************/

#include <machine/cpu-features.h>
#include <machine/asm.h>
/*
 * These can be overridden in:
 *   device/<vendor>/<board>/BoardConfig.mk
 * by setting the following:
 *   TARGET_USE_KRAIT_BIONIC_OPTIMIZATION := true
 *   TARGET_USE_KRAIT_PLD_SET := true
 *   TARGET_KRAIT_BIONIC_PLDOFFS := <pldoffset>
 *   TARGET_KRAIT_BIONIC_PLDSIZE := <pldsize>
 *   TARGET_KRAIT_BIONIC_PLDTHRESH := <pldthreshold>
 */
#ifndef PLDOFFS
#define PLDOFFS	(10)
#endif
#ifndef PLDTHRESH
#define PLDTHRESH (PLDOFFS)
#endif
#if (PLDOFFS < 5)
#error Routine does not support offsets less than 5
#endif
#if (PLDTHRESH < PLDOFFS)
#error PLD threshold must be greater than or equal to the PLD offset
#endif
#ifndef PLDSIZE
#define PLDSIZE (64)
#endif

	.text
	.syntax	unified
	.fpu neon
	.thumb
	.thumb_func

ENTRY(bcopy)
        .cfi_startproc
	mov	r12, r0
	mov	r0, r1
	mov	r1, r12
        // Fall through to memmove
        .cfi_endproc
END(bcopy)

ENTRY(memmove)
_memmove_words:
        .cfi_startproc
	.save	{r0, lr}
	cmp	r2, #0
	it	ne
	subsne	r12, r0, r1	// Warning: do not combine these "it" blocks
	it	eq
	bxeq	lr
//	memmove only if r1 < r0 < r1+r2
	cmp	r0, r1
	itt	ge
	addge	r12, r1, r2
	cmpge	r12, r0
	it	le
	ble	memcpy
	cmp	r2, #4
	it	le
	ble	.Lneon_b2f_smallcopy_loop
	push	{r0, lr}
	add	r0, r0, r2
	add	r1, r1, r2
	cmp	r2, #64
	it	ge
	bge	.Lneon_b2f_copy_64
	cmp	r2, #32
	it	ge
	bge	.Lneon_b2f_copy_32
	cmp	r2, #8
	it	ge
	bge	.Lneon_b2f_copy_8
	b	.Lneon_b2f_copy_1
.Lneon_b2f_copy_64:
	mov	r12, r2, lsr #6
	add	r0, r0, #32
	add	r1, r1, #32
	cmp	r12, #PLDTHRESH
	it	le
	ble	.Lneon_b2f_copy_64_loop_nopld
	sub	r12, #PLDOFFS
	sub	lr, r1, #(PLDOFFS)*PLDSIZE
.Lneon_b2f_copy_64_loop_outer:
	pld	[lr]
	sub	r1, r1, #96
	sub	r0, r0, #96
	vld1.32	{q0, q1}, [r1]!
	vld1.32	{q2, q3}, [r1]
	sub	lr, lr, #64
	subs	r12, r12, #1
	vst1.32	{q0, q1}, [r0]!
	vst1.32	{q2, q3}, [r0]
	it	ne
	bne	.Lneon_b2f_copy_64_loop_outer
	mov	r12, #PLDOFFS
.Lneon_b2f_copy_64_loop_nopld:
	sub	r1, r1, #96
	sub	r0, r0, #96
	vld1.32	{q8, q9}, [r1]!
	vld1.32	{q10, q11}, [r1]
	subs	r12, r12, #1
	vst1.32	{q8, q9}, [r0]!
	vst1.32	{q10, q11}, [r0]
	it	ne
	bne	.Lneon_b2f_copy_64_loop_nopld
	ands	r2, r2, #0x3f
	it	eq
	beq	.Lneon_memmove_done
	sub	r1, r1, #32
	sub	r0, r0, #32
	cmp	r2, #32
	it	lt
	blt	.Lneon_b2f_copy_8
.Lneon_b2f_copy_32:
	sub	r1, r1, #32
	sub	r0, r0, #32
	vld1.32	{q0, q1}, [r1]
	vst1.32	{q0, q1}, [r0]
	ands	r2, r2, #0x1f
	it	eq
	beq	.Lneon_memmove_done
.Lneon_b2f_copy_8:
	movs	r12, r2, lsr #0x3
	it	eq
	beq	.Lneon_b2f_copy_1
.Lneon_b2f_copy_8_loop:
	sub	r1, r1, #8
	sub	r0, r0, #8
	vld1.32	{d0}, [r1]
	subs	r12, r12, #1
	vst1.32	{d0}, [r0]
	it	ne
	bne	.Lneon_b2f_copy_8_loop
	ands	r2, r2, #0x7
	beq	.Lneon_memmove_done
.Lneon_b2f_copy_1:
	movs	r12, r2, lsl #29
	itttt	mi
	submi	r1, r1, #4
	submi	r0, r0, #4
	ldrmi	r3, [r1]
	strmi	r3, [r0]
	movs	r2, r2, lsl #31
	itttt	cs
	subcs	r1, r1, #2
	subcs	r0, r0, #2
	ldrhcs	r3, [r1]
	strhcs	r3, [r0]
	itttt	mi
	submi	r1, r1, #1
	submi	r0, r0, #1
	ldrbmi	r12, [r1]
	strbmi	r12, [r0]
.Lneon_memmove_done:
	pop	{r0, pc}
.Lneon_b2f_smallcopy_loop:
	// 4 bytes or less
	add	r1, r1, r2
	add	r0, r0, r2
	movs	r12, r2, lsl #29
	itttt	mi
	submi	r1, r1, #4
	submi	r0, r0, #4
	ldrmi	r3, [r1]
	strmi	r3, [r0]
	movs	r2, r2, lsl #31
	itttt	cs
	subcs	r1, r1, #2
	subcs	r0, r0, #2
	ldrhcs	r3, [r1]
	strhcs	r3, [r0]
	itttt	mi
	submi	r1, r1, #1
	submi	r0, r0, #1
	ldrbmi	r12, [r1]
	strbmi	r12, [r0]
	bx	lr
	.cfi_endproc
END(memmove)

