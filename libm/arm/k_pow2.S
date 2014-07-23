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
 *        a    a             a         2    a         3
 * 2^x = 2  + 2 *S1*(x-a) + 2 *S2*(x-a)  + 2 *S3*(x-a)
 *
 *        a         4    a         5
 *     + 2 *S4*(x-a)  + 2 *S5*(x-a)
 *
 * a is a number which is very close to x, and:
 *
 * S1 = ln2
 *
 *            2
 *       (ln2)
 * S2 = --------
 *         2!
 *
 * ...
 *
 *            5
 *       (ln2)
 * S5 = --------
 *         5!
 *
 */

#include <bionic_asm.h>

#define LUT_SIZE	256
#define LUT_SIZE_SHIFT	8

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
#define pow2a		d28

#if FPU_VFPV4
	.fpu	vfpv4
#define MLAF64		vfma.f64
#define MLSF64		vfms.f64
#else
#define MLAF64		vmla.f64
#define MLSF64		vmls.f64
#endif

ENTRY(__kernel_pow2)	/* x in d0 and r0/r1, 1.0 <= x < 2.0 */

lookup:
	/* get index in lut */
	add		ixh, ixh, #(1 << (20-LUT_SIZE_SHIFT-1))
        mov		ixl, #0
        bfi		ixh, ixl, #0, #(20-LUT_SIZE_SHIFT)
        vmov		a, ixl, ixh
        sub		r3, ixh, #0x3fc00000
        sub		r3, r3, #0x00300000
        lsr		r3, r3, #(20-LUT_SIZE_SHIFT)
        adr		ip, .Lpow2_lut
        add		ip, ip, r3, lsl #3
        vldr		pow2a, [ip]

taylor_series:
	adr		r2, .Ls5
	vldmia		r2, {t5-t1}
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
	/* (2^a) * (1.0 + (S1 + (S2 + (S3 + (S4 + S5 *
		dx) * dx) * dx) * dx) * dx) */
	vmul.f64	ret, pow2a, t0
	bx		lr

.Ls5:
	.word	0xe78a6731, 0x3f55d87f	/* ((ln2)^5)/(5!) */
.Ls4:
	.word	0x6fba4e77, 0x3f83b2ab	/* ((ln2)^4)/(4!) */
.Ls3:
	.word	0xd704a0c0, 0x3fac6b08	/* ((ln2)^3)/(3!) */
.Ls2:
	.word	0xff82c58f, 0x3fcebfbd	/* ((ln2)^2)/(2!) */
.Ls1:
	.word	0xfefa39ef, 0x3fe62e42	/* ((ln2)^1)/(1!) */

