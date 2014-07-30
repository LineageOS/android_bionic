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

#define ixl	r0
#define ixh	r1
#define abs_ixh	r2

#define j	r3
#define ti	r2

#define x	d0
#define y0	d2
#define y1	d3

#define t0	d4
#define t1	d5
#define t2	d6
#define t3	d16
#define fn	d17
#define w	d18

#define ts0	s15

#define reti	r0

#ifdef FPU_VFPV4
	.fpu    vfpv4
#define MLAF64	vfma.f64
#define MLSF64	vfms.f64
#else
#define MLAF64	vmla.f64
#define MLSF64	vmls.f64
#endif

ENTRY(__rem_pio2_fast)
	.cfi_startproc
	bic		abs_ixh, ixh, #0x80000000

	/* |x| ~< 2^20*(pi/2)? */
	movw		ip, #0x21fb
	movt		ip, #0x4139
	cmp		abs_ixh, ip
	ble		__medium

__large:
	push		{lr}
	sub		sp, sp, #0x10
	mov		r3, sp
	bl		__rem_pio2_large
	vldmia		sp, {y0-y1}
	add		sp, sp, #0x10
	pop		{pc}

__medium:
	/* fn = round_to_nearest(x / pio2); */
	adr		ip, .Linvpio2
	vldmia		ip, {t3-fn}
	vmov.f64	t0, fn
	MLAF64		fn, x, t3
	vsub.f64	fn, fn, t0

	/* j = ix >> 20; */
	asr		j, abs_ixh, #20

	/* reti = (int32_t)fn; */
	vcvt.s32.f64	ts0, fn
	vmov		reti, ts0

	/* x -= fn * pio2_1; */
	/* w = fn * pio2_1t; */
	adr		ip, .Lpio2_1
	vldmia		ip, {t0-t1}
	MLSF64		x, fn, t0
	vmul.f64	w, fn, t1

__1st_round:
	/* {ixh, ti} = y0 = x - w; */
	vsub.f64	y0, x, w
	vmov		ti, ixh, y0

	/* ixh = abs(ixh) */
	bic		ixh, ixh, #0x80000000

	/* ti = j - (ixh >> 20); */
	sub		ti, j, ixh, asr #20

	/* ti > 16? */
	cmp		ti, #0x10
	ble		__done

__2nd_round:
	/* t2 = x; */
	/* t0 = fn * pio2_2 */
	/* t1 = fn * pio2_2t */
	/* x -= t0 */
	/* w = t1 - ((t2 - x) - t0); */
	vmov.f64	t2, x
	adr		ip, .Lpio2_2
	vldmia		ip, {t0-t1}
	vmul.f64	t0, fn, t0
	vmul.f64	t1, fn, t1
	vsub.f64	x, x, t0
	vsub.f64	t2, t2, x
	vsub.f64	t2, t2, t0
	vsub.f64	w, t1, t2

	/* {ixh, ti} = y0 = x - w; */
	vsub.f64	y0, x, w
	vmov		ti, ixh, y0

	/* ixh = abs(ixh) */
	bic		ixh, ixh, #0x80000000

	/* ti = j - (ixh >> 20); */
	sub		ti, j, ixh, asr #20

	/* ti > 49? */
	cmp		ti, #0x31
	ble		__done

__3rd_round:
	/* t2 = x; */
	/* t0 = fn * pio2_3 */
	/* t1 = fn * pio2_3t */
	/* x -= t0 */
	/* w = t1 - ((t2 - x) - t0); */
	vmov.f64	t2, x
	adr		ip, .Lpio2_3
	vldmia		ip, {t0-t1}
	vmul.f64	t0, fn, t0
	vmul.f64	t1, fn, t1
	vsub.f64	x, x, t0
	vsub.f64	t2, t2, x
	vsub.f64	t2, t2, t0
	vsub.f64	w, t1, t2

	/* y0 = x - w; */
	vsub.f64	y0, x, w

__done:

#ifdef PRECISE_TRIGONOMETRIC

	/* y1 = (x - y0) - w; */
	vsub.f64	y1, x, y0
	vsub.f64	y1, y1, w

#endif

	bx		lr

__ret_nan:
	vsub.f64	y0, x, x
	vmov.f64	y1, y0
	mov		reti, #0x0
	bx		lr

.Linvpio2:
	.word		0x6DC9C883, 0x3FE45F30	/* 6.36619772367581382433e-01 */
.Lmagic:
	.word		0x00000000, 0x43380000  /* 0x1.8p52 */
.Lpio2_1:
	.word		0x54400000, 0x3FF921FB	/* 1.57079632673412561417e+00 */
	.word		0x1A626331, 0x3DD0B461	/* 6.07710050650619224932e-11 */
.Lpio2_2:
	.word		0x1A600000, 0x3DD0B461	/* 6.07710050630396597660e-11 */
	.word		0x2E037073, 0x3BA3198A	/* 2.02226624879595063154e-21 */
.Lpio2_3:
	.word		0x2E000000, 0x3BA3198A	/* 2.02226624871116645580e-21 */
	.word		0x252049C1, 0x397B839A	/* 8.47842766036889956997e-32 */
	.cfi_endproc
END(__rem_pio2_fast)
