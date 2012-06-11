/* Copyright (c) 2010-2011, Linaro Limited
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

      * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

      * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

      * Neither the name of Linaro Limited nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   memset Written by Dave Gilbert <david.gilbert@linaro.org>
   Adapted to bzero and Bionic by Bernhard Rosenkraenzer <Bernhard.Rosenkranzer@linaro.org>

   This memset routine is optimised on a Cortex-A9 and should work on
   all ARMv7 processors. */

#include <machine/asm.h>

	.syntax unified
	.arch armv7-a
	.text
	.thumb

@ ---------------------------------------------------------------------------
	.thumb_func
	.p2align 4,,15
ENTRY(bzero)
	@ r0 = address
	@ r1 = count
	@ Doesn't return anything

	cbz	r1, 10f		@ Exit if 0 length
	mov	r2, #0

	tst	r0, #7
	beq	2f		@ Already aligned

	@ Ok, so we're misaligned here
1:
	strb	r2, [r0], #1
	subs	r1,r1,#1
	tst	r0, #7
	cbz	r1, 10f		@ Exit if we hit the end
	bne	1b		@ go round again if still misaligned

2:
	@ OK, so we're aligned
	push	{r4,r5,r6,r7}
	bics	r4, r1, #15	@ if less than 16 bytes then need to finish it off
	beq	5f

3:
	mov	r5,r2
	mov	r6,r2
	mov	r7,r2

4:
	subs	r4,r4,#16
	stmia	r0!,{r2,r5,r6,r7}
	bne	4b
	and	r1,r1,#15

	@ At this point we're still aligned and we have upto align-1 bytes left to right
	@ we can avoid some of the byte-at-a time now by testing for some big chunks
	tst	r1,#8
	itt	ne
	subne	r1,r1,#8
	stmiane	r0!,{r2,r5}

5:
	pop	{r4,r5,r6,r7}
	cbz	r1, 10f

	@ Got to do any last < alignment bytes
6:
	subs	r1,r1,#1
	strb	r2,[r0],#1
	bne	6b

10:
	bx	lr		@ goodbye
END(bzero)
