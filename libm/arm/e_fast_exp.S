/* Copyright (C) 2012 The Android Open Source Project
 * Copyright (c) 2013, NVIDIA CORPORATION.  All rights reserved.
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
 *  x    k+x'    k    x'
 * e  = e     = e  * e   (1.0 <= x' < 2.0, k is integer)
 *
 */

#include <float.h>
#include <machine/cpu-features.h>
#include <machine/asm.h>

#define x		d0
#define x2		d1
#define ret		d0
#define sk		s8
#define dk		d2
#define rk		r5
#define t0		d3

ENTRY(exp)
	 .cfi_startproc

	/* |x| < 2^(-28)? */
	bic		r2, r1, #0x80000000
	mov		r3, #0x0
	movt		r3, #0x3e30
	cmp		r2, r3
	blt		__ieee754_exp

	/* |x| >= 16? */
	movt		r3, #0x4030
	cmp		r2, r3
	bge		__ieee754_exp

	push		{rk, lr}
	vmov		x, r0, r1

	/* |x| >= 1? */
	movt		r3, #0x3ff0
	cmp		r2, r3
	bge		calc_k

	/* if (x > 0) {x++; k=-1} else {x+=2; k=-2} */
	cmp		r1, #0x0
	bgt		plus
	vmov.f64	t0, #2.0
	vadd.f64	x, x, t0
	mov		rk, #-2
	b		skip
plus:
	vmov.f64	t0, #1.0
	vadd.f64	x, x, t0
	mov		rk, #-1
	b		skip

calc_k:
	/* k = (int)x; */
	vcvt.s32.f64	sk, x
	vcvt.f64.s32	dk, sk
	vmov		rk, sk

	/* x = 1.0 + x - k; k-- */
	vmov.f64	t0, #1.0
	vadd.f64	x, x, t0
	vsub.f64	x, x, dk
	sub		rk, rk, #1

	/* if (x < 1.0) {k--; x++;} */
	cmp		r1, #0x0
	bgt		skip
	sub		rk, rk, #1
	vadd.f64	x, x, t0

skip:
	/* t0 = e^k */
	adr		ip, .Lexpk_lut
	add		rk, rk, #17
	add		ip, ip, rk, lsl #3
	vldr		t0, [ip]

	/* ret = e^x */
	vmov		r0, r1, x
	bl		__kernel_exp
	/* ret = ret * t0 */
	vmul.f64	ret, ret, t0
	vmov		r0, r1, ret
	pop		{rk, pc}

.Lexpk_lut:
	.word	0x175a689d, 0x3e6639e3	/* e^-17.000000 */
	.word	0xbaee85cb, 0x3e7e355b	/* e^-16.000000 */
	.word	0xa227ec38, 0x3e94875c	/* e^-15.000000 */
	.word	0xfdb01612, 0x3eabe6c6	/* e^-14.000000 */
	.word	0x3b981d98, 0x3ec2f605	/* e^-13.000000 */
	.word	0x3b43bc8b, 0x3ed9c54c	/* e^-12.000000 */
	.word	0x238f6764, 0x3ef18354	/* e^-11.000000 */
	.word	0xb5647c9b, 0x3f07cd79	/* e^-10.000000 */
	.word	0x2526545a, 0x3f202cf2	/* e^-9.000000 */
	.word	0x041027ad, 0x3f35fc21	/* e^-8.000000 */
	.word	0x9c24a98f, 0x3f4de16b	/* e^-7.000000 */
	.word	0xf113d4d6, 0x3f644e51	/* e^-6.000000 */
	.word	0xe00d5376, 0x3f7b993f	/* e^-5.000000 */
	.word	0xb8213cf4, 0x3f92c155	/* e^-4.000000 */
	.word	0xccceb0af, 0x3fa97db0	/* e^-3.000000 */
	.word	0xa3bf81cc, 0x3fc152aa	/* e^-2.000000 */
	.word	0x362cef38, 0x3fd78b56	/* e^-1.000000 */
	.word	0x00000000, 0x3ff00000	/* e^0.000000 */
	.word	0x8b145769, 0x4005bf0a	/* e^1.000000 */
	.word	0xb8d4ddae, 0x401d8e64	/* e^2.000000 */
	.word	0xbf6fb106, 0x403415e5	/* e^3.000000 */
	.word	0x2e273a58, 0x404b4c90	/* e^4.000000 */
	.word	0x9970338f, 0x40628d38	/* e^5.000000 */
	.word	0x5690c08f, 0x407936dc	/* e^6.000000 */
	.word	0x5aaeddaa, 0x40912288	/* e^7.000000 */
	.word	0x7d470c6e, 0x40a749ea	/* e^8.000000 */
	.word	0x7c470f82, 0x40bfa715	/* e^9.000000 */
	.word	0xcf950560, 0x40d5829d	/* e^10.000000 */
	.word	0x88ee4f7f, 0x40ed3c44	/* e^11.000000 */
	.word	0x54d37c9a, 0x4103de16	/* e^12.000000 */
	.word	0x916ac955, 0x411b00b5	/* e^13.000000 */
	.word	0x48bf05d7, 0x413259ac	/* e^14.000000 */
	.cfi_endproc
END(exp)

	.weak		expl
	.equ		expl, exp
