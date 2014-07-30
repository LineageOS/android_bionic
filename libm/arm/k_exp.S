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
 *
 *  x    a      1          1      2    1      3    1      4    1      5
 * e  = e (1 + ---(x-a) + ---(x-a)  + ---(x-a)  + ---(x-a)  + ---(x-a) )
 *              1!         2!          3!          4!          5!
 *
 * a is a number which is very close to x.
 *
 */

#include <float.h>
#include <machine/cpu-features.h>
#include <machine/asm.h>

#define LUT_SIZE        128
#define LUT_SIZE_SHIFT  7

#define x		d0
#define ixl		r0
#define ixh		r1
#define ret		d0
#define t5		d20
#define t4		d21
#define t3		d22
#define t2		d23
#define t1		d24
#define t0		d25
#define dx		d26
#define a		d27
#define expa		d28

#if FPU_VFPV4
	.fpu	vfpv4
#define MLAF64		vfma.f64
#define MLSF64		vfms.f64
#else
#define MLAF64		vmla.f64
#define MLSF64		vmls.f64
#endif

ENTRY(__kernel_exp)
	.cfi_startproc
lookup:
	/* get index in lut */
	add		ixh, ixh, #(1 << (20-LUT_SIZE_SHIFT-1))
        mov		ixl, #0
        bfi		ixh, ixl, #0, #(20-LUT_SIZE_SHIFT)
        vmov		a, ixl, ixh
        sub		r3, ixh, #0x3fc00000
        sub		r3, r3, #0x00300000
        lsr		r3, r3, #(20-LUT_SIZE_SHIFT)
        adr		ip, .Lexp_lut
        add		ip, ip, r3, lsl #3
        vldr		expa, [ip]

taylor_series:
	adr		r2, .Ls5
	vldmia		r2, {t5-t3}
	vmov.f64	t2, #0.5
	vmov.f64	t1, #1.0
	vmov.f64	t0, #1.0

	/* dx = x - a; */
	vsub.f64	dx, x, a

	/* S4 + S5 * dx */
	MLAF64	t4, t5, dx
	/* S3 + (S4 + S5 * dx) * dx */
	MLAF64	t3, t4, dx
	/* S2 + (S3 + (S4 + S5 * dx) * dx) * dx */
	MLAF64	t2, t3, dx
	/* S1 + (S2 + (S3 + (S4 + S5 * dx) * dx) * dx) * dx */
	MLAF64	t1, t2, dx
	/* 1.0 + (S1 + (S2 + (S3 + (S4 + S5 * dx) * dx) * dx) * dx) * dx */
	MLAF64	t0, t1, dx
	/* (e^a) * (1.0 + (S1 + (S2 + (S3 + (S4 + S5 *
		dx) * dx) * dx) * dx) * dx) */
	vmul.f64	ret, expa, t0
	bx		lr

.Ls5:
	.word	0x11111111, 0x3f811111	/* 1/5! */
.Ls4:
	.word	0x55555555, 0x3fa55555	/* 1/4! */
.Ls3:
	.word	0x55555555, 0x3fc55555	/* 1/3! */

