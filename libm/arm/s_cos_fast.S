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
#define	ixh	r1
#define abs_ixh	r2
#define t0i	r3

#define n	r0

#define x	d0
#define t0s	s15

	.fpu	neon

ENTRY(cos)
	.cfi_startproc
	vmov		x, ixl, ixh

	/* |x| > pi/4? */
	bic		abs_ixh, ixh, #0x80000000
	movw		ip, #0x21fb
	movt		ip, #0x3fe9
	cmp		abs_ixh, ip
	bgt		__x_gt_pio4

__x_lt_pio4:
	/* |x| > 2^-27 * sqrt(2)? */
	movw		ip, #0xa09e
	movt		ip, #0x3e46
	cmp		abs_ixh, ip
	vmov		d2, x
	vmov.i64	d3, #0x0
	bgt		__kernel_cos_fast

	/* x is tiny? */
	mov		r0, #0x0
	mov		r1, #0x0
	movt		r1, #0x3ff0
	bx		lr

__x_gt_pio4:
	push		{lr}

	/* Get reminder of x / pio2 */
	bl		__rem_pio2_fast
	and		t0i, n, #0x3
	mov		r0, #0x1

	/*         cos(y0 + y1),  n % 4 == 0
	   ret = { -sin(y0 + y1), n % 4 == 1
	           -cos(y0 + y1), n % 4 == 2
	           sin(y0 + y1),  n % 4 == 3
	*/
	add		pc, pc, t0i, lsl #4
	nop
__0:
	bl		__kernel_cos_fast
	pop		{pc}
	nop
	nop
__1:
	bl		__kernel_sin_fast
	eor		r1, r1, #0x80000000
	pop		{pc}
	nop
__2:
	bl		__kernel_cos_fast
	eor		r1, r1, #0x80000000
	pop		{pc}
	nop
__3:
	bl		__kernel_sin_fast
	pop		{pc}
	nop
	nop
	.cfi_endproc
END(cos)

	.weak		cosl
	.equ		cosl,cos
