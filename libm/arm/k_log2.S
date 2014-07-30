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

/*
 *                      1               1  2         2     1  3         3
 * log2(x) = log2(a) + ---*S1*(x-a) + (---) *S2*(x-a)  + (---) *S3*(x-a)
 *                      a               a                  a
 *
 *             1  4         4     1  5         5    1  6         6
 *         + (---) *S4*(x-a)  + (---) *S5*(x-a) + (---) *S6*(x-a)
 *             a                  a                 a
 *
 * a is a number which is very close to x, and:
 *
 *        1
 * S1 = -----
 *       ln2
 *
 *           1
 * S2 = - -------
 *         2*ln2
 *
 *         1
 * S3 = --------
 *       3*ln2
 *
 *           1
 * S4 = - -------
 *         4*ln2
 *
 *         1
 * S5 = -------
 *       5*ln2
 *
 *           1
 * S6 = - -------
 *         6*ln2
 *
 */

#include <float.h>
#include <machine/cpu-features.h>
#include <machine/asm.h>

#define LUT_SIZE	256
#define LUT_SIZE_SHIFT	8

#define x		d0
#define ixl		r0
#define ixh		r1
#define ret		d0
#define t6		d20
#define t5		d21
#define t4		d22
#define t3		d23
#define t2		d24
#define t1		d25
#define dx2		d28
#define dx		d26
#define a		d27
#define log2a		d24
#define a_recp		d25

#if FPU_VFPV4
	.fpu	vfpv4
#define MLAF64		vfma.f64
#define MLSF64		vfms.f64
#else
#define MLAF64		vmla.f64
#define MLSF64		vmls.f64
#endif

ENTRY_PRIVATE(__kernel_log2)
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
	adr		ip, .Llog2_lut
	add		ip, ip, r3, lsl #4
	vldmia		ip, {log2a-a_recp}

taylor_series_expanding:


	/* dx = x - a; */
	vsub.f64	dx, x, a
	/* dx /= a; */
	vmul.f64	dx, dx, a_recp

	vmov.f64	ret, log2a
	vmul.f64	dx2, dx, dx
	adr		ip, .Ls6
	vldmia		ip, {t6-t1}
	MLAF64	t5, t6, dx
	/* S5 + S6 * dx */
	MLAF64	t3, t4, dx
	/* S3 + S4 * dx */
	MLAF64	t1, t2, dx
	/* S1 + S2 * dx */
	MLAF64	t3, t5, dx2
	/* S3 + S4 * dx + (S5 + S6 * dx) * dx^2 */
	MLAF64	t1, t3, dx2
	/* S1 + S2 * dx +
           (S3 + S4 * dx + (S5 + S6 * dx) * dx^2) * dx^2 */
	MLAF64	ret, t1, dx
	/* log2(a) + (S1 + S2 * dx + (S3 + S4 * dx^2 +
	(S5 + S6 * dx^2) * dx^2) * dx^2) * dx */
	bx		lr

.Ls6:
	.word	0xdc3a03fe, 0xbfcec709	/* -1.0 / (6.0 * ln2) */
.Ls5:
	.word	0x50ef9bff, 0x3fd2776c	/* 1.0 / (5.0 * ln2) */
.Ls4:
	.word	0x652b82fe, 0xbfd71547	/* -1.0 / (4.0 * ln2) */
.Ls3:
	.word	0xdc3a03fe, 0x3fdec709	/* 1.0 / (3.0 * ln2) */
.Ls2:
	.word	0x652b82fe, 0xbfe71547	/* -1.0 / (2.0 * ln2) */
.Ls1:
	.word	0x652b82fe, 0x3ff71547	/* 1.0 / (1.0 * ln2) */

