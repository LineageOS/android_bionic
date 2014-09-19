/* Copyright (c) 2009-2014 The Linux Foundation. All rights reserved.
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

#include <private/bionic_asm.h>
//#define NO_FUSED_MULTIPLY

#define KRAIT_NO_AAPCS_VFP_MODE

ENTRY(pow)
#if defined(KRAIT_NO_AAPCS_VFP_MODE)
	// ARM ABI has inputs coming in via d registers, lets copy to x registers
	fmov	x0, d0
	fmov	x1, d1
#endif
	mov w12, #0x40100000    // high word of 64-bit 4.0

	// pre-staged bp values
	ldr	d5, .LbpA
	ldr	d3, .LbpB

	// load two fifths into constant term in case we need it due to offsets
	ldr	d6, .Ltwofifths

	// bp is initially 1.0, may adjust later based on x value
	fmov	d4,  #1.0

	// twoto1o5 = 2^(1/5) (input bracketing)
	ldr	x4, .Ltwoto1o5

	// twoto3o5 = 2^(3/5) (input bracketing)
	ldr	x5, .Ltwoto3o5

	// extract xmantissa
	bic	x6, x0, #0xFFF0000000000000

	// begin preparing a mask for normalization (high 32-bit mask)
	movi	d31, #0xFFFFFFFF00000000

	// double_1 = (double) 1.0
	fmov	d28, #1.0

	cmp	x6, x4

	shl	d30, d31, #20	// d30 can mask just sign/exp bits
	ushr	d29, d31, #63	// mask has only bit 1 set

	adr	x10, .LliteralTable		// x10->k4 in literal table (below)

	bhi	.Lxgt2to1over5
	// zero out lg2 constant term if don't offset our input
	fsub	d6, d6, d6
	b	.Lxle2to1over5

.Lxgt2to1over5:
	// if normalized x > 2^(1/5), bp = 1 + (2^(2/5)-1) = 2^(2/5)
	fadd	d4, d4, d5

.Lxle2to1over5:
	ldr	d5, .Lln2			// d5 = ln2 = 0.69314718056

	cmp	x6, x5				// non-normalized compare

//@@@ X Value Normalization @@@@

	// ss = abs(x) 2^(-1024)
	bic	v16.8B, v0.8B, v30.8B		// mantissa of x into v16.8B (aka d16)

	// N = (floor(log2(x)) + 0x3ff) * 2^52
	and	v2.8B, v0.8B, v30.8B		// exponent of x (d0) into v2.8B aka d2

	bls	.Lxle2to3over5			// branch not taken if (x6 > x5)
	// if normalized x > 2^(3/5), bp = 2^(2/5) + (2^(4/5) - 2^(2/5)) = 2^(4/5)
	fadd	d4, d4, d3			// d4 = 2^(2/5) + (2^(4/5) - 2^(2/5)) = 2^(4/5)
	fadd	d6, d6, d6			// d6 = 2/5 + 2/5 = 4/5 or 0 (see logic above)

.Lxle2to3over5:

	lsr	x2, x0, #32			// Need just high word of x...x2 can take it
	cmp	w2, w12				// Compare x to 4.0 (high word only)
	lsr	x3, x1, #32			// Need just high word of y...x3 can take it.
	ccmp	w3, w12, #2, ls			// If x < 4.0, compare y to 4.0 (high word)
	bic	w12, w12, #0xFFFF0000		// Change w12 for compare to 0.0000325
	orr	w12, w12, #0x3fe00000
	ccmp	w12, w2, #2, ls			// If y < 4, compare 0.5 to x

	// load log2 polynomial series constants
	ldp	d24, d25, [x10, #0]
	ldp	d26, d27, [x10, #16]

	// s = abs(x) 2^(-floor(log2(x))) (normalize abs(x) to around 1)
	orr	v16.8B, v16.8B, v28.8B

//@@@ 3/2 (Log(bp(1+s)/(1-s))) input computation (s = (x-bp)/(x+bp)) @@@@

	fsub	d19, d16, d4		// take normalized x and subtract 2^(4/5) from it
	fadd	d20, d16, d4
	bhi	.LuseFullImpl			// |x| < 0.5 or x > 4 or y > 4

	// s = (x-1)/(x+1)
	fdiv	d16, d19, d20

	// load 2/(3log2) into lg2coeff
	ldr	d21, .Ltwooverthreeln2

	// N = floor(log2(x)) * 2^52
	sub	d2, d2, d28

//@@@ 3/2 (Log(bp(1+s)/(1-s))) polynomial series @@@@

	// ss2 = ((x-bp)/(x+bp))^2
	fmul	d17, d16, d16

	// ylg2x = 3.0
	fmov	d0, #3.0
	fmul	d18, d17, d17

	// todo: useful later for two-way clamp
	fmul	d21, d21, d1

	// N = floor(log2(x))
	sshr	d2, d2, #52
	// k3 = ss^2 * L4 + L3
#ifdef NO_FUSED_MULTIPLY
	fmul	d3, d17, v24.2D[0]
	fadd	d25, d25, d3

	// k1 = ss^2 * L2 + L1
	fmul	d3, d17, v26.2D[0]
	fadd	d27, d27, d3
#else
	fmla	d25, d17, v24.2D[0]

	// k1 = ss^2 * L2 + L1
	fmla	d27, d17, v26.2D[0]
#endif

	// scale ss by 2/(3 ln 2)
	fmul	d21, d16, d21

	// ylg2x = 3.0 + s^2
	fadd	d0, d0, d17

	fmov	x2, d2
	scvtf	d3, w2		// Low-order 32-bit integer half of d2 to fp64

	// k1 = s^4 (s^2 L4 + L3) + s^2 L2 + L1
#ifdef NO_FUSED_MULTIPLY
	fmul	d31, d18, v25.2D[0]
	fadd	d27, d27, d31
#else
	fmla	d27, d18, v25.2D[0]
#endif
	// add in constant term
	fadd	d3, d3, d6

	// ylg2x = 3.0 + s^2 + s^4 (s^4 (s^2 L4 + L3) + s^2 L2 + L1)
#ifdef NO_FUSED_MULTIPLY
	fmul	d31, d18, v27.2D[0]
	fadd	d0, d0, d31
#else
	fmla	d0, d18, v27.2D[0]
#endif
	// ylg2x = y 2 s / (3 ln(2)) (3.0 + s^2 + s^4 (s^4(s^2 L4 + L3) + s^2 L2 + L1)
	fmul	d0, d21, d0

//@@@ Compute input to Exp(s) (s = y(n + log2(x)) - (floor(8 yn + 1)/8 + floor(8 ylog2(x) + 1)/8) @@@@@

	// mask to extract bit 1 (2^-2 from our fixed-point representation)
	shl	d4, d29, #1

	// double_n = y * n
	fmul	d3, d3, d1

	// Load 2^(1/4) for later computations
	ldr	d6, .Ltwoto1o4

	// either add or subtract one based on the sign of double_n and ylg2x
	sshr	d16, d0, #62
	sshr	d19, d3, #62

	// move unmodified y*lg2x into temp space
	fmov	d17, d0

	// compute floor(8 y * n + 1)/8
	// and floor(8 y (log2(x)) + 1)/8
	fcvtzs	w2, d0, #3	// no instruction exists to use s0 as a direct target
	fmov	s0, w2		// run our conversion into w2, then mov it to compensate
	// move unmodified y*n into temp space
	fmov	d18, d3
	fcvtzs	w2, d3, #3
	fmov	s3, w2

	// load exp polynomial series constants
	ldp	d20, d21, [x10, #32]
	ldp	d22, d23, [x10, #48]
	ldp	d24, d25, [x10, #64]
	ldp	d26, d27, [x10, #80]

	// mask to extract bit 2 (2^-1 from our fixed-point representation)
	shl	d1, d29, #2

	// make rounding offsets either 1 or -1 instead of 0 or -2
	orr	v16.8B, v16.8B, v29.8B
	orr	v19.8B, v19.8B, v29.8B

	// round up to the nearest 1/8th
	add	d0, d0, d16
	add	d3, d3, d19

	// clear out round-up bit for y log2(x)
	bic	v0.8B, v0.8B, v29.8B
	// clear out round-up bit for yn
	bic	v3.8B, v3.8B, v29.8B
	// add together the (fixed precision) rounded parts
	add	d31, d3, d0
	// turn int_n into a double with value 2^int_n
	shl	d2, d31, #49
	// compute masks for 2^(1/4) and 2^(1/2) fixups for fractional part of fixed-precision rounded values:
	and	v4.8B, v4.8B, v31.8B
	and	v1.8B, v1.8B, v31.8B

	// convert back into floating point, d3 now holds (double) floor(8 y * n + 1)/8
	//                                   d0 now holds (double) floor(8 y * log2(x) + 1)/8
	fmov	w2, s0
	scvtf	d0, w2, #3
	fmov	w2, s3
	scvtf	d3, w2, #3

	// put the 2 bit (0.5) through the roof of twoto1o2mask (make it 0x0 or 0xffffffffffffffff)
	uqshl	d1, d1, #62

	// put the 1 bit (0.25) through the roof of twoto1o4mask (make it 0x0 or 0xffffffffffffffff)
	uqshl	d4, d4, #63

	// center y*log2(x) fractional part between -0.125 and 0.125 by subtracting (double) floor(8 y * log2(x) + 1)/8
	fsub	d17, d17, d0
	// center y*n fractional part between -0.125 and 0.125 by subtracting (double) floor(8 y * n + 1)/8
	fsub	d18, d18, d3

	// Add fractional parts of yn and y log2(x) together
	fadd	d16, d17, d18

	// Result = 1.0 (offset for exp(s) series)
	fmov	d0, #1.0

	// multiply fractional part of y * log2(x) by ln(2)
	fmul	d16, d5, d16

//@@@ 10th order polynomial series for Exp(s) @@@@

	// ss2 = (ss)^2
	fmul	d17, d16, d16

	// twoto1o2mask = twoto1o2mask & twoto1o4
	and	v1.8B, v1.8B, v6.8B
	// twoto1o2mask = twoto1o2mask & twoto1o4
	and	v4.8B, v4.8B, v6.8B

	// Result = 1.0 + ss
	fadd	d0, d0, d16

	// k7 = ss k8 + k7
#ifdef NO_FUSED_MULTIPLY
	fmul	d31, d16, v20.2D[0]
	fadd	d21, d21, d31
#else
	fmla	d21, d16, v20.2D[0]
#endif
	// ss4 = (ss*ss) * (ss*ss)
	fmul	d18, d17, d17

	// twoto1o2mask = twoto1o2mask | (double) 1.0 - results in either 1.0 or 2^(1/4) in twoto1o2mask
	orr	v1.8B, v1.8B, v28.8B
	// twoto1o2mask = twoto1o4mask | (double) 1.0 - results in either 1.0 or 2^(1/4) in twoto1o4mask
	orr	v4.8B, v4.8B, v28.8B

	// sign could be set up here, but for now expadjustment = 1.0
	fmov	d7, #1.0

	// ss3 = (ss*ss) * ss
	fmul	d19, d17, d16

	// k0 = 1/2 (first non-unity coefficient)
	fmov	d28, #0.5

	// Mask out non-exponent bits to make sure we have just 2^int_n
	and	v2.8B, v2.8B, v30.8B

	// square twoto1o2mask to get 1.0 or 2^(1/2)
	fmul	d1, d1, d1

	// multiply twoto2o4mask into the exponent output adjustment value
	fmul	d7, d7, d4

#ifdef NO_FUSED_MULTIPLY
	// k5 = ss k6 + k5
	fmul	d31, d16, v22.2D[0]
	fadd	d23, d23, d31

	// k3 = ss k4 + k3
	fmul	d31, d16, v24.2D[0]
	fadd	d25, d25, d31

	// k1 = ss k2 + k1
	fmul	d31, d16, v26.2D[0]
	fadd	d27, d27, d31
#else
	// k5 = ss k6 + k5
	fmla	d23, d16, v22.2D[0]

	// k3 = ss k4 + k3
	fmla	d25, d16, v24.2D[0]

	// k1 = ss k2 + k1
	fmla	d27, d16, v26.2D[0]
#endif
	// multiply twoto1o2mask into exponent output adjustment value
	fmul	d7, d7, d1
#ifdef NO_FUSED_MULTIPLY
	// k5 = ss^2 ( ss k8 + k7 ) + ss k6 + k5
	fmul	d31, d17, v21.2D[0]
	fadd	d23, d23, d31

	// k1 = ss^2 ( ss k4 + k3 ) + ss k2 + k1
	fmul	d31, d17, v25.2D[0]
	fadd	d27, d27, d31

	// Result = 1.0 + ss + 1/2 ss^2
	fmul	d31, d17, v28.2D[0]
	fadd	d0, d0, d31
#else
	// k5 = ss^2 ( ss k8 + k7 ) + ss k6 + k5
	fmla	d23, d17, v21.2D[0]

	// k1 = ss^2 ( ss k4 + k3 ) + ss k2 + k1
	fmla	d27, d17, v25.2D[0]

	// Result = 1.0 + ss + 1/2 ss^2
	fmla	d0, d17, v28.2D[0]
#endif
	// Adjust int_n so that it's a double precision value that can be multiplied by Result
	add	d7, d2, d7
#ifdef NO_FUSED_MULTIPLY
	// k1 = ss^4 ( ss^2 ( ss k8 + k7 ) + ss k6 + k5 ) + ss^2 ( ss k4 + k3 ) + ss k2 + k1
	fmul	d31, d18, v23.2D[0]
	fadd	d27, d27, d31

	// Result = 1.0 + ss + 1/2 ss^2 + ss^3 ( ss^4 ( ss^2 ( ss k8 + k7 ) + ss k6 + k5 ) + ss^2 ( ss k4 + k3 ) + ss k2 + k1 )
	fmul	d31, d19, v27.2D[0]
	fadd	d0, d0, d31
#else
	// k1 = ss^4 ( ss^2 ( ss k8 + k7 ) + ss k6 + k5 ) + ss^2 ( ss k4 + k3 ) + ss k2 + k1
	fmla	d27, d18, v23.2D[0]

	// Result = 1.0 + ss + 1/2 ss^2 + ss^3 ( ss^4 ( ss^2 ( ss k8 + k7 ) + ss k6 + k5 ) + ss^2 ( ss k4 + k3 ) + ss k2 + k1 )
	fmla	d0, d19, v27.2D[0]
#endif
	// multiply by adjustment (sign*(rounding ? sqrt(2) : 1) * 2^int_n)
	fmul	d0, d7, d0

.LleavePow:
#if defined(KRAIT_NO_AAPCS_VFP_MODE)
	// return Result (FP)
	// fmov	x0, d0
#endif
.LleavePowDirect:
	// leave directly returning whatever is in d0
	ret
.LuseFullImpl:
	fmov	d0, x0
	fmov	d1, x1
	b	__full_ieee754_pow

.align 6
.LliteralTable:
// Least-sqares tuned constants for 11th order (log2((1+s)/(1-s)):
.LL4: // ~3/11
    .long       0x53a79915, 0x3fd1b108
.LL3: // ~1/3
    .long       0x9ca0567a, 0x3fd554fa
.LL2: // ~3/7
    .long       0x1408e660, 0x3fdb6db7
.LL1: // ~3/5
    .long       0x332D4313, 0x3fe33333

// Least-squares tuned constants for 10th order exp(s):
.LE10: // ~1/3628800
    .long       0x25c7ba0a, 0x3e92819b
.LE9: // ~1/362880
    .long       0x9499b49c, 0x3ec72294
.LE8: // ~1/40320
    .long       0xabb79d95, 0x3efa019f
.LE7: // ~1/5040
    .long       0x8723aeaa, 0x3f2a019f
.LE6: // ~1/720
    .long       0x16c76a94, 0x3f56c16c
.LE5: // ~1/120
    .long       0x11185da8, 0x3f811111
.LE4: // ~1/24
    .long       0x5555551c, 0x3fa55555
.LE3: // ~1/6
    .long       0x555554db, 0x3fc55555

.LbpA: // (2^(2/5) - 1)
    .long       0x4ee54db1, 0x3fd472d1

.LbpB: // (2^(4/5) - 2^(2/5))
    .long       0x1c8a36cf, 0x3fdafb62

.Ltwofifths: // 2/5
    .long       0x9999999a, 0x3fd99999

.Ltwooverthreeln2:
    .long       0xDC3A03FD, 0x3FEEC709

.Ltwoto1o5:	// 2^(1/5) exponent 3ff stripped for non-normalized compares
    .long	0x86BAE675, 0x00026111

.Ltwoto3o5:	// 2^(3/5) exponent 3ff stripped for non-normalized compares
    .long	0x03B2AE5C, 0x00084060

.Lln2: // ln(2)
    .long       0xFEFA39EF, 0x3FE62E42

.Ltwoto1o4: // 2^1/4
    .long       0x0a31b715, 0x3ff306fe
END(pow)
