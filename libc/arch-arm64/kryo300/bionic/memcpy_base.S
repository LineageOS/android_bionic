/* Copyright (c) 2015 The Linux Foundation. All rights reserved.
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

#define		A53_OPT

#define		TEST		(0x200)

#ifdef	IL_512
#define		IL_DIST		(0x200)
#define		PRFM_SUB	(64*1)
#define		PRFM_HI_DIST	(0x10*2)
#else
#define		IL_DIST		(0x400)
#define		PRFM_SUB	(64*2)
#define		PRFM_HI_DIST	(0x14*2)
#endif

#define		PRFM_COPY

//Configurable parameters
#define		PLD_COPY_SIZE		(0x400 * 0x100 * 1)

	PRFM	PLDL1KEEP,	[X1]
	CMP	X2,	(320*2)
	B.HI	copy_long
	CMP	X2,	16
	B.LS	copy16
	PRFM	PSTL1KEEP,	[X0]

	LDP	X6,	X7,	[X1]
	ADD	X4,	X1,	X2
	LDP	X12,	X13,	[X4, -16]
	SUBS	X2,	X2,	32
	ADD	X3,	X0,	X2
	BGT	small_copy
	STP	X6,	X7,	[X0]
	STP	X12,	X13,	[X3, 16]
	RET

	.p2align 4
small_copy:
	SUBS	X2,	X2,	#32
	BGT	2f
	LDP	X10,	X11,	[X4, -32]
	LDP	X8,	X9,	[X1, 16]
	STP	X6,	X7,	[X0]
	STP	X8,	X9,	[X0, 16]
	STP	X10,	X11,	[X3]
	STP	X12,	X13,	[X3, 16]
	RET
2:
	BIC	X5,	X1,	#0xF
	LDP	X8,	X9,	[X5, 16]
	LDP	X10,	X11,	[X4, -32]
	PRFM	PSTL1KEEP,	[X0, #80]
	STP	X6,	X7,	[X0]
	LDP	X6,	X7,	[X5, 32]!
	AND	X14,	X1,	#0xF
	SUB	X15,	X0,	X14
	ADD	X2,	X2,	X14
	SUBS	X2,	X2,	#0x10
	BLE	2f
	PRFM	PLDL1KEEP,	[X5, #48]
	PRFM	PSTL1KEEP,	[X3]
1:
	STP	X8,	X9,	[X15, 16]
	LDP	X8,	X9,	[X5, 16]
	STP	X6,	X7,	[X15, 32]!
	LDP	X6,	X7,	[X5, 32]!
	SUBS	X2,	X2,	32
	BGT	1b
2:
	STP	X8,	X9,	[X15, 16]
	STP	X6,	X7,	[X15, 32]
	STP	X10,	X11,	[X3]
	STP	X12,	X13,	[X3, 16]
	RET

	.p2align 6
	/* Small copies: 0..16 bytes.  */
copy16:
	CBZ	X2,	2f
	PRFM	PSTL1KEEP,	[X0]
	ADD	X3,	X0,	X2
	ADD	X4,	X1,	X2
	CMP	X2,	8
	B.LO	1f
	LDR	X6,	[X1]
	LDR	X7,	[X4, -8]
	STR	X6,	[X0]
	STR	X7,	[X3, -8]
	RET
1:
	TBZ	X2,	2,	1f
	LDR	W6,	[X1]
	LDR	W7,	[X4, -4]
	STR	W6,	[X0]
	STR	W7,	[X3, -4]
	RET
	/* Copy 0..3 bytes.  Use a branchless sequence that copies the same
	 byte 3 times if count==1, or the 2nd byte twice if count==2.  */
1:
	LSR	X9,	X2,	1
	LDRB	W6,	[X1]
	LDRB	W7,	[X4, -1]
	LDRB	W8,	[X1, X9]
	STRB	W6,	[X0]
	STRB	W8,	[X0, x9]
	STRB	W7,	[X3, -1]
