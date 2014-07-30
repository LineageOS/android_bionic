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
#define z	d4
#define w	d5

#define C2	d16
#define C5	d17
#define C3	d18
#define C6	d19
#define C1	d20
#define C4	d21
#define r	d22
#define t0	d23
#define hz	d24

#ifdef FPU_VFPV4
	.fpu	vfpv4
#define MLAF64	vfma.f64
#define MLSF64	vfms.f64
#else
#define MLAF64	vmla.f64
#define MLSF64	vmls.f64
#endif

ENTRY_PRIVATE(__kernel_cos_fast)
	.cfi_startproc
	/* z = x^2; */
	vmul.f64	z, x, x

	/* w = x^4; */
	vmul.f64	w, z, z

calc_r:
	/* r = z*(C1+z*(C2+z*C3)) + w*w*(C4+z*(C5+z*C6)); */

	/* load(C2, C5, C3, C6, C1, C4) */
	adr		ip, .LC2
	vldmia		ip, {C2-C4}

	/* C2 += z*C3; || C5 += z*C6; */
	MLAF64		C2, z, C3
	MLAF64		C5, z, C6

	/* C1 += z*C2; || C4 += z*C5; */
	MLAF64		C1, z, C2
	MLAF64		C4, z, C5

	/* r = z*C1; || t0 = w*C4; */
	vmul.f64	r, z, C1
	vmul.f64	t0, w, C4

	/* r += t0*w */
	MLAF64		r, t0, w

	/* hz = 0.5*z; */
	vmov.f64	hz, #0.5
	vmul.f64	hz, hz, z

	/* w = 1.0-hz; */
	vmov.f64	t0, #1.0
	vsub.f64	w, t0, hz

#ifdef PRECISE_TRIGONOMETRIC
	/* t0 = (1.0-w)-hz; */
	vsub.f64	t0, t0, w
	vsub.f64	t0, t0, hz

	/* z = z*r-x*y; */
	vmul.f64	z, z, r
	MLSF64		z, x, y

	/* ret = w+(t0+z); */
	vadd.f64	t0, t0, z
	vadd.f64	ret, w, t0

#else
	/* ret = w; */
	/* ret += z*r; */
	vmov.f64	ret, w
	MLAF64		ret, z, r

#endif

	vmov		r0, r1, ret
	bx		lr

.LC2:
	.word		0x16C15177, 0xBF56C16C	/* -1.38888888888741095749e-03 */
.LC5:
	.word		0xBDB4B1C4, 0x3E21EE9E	/* 2.08757232129817482790e-09 */
.LC3:
	.word		0x19CB1590, 0x3EFA01A0	/* 2.48015872894767294178e-05 */
.LC6:
	.word		0xBE8838D4, 0xBDA8FAE9	/* -1.13596475577881948265e-11 */
.LC1:
	.word		0x5555554C, 0x3FA55555	/* 4.16666666666666019037e-02 */
.LC4:
	.word		0x809C52AD, 0xBE927E4F	/* -2.75573143513906633035e-07 */
	.cfi_endproc
END(__kernel_cos_fast)