.Lexp_lut:
	.word	0x8b145769, 0x4005bf0a	/* e^1.000000 */
	.word	0x3b4cd425, 0x4005eab4	/* e^1.007812 */
	.word	0x96737708, 0x400616b5	/* e^1.015625 */
	.word	0x4c8de75a, 0x4006430f	/* e^1.023438 */
	.word	0x0f0338a7, 0x40066fc2	/* e^1.031250 */
	.word	0x909eb05c, 0x40069cce	/* e^1.039062 */
	.word	0x859290f9, 0x4006ca35	/* e^1.046875 */
	.word	0xa37aead7, 0x4006f7f7	/* e^1.054688 */
	.word	0xa1607299, 0x40072615	/* e^1.062500 */
	.word	0x37bb5d53, 0x40075490	/* e^1.070312 */
	.word	0x20764269, 0x40078368	/* e^1.078125 */
	.word	0x16f1033d, 0x4007b29e	/* e^1.085938 */
	.word	0xd803b8ac, 0x4007e232	/* e^1.093750 */
	.word	0x2201a672, 0x40081227	/* e^1.101562 */
	.word	0xb4bc3477, 0x4008427b	/* e^1.109375 */
	.word	0x5185ee16, 0x40087331	/* e^1.117188 */
	.word	0xbb358768, 0x4008a448	/* e^1.125000 */
	.word	0xb628e8a1, 0x4008d5c2	/* e^1.132812 */
	.word	0x08483f85, 0x400907a0	/* e^1.140625 */
	.word	0x7909170e, 0x400939e1	/* e^1.148438 */
	.word	0xd1717543, 0x40096c87	/* e^1.156250 */
	.word	0xdc1aff4c, 0x40099f93	/* e^1.164062 */
	.word	0x653623e0, 0x4009d306	/* e^1.171875 */
	.word	0x3a8d4c04, 0x400a06e0	/* e^1.179688 */
	.word	0x2b881238, 0x400a3b22	/* e^1.187500 */
	.word	0x092e8014, 0x400a6fcd	/* e^1.195312 */
	.word	0xa62c526b, 0x400aa4e1	/* e^1.203125 */
	.word	0xd6d443f9, 0x400ada60	/* e^1.210938 */
	.word	0x71235eb4, 0x400b104b	/* e^1.218750 */
	.word	0x4cc453bc, 0x400b46a2	/* e^1.226562 */
	.word	0x4312da07, 0x400b7d66	/* e^1.234375 */
	.word	0x2f1f13d5, 0x400bb498	/* e^1.242188 */
	.word	0xedb0faf0, 0x400bec38	/* e^1.250000 */
	.word	0x5d4bd3ca, 0x400c2449	/* e^1.257812 */
	.word	0x5e31a78f, 0x400c5cca	/* e^1.265625 */
	.word	0xd266c52e, 0x400c95bc	/* e^1.273438 */
	.word	0x9db54969, 0x400ccf21	/* e^1.281250 */
	.word	0xa5b0ae01, 0x400d08f9	/* e^1.289062 */
	.word	0xd1b96002, 0x400d4345	/* e^1.296875 */
	.word	0x0b005d4b, 0x400d7e07	/* e^1.304688 */
	.word	0x3c8ad94f, 0x400db93e	/* e^1.312500 */
	.word	0x5335e92c, 0x400df4ec	/* e^1.320312 */
	.word	0x3dba3721, 0x400e3112	/* e^1.328125 */
	.word	0xecafbd72, 0x400e6db0	/* e^1.335938 */
	.word	0x529188c9, 0x400eaac9	/* e^1.343750 */
	.word	0x63c18222, 0x400ee85c	/* e^1.351562 */
	.word	0x168c4057, 0x400f266b	/* e^1.359375 */
	.word	0x632ce152, 0x400f64f6	/* e^1.367188 */
	.word	0x43d0eaf9, 0x400fa3ff	/* e^1.375000 */
	.word	0xb49c33e8, 0x400fe386	/* e^1.382812 */
	.word	0xd9d66a01, 0x401011c6	/* e^1.390625 */
	.word	0xa08f8e73, 0x4010320a	/* e^1.398438 */
	.word	0x2f88cd34, 0x4010528f	/* e^1.406250 */
	.word	0x08d48d86, 0x40107355	/* e^1.414062 */
	.word	0xaf8a6048, 0x4010945c	/* e^1.421875 */
	.word	0xa7c90c5d, 0x4010b5a6	/* e^1.429688 */
	.word	0x76b89f22, 0x4010d733	/* e^1.437500 */
	.word	0xa28c8112, 0x4010f903	/* e^1.445312 */
	.word	0xb2858e90, 0x40111b17	/* e^1.453125 */
	.word	0x2ef434f2, 0x40113d70	/* e^1.460938 */
	.word	0xa13a93be, 0x4011600d	/* e^1.468750 */
	.word	0x93cea233, 0x401182f0	/* e^1.476562 */
	.word	0x923c5928, 0x4011a619	/* e^1.484375 */
	.word	0x2927e132, 0x4011c989	/* e^1.492188 */
	.word	0xe64fc541, 0x4011ed3f	/* e^1.500000 */
	.word	0x588f2992, 0x4012113e	/* e^1.507812 */
	.word	0x0fe00721, 0x40123585	/* e^1.515625 */
	.word	0x9d5d6b8f, 0x40125a14	/* e^1.523438 */
	.word	0x9345bd92, 0x40127eed	/* e^1.531250 */
	.word	0x84fd05ec, 0x4012a410	/* e^1.539062 */
	.word	0x070f3cfe, 0x4012c97e	/* e^1.546875 */
	.word	0xaf329cf8, 0x4012ef36	/* e^1.554688 */
	.word	0x1449f8b3, 0x4013153b	/* e^1.562500 */
	.word	0xce67173e, 0x40133b8b	/* e^1.570312 */
	.word	0x76cd1423, 0x40136229	/* e^1.578125 */
	.word	0xa7f2c477, 0x40138914	/* e^1.585938 */
	.word	0xfd8520b5, 0x4013b04d	/* e^1.593750 */
	.word	0x1469b374, 0x4013d7d6	/* e^1.601562 */
	.word	0x8ac10cfa, 0x4013ffad	/* e^1.609375 */
	.word	0xffe93bc4, 0x401427d4	/* e^1.617188 */
	.word	0x148049fe, 0x4014504d	/* e^1.625000 */
	.word	0x6a66bff8, 0x40147916	/* e^1.632812 */
	.word	0xa4c22baf, 0x4014a231	/* e^1.640625 */
	.word	0x67ffad5f, 0x4014cb9f	/* e^1.648438 */
	.word	0x59d6893c, 0x4014f560	/* e^1.656250 */
	.word	0x214abe4c, 0x40151f75	/* e^1.664062 */
	.word	0x66afa27c, 0x401549de	/* e^1.671875 */
	.word	0xd3aa83ed, 0x4015749c	/* e^1.679688 */
	.word	0x13354f87, 0x40159fb1	/* e^1.687500 */
	.word	0xd1a13ce7, 0x4015cb1b	/* e^1.695312 */
	.word	0xbc997f9f, 0x4015f6dd	/* e^1.703125 */
	.word	0x8325fde8, 0x401622f7	/* e^1.710938 */
	.word	0xd5ae0cc3, 0x40164f69	/* e^1.718750 */
	.word	0x65fb3191, 0x40167c35	/* e^1.726562 */
	.word	0xe73be941, 0x4016a95a	/* e^1.734375 */
	.word	0x0e06750a, 0x4016d6db	/* e^1.742188 */
	.word	0x905bacbf, 0x401704b6	/* e^1.750000 */
	.word	0x25a9d6da, 0x401732ee	/* e^1.757812 */
	.word	0x86cf8633, 0x40176182	/* e^1.765625 */
	.word	0x6e1e7d7d, 0x40179074	/* e^1.773438 */
	.word	0x975e988b, 0x4017bfc4	/* e^1.781250 */
	.word	0xbfd0bb73, 0x4017ef73	/* e^1.789062 */
	.word	0xa631c791, 0x40181f82	/* e^1.796875 */
	.word	0x0abd967f, 0x40184ff2	/* e^1.804688 */
	.word	0xaf31fb00, 0x401880c2	/* e^1.812500 */
	.word	0x56d1c7fa, 0x4018b1f5	/* e^1.820312 */
	.word	0xc667dd88, 0x4018e38a	/* e^1.828125 */
	.word	0xc44a3c1d, 0x40191583	/* e^1.835938 */
	.word	0x185d1de5, 0x401947e1	/* e^1.843750 */
	.word	0x8c161651, 0x40197aa3	/* e^1.851562 */
	.word	0xea7f37f5, 0x4019adcb	/* e^1.859375 */
	.word	0x003a40aa, 0x4019e15b	/* e^1.867188 */
	.word	0x9b83cc1b, 0x401a1551	/* e^1.875000 */
	.word	0x8c368cb8, 0x401a49b0	/* e^1.882812 */
	.word	0xa3ce8b1e, 0x401a7e78	/* e^1.890625 */
	.word	0xb56c6c10, 0x401ab3aa	/* e^1.898438 */
	.word	0x95d8bcf0, 0x401ae947	/* e^1.906250 */
	.word	0x1b8746ed, 0x401b1f50	/* e^1.914062 */
	.word	0x1e9a68cc, 0x401b55c5	/* e^1.921875 */
	.word	0x78e67776, 0x401b8ca7	/* e^1.929688 */
	.word	0x05f52549, 0x401bc3f8	/* e^1.937500 */
	.word	0xa308f03f, 0x401bfbb7	/* e^1.945312 */
	.word	0x2f2096fe, 0x401c33e7	/* e^1.953125 */
	.word	0x8afa94ce, 0x401c6c87	/* e^1.960938 */
	.word	0x9918a498, 0x401ca599	/* e^1.968750 */
	.word	0x3dc34aeb, 0x401cdf1e	/* e^1.976562 */
	.word	0x5f0d6723, 0x401d1916	/* e^1.984375 */
	.word	0xe4d7cbb4, 0x401d5382	/* e^1.992188 */
	.word	0xb8d4ddae, 0x401d8e64	/* e^2.000000 */
	.cfi_endproc
END(__kernel_exp)
