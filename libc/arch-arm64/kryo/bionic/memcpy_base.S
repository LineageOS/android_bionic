/* Copyright (c) 2015 The Linux Foundation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of The Linux Foundation nor the names of its contributors may
 *       be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#ifdef PLDOFFS
#undef PLDOFFS
#endif
#define PLDOFFS		(16)

#ifdef PLDTHRESH
#undef PLDTHRESH
#endif
#define PLDTHRESH (PLDOFFS)

#ifdef BBTHRESH
#undef BBTHRESH
#endif
#define BBTHRESH (2048/128)

#if (PLDOFFS < 1)
#error Routine does not support offsets less than 1
#endif
#if (PLDTHRESH < PLDOFFS)
#error PLD threshold must be greater than or equal to the PLD offset
#endif

#ifdef PLDSIZE
#undef PLDSIZE
#endif
#define PLDSIZE	(128)

kryo_bb_memcpy:
	mov	x11, x0
	cmp	x2, #4
	blo	kryo_bb_lt4
	cmp	x2, #16
	blo	kryo_bb_lt16
	cmp	x2, #32
	blo	kryo_bb_16
	cmp	x2, #64
	blo	kryo_bb_copy_32_a
	cmp	x2, #128
	blo	kryo_bb_copy_64_a

	// we have at least 127 bytes to achieve 128-byte alignment
	neg	x3, x1			// calculate count to get SOURCE aligned
	ands	x3, x3, #0x7F
	b.eq	kryo_bb_source_aligned	// already aligned
	// alignment fixup, small to large (favorable alignment)
	tbz	x3, #0, 1f
	ldrb	w5, [x1], #1
	strb	w5, [x0], #1
1:	tbz	x3, #1, 2f
	ldrh	w6, [x1], #2
	strh	w6, [x0], #2
2:	tbz	x3, #2, 3f
	ldr	w8, [x1], #4
	str	w8, [x0], #4
3:	tbz	x3, #3, 4f
	ldr	x9, [x1], #8
	str	x9, [x0], #8
4:	tbz	x3, #4, 5f
	ldr	q7, [x1], #16
	str	q7, [x0], #16
5:	tbz	x3, #5, 55f
	ldp	q0, q1, [x1], #32
	stp	q0, q1, [x0], #32
55:	tbz	x3, #6, 6f
	ldp	q0, q1, [x1], #32
	ldp	q2, q3, [x1], #32
	stp	q0, q1, [x0], #32
	stp	q2, q3, [x0], #32
6:	subs	x2, x2, x3		// fixup count after alignment
	b.eq	kryo_bb_exit
	cmp	x2, #128
	blo	kryo_bb_copy_64_a
kryo_bb_source_aligned:
	lsr	x12, x2, #7
	cmp	x12, #PLDTHRESH
	bls	kryo_bb_copy_128_loop_nopld

	cmp	x12, #BBTHRESH
	bls	kryo_bb_prime_pump

	add	x14, x0, #0x400
	add	x9,  x1, #(PLDOFFS*PLDSIZE)
	sub	x14, x14, x9
	lsl	x14, x14, #(21+32)
	lsr	x14, x14, #(21+32)
	add	x14, x14, #(PLDOFFS*PLDSIZE)
	cmp	x12, x14, lsr #7
	bls	kryo_bb_prime_pump

	mov	x9, #(PLDOFFS)
	lsr     x13, x14, #7
	subs    x9, x13, x9
	bls	kryo_bb_prime_pump

	add	x10, x1, x14
	bic	x10, x10, #0x7F		// Round to multiple of PLDSIZE

	sub	x12, x12, x14, lsr #7
	cmp	x9, x12
	sub     x13, x12, x9
	csel    x12, x13, x12, LS
	csel    x9, x12, x9, HI
	csel    x12, xzr, x12, HI

	prfm	PLDL1STRM, [x1, #((PLDOFFS-1)*PLDSIZE)]
	prfm	PLDL1STRM, [x1, #((PLDOFFS-1)*PLDSIZE+64)]
kryo_bb_copy_128_loop_outer_doublepld:
	prfm	PLDL1STRM, [x1, #((PLDOFFS)*PLDSIZE)]
	prfm	PLDL1STRM, [x1, #((PLDOFFS)*PLDSIZE)+64]
	subs	x9, x9, #1
	ldp	q0, q1, [x1], #32
	ldp	q2, q3, [x1], #32
	ldp	q4, q5, [x1], #32
	ldp	q6, q7, [x1], #32
	prfm	PLDL1KEEP, [x10]
	prfm	PLDL1KEEP, [x10, #64]
	add	x10, x10, #128
	stp	q0, q1, [x0], #32
	stp	q2, q3, [x0], #32
	stp	q4, q5, [x0], #32
	stp	q6, q7, [x0], #32
	bne	kryo_bb_copy_128_loop_outer_doublepld
	cmp	x12, #0
	beq	kryo_bb_pop_before_nopld
	cmp	x12, #(448*1024/128)
	bls	kryo_bb_copy_128_loop_outer

kryo_bb_copy_128_loop_ddr:
	subs	x12, x12, #1
	ldr	x3, [x10], #128
	ldp	q0, q1, [x1], #32
	ldp	q2, q3, [x1], #32
	ldp	q4, q5, [x1], #32
	ldp	q6, q7, [x1], #32
	stp	q0, q1, [x0], #32
	stp	q2, q3, [x0], #32
	stp	q4, q5, [x0], #32
	stp	q6, q7, [x0], #32
	bne	kryo_bb_copy_128_loop_ddr
	b	kryo_bb_pop_before_nopld

kryo_bb_prime_pump:
	mov	x14, #(PLDOFFS*PLDSIZE)
	add	x10, x1, #(PLDOFFS*PLDSIZE)
	bic	x10, x10, #0x7F
	sub	x12, x12, #PLDOFFS
	prfum	PLDL1KEEP, [x10, #(-1*PLDSIZE)]
	prfum	PLDL1KEEP, [x10, #(-1*PLDSIZE+64)]
	cmp	x12, #(448*1024/128)
	bhi	kryo_bb_copy_128_loop_ddr

kryo_bb_copy_128_loop_outer:
	subs	x12, x12, #1
	prfm	PLDL1KEEP, [x10]
	prfm	PLDL1KEEP, [x10, #64]
	ldp	q0, q1, [x1], #32
	ldp	q2, q3, [x1], #32
	ldp	q4, q5, [x1], #32
	ldp	q6, q7, [x1], #32
	add	x10, x10, #128
	stp	q0, q1, [x0], #32
	stp	q2, q3, [x0], #32
	stp	q4, q5, [x0], #32
	stp	q6, q7, [x0], #32
	bne	kryo_bb_copy_128_loop_outer

kryo_bb_pop_before_nopld:
	lsr	x12, x14, #7
kryo_bb_copy_128_loop_nopld:
	ldp	q0, q1, [x1], #32
	ldp	q2, q3, [x1], #32
	ldp	q4, q5, [x1], #32
	ldp	q6, q7, [x1], #32
	subs	x12, x12, #1
	stp	q0, q1, [x0], #32
	stp	q2, q3, [x0], #32
	stp	q4, q5, [x0], #32
	stp	q6, q7, [x0], #32
	bne	kryo_bb_copy_128_loop_nopld
	ands	x2, x2, #0x7f
	beq	kryo_bb_exit

kryo_bb_copy_64_a:
	tbz	x2, #6, kryo_bb_copy_32_a
	ldp	q0, q1, [x1], #32
	ldp	q2, q3, [x1], #32
	stp	q0, q1, [x0], #32
	stp	q2, q3, [x0], #32
kryo_bb_copy_32_a:
	tbz	x2, #5, kryo_bb_16
	ldp	q0, q1, [x1], #32
	stp	q0, q1, [x0], #32
kryo_bb_16:
	tbz	x2, #4, kryo_bb_lt16
	ldr	q7, [x1], #16
	str	q7, [x0], #16
	ands	x2, x2, #0x0f
	beq	kryo_bb_exit
kryo_bb_lt16:
	tbz	x2, #3, kryo_bb_lt8
	ldr	x3, [x1], #8
	str	x3, [x0], #8
kryo_bb_lt8:
	tbz	x2, #2, kryo_bb_lt4
	ldr	w3, [x1], #4
	str	w3, [x0], #4
kryo_bb_lt4:
	tbz	x2, #1, kryo_bb_lt2
	ldrh	w3, [x1], #2
	strh	w3, [x0], #2
kryo_bb_lt2:
	tbz	x2, #0, kryo_bb_exit
	ldrb	w3, [x1], #1
	strb	w3, [x0], #1
kryo_bb_exit:
	mov	x0, x11
	ret