2:	RET

	.p2align	6
copy_long:
#ifdef	PRFM_COPY
	CMP	X2,	#PLD_COPY_SIZE
	BGE	prfm_cpy
#endif
	LDP	X12,	X13,	[X1]
	PRFM	PLDL1KEEP,	[X1, #64]
	BIC	X5,	X1,	#0xF
	AND	X14,	X1,	#0xF
	SUB	X15,	X0,	X14
	LDP	X6,	X7,	[X5, 16]
	LDP	X8,	X9,	[X5, 32]
	PRFM	PLDL1KEEP,	[X5, #144]
	STP	X12,	X13,	[X0]
	LDP	X10,	X11,	[X5, 48]
	LDP	X12,	X13,	[X5, 64]!
	ADD	X2,	X2,	X14
	SUB	X2,	X2,	#144
	PRFM	PLDL1KEEP,	[X5, #144]
	ADD	X4,	X5,	X2
	ADD	X3,	X15,	X2
1:
	STP	X6,	X7,	[X15, 16]
	LDP	X6,	X7,	[X5, 16]
	STP	X8,	X9,	[X15, 32]
	LDP	X8,	X9,	[X5, 32]
	STP	X10,	X11,	[X15, 48]
	LDP	X10,	X11,	[X5, 48]
	STP	X12,	X13,	[X15, 64]!
	LDP	X12,	X13,	[X5, 64]!
	SUBS	X2,	X2,	64
	BGT	1b
	LDP	X1,	X14,	[X4, 16]
	STP	X6,	X7,	[X15, 16]
	LDP	X6,	X7,	[X4, 32]
	STP	X8,	X9,	[X15, 32]
	LDP	X8,	X9,	[X4, 48]
	STP	X10,	X11,	[X15, 48]
	LDP	X10,	X11,	[X4, 64]
	STP	X12,	X13,	[X15, 64]
	STP	X1,	X14,	[X3, 80]
	STP	X6,	X7,	[X3, 96]
	STP	X8,	X9,	[X3, 112]
	STP	X10,	X11,	[X3, 128]
	RET

	.p2align	6
prfm_cpy:
	NEG	X4,	X1
	ANDS	X4,	X4,	#0x3F
	ADD	X15,	X0,	X4
	PRFM	PLDL1KEEP,	[X1, 64]
	BEQ	dst_64_bytealigned
	SUB	X6,	X1,	#0x10
	LDP	X7,	X8,	[X6, #0x10]!
	ADD	X1,	X1,	X4
	SUB	X2,	X2,	X4
	SUB	X5,	X0,	#0x10
	SUBS	X4,	X4,	#0x10
	BLE	2f
1:
	STP	X7,	X8,	[X5, #0x10]!
	LDP	X7,	X8,	[X6, #0x10]!
	SUBS	X4,	X4,	#0x10
	BGT	1b
2:
	STP	X7,	X8,	[X5, #0x10]
dst_64_bytealigned:
	MOV	X4,	#(IL_DIST)
	SUB	X3,	X4,	#1
	AND	X6,	X15,	X3
	AND	X4,	X1,	X3
	PRFM	PLDL1KEEP,	[x1, 128]
	SUBS	X6,	X4,	X6
	SUB	X7,	XZR,	X6
	CSEL	X7,	X7,	X6,	LT
	PRFM	PLDL1KEEP,	[x1, 192]
	MOV	X4,	#(IL_DIST)
	EOR	X8,	X15,	X1
	ANDS	X8,	X8,	X4
	CSEL	X11,	X4,	XZR,	EQ
	PRFM	PLDL1KEEP,	[x1, 256]
	LSR	X5,	X4,	1
	SUB	X9,	XZR,	X9
	CSEL	X9,	XZR,	X9,	EQ
	PRFM	PLDL1KEEP,	[x1, 320]
	CMP	X6,	X9
	BLT	1f
	ADDS	X8,	X8,	XZR
	CSEL	X9,	X7,	X6,	EQ
	SUB	X7,	XZR,	X9
	ADD	X11,	X4,	X11
	BNE	1f
	ADD	X11,	X11,	X4
	CMP	X6,	X5
	CSEL	X11,	X4,	X11,	LT
1:
	ADD	X6,	X11,	X7
	LDP	X7,	X8,	[X1]
	LDP	X9,	X10,	[X1, #16]
	PRFM	PLDL1KEEP,	[x1, 384]

	ADD	X6,	X6,	#(PRFM_HI_DIST << 6)
	BIC	X6,	X6,	#0x3F
	ADD	X3,	X1,	X6
	SUB	X3,	X3,	#(PRFM_SUB)
	PRFM	PLDL1KEEP,	[x1, 448]
	SUB	X4,	X3,	X1
	SUB	X4,	X4,	#(TEST)
	SUB	X5,	X2,	X4
	SUB	X5,	X5,	X6
	PRFM	PLDL1KEEP,	[x1, 512]
	LDP	X11,	X12,	[X1, #32]
	LDP	X13,	X14,	[X1, #48]!
	SUB	X15,	X15,	#16
	SUB	X4,	X4,	#0x40 * 2

double_pld:
	PRFM	PLDL1KEEP,	[X1, #(TEST + 16)]
	STP	X7,	X8,	[X15, #16]
	LDP	X7,	X8,	[X1, #16]
	STP	X9,	X10,	[X15, #32]
	LDP	X9,	X10,	[X1, #32]
	PRFM	PLDL3KEEP,	[X3]
	ADD	X3,	X3,	#64
	STP	X11,	X12,	[X15, #48]
	LDP	X11,	X12,	[X1, #48]
	STP	X13,	X14,	[X15, #64]!
	LDP	X13,	X14,	[X1, #64]!
	SUBS	X4,	X4,	#0x40
	BGT	double_pld
single_pld:
prfm_copy_loop:
	PRFM	PLDL3KEEP,	[X3]
	ADD	X3,	X3,	#64
	STP	X7,	X8,	[X15, #16]
	LDP	X7,	X8,	[X1, #16]
	STP	X9,	X10,	[X15, #32]
	LDP	X9,	X10,	[X1, #32]
	STP	X11,	X12,	[X15, #48]
	LDP	X11,	X12,	[X1, #48]
	STP	X13,	X14,	[X15, #64]!
	LDP	X13,	X14,	[X1, #64]!
	SUBS	X5,	X5,	#0x40
	BGT	prfm_copy_loop
prfm_done:
	PRFM	PLDL3KEEP,	[X3]
plded_copy_loop:
	STP	X7,	X8,	[X15, #16]
	LDP	X7,	X8,	[X1, #16]
	STP	X9,	X10,	[X15, #32]
	LDP	X9,	X10,	[X1, #32]
	STP	X11,	X12,	[X15, #48]
	LDP	X11,	X12,	[X1, #48]
	STP	X13,	X14,	[X15, #64]!
	LDP	X13,	X14,	[X1, #64]!
	SUBS	X6,	X6,	#0x40
	BGT	plded_copy_loop
	ADD	X4,	X1,	X5
	STP	X7,	X8,	[X15, #16]
	LDP	X1,	X2,	[X4, #16]
	STP	X9,	X10,	[X15, 32]
	LDP	X7,	X8,	[X4, 32]
	STP	X11,	X12,	[X15, 48]
	LDP	X9,	X10,	[X4, 48]
	STP	X13,	X14,	[X15, 64]
	LDP	X11,	X12,	[X4, 64]
	ADD	X3,	X15,	X5
	STP	X1,	X2,	[X3, 80]
	STP	X7,	X8,	[X3, 96]
	STP	X9,	X10,	[X3, 112]
	STP	X11,	X12,	[X3, 128]
	RET