.Llog2_lut:
	/* log2(1.000000), 1.0 / 1.000000 */
	.word	0x00000000, 0x00000000, 0x00000000, 0x3ff00000
	/* log2(1.003906), 1.0 / 1.003906 */
	.word	0x6d7aac77, 0x3f7709c4, 0xe01fe020, 0x3fefe01f
	/* log2(1.007812), 1.0 / 1.007812 */
	.word	0xb6ef0851, 0x3f86fe50, 0x01fc07f0, 0x3fefc07f
	/* log2(1.011719), 1.0 / 1.011719 */
	.word	0x17a97b0c, 0x3f913631, 0xaa01fa12, 0x3fefa11c
	/* log2(1.015625), 1.0 / 1.015625 */
	.word	0x85c2d22a, 0x3f96e796, 0x1f81f820, 0x3fef81f8
	/* log2(1.019531), 1.0 / 1.019531 */
	.word	0xba850f86, 0x3f9c9363, 0xaca0dbb5, 0x3fef6310
	/* log2(1.023438), 1.0 / 1.023438 */
	.word	0xd5133413, 0x3fa11cd1, 0x9e4a4271, 0x3fef4465
	/* log2(1.027344), 1.0 / 1.027344 */
	.word	0x94685a26, 0x3fa3ed30, 0x44230ab5, 0x3fef25f6
	/* log2(1.031250), 1.0 / 1.031250 */
	.word	0x758efd87, 0x3fa6bad3, 0xf07c1f08, 0x3fef07c1
	/* log2(1.035156), 1.0 / 1.035156 */
	.word	0xc3495194, 0x3fa985bf, 0xf8458e02, 0x3feee9c7
	/* log2(1.039062), 1.0 / 1.039062 */
	.word	0xb90aab5f, 0x3fac4dfa, 0xb301ecc0, 0x3feecc07
	/* log2(1.042969), 1.0 / 1.042969 */
	.word	0x833253a0, 0x3faf1389, 0x7aba01eb, 0x3feeae80
	/* log2(1.046875), 1.0 / 1.046875 */
	.word	0x9fa29f9b, 0x3fb0eb38, 0xabf0b767, 0x3fee9131
	/* log2(1.050781), 1.0 / 1.050781 */
	.word	0x7e135a3d, 0x3fb24b5b, 0xa59750e4, 0x3fee741a
	/* log2(1.054688), 1.0 / 1.054688 */
	.word	0xdd27f1c3, 0x3fb3aa2f, 0xc901e574, 0x3fee573a
	/* log2(1.058594), 1.0 / 1.058594 */
	.word	0x36033bb7, 0x3fb507b8, 0x79dc1a73, 0x3fee3a91
	/* log2(1.062500), 1.0 / 1.062500 */
	.word	0xfac91316, 0x3fb663f6, 0x1e1e1e1e, 0x3fee1e1e
	/* log2(1.066406), 1.0 / 1.066406 */
	.word	0x96b8a281, 0x3fb7beee, 0x1e01e01e, 0x3fee01e0
	/* log2(1.070312), 1.0 / 1.070312 */
	.word	0x6e46335b, 0x3fb918a1, 0xe3f8868a, 0x3fede5d6
	/* log2(1.074219), 1.0 / 1.074219 */
	.word	0xdf348494, 0x3fba7111, 0xdca01dca, 0x3fedca01
	/* log2(1.078125), 1.0 / 1.078125 */
	.word	0x40adabba, 0x3fbbc842, 0x76b981db, 0x3fedae60
	/* log2(1.082031), 1.0 / 1.082031 */
	.word	0xe35b82da, 0x3fbd1e34, 0x231e7f8a, 0x3fed92f2
	/* log2(1.085938), 1.0 / 1.085938 */
	.word	0x117fa5b2, 0x3fbe72ec, 0x54b82c34, 0x3fed77b6
	/* log2(1.089844), 1.0 / 1.089844 */
	.word	0x0f0b00a5, 0x3fbfc66a, 0x807572b2, 0x3fed5cac
	/* log2(1.093750), 1.0 / 1.093750 */
	.word	0x8cda79e4, 0x3fc08c58, 0x1d41d41d, 0x3fed41d4
	/* log2(1.097656), 1.0 / 1.097656 */
	.word	0xb489062e, 0x3fc134e1, 0xa3fc5b1a, 0x3fed272c
	/* log2(1.101562), 1.0 / 1.101562 */
	.word	0x97552b7b, 0x3fc1dcd1, 0x8f6ec074, 0x3fed0cb5
	/* log2(1.105469), 1.0 / 1.105469 */
	.word	0x4b07a640, 0x3fc28429, 0x5c44bfc6, 0x3fecf26e
	/* log2(1.109375), 1.0 / 1.109375 */
	.word	0xe278ae1a, 0x3fc32ae9, 0x89039b0b, 0x3fecd856
	/* log2(1.113281), 1.0 / 1.113281 */
	.word	0x6d9a8a64, 0x3fc3d114, 0x9601cbe7, 0x3fecbe6d
	/* log2(1.117188), 1.0 / 1.117188 */
	.word	0xf983f74d, 0x3fc476a9, 0x055ee191, 0x3feca4b3
	/* log2(1.121094), 1.0 / 1.121094 */
	.word	0x907a5c8a, 0x3fc51bab, 0x5afb8a42, 0x3fec8b26
	/* log2(1.125000), 1.0 / 1.125000 */
	.word	0x39fbd688, 0x3fc5c01a, 0x1c71c71c, 0x3fec71c7
	/* log2(1.128906), 1.0 / 1.128906 */
	.word	0xfac91316, 0x3fc663f6, 0xd10d4986, 0x3fec5894
	/* log2(1.132812), 1.0 / 1.132812 */
	.word	0xd4ef027f, 0x3fc70742, 0x01c3f8f0, 0x3fec3f8f
	/* log2(1.136719), 1.0 / 1.136719 */
	.word	0xc7d05ddf, 0x3fc7a9fe, 0x392ea01c, 0x3fec26b5
	/* log2(1.140625), 1.0 / 1.140625 */
	.word	0xd02f03b3, 0x3fc84c2b, 0x0381c0e0, 0x3fec0e07
	/* log2(1.144531), 1.0 / 1.144531 */
	.word	0xe8352b6c, 0x3fc8edca, 0xee868d8b, 0x3febf583
	/* log2(1.148438), 1.0 / 1.148438 */
	.word	0x077e70df, 0x3fc98edd, 0x899406f7, 0x3febdd2b
	/* log2(1.152344), 1.0 / 1.152344 */
	.word	0x2320b86b, 0x3fca2f63, 0x65883e7b, 0x3febc4fd
	/* log2(1.156250), 1.0 / 1.156250 */
	.word	0x2db4ec94, 0x3fcacf5e, 0x14c1bad0, 0x3febacf9
	/* log2(1.160156), 1.0 / 1.160156 */
	.word	0x175f95e9, 0x3fcb6ecf, 0x2b18ff23, 0x3feb951e
	/* log2(1.164062), 1.0 / 1.164062 */
	.word	0xcdd94dee, 0x3fcc0db6, 0x3dda338b, 0x3feb7d6c
	/* log2(1.167969), 1.0 / 1.167969 */
	.word	0x3c770dc9, 0x3fccac16, 0xe3beee05, 0x3feb65e2
	/* log2(1.171875), 1.0 / 1.171875 */
	.word	0x4c325970, 0x3fcd49ee, 0xb4e81b4f, 0x3feb4e81
	/* log2(1.175781), 1.0 / 1.175781 */
	.word	0xe3b1480f, 0x3fcde73f, 0x4ad806ce, 0x3feb3748
	/* log2(1.179688), 1.0 / 1.179688 */
	.word	0xe74e6a4d, 0x3fce840b, 0x406c80d9, 0x3feb2036
	/* log2(1.183594), 1.0 / 1.183594 */
	.word	0x39208f27, 0x3fcf2053, 0x31d922a4, 0x3feb094b
	/* log2(1.187500), 1.0 / 1.187500 */
	.word	0xb902680a, 0x3fcfbc16, 0xbca1af28, 0x3feaf286
	/* log2(1.191406), 1.0 / 1.191406 */
	.word	0xa24d0664, 0x3fd02bab, 0x7f94905e, 0x3feadbe8
	/* log2(1.195312), 1.0 / 1.195312 */
	.word	0xdbb03009, 0x3fd0790a, 0x1ac5701b, 0x3feac570
	/* log2(1.199219), 1.0 / 1.199219 */
	.word	0x75542a8f, 0x3fd0c629, 0x2f87ebfd, 0x3feaaf1d
	/* log2(1.203125), 1.0 / 1.203125 */
	.word	0xdad30b76, 0x3fd11307, 0x606a63be, 0x3fea98ef
	/* log2(1.207031), 1.0 / 1.207031 */
	.word	0x76bb08ff, 0x3fd15fa6, 0x5130e159, 0x3fea82e6
	/* log2(1.210938), 1.0 / 1.210938 */
	.word	0xb291f070, 0x3fd1ac05, 0xa6d01a6d, 0x3fea6d01
	/* log2(1.214844), 1.0 / 1.214844 */
	.word	0xf6d88e13, 0x3fd1f825, 0x07688a4a, 0x3fea5741
	/* log2(1.218750), 1.0 / 1.218750 */
	.word	0xab0e073a, 0x3fd24407, 0x1a41a41a, 0x3fea41a4
	/* log2(1.222656), 1.0 / 1.222656 */
	.word	0x35b32683, 0x3fd28fab, 0x87c51ca0, 0x3fea2c2a
	/* log2(1.226562), 1.0 / 1.226562 */
	.word	0xfc4d9aaf, 0x3fd2db10, 0xf97a4b02, 0x3fea16d3
	/* log2(1.230469), 1.0 / 1.230469 */
	.word	0x636b2836, 0x3fd32639, 0x1a01a01a, 0x3fea01a0
	/* log2(1.234375), 1.0 / 1.234375 */
	.word	0xcea4cded, 0x3fd37124, 0x951033d9, 0x3fe9ec8e
	/* log2(1.238281), 1.0 / 1.238281 */
	.word	0xa0a1dcfb, 0x3fd3bbd3, 0x176b682d, 0x3fe9d79f
	/* log2(1.242188), 1.0 / 1.242188 */
	.word	0x3b1b0449, 0x3fd40646, 0x4ee4a102, 0x3fe9c2d1
	/* log2(1.246094), 1.0 / 1.246094 */
	.word	0xfedd4fc4, 0x3fd4507c, 0xea5510da, 0x3fe9ae24
	/* log2(1.250000), 1.0 / 1.250000 */
	.word	0x4bcd1b8b, 0x3fd49a78, 0x9999999a, 0x3fe99999
	/* log2(1.253906), 1.0 / 1.253906 */
	.word	0x80e8fb6a, 0x3fd4e438, 0x0d8ec0ff, 0x3fe9852f
	/* log2(1.257812), 1.0 / 1.257812 */
	.word	0xfc4c96b3, 0x3fd52dbd, 0xf80cb872, 0x3fe970e4
	/* log2(1.261719), 1.0 / 1.261719 */
	.word	0x1b3378cb, 0x3fd57709, 0x0be377ae, 0x3fe95cbb
	/* log2(1.265625), 1.0 / 1.265625 */
	.word	0x39fbd688, 0x3fd5c01a, 0xfcd6e9e0, 0x3fe948b0
	/* log2(1.269531), 1.0 / 1.269531 */
	.word	0xb42948ae, 0x3fd608f1, 0x7f9b2ce6, 0x3fe934c6
	/* log2(1.273438), 1.0 / 1.273438 */
	.word	0xe4677ba7, 0x3fd6518f, 0x49d0e229, 0x3fe920fb
	/* log2(1.277344), 1.0 / 1.277344 */
	.word	0x248cd4b8, 0x3fd699f5, 0x120190d5, 0x3fe90d4f
	/* log2(1.281250), 1.0 / 1.281250 */
	.word	0xcd9d0cde, 0x3fd6e221, 0x8f9c18fa, 0x3fe8f9c1
	/* log2(1.285156), 1.0 / 1.285156 */
	.word	0x37cbc183, 0x3fd72a16, 0x7af1373f, 0x3fe8e652
	/* log2(1.289062), 1.0 / 1.289062 */
	.word	0xba7efb3c, 0x3fd771d2, 0x8d3018d3, 0x3fe8d301
	/* log2(1.292969), 1.0 / 1.292969 */
	.word	0xac51aac4, 0x3fd7b957, 0x8062ff3a, 0x3fe8bfce
	/* log2(1.296875), 1.0 / 1.296875 */
	.word	0x63161c54, 0x3fd800a5, 0x0f6bf3aa, 0x3fe8acb9
	/* log2(1.300781), 1.0 / 1.300781 */
	.word	0x33d8618e, 0x3fd847bc, 0xf601899c, 0x3fe899c0
	/* log2(1.304688), 1.0 / 1.304688 */
	.word	0x72e0b226, 0x3fd88e9c, 0xf0abb04a, 0x3fe886e5
	/* log2(1.308594), 1.0 / 1.308594 */
	.word	0x73b5c372, 0x3fd8d546, 0xbcc092b9, 0x3fe87427
	/* log2(1.312500), 1.0 / 1.312500 */
	.word	0x891f1709, 0x3fd91bba, 0x18618618, 0x3fe86186
	/* log2(1.316406), 1.0 / 1.316406 */
	.word	0x0527409c, 0x3fd961f9, 0xc2780614, 0x3fe84f00
	/* log2(1.320312), 1.0 / 1.320312 */
	.word	0x391e232f, 0x3fd9a802, 0x7ab2bedd, 0x3fe83c97
	/* log2(1.324219), 1.0 / 1.324219 */
	.word	0x759b25e0, 0x3fd9edd6, 0x0182a4a0, 0x3fe82a4a
	/* log2(1.328125), 1.0 / 1.328125 */
	.word	0x0a7f6051, 0x3fda3376, 0x18181818, 0x3fe81818
	/* log2(1.332031), 1.0 / 1.332031 */
	.word	0x46f7bef4, 0x3fda78e1, 0x80601806, 0x3fe80601
	/* log2(1.335938), 1.0 / 1.335938 */
	.word	0x797f1f49, 0x3fdabe18, 0xfd017f40, 0x3fe7f405
	/* log2(1.339844), 1.0 / 1.339844 */
	.word	0xefe06434, 0x3fdb031b, 0x515a4f1d, 0x3fe7e225
	/* log2(1.343750), 1.0 / 1.343750 */
	.word	0xf73882a1, 0x3fdb47eb, 0x417d05f4, 0x3fe7d05f
	/* log2(1.347656), 1.0 / 1.347656 */
	.word	0xdbf8867a, 0x3fdb8c88, 0x922e017c, 0x3fe7beb3
	/* log2(1.351562), 1.0 / 1.351562 */
	.word	0xe9e79031, 0x3fdbd0f2, 0x08e0ecc3, 0x3fe7ad22
	/* log2(1.355469), 1.0 / 1.355469 */
	.word	0x6c24cae6, 0x3fdc152a, 0x6bb6398b, 0x3fe79baa
	/* log2(1.359375), 1.0 / 1.359375 */
	.word	0xad295b56, 0x3fdc592f, 0x8178a4c8, 0x3fe78a4c
	/* log2(1.363281), 1.0 / 1.363281 */
	.word	0xf6ca47b4, 0x3fdc9d02, 0x119ac60d, 0x3fe77908
	/* log2(1.367188), 1.0 / 1.367188 */
	.word	0x923a587d, 0x3fdce0a4, 0xe434a9b1, 0x3fe767dc
	/* log2(1.371094), 1.0 / 1.371094 */
	.word	0xc80bf27d, 0x3fdd2414, 0xc201756d, 0x3fe756ca
	/* log2(1.375000), 1.0 / 1.375000 */
	.word	0xe032ea0f, 0x3fdd6753, 0x745d1746, 0x3fe745d1
	/* log2(1.378906), 1.0 / 1.378906 */
	.word	0x22064fb9, 0x3fddaa62, 0xc541fe8d, 0x3fe734f0
	/* log2(1.382812), 1.0 / 1.382812 */
	.word	0xd442364c, 0x3fdded3f, 0x7f46debc, 0x3fe72428
	/* log2(1.386719), 1.0 / 1.386719 */
	.word	0x3d097298, 0x3fde2fed, 0x6d9c7c09, 0x3fe71378
	/* log2(1.390625), 1.0 / 1.390625 */
	.word	0xa1e754d2, 0x3fde726a, 0x5c0b8170, 0x3fe702e0
	/* log2(1.394531), 1.0 / 1.394531 */
	.word	0x47d15bce, 0x3fdeb4b8, 0x16f26017, 0x3fe6f260
	/* log2(1.398438), 1.0 / 1.398438 */
	.word	0x7328e220, 0x3fdef6d6, 0x6b4337c7, 0x3fe6e1f7
	/* log2(1.402344), 1.0 / 1.402344 */
	.word	0x67bcc541, 0x3fdf38c5, 0x2681c861, 0x3fe6d1a6
	/* log2(1.406250), 1.0 / 1.406250 */
	.word	0x68cb06cf, 0x3fdf7a85, 0x16c16c17, 0x3fe6c16c
	/* log2(1.410156), 1.0 / 1.410156 */
	.word	0xb902680a, 0x3fdfbc16, 0x0aa31a3d, 0x3fe6b149
	/* log2(1.414062), 1.0 / 1.414062 */
	.word	0x9a83ff9b, 0x3fdffd79, 0xd1537290, 0x3fe6a13c
	/* log2(1.417969), 1.0 / 1.417969 */
	.word	0x277264e0, 0x3fe01f57, 0x3a88d0c0, 0x3fe69147
	/* log2(1.421875), 1.0 / 1.421875 */
	.word	0x8b97997f, 0x3fe03fda, 0x16816817, 0x3fe68168
	/* log2(1.425781), 1.0 / 1.425781 */
	.word	0x19f24eb2, 0x3fe06047, 0x3601671a, 0x3fe6719f
	/* log2(1.429688), 1.0 / 1.429688 */
	.word	0xf27f703d, 0x3fe0809c, 0x6a5122f9, 0x3fe661ec
	/* log2(1.433594), 1.0 / 1.433594 */
	.word	0x34f8e1fc, 0x3fe0a0dc, 0x853b4aa3, 0x3fe6524f
	/* log2(1.437500), 1.0 / 1.437500 */
	.word	0x00d63aa6, 0x3fe0c105, 0x590b2164, 0x3fe642c8
	/* log2(1.441406), 1.0 / 1.441406 */
	.word	0x754d7c11, 0x3fe0e117, 0xb88ac0de, 0x3fe63356
	/* log2(1.445312), 1.0 / 1.445312 */
	.word	0xb153c8ea, 0x3fe10113, 0x77016240, 0x3fe623fa
	/* log2(1.449219), 1.0 / 1.449219 */
	.word	0xd39e1807, 0x3fe120f9, 0x6831ae94, 0x3fe614b3
	/* log2(1.453125), 1.0 / 1.453125 */
	.word	0xfaa1e544, 0x3fe140c9, 0x60581606, 0x3fe60581
	/* log2(1.457031), 1.0 / 1.457031 */
	.word	0x4495e006, 0x3fe16084, 0x34292dfc, 0x3fe5f664
	/* log2(1.460938), 1.0 / 1.460938 */
	.word	0xcf72976a, 0x3fe18028, 0xb8d015e7, 0x3fe5e75b
	/* log2(1.464844), 1.0 / 1.464844 */
	.word	0xb8f32421, 0x3fe19fb7, 0xc3ece2a5, 0x3fe5d867
	/* log2(1.468750), 1.0 / 1.468750 */
	.word	0x1e95d00e, 0x3fe1bf31, 0x2b931057, 0x3fe5c988
	/* log2(1.472656), 1.0 / 1.472656 */
	.word	0x1d9cbba6, 0x3fe1de95, 0xc647fa91, 0x3fe5babc
	/* log2(1.476562), 1.0 / 1.476562 */
	.word	0xd30e8126, 0x3fe1fde3, 0x6b015ac0, 0x3fe5ac05
	/* log2(1.480469), 1.0 / 1.480469 */
	.word	0x5bb6d59a, 0x3fe21d1d, 0xf123ccaa, 0x3fe59d61
	/* log2(1.484375), 1.0 / 1.484375 */
	.word	0xd42727c8, 0x3fe23c41, 0x308158ed, 0x3fe58ed2
	/* log2(1.488281), 1.0 / 1.488281 */
	.word	0x58b73d04, 0x3fe25b51, 0x01580560, 0x3fe58056
	/* log2(1.492188), 1.0 / 1.492188 */
	.word	0x0585cbf8, 0x3fe27a4c, 0x3c506b3a, 0x3fe571ed
	/* log2(1.496094), 1.0 / 1.496094 */
	.word	0xf6791560, 0x3fe29931, 0xba7c52e2, 0x3fe56397
	/* log2(1.500000), 1.0 / 1.500000 */
	.word	0x473f7ad1, 0x3fe2b803, 0x55555555, 0x3fe55555
	/* log2(1.503906), 1.0 / 1.503906 */
	.word	0x13501380, 0x3fe2d6c0, 0xe6bb82fe, 0x3fe54725
	/* log2(1.507812), 1.0 / 1.507812 */
	.word	0x75eb3f26, 0x3fe2f568, 0x48f40feb, 0x3fe53909
	/* log2(1.511719), 1.0 / 1.511719 */
	.word	0x8a1b36f2, 0x3fe313fc, 0x56a8054b, 0x3fe52aff
	/* log2(1.515625), 1.0 / 1.515625 */
	.word	0x6ab49ca7, 0x3fe3327c, 0xeae2f815, 0x3fe51d07
	/* log2(1.519531), 1.0 / 1.519531 */
	.word	0x325707d9, 0x3fe350e8, 0xe111c4c5, 0x3fe50f22
	/* log2(1.523438), 1.0 / 1.523438 */
	.word	0xfb6d9162, 0x3fe36f3f, 0x15015015, 0x3fe50150
	/* log2(1.527344), 1.0 / 1.527344 */
	.word	0xe02f5d09, 0x3fe38d83, 0x62dd4c9b, 0x3fe4f38f
	/* log2(1.531250), 1.0 / 1.531250 */
	.word	0xfaa02167, 0x3fe3abb3, 0xa72f0539, 0x3fe4e5e0
	/* log2(1.535156), 1.0 / 1.535156 */
	.word	0x6490ae12, 0x3fe3c9d0, 0xbedc2c4c, 0x3fe4d843
	/* log2(1.539062), 1.0 / 1.539062 */
	.word	0x379f7016, 0x3fe3e7d9, 0x8725af6e, 0x3fe4cab8
	/* log2(1.542969), 1.0 / 1.542969 */
	.word	0x8d38f4bc, 0x3fe405ce, 0xdda68fe1, 0x3fe4bd3e
	/* log2(1.546875), 1.0 / 1.546875 */
	.word	0x7e986aa9, 0x3fe423b0, 0xa052bf5b, 0x3fe4afd6
	/* log2(1.550781), 1.0 / 1.550781 */
	.word	0x24c82165, 0x3fe4417f, 0xad76014a, 0x3fe4a27f
	/* log2(1.554688), 1.0 / 1.554688 */
	.word	0x98a20739, 0x3fe45f3a, 0xe3b2d067, 0x3fe49539
	/* log2(1.558594), 1.0 / 1.558594 */
	.word	0xf2d02587, 0x3fe47ce2, 0x22014880, 0x3fe48805
	/* log2(1.562500), 1.0 / 1.562500 */
	.word	0x4bcd1b8b, 0x3fe49a78, 0x47ae147b, 0x3fe47ae1
	/* log2(1.566406), 1.0 / 1.566406 */
	.word	0xbbe49795, 0x3fe4b7fa, 0x34596066, 0x3fe46dce
	/* log2(1.570312), 1.0 / 1.570312 */
	.word	0x5b33cec4, 0x3fe4d56a, 0xc7f5cf9a, 0x3fe460cb
	/* log2(1.574219), 1.0 / 1.574219 */
	.word	0x41a9f33e, 0x3fe4f2c7, 0xe2c776ca, 0x3fe453d9
	/* log2(1.578125), 1.0 / 1.578125 */
	.word	0x8708a8f9, 0x3fe51011, 0x6562d9fb, 0x3fe446f8
	/* log2(1.582031), 1.0 / 1.582031 */
	.word	0x42e47909, 0x3fe52d49, 0x30abee4d, 0x3fe43a27
	/* log2(1.585938), 1.0 / 1.585938 */
	.word	0x8ca5438e, 0x3fe54a6e, 0x25d51f87, 0x3fe42d66
	/* log2(1.589844), 1.0 / 1.589844 */
	.word	0x7b86b02c, 0x3fe56781, 0x265e5951, 0x3fe420b5
	/* log2(1.593750), 1.0 / 1.593750 */
	.word	0x26989d34, 0x3fe58482, 0x14141414, 0x3fe41414
	/* log2(1.597656), 1.0 / 1.597656 */
	.word	0xa4bf8d5c, 0x3fe5a170, 0xd10e6566, 0x3fe40782
	/* log2(1.601562), 1.0 / 1.601562 */
	.word	0x0cb51435, 0x3fe5be4d, 0x3fb013fb, 0x3fe3fb01
	/* log2(1.605469), 1.0 / 1.605469 */
	.word	0x7508413c, 0x3fe5db17, 0x42a5af07, 0x3fe3ee8f
	/* log2(1.609375), 1.0 / 1.609375 */
	.word	0xf41e09af, 0x3fe5f7cf, 0xbce4a902, 0x3fe3e22c
	/* log2(1.613281), 1.0 / 1.613281 */
	.word	0xa031b109, 0x3fe61476, 0x91aa75c6, 0x3fe3d5d9
	/* log2(1.617188), 1.0 / 1.617188 */
	.word	0x8f553048, 0x3fe6310b, 0xa47babe7, 0x3fe3c995
	/* log2(1.621094), 1.0 / 1.621094 */
	.word	0xd7719bf0, 0x3fe64d8e, 0xd9232955, 0x3fe3bd60
	/* log2(1.625000), 1.0 / 1.625000 */
	.word	0x8e4788cc, 0x3fe66a00, 0x13b13b14, 0x3fe3b13b
	/* log2(1.628906), 1.0 / 1.628906 */
	.word	0xc96f6f87, 0x3fe68660, 0x387ac822, 0x3fe3a524
	/* log2(1.632812), 1.0 / 1.632812 */
	.word	0x9e5a0f0a, 0x3fe6a2af, 0x2c187f63, 0x3fe3991c
	/* log2(1.636719), 1.0 / 1.636719 */
	.word	0x2250cdae, 0x3fe6beed, 0xd366088e, 0x3fe38d22
	/* log2(1.640625), 1.0 / 1.640625 */
	.word	0x6a76194a, 0x3fe6db19, 0x13813814, 0x3fe38138
	/* log2(1.644531), 1.0 / 1.644531 */
	.word	0x8bc5c618, 0x3fe6f734, 0xd1c945ee, 0x3fe3755b
	/* log2(1.648438), 1.0 / 1.648438 */
	.word	0x9b156c7c, 0x3fe7133e, 0xf3de0748, 0x3fe3698d
	/* log2(1.652344), 1.0 / 1.652344 */
	.word	0xad14c5b0, 0x3fe72f37, 0x5f9f2af8, 0x3fe35dce
	/* log2(1.656250), 1.0 / 1.656250 */
	.word	0xd64e0754, 0x3fe74b1f, 0xfb2b78c1, 0x3fe3521c
	/* log2(1.660156), 1.0 / 1.660156 */
	.word	0x2b263dee, 0x3fe766f7, 0xace01346, 0x3fe34679
	/* log2(1.664062), 1.0 / 1.664062 */
	.word	0xbfdda657, 0x3fe782bd, 0x5b57bcb2, 0x3fe33ae4
	/* log2(1.667969), 1.0 / 1.667969 */
	.word	0xa8900620, 0x3fe79e73, 0xed6a1dfa, 0x3fe32f5c
	/* log2(1.671875), 1.0 / 1.671875 */
	.word	0xf93502e4, 0x3fe7ba18, 0x4a2b10bf, 0x3fe323e3
	/* log2(1.675781), 1.0 / 1.675781 */
	.word	0xc5a078a4, 0x3fe7d5ad, 0x58e9ebb6, 0x3fe31877
	/* log2(1.679688), 1.0 / 1.679688 */
	.word	0x2182cf16, 0x3fe7f132, 0x0130d190, 0x3fe30d19
	/* log2(1.683594), 1.0 / 1.683594 */
	.word	0x20694df9, 0x3fe80ca6, 0x2ac40260, 0x3fe301c8
	/* log2(1.687500), 1.0 / 1.687500 */
	.word	0xd5be7073, 0x3fe82809, 0xbda12f68, 0x3fe2f684
	/* log2(1.691406), 1.0 / 1.691406 */
	.word	0x54ca3774, 0x3fe8435d, 0xa1fed14b, 0x3fe2eb4e
	/* log2(1.695312), 1.0 / 1.695312 */
	.word	0xb0b27b26, 0x3fe85ea0, 0xc04b8097, 0x3fe2e025
	/* log2(1.699219), 1.0 / 1.699219 */
	.word	0xfc7b3b71, 0x3fe879d3, 0x012d50a0, 0x3fe2d50a
	/* log2(1.703125), 1.0 / 1.703125 */
	.word	0x4b06ef8b, 0x3fe894f7, 0x4d812ca0, 0x3fe2c9fb
	/* log2(1.707031), 1.0 / 1.707031 */
	.word	0xaf16d4a9, 0x3fe8b00a, 0x8e5a3711, 0x3fe2bef9
	/* log2(1.710938), 1.0 / 1.710938 */
	.word	0x3b4b3bbe, 0x3fe8cb0e, 0xad012b40, 0x3fe2b404
	/* log2(1.714844), 1.0 / 1.714844 */
	.word	0x0223d661, 0x3fe8e602, 0x92f3c105, 0x3fe2a91c
	/* log2(1.718750), 1.0 / 1.718750 */
	.word	0x160002cd, 0x3fe900e6, 0x29e4129e, 0x3fe29e41
	/* log2(1.722656), 1.0 / 1.722656 */
	.word	0x891f1709, 0x3fe91bba, 0x5bb804a5, 0x3fe29372
	/* log2(1.726562), 1.0 / 1.726562 */
	.word	0x6da0ab2f, 0x3fe9367f, 0x1288b013, 0x3fe288b0
	/* log2(1.730469), 1.0 / 1.730469 */
	.word	0xd584e2e3, 0x3fe95134, 0x38a1ce4d, 0x3fe27dfa
	/* log2(1.734375), 1.0 / 1.734375 */
	.word	0xd2acb5f6, 0x3fe96bda, 0xb8812735, 0x3fe27350
	/* log2(1.738281), 1.0 / 1.738281 */
	.word	0x76da382f, 0x3fe98671, 0x7cd60127, 0x3fe268b3
	/* log2(1.742188), 1.0 / 1.742188 */
	.word	0xd3b0e050, 0x3fe9a0f8, 0x708092f1, 0x3fe25e22
	/* log2(1.746094), 1.0 / 1.746094 */
	.word	0xfab5ce4d, 0x3fe9bb70, 0x7e9177b2, 0x3fe2539d
	/* log2(1.750000), 1.0 / 1.750000 */
	.word	0xfd5010b3, 0x3fe9d5d9, 0x92492492, 0x3fe24924
	/* log2(1.753906), 1.0 / 1.753906 */
	.word	0xecc8e956, 0x3fe9f033, 0x9717605b, 0x3fe23eb7
	/* log2(1.757812), 1.0 / 1.757812 */
	.word	0xda4c112d, 0x3fea0a7e, 0x789abcdf, 0x3fe23456
	/* log2(1.761719), 1.0 / 1.761719 */
	.word	0xd6e7fb77, 0x3fea24ba, 0x22a0122a, 0x3fe22a01
	/* log2(1.765625), 1.0 / 1.765625 */
	.word	0xf38e181f, 0x3fea3ee7, 0x8121fb78, 0x3fe21fb7
	/* log2(1.769531), 1.0 / 1.769531 */
	.word	0x41131564, 0x3fea5906, 0x804855e6, 0x3fe21579
	/* log2(1.773438), 1.0 / 1.773438 */
	.word	0xd02f20c8, 0x3fea7315, 0x0c67c0d9, 0x3fe20b47
	/* log2(1.777344), 1.0 / 1.777344 */
	.word	0xb17e2745, 0x3fea8d16, 0x12012012, 0x3fe20120
	/* log2(1.781250), 1.0 / 1.781250 */
	.word	0xf58014d3, 0x3feaa708, 0x7dc11f70, 0x3fe1f704
	/* log2(1.785156), 1.0 / 1.785156 */
	.word	0xac99133b, 0x3feac0ec, 0x3c7fb84c, 0x3fe1ecf4
	/* log2(1.789062), 1.0 / 1.789062 */
	.word	0xe711c833, 0x3feadac1, 0x3b3fb874, 0x3fe1e2ef
	/* log2(1.792969), 1.0 / 1.792969 */
	.word	0xb51792d6, 0x3feaf488, 0x672e4abd, 0x3fe1d8f5
	/* log2(1.796875), 1.0 / 1.796875 */
	.word	0x26bcc86c, 0x3feb0e41, 0xada2811d, 0x3fe1cf06
	/* log2(1.800781), 1.0 / 1.800781 */
	.word	0x4bf8f08a, 0x3feb27eb, 0xfc1ce059, 0x3fe1c522
	/* log2(1.804688), 1.0 / 1.804688 */
	.word	0x34a9008c, 0x3feb4187, 0x4046ed29, 0x3fe1bb4a
	/* log2(1.808594), 1.0 / 1.808594 */
	.word	0xf08f9666, 0x3feb5b14, 0x67f2bae3, 0x3fe1b17c
	/* log2(1.812500), 1.0 / 1.812500 */
	.word	0x8f5532da, 0x3feb7494, 0x611a7b96, 0x3fe1a7b9
	/* log2(1.816406), 1.0 / 1.816406 */
	.word	0x20887309, 0x3feb8e06, 0x19e0119e, 0x3fe19e01
	/* log2(1.820312), 1.0 / 1.820312 */
	.word	0xb39e4964, 0x3feba769, 0x808ca29c, 0x3fe19453
	/* log2(1.824219), 1.0 / 1.824219 */
	.word	0x57f23606, 0x3febc0bf, 0x83902bdb, 0x3fe18ab0
	/* log2(1.828125), 1.0 / 1.828125 */
	.word	0x1cc67e6e, 0x3febda07, 0x11811812, 0x3fe18118
	/* log2(1.832031), 1.0 / 1.832031 */
	.word	0x114464a7, 0x3febf341, 0x191bd684, 0x3fe1778a
	/* log2(1.835938), 1.0 / 1.835938 */
	.word	0x447c5dd3, 0x3fec0c6d, 0x89427379, 0x3fe16e06
	/* log2(1.839844), 1.0 / 1.839844 */
	.word	0xc5664829, 0x3fec258b, 0x50fc3201, 0x3fe1648d
	/* log2(1.843750), 1.0 / 1.843750 */
	.word	0xa2e1a055, 0x3fec3e9c, 0x5f75270d, 0x3fe15b1e
	/* log2(1.847656), 1.0 / 1.847656 */
	.word	0xebb5b658, 0x3fec579f, 0xa3fdd5c9, 0x3fe151b9
	/* log2(1.851562), 1.0 / 1.851562 */
	.word	0xae91e1c7, 0x3fec7095, 0x0e0acd3b, 0x3fe1485f
	/* log2(1.855469), 1.0 / 1.855469 */
	.word	0xfa0db58e, 0x3fec897d, 0x8d344724, 0x3fe13f0e
	/* log2(1.859375), 1.0 / 1.859375 */
	.word	0xdca93316, 0x3feca258, 0x1135c811, 0x3fe135c8
	/* log2(1.863281), 1.0 / 1.863281 */
	.word	0x64ccfcf6, 0x3fecbb26, 0x89edc0ac, 0x3fe12c8b
	/* log2(1.867188), 1.0 / 1.867188 */
	.word	0xa0ca8907, 0x3fecd3e6, 0xe75d3033, 0x3fe12358
	/* log2(1.871094), 1.0 / 1.871094 */
	.word	0x9edc5203, 0x3fecec99, 0x19a74826, 0x3fe11a30
	/* log2(1.875000), 1.0 / 1.875000 */
	.word	0x6d260896, 0x3fed053f, 0x11111111, 0x3fe11111
	/* log2(1.878906), 1.0 / 1.878906 */
	.word	0x19b4c3f1, 0x3fed1dd8, 0xbe011080, 0x3fe107fb
	/* log2(1.882812), 1.0 / 1.882812 */
	.word	0xb27f31d5, 0x3fed3663, 0x10fef011, 0x3fe0fef0
	/* log2(1.886719), 1.0 / 1.886719 */
	.word	0x4565c62b, 0x3fed4ee2, 0xfab325a2, 0x3fe0f5ed
	/* log2(1.890625), 1.0 / 1.890625 */
	.word	0xe032ea0f, 0x3fed6753, 0x6be69c90, 0x3fe0ecf5
	/* log2(1.894531), 1.0 / 1.894531 */
	.word	0x909b2a6c, 0x3fed7fb8, 0x55826011, 0x3fe0e406
	/* log2(1.898438), 1.0 / 1.898438 */
	.word	0x643d6615, 0x3fed9810, 0xa88f4696, 0x3fe0db20
	/* log2(1.902344), 1.0 / 1.902344 */
	.word	0x68a2fb65, 0x3fedb05b, 0x56359e3a, 0x3fe0d244
	/* log2(1.906250), 1.0 / 1.906250 */
	.word	0xab3ff56c, 0x3fedc899, 0x4fbcda3b, 0x3fe0c971
	/* log2(1.910156), 1.0 / 1.910156 */
	.word	0x397338a4, 0x3fede0cb, 0x868b4171, 0x3fe0c0a7
	/* log2(1.914062), 1.0 / 1.914062 */
	.word	0x2086af2c, 0x3fedf8f0, 0xec259dc8, 0x3fe0b7e6
	/* log2(1.917969), 1.0 / 1.917969 */
	.word	0x6daf7496, 0x3fee1108, 0x722eecb5, 0x3fe0af2f
	/* log2(1.921875), 1.0 / 1.921875 */
	.word	0x2e0e0140, 0x3fee2914, 0x0a6810a7, 0x3fe0a681
	/* log2(1.925781), 1.0 / 1.925781 */
	.word	0x6eae553d, 0x3fee4113, 0xa6af8360, 0x3fe09ddb
	/* log2(1.929688), 1.0 / 1.929688 */
	.word	0x3c8822ce, 0x3fee5906, 0x39010954, 0x3fe0953f
	/* log2(1.933594), 1.0 / 1.933594 */
	.word	0xa47ef86f, 0x3fee70ec, 0xb37565e2, 0x3fe08cab
	/* log2(1.937500), 1.0 / 1.937500 */
	.word	0xb3626a73, 0x3fee88c6, 0x08421084, 0x3fe08421
	/* log2(1.941406), 1.0 / 1.941406 */
	.word	0x75ee3c3a, 0x3feea094, 0x29b8eae2, 0x3fe07b9f
	/* log2(1.945312), 1.0 / 1.945312 */
	.word	0xf8ca88fb, 0x3feeb855, 0x0a47f7c6, 0x3fe07326
	/* log2(1.949219), 1.0 / 1.949219 */
	.word	0x488bec23, 0x3feed00b, 0x9c7912fb, 0x3fe06ab5
	/* log2(1.953125), 1.0 / 1.953125 */
	.word	0x71b3a950, 0x3feee7b4, 0xd2f1a9fc, 0x3fe0624d
	/* log2(1.957031), 1.0 / 1.957031 */
	.word	0x80afd3e4, 0x3feeff51, 0xa0727586, 0x3fe059ee
	/* log2(1.960938), 1.0 / 1.960938 */
	.word	0x81db7630, 0x3fef16e2, 0xf7d73404, 0x3fe05197
	/* log2(1.964844), 1.0 / 1.964844 */
	.word	0x817eb845, 0x3fef2e67, 0xcc1664c5, 0x3fe04949
	/* log2(1.968750), 1.0 / 1.968750 */
	.word	0x8bcf0655, 0x3fef45e0, 0x10410410, 0x3fe04104
	/* log2(1.972656), 1.0 / 1.972656 */
	.word	0xacef36be, 0x3fef5d4d, 0xb78247fc, 0x3fe038c6
	/* log2(1.976562), 1.0 / 1.976562 */
	.word	0xf0efafae, 0x3fef74ae, 0xb51f5e1a, 0x3fe03091
	/* log2(1.980469), 1.0 / 1.980469 */
	.word	0x63ce8c69, 0x3fef8c04, 0xfc7729e9, 0x3fe02864
	/* log2(1.984375), 1.0 / 1.984375 */
	.word	0x1177c233, 0x3fefa34e, 0x81020408, 0x3fe02040
	/* log2(1.988281), 1.0 / 1.988281 */
	.word	0x05c544df, 0x3fefba8c, 0x36517a37, 0x3fe01824
	/* log2(1.992188), 1.0 / 1.992188 */
	.word	0x4c7f2af9, 0x3fefd1be, 0x10101010, 0x3fe01010
	/* log2(1.996094), 1.0 / 1.996094 */
	.word	0xf15bd1a0, 0x3fefe8e4, 0x02010080, 0x3fe00804
	/* log2(2.000000), 1.0 / 2.000000 */
	.word	0x00000000, 0x3ff00000, 0x00000000, 0x3fe00000
	.cfi_endproc
END(__kernel_log2)
