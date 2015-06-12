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
//size of long int is 4 bytes
        pextrw    $1, %xmm0, %ecx
        andl      $0x7f80, %ecx
        cmpl      $0x4f00, %ecx
        jge       ..l_large
        cvtss2si  %xmm0, %eax
//  raise Denormal flag on denormal input
        //addsd     %xmm0, %xmm0
        jmp       ..EPILOG
..l_large:
        mov       $0xcf000000, %edx
        movd      %edx, %xmm1
        comiss    %xmm1, %xmm0
        jp        ..l_nan
        je        ..l_neg_2_pow_31
//  raise inValid exception
        mov       $0x7f800000, %ecx
        movd      %ecx, %xmm2
        subss     %xmm2, %xmm2
..l_nan:
..l_neg_2_pow_31:
//  rax := undefined result
        mov       $0x80000000, %eax
        jmp       ..EPILOG
..EPILOG:
        ret
END(lrintf)
