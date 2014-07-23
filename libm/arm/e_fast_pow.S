/* Copyright (C) 2012 The Android Open Source Project
 * Copyright (c) 2013-2014, NVIDIA CORPORATION.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 *  y    y*log2(x)
 * x  = 2
 *
 */

#include <bionic_asm.h>

#define x		d0
#define y		d1
#define ret		d0
#define exp		s5
#define iylog2x		s6
#define expd		d20
#define ylog2x		d21
#define iylog2xd	d22
#define t0		d23
#define diff		d24

#if FPU_VFPV4
	.fpu	vfpv4
#define MLAF64		vfma.f64
#define MLSF64		vfms.f64
#else
#define MLAF64		vmla.f64
#define MLSF64		vmls.f64
#endif

ENTRY(pow)	/* x in r0, r1. y in r2, r3 */

	push		{r4, r5, lr}

	/* x is close to 0 / minus? */
	cmp		r1, #0x30000000
	ble		punt_to_ieee754_pow

	/* |y| == +/-2.0? */
	bic		r4, r3, #0x80000000
	cmp		r4, #0x40000000
	cmpeq		r2, #0
	beq		return_y_is_two

	/* |y| == +/-0.5? */
	mov		r5, #0x3fc00000
	add		r5, r5, #0x00200000
	cmp		r4, r5
	cmpeq		r2, #0
	beq		return_y_is_0_5

	/* |y| > 4.0? */
	mov		r5, #0x40000000
	add		r5, r5, #0x00100000
	cmp		r4, r5
	bhi		punt_to_ieee754_pow

	/* x > 4.0? */
	cmp		r1, r5
	bhi		punt_to_ieee754_pow

	/* |y| == +/-1.0? */
	mov		r5, #0x3fc00000
	add		r5, r5, #0x00300000
	cmp		r4, r5
	cmpeq		r2, #0
	beq		return_y_is_one

	/* x == 1.0? */
	cmp		r1, r5
	cmpeq		r0, #0
	beq		return_x

	/* extract exp of x */
	lsr		r4, r5, #20
	lsr		r5, r1, #20
	sub		r5, r5, r4	/* exp -> r5 */

	/* set exp of x to 0 */
	bfi		r1, r4, #20, #11

	/* ret = __kernel_log2(x); */
	/* 1.0 <= x < 2.0 */
	/* 0.0 <= ret < 1.0 */
	vmov		x, r0, r1
	vmov		y, r2, r3
	bl		__kernel_log2

	/* ylog2x = ret * y + exp * y; */
	vmov		exp, r5
	vcvt.f64.s32	expd, exp
	vmul.f64	ylog2x, ret, y
	MLAF64		ylog2x, expd, y

	/* get the diff */
	vmov.f64	diff, ylog2x
	MLSF64		diff, expd, y
	MLSF64		diff, ret, y

	/* iylog2x = (int)ylog2x; */
	vcvt.s32.f64	iylog2x, ylog2x
	vcvt.f64.s32	iylog2xd, iylog2x
	vmov		r5, iylog2x	/* iylog2x -> r5 */

	/* x = 1.0 + ylog2x - iylog2x; */
	vmov.f64	t0, #1.0
	vsub.f64	x, ylog2x, iylog2xd
	vadd.f64	x, x, t0

	/* if (x < 1.0) {iylog2x--; x++;} */
	vcmp.f64	x, t0
	vmrs		APSR_nzcv, fpscr
	bge		skip
	sub		r5, r5, #1
	vadd.f64	x, x, t0

skip:
	/* default diff from x*/
	vsub.f64	x, x, diff

	/* ret = __kernel_pow2(x); */
	/* 1.0 <= x < 2.0 */
	/* 2.0 <= ret < 4.0 */
	vmov		r0, r1, x
	bl		__kernel_pow2
	vmov		r0, r1, ret

	/* if (ret >= 4.0) {exp++;} */
	movw		r4, #0xffff
	movt		r4, #0x400f
	cmp		r1, r4
	addgt		r5, r5, #1

	/* set exp of ret to iylog2x */
	add		r5, r5, #0x3fc
	add		r5, r5, #0x3
	bfi		r1, r5, #20, #11

	pop		{r4, r5, pc}

return_x:
	pop		{r4, r5, pc}

return_y_is_two:
	vmov		x, r0, r1
	vmul.f64	ret, x, x
	cmp		r3, #0
	blt		return_recp
	vmov		r0, r1, ret
	pop		{r4, r5, pc}

return_y_is_one:
	cmp		r3, #0
	popgt		{r4, r5, pc}
	vmov		ret, r0, r1
	b		return_recp

return_y_is_0_5:
	vmov		x, r0, r1
	vsqrt.f64	ret, x
	cmp		r3, #0
	blt		return_recp
	vmov		r0, r1, ret
	pop		{r4, r5, pc}

return_recp:
	vmov.f64	t0, #1.0
	vdiv.f64	ret, t0, ret
	vmov		r0, r1, ret
	pop		{r4, r5, pc}

punt_to_ieee754_pow:
	bl		__ieee754_pow
	pop		{r4, r5, pc}

END(pow)

	.weak		powl
	.equ		powl,pow