.Lpow2_lut:
	.word	0x00000000, 0x40000000	/* 2^1.000000 */
	.word	0xfa5abcbf, 0x40000b1a	/* 2^1.003906 */
	.word	0xa9fb3335, 0x4000163d	/* 2^1.007812 */
	.word	0x143b0281, 0x40002168	/* 2^1.011719 */
	.word	0x3e778061, 0x40002c9a	/* 2^1.015625 */
	.word	0x2e11bbcc, 0x400037d4	/* 2^1.019531 */
	.word	0xe86e7f85, 0x40004315	/* 2^1.023438 */
	.word	0x72f654b1, 0x40004e5f	/* 2^1.027344 */
	.word	0xd3158574, 0x400059b0	/* 2^1.031250 */
	.word	0x0e3c1f89, 0x4000650a	/* 2^1.035156 */
	.word	0x29ddf6de, 0x4000706b	/* 2^1.039062 */
	.word	0x2b72a836, 0x40007bd4	/* 2^1.042969 */
	.word	0x18759bc8, 0x40008745	/* 2^1.046875 */
	.word	0xf66607e0, 0x400092bd	/* 2^1.050781 */
	.word	0xcac6f383, 0x40009e3e	/* 2^1.054688 */
	.word	0x9b1f3919, 0x4000a9c7	/* 2^1.058594 */
	.word	0x6cf9890f, 0x4000b558	/* 2^1.062500 */
	.word	0x45e46c85, 0x4000c0f1	/* 2^1.066406 */
	.word	0x2b7247f7, 0x4000cc92	/* 2^1.070312 */
	.word	0x23395dec, 0x4000d83b	/* 2^1.074219 */
	.word	0x32d3d1a2, 0x4000e3ec	/* 2^1.078125 */
	.word	0x5fdfa9c5, 0x4000efa5	/* 2^1.082031 */
	.word	0xaffed31b, 0x4000fb66	/* 2^1.085938 */
	.word	0x28d7233e, 0x40010730	/* 2^1.089844 */
	.word	0xd0125b51, 0x40011301	/* 2^1.093750 */
	.word	0xab5e2ab6, 0x40011edb	/* 2^1.097656 */
	.word	0xc06c31cc, 0x40012abd	/* 2^1.101562 */
	.word	0x14f204ab, 0x400136a8	/* 2^1.105469 */
	.word	0xaea92de0, 0x4001429a	/* 2^1.109375 */
	.word	0x934f312e, 0x40014e95	/* 2^1.113281 */
	.word	0xc8a58e51, 0x40015a98	/* 2^1.117188 */
	.word	0x5471c3c2, 0x400166a4	/* 2^1.121094 */
	.word	0x3c7d517b, 0x400172b8	/* 2^1.125000 */
	.word	0x8695bbc0, 0x40017ed4	/* 2^1.128906 */
	.word	0x388c8dea, 0x40018af9	/* 2^1.132812 */
	.word	0x58375d2f, 0x40019726	/* 2^1.136719 */
	.word	0xeb6fcb75, 0x4001a35b	/* 2^1.140625 */
	.word	0xf8138a1c, 0x4001af99	/* 2^1.144531 */
	.word	0x84045cd4, 0x4001bbe0	/* 2^1.148438 */
	.word	0x95281c6b, 0x4001c82f	/* 2^1.152344 */
	.word	0x3168b9aa, 0x4001d487	/* 2^1.156250 */
	.word	0x5eb44027, 0x4001e0e7	/* 2^1.160156 */
	.word	0x22fcd91d, 0x4001ed50	/* 2^1.164062 */
	.word	0x8438ce4d, 0x4001f9c1	/* 2^1.167969 */
	.word	0x88628cd6, 0x4002063b	/* 2^1.171875 */
	.word	0x3578a819, 0x400212be	/* 2^1.175781 */
	.word	0x917ddc96, 0x40021f49	/* 2^1.179688 */
	.word	0xa27912d1, 0x40022bdd	/* 2^1.183594 */
	.word	0x6e756238, 0x4002387a	/* 2^1.187500 */
	.word	0xfb82140a, 0x4002451f	/* 2^1.191406 */
	.word	0x4fb2a63f, 0x400251ce	/* 2^1.195312 */
	.word	0x711ece75, 0x40025e85	/* 2^1.199219 */
	.word	0x65e27cdd, 0x40026b45	/* 2^1.203125 */
	.word	0x341ddf29, 0x4002780e	/* 2^1.207031 */
	.word	0xe1f56381, 0x400284df	/* 2^1.210938 */
	.word	0x7591bb70, 0x400291ba	/* 2^1.214844 */
	.word	0xf51fdee1, 0x40029e9d	/* 2^1.218750 */
	.word	0x66d10f13, 0x4002ab8a	/* 2^1.222656 */
	.word	0xd0dad990, 0x4002b87f	/* 2^1.226562 */
	.word	0x39771b2f, 0x4002c57e	/* 2^1.230469 */
	.word	0xa6e4030b, 0x4002d285	/* 2^1.234375 */
	.word	0x1f641589, 0x4002df96	/* 2^1.238281 */
	.word	0xa93e2f56, 0x4002ecaf	/* 2^1.242188 */
	.word	0x4abd886b, 0x4002f9d2	/* 2^1.246094 */
	.word	0x0a31b715, 0x400306fe	/* 2^1.250000 */
	.word	0xedeeb2fd, 0x40031432	/* 2^1.253906 */
	.word	0xfc4cd831, 0x40032170	/* 2^1.257812 */
	.word	0x3ba8ea32, 0x40032eb8	/* 2^1.261719 */
	.word	0xb26416ff, 0x40033c08	/* 2^1.265625 */
	.word	0x66e3fa2d, 0x40034962	/* 2^1.269531 */
	.word	0x5f929ff1, 0x400356c5	/* 2^1.273438 */
	.word	0xa2de883b, 0x40036431	/* 2^1.277344 */
	.word	0x373aa9cb, 0x400371a7	/* 2^1.281250 */
	.word	0x231e754a, 0x40037f26	/* 2^1.285156 */
	.word	0x6d05d866, 0x40038cae	/* 2^1.289062 */
	.word	0x1b7140ef, 0x40039a40	/* 2^1.292969 */
	.word	0x34e59ff7, 0x4003a7db	/* 2^1.296875 */
	.word	0xbfec6cf4, 0x4003b57f	/* 2^1.300781 */
	.word	0xc313a8e5, 0x4003c32d	/* 2^1.304688 */
	.word	0x44ede173, 0x4003d0e5	/* 2^1.308594 */
	.word	0x4c123422, 0x4003dea6	/* 2^1.312500 */
	.word	0xdf1c5175, 0x4003ec70	/* 2^1.316406 */
	.word	0x04ac801c, 0x4003fa45	/* 2^1.320312 */
	.word	0xc367a024, 0x40040822	/* 2^1.324219 */
	.word	0x21f72e2a, 0x4004160a	/* 2^1.328125 */
	.word	0x2709468a, 0x400423fb	/* 2^1.332031 */
	.word	0xd950a897, 0x400431f5	/* 2^1.335938 */
	.word	0x3f84b9d4, 0x40043ffa	/* 2^1.339844 */
	.word	0x6061892d, 0x40044e08	/* 2^1.343750 */
	.word	0x42a7d232, 0x40045c20	/* 2^1.347656 */
	.word	0xed1d0057, 0x40046a41	/* 2^1.351562 */
	.word	0x668b3237, 0x4004786d	/* 2^1.355469 */
	.word	0xb5c13cd0, 0x400486a2	/* 2^1.359375 */
	.word	0xe192aed2, 0x400494e1	/* 2^1.363281 */
	.word	0xf0d7d3de, 0x4004a32a	/* 2^1.367188 */
	.word	0xea6db7d7, 0x4004b17d	/* 2^1.371094 */
	.word	0xd5362a27, 0x4004bfda	/* 2^1.375000 */
	.word	0xb817c114, 0x4004ce41	/* 2^1.378906 */
	.word	0x99fddd0d, 0x4004dcb2	/* 2^1.382812 */
	.word	0x81d8abff, 0x4004eb2d	/* 2^1.386719 */
	.word	0x769d2ca7, 0x4004f9b2	/* 2^1.390625 */
	.word	0x7f4531ee, 0x40050841	/* 2^1.394531 */
	.word	0xa2cf6642, 0x400516da	/* 2^1.398438 */
	.word	0xe83f4eef, 0x4005257d	/* 2^1.402344 */
	.word	0x569d4f82, 0x4005342b	/* 2^1.406250 */
	.word	0xf4f6ad27, 0x400542e2	/* 2^1.410156 */
	.word	0xca5d920f, 0x400551a4	/* 2^1.414062 */
	.word	0xdde910d2, 0x40056070	/* 2^1.417969 */
	.word	0x36b527da, 0x40056f47	/* 2^1.421875 */
	.word	0xdbe2c4cf, 0x40057e27	/* 2^1.425781 */
	.word	0xd497c7fd, 0x40058d12	/* 2^1.429688 */
	.word	0x27ff07cc, 0x40059c08	/* 2^1.433594 */
	.word	0xdd485429, 0x4005ab07	/* 2^1.437500 */
	.word	0xfba87a03, 0x4005ba11	/* 2^1.441406 */
	.word	0x8a5946b7, 0x4005c926	/* 2^1.445312 */
	.word	0x90998b93, 0x4005d845	/* 2^1.449219 */
	.word	0x15ad2148, 0x4005e76f	/* 2^1.453125 */
	.word	0x20dceb71, 0x4005f6a3	/* 2^1.457031 */
	.word	0xb976dc09, 0x400605e1	/* 2^1.460938 */
	.word	0xe6cdf6f4, 0x4006152a	/* 2^1.464844 */
	.word	0xb03a5585, 0x4006247e	/* 2^1.468750 */
	.word	0x1d1929fd, 0x400633dd	/* 2^1.472656 */
	.word	0x34ccc320, 0x40064346	/* 2^1.476562 */
	.word	0xfebc8fb7, 0x400652b9	/* 2^1.480469 */
	.word	0x82552225, 0x40066238	/* 2^1.484375 */
	.word	0xc70833f6, 0x400671c1	/* 2^1.488281 */
	.word	0xd44ca973, 0x40068155	/* 2^1.492188 */
	.word	0xb19e9538, 0x400690f4	/* 2^1.496094 */
	.word	0x667f3bcd, 0x4006a09e	/* 2^1.500000 */
	.word	0xfa75173e, 0x4006b052	/* 2^1.503906 */
	.word	0x750bdabf, 0x4006c012	/* 2^1.507812 */
	.word	0xddd47645, 0x4006cfdc	/* 2^1.511719 */
	.word	0x3c651a2f, 0x4006dfb2	/* 2^1.515625 */
	.word	0x98593ae5, 0x4006ef92	/* 2^1.519531 */
	.word	0xf9519484, 0x4006ff7d	/* 2^1.523438 */
	.word	0x66f42e87, 0x40070f74	/* 2^1.527344 */
	.word	0xe8ec5f74, 0x40071f75	/* 2^1.531250 */
	.word	0x86ead08a, 0x40072f82	/* 2^1.535156 */
	.word	0x48a58174, 0x40073f9a	/* 2^1.539062 */
	.word	0x35d7cbfd, 0x40074fbd	/* 2^1.542969 */
	.word	0x564267c9, 0x40075feb	/* 2^1.546875 */
	.word	0xb1ab6e09, 0x40077024	/* 2^1.550781 */
	.word	0x4fde5d3f, 0x40078069	/* 2^1.554688 */
	.word	0x38ac1cf6, 0x400790b9	/* 2^1.558594 */
	.word	0x73eb0187, 0x4007a114	/* 2^1.562500 */
	.word	0x0976cfdb, 0x4007b17b	/* 2^1.566406 */
	.word	0x0130c132, 0x4007c1ed	/* 2^1.570312 */
	.word	0x62ff86f0, 0x4007d26a	/* 2^1.574219 */
	.word	0x36cf4e62, 0x4007e2f3	/* 2^1.578125 */
	.word	0x8491c491, 0x4007f387	/* 2^1.582031 */
	.word	0x543e1a12, 0x40080427	/* 2^1.585938 */
	.word	0xadd106d9, 0x400814d2	/* 2^1.589844 */
	.word	0x994cce13, 0x40082589	/* 2^1.593750 */
	.word	0x1eb941f7, 0x4008364c	/* 2^1.597656 */
	.word	0x4623c7ad, 0x4008471a	/* 2^1.601562 */
	.word	0x179f5b21, 0x400857f4	/* 2^1.605469 */
	.word	0x9b4492ed, 0x400868d9	/* 2^1.609375 */
	.word	0xd931a436, 0x400879ca	/* 2^1.613281 */
	.word	0xd98a6699, 0x40088ac7	/* 2^1.617188 */
	.word	0xa478580f, 0x40089bd0	/* 2^1.621094 */
	.word	0x422aa0db, 0x4008ace5	/* 2^1.625000 */
	.word	0xbad61778, 0x4008be05	/* 2^1.628906 */
	.word	0x16b5448c, 0x4008cf32	/* 2^1.632812 */
	.word	0x5e0866d9, 0x4008e06a	/* 2^1.636719 */
	.word	0x99157736, 0x4008f1ae	/* 2^1.640625 */
	.word	0xd0282c8a, 0x400902fe	/* 2^1.644531 */
	.word	0x0b91ffc6, 0x4009145b	/* 2^1.648438 */
	.word	0x53aa2fe2, 0x400925c3	/* 2^1.652344 */
	.word	0xb0cdc5e5, 0x40093737	/* 2^1.656250 */
	.word	0x2b5f98e5, 0x400948b8	/* 2^1.660156 */
	.word	0xcbc8520f, 0x40095a44	/* 2^1.664062 */
	.word	0x9a7670b3, 0x40096bdd	/* 2^1.667969 */
	.word	0x9fde4e50, 0x40097d82	/* 2^1.671875 */
	.word	0xe47a22a2, 0x40098f33	/* 2^1.675781 */
	.word	0x70ca07ba, 0x4009a0f1	/* 2^1.679688 */
	.word	0x4d53fe0d, 0x4009b2bb	/* 2^1.683594 */
	.word	0x82a3f090, 0x4009c491	/* 2^1.687500 */
	.word	0x194bb8d5, 0x4009d674	/* 2^1.691406 */
	.word	0x19e32323, 0x4009e863	/* 2^1.695312 */
	.word	0x8d07f29e, 0x4009fa5e	/* 2^1.699219 */
	.word	0x7b5de565, 0x400a0c66	/* 2^1.703125 */
	.word	0xed8eb8bb, 0x400a1e7a	/* 2^1.707031 */
	.word	0xec4a2d33, 0x400a309b	/* 2^1.710938 */
	.word	0x80460ad8, 0x400a42c9	/* 2^1.714844 */
	.word	0xb23e255d, 0x400a5503	/* 2^1.718750 */
	.word	0x8af46052, 0x400a674a	/* 2^1.722656 */
	.word	0x1330b358, 0x400a799e	/* 2^1.726562 */
	.word	0x53c12e59, 0x400a8bfe	/* 2^1.730469 */
	.word	0x5579fdbf, 0x400a9e6b	/* 2^1.734375 */
	.word	0x21356eba, 0x400ab0e5	/* 2^1.738281 */
	.word	0xbfd3f37a, 0x400ac36b	/* 2^1.742188 */
	.word	0x3a3c2774, 0x400ad5ff	/* 2^1.746094 */
	.word	0x995ad3ad, 0x400ae89f	/* 2^1.750000 */
	.word	0xe622f2ff, 0x400afb4c	/* 2^1.753906 */
	.word	0x298db666, 0x400b0e07	/* 2^1.757812 */
	.word	0x6c9a8952, 0x400b20ce	/* 2^1.761719 */
	.word	0xb84f15fb, 0x400b33a2	/* 2^1.765625 */
	.word	0x15b749b1, 0x400b4684	/* 2^1.769531 */
	.word	0x8de5593a, 0x400b5972	/* 2^1.773438 */
	.word	0x29f1c52a, 0x400b6c6e	/* 2^1.777344 */
	.word	0xf2fb5e47, 0x400b7f76	/* 2^1.781250 */
	.word	0xf22749e4, 0x400b928c	/* 2^1.785156 */
	.word	0x30a1064a, 0x400ba5b0	/* 2^1.789062 */
	.word	0xb79a6f1f, 0x400bb8e0	/* 2^1.792969 */
	.word	0x904bc1d2, 0x400bcc1e	/* 2^1.796875 */
	.word	0xc3f3a207, 0x400bdf69	/* 2^1.800781 */
	.word	0x5bd71e09, 0x400bf2c2	/* 2^1.804688 */
	.word	0x6141b33d, 0x400c0628	/* 2^1.808594 */
	.word	0xdd85529c, 0x400c199b	/* 2^1.812500 */
	.word	0xd9fa652c, 0x400c2d1c	/* 2^1.816406 */
	.word	0x5fffd07a, 0x400c40ab	/* 2^1.820312 */
	.word	0x78fafb22, 0x400c5447	/* 2^1.824219 */
	.word	0x2e57d14b, 0x400c67f1	/* 2^1.828125 */
	.word	0x8988c933, 0x400c7ba8	/* 2^1.832031 */
	.word	0x9406e7b5, 0x400c8f6d	/* 2^1.835938 */
	.word	0x5751c4db, 0x400ca340	/* 2^1.839844 */
	.word	0xdcef9069, 0x400cb720	/* 2^1.843750 */
	.word	0x2e6d1675, 0x400ccb0f	/* 2^1.847656 */
	.word	0x555dc3fa, 0x400cdf0b	/* 2^1.851562 */
	.word	0x5b5bab74, 0x400cf315	/* 2^1.855469 */
	.word	0x4a07897c, 0x400d072d	/* 2^1.859375 */
	.word	0x2b08c968, 0x400d1b53	/* 2^1.863281 */
	.word	0x080d89f2, 0x400d2f87	/* 2^1.867188 */
	.word	0xeacaa1d6, 0x400d43c8	/* 2^1.871094 */
	.word	0xdcfba487, 0x400d5818	/* 2^1.875000 */
	.word	0xe862e6d3, 0x400d6c76	/* 2^1.878906 */
	.word	0x16c98398, 0x400d80e3	/* 2^1.882812 */
	.word	0x71ff6075, 0x400d955d	/* 2^1.886719 */
	.word	0x03db3285, 0x400da9e6	/* 2^1.890625 */
	.word	0xd63a8315, 0x400dbe7c	/* 2^1.894531 */
	.word	0xf301b460, 0x400dd321	/* 2^1.898438 */
	.word	0x641c0658, 0x400de7d5	/* 2^1.902344 */
	.word	0x337b9b5f, 0x400dfc97	/* 2^1.906250 */
	.word	0x6b197d17, 0x400e1167	/* 2^1.910156 */
	.word	0x14f5a129, 0x400e2646	/* 2^1.914062 */
	.word	0x3b16ee12, 0x400e3b33	/* 2^1.917969 */
	.word	0xe78b3ff6, 0x400e502e	/* 2^1.921875 */
	.word	0x24676d76, 0x400e6539	/* 2^1.925781 */
	.word	0xfbc74c83, 0x400e7a51	/* 2^1.929688 */
	.word	0x77cdb740, 0x400e8f79	/* 2^1.933594 */
	.word	0xa2a490da, 0x400ea4af	/* 2^1.937500 */
	.word	0x867cca6e, 0x400eb9f4	/* 2^1.941406 */
	.word	0x2d8e67f1, 0x400ecf48	/* 2^1.945312 */
	.word	0xa2188510, 0x400ee4aa	/* 2^1.949219 */
	.word	0xee615a27, 0x400efa1b	/* 2^1.953125 */
	.word	0x1cb6412a, 0x400f0f9c	/* 2^1.957031 */
	.word	0x376bba97, 0x400f252b	/* 2^1.960938 */
	.word	0x48dd7274, 0x400f3ac9	/* 2^1.964844 */
	.word	0x5b6e4540, 0x400f5076	/* 2^1.968750 */
	.word	0x798844f8, 0x400f6632	/* 2^1.972656 */
	.word	0xad9cbe14, 0x400f7bfd	/* 2^1.976562 */
	.word	0x02243c89, 0x400f91d8	/* 2^1.980469 */
	.word	0x819e90d8, 0x400fa7c1	/* 2^1.984375 */
	.word	0x3692d514, 0x400fbdba	/* 2^1.988281 */
	.word	0x2b8f71f1, 0x400fd3c2	/* 2^1.992188 */
	.word	0x6b2a23d9, 0x400fe9d9	/* 2^1.996094 */
	.word	0x00000000, 0x40100000	/* 2^2.000000 */

END(__kernel_pow2)
