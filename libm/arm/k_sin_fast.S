/* Copyright (C) 2013 The Android Open Source Project
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

#include <float.h>
#include <machine/cpu-features.h>
#include <machine/asm.h>

#define ret	d0
#define x	d2
#define y	d3
#define iy	r0
#define z	d1

#define v	d4
#define w	d5

#define S3	d16
#define S5	d17
#define S4	d18
#define S6	d19
#define S1	d20
#define S2	d21
#define r	d21
#define t0	d22

#ifdef FPU_VFPV4
	.fpu	vfpv4
#define MLAF64	vfma.f64
#define MLSF64	vfms.f64
#else
#define MLAF64	vmla.f64
#define MLSF64	vmls.f64
#endif

ENTRY_PRIVATE(__kernel_sin_fast)
	.cfi_startproc
	/* z = x^2; */
	vmul.f64	z, x, x

	/* v = x^3; || w = x^4; */
	vmul.f64	v, z, x
	vmul.f64	w, z, z

calc_r:
	/* r = S2 = S2+z*((S3+z*S4)+w*(S5+z*S6)); */

	/* load(S3, S5, S4, S6, S1, S2) */
	adr		ip, .LS3
	vldmia		ip, {S3-S2}

	/* S3 += z*S4; || S5 += z*S6; */
	MLAF64		S3, z, S4
	MLAF64		S5, z, S6

	/* S3 += w*S5 */
	MLAF64		S3, w, S5

	/* r = S2 = S2+z*S3 */
	MLAF64		r, z, S3

#ifdef PRECISE_TRIGONOMETRIC

	/* iy == 0? */
	cmp		r0, #0
	bne		__tail_is_not_zero

#endif

__tail_is_zero:

	/* ret = x+v*(S1+z*r); */

	/* S1 += z*r; */
	MLAF64		S1, z, r

	/* ret = x+v*S1 */
	vmov.f64	ret, x
	MLAF64		ret, v, S1

	vmov		r0, r1, ret
	bx		lr

__tail_is_not_zero:

	/* ret = x+((y-z*(0.5*y-v*r))+v*S1); */

	/* t0 = 0.5; */
	vmov.f64	t0, #0.5

	/* t0 *= y; */
	vmul.f64	t0, t0, y

	/* t0 -= v*r; */
	MLSF64		t0, v, r

	/* y -= t0*z; */
	MLSF64		y, t0, z

	/* y += v*S1; */
	MLAF64		y, v, S1

	/* ret = x+y; */
	vadd.f64	ret, x, y

	vmov		r0, r1, ret
	bx		lr

.LS3:
	.word		0x19C161D5, 0xBF2A01A0	/* -1.98412698298579493134e-04 */
.LS5:
	.word		0x8A2B9CEB, 0xBE5AE5E6	/* -2.50507602534068634195e-08 */
.LS4:
	.word		0x57B1FE7D, 0x3EC71DE3	/* 2.75573137070700676789e-06 */
.LS6:
	.word		0x5ACFD57C, 0x3DE5D93A	/* 1.58969099521155010221e-10 */
.LS1:
	.word		0x55555549, 0xBFC55555	/* -1.66666666666666324348e-01 */
.LS2:
	.word		0x1110F8A6, 0x3F811111	/* 8.33333333332248946124e-03 */
	.cfi_endproc
END(__kernel_sin_fast)
