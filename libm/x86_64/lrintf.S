/*
Copyright (c) 2014, Intel Corporation
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice,
    * this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    * this list of conditions and the following disclaimer in the documentation
    * and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors
    * may be used to endorse or promote products derived from this software
    * without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
#include <private/bionic_asm.h>

ENTRY(lrintf)
//size of long int is 8 bytes
        pextrw    $1, %xmm0, %ecx
        andl      $32640, %ecx
        cmpl      $24320, %ecx
        jge       ..l_large
        cvtss2si  %xmm0, %rax
//  raise Denormal flag on denormal input
        //addsd     %xmm0, %xmm0
        jmp       ..EPILOG
..l_large:
        comiss    NEG_TWO_POW_63(%rip), %xmm0
        jp        ..l_nan
        je        ..l_neg_2_pow_63
//  raise inValid exception
        movss     POS_INF(%rip), %xmm1
        subss     %xmm1, %xmm1
..l_nan:
..l_neg_2_pow_63:
//  rax := undefined result
        movq      $0x8000000000000000, %rax
        jmp       ..EPILOG
..EPILOG:
        ret
END(lrintf)
//size of long long int is also 8 bytes
ALIAS_SYMBOL(llrintf, lrintf);

    .section .rodata, "a"
    .align 4
NEG_TWO_POW_63:
    .long   -553648128
    .type   NEG_TWO_POW_63,@object
    .size   NEG_TWO_POW_63,4
    .align 4
POS_INF:
    .long   2139095040
    .type   POS_INF,@object
    .size   POS_INF,4
