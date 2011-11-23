/*
 * Copyright (C) 2011 Texas Instruments
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

   .text
   .fpu    neon
   .code   32
   .align 4


/* r0 - dest */
/* r1 - src  */
/* r2 - length */
   .global memcpy
memcpy:
       .fnstart
#if defined TARGET_BOARD_PLATFORM == omap4
#define CACHE_LINE_SIZE  32
#else
#define CACHE_LINE_SIZE  64
#endif
        CMP      r2,#3
        BLS      _BMLIB_memcpy_lastbytes
        ANDS     r12,r0,#3
        BEQ      l1;
        LDRB     r3,[r1],#1
        CMP      r12,#2
        ADD      r2,r2,r12
        LDRLSB   r12, [r1], #1
        STRB     r3,[r0],#1
        LDRCCB   r3,[r1],#1
        STRLSB   r12,[r0],#1
        SUB      r2,r2,#4
        STRCCB   r3,[r0],#1
l1:
        ANDS     r3,r1,#3
        BEQ      _BMLIB_aeabi_memcpy4
l3:
        SUBS     r2,r2,#8
        BCC      l2
        LDR      r3,[r1],#4
        LDR      r12,[r1],#4
        STR      r3,[r0],#4
        STR      r12,[r0],#4
        B        l3
l2:
        ADDS     r2,r2,#4
        LDRPL    r3,[r1],#4
        STRPL    r3,[r0],#4
        MOV      r0,r0
_BMLIB_memcpy_lastbytes:
        LSLS     r2,r2,#31
        LDRCSB   r3,[r1],#1
        LDRCSB   r12,[r1],#1
        LDRMIB   r2,[r1],#1
        STRCSB   r3,[r0],#1
        STRCSB   r12,[r0],#1
        STRMIB   r2,[r0],#1
        BX       lr

_BMLIB_aeabi_memcpy4:
        PUSH     {r4-r8,lr}
        SUBS     r2,r2,#0x20
        BCC      l4
        DSB
#ifndef NOPLD
        PLD      [r1, #0]
        PLD      [r1, #(CACHE_LINE_SIZE*1)]
        PLD      [r1, #(CACHE_LINE_SIZE*2)]
        PLD      [r1, #(CACHE_LINE_SIZE*3)]
        PLD      [r1, #(CACHE_LINE_SIZE*4)]
#endif
l5:
#ifndef NOPLD
        PLD      [r1, #(CACHE_LINE_SIZE*5)]
#endif
        LDMCS    r1!,{r3-r8,r12,lr}
        STMCS    r0!,{r3-r8,r12,lr}
        SUBS     r2,r2,#0x20
        BCS      l5
l4:
        LSLS     r12,r2,#28
        LDMCS    r1!,{r3,r4,r12,lr}
        STMCS    r0!,{r3,r4,r12,lr}
        LDMMI    r1!,{r3,r4}
        STMMI    r0!,{r3,r4}
        POP      {r4-r8,lr}
        LSLS     r12,r2,#30
        LDRCS    r3,[r1],#4
        STRCS    r3,[r0],#4
        BXEQ     lr
_BMLIB_memcpy_lastbytes_aligned:
        LSLS     r2,r2,#31
        LDRCSH   r3,[r1],#2
        LDRMIB   r2,[r1],#1
        STRCSH   r3,[r0],#2
        STRMIB   r2,[r0],#1
        BX       lr
        .fnend
