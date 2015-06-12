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

# -- Begin  static_func
        .text
        .align __bionic_asm_align
        .type static_func, @function
static_func:
..B1.1:
        call      ..L2
..L2:
        popl      %eax
        lea       _GLOBAL_OFFSET_TABLE_+[. - ..L2](%eax), %eax
        lea       static_const_table@GOTOFF(%eax), %eax
        ret
        .size   static_func,.-static_func
# -- End  static_func

ENTRY(lrint)
// size of long int is 4 bytes
        pushl     %ebp
        movl      %esp, %ebp
        subl      $20, %esp
        movl      %ebx, 8(%esp)

        call      static_func
        movl      %eax, %ebx

        pextrw    $3, %xmm0, %ecx
        andl      $0x7ff0, %ecx
        cmpl      $0x41df, %ecx
        jge       ..l_large
..l_main:
        cvtsd2si  %xmm0, %eax
// raise Denormal flag on denormal input
        //addsd     %xmm0, %xmm0
        jmp       ..EPILOG
..l_large:
// now |x| >= 2^31-2^26 or x is Inf or NaN
        comisd    (%ebx), %xmm0
        jp        ..l_nan
        ja        ..l_large_pos
// now x<=2^31-1 or x=-Inf
        ucomisd   16(%ebx), %xmm0
        jb        ..l_large_neg
// now -2^31 <= x <= 2^31-1
        jmp       ..l_main
..l_large_neg:
// now x<-2^31 or x=-Inf
        ucomisd   32(%ebx), %xmm0
        ja        ..l_questionable_cases
        jmp       ..l_spec
..l_large_pos:
// now x>2^31-1 or x=+Inf
        ucomisd   48(%ebx), %xmm0
        jb        ..l_questionable_cases
..l_spec:
// raise inValid exception
        movss     64(%ebx), %xmm1
        subss     %xmm1, %xmm1
..l_nan:
        movl      $0x80000000, %eax
        jmp       ..EPILOG
..l_questionable_cases:
        stmxcsr   (%esp)
// clear inValid flag in MXCSR
        movl      (%esp), %eax
        andl      $-2, %eax
        movl      %eax, (%esp)
        ldmxcsr   (%esp)
        cvtsd2si  %xmm0, %eax
        stmxcsr   (%esp)
// check if inValid flag was raised during conversion
        movl      (%esp), %edx
        testl     $1, %edx
        jne       ..l_spec
..EPILOG:
        movl      8(%esp), %ebx
        movl      %ebp, %esp
        popl      %ebp
        ret
END(lrint)
//ALIAS_SYMBOL(lrintl, lrint);

    .section .rodata, "a"
    .align 16
    .align 16
static_const_table:
    .long   4290772992
    .long   1105199103
    .long   4290772992
    .long   1105199103
    .long   0
    .long   3252682752
    .long   0
    .long   3252682752
    .long   2097152
    .long   3252682752
    .long   2097152
    .long   3252682752
    .long   0
    .long   1105199104
    .long   0
    .long   1105199104
    .long   2139095040
    .long   2139095040
    .long   2139095040
    .long   2139095040
    .type   static_const_table,@object
    .size   static_const_table,80
    .data
