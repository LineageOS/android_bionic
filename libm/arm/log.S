/*
 * Copyright 2015, The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <private/bionic_asm.h>
#include <private/libc_events.h>

   .text
    .align
    .global     log
    .type       log, %function
log:
    .fnstart
    ubfx        r2, r1, #0, #20
    movw        ip, #0x5f64
    movt        ip, #0x0009
    add         ip, r2, ip
    and         ip, ip, #0x100000
    eor         r3, ip, #0x3FC00000
    eor         r3, r3, #0x00300000
    orr         r3, r2, r3
    fmdrr       d0, r0, r3
    fconstd     d1,  #0x70
    vldr        d31, .LDLG7
    vldr        d30, .LDLG6
    vsub.f64    d19, d0, d1
    vadd.f64    d20, d0, d1
    vldr        d29, .LDLG5
    vldr        d28, .LDLG4
    vdiv.f64    d16, d19, d20
    vldr        d27, .LDLG3
    vldr        d26, .LDLG2
    vldr        d25, .LDLG1
    movw        r3, #0x0000
    movt        r3, #0x7ff0
    cmp         r1, r3
    bge         .LLogInfNan
    movt        r3, #0x0010
    cmp         r1, r3
    blt         .LSubnormal
    vmul.f64    d17, d16, d16
    movw        r3, #0x03ff
    movt        r3, #0x0000
    vmul.f64    d18, d17, d17
    rsb         r3, r3, r1, asr #20
    add         r3, r3, ip, lsr #20
    vmla.f64    d28, d18, d30
    vmla.f64    d29, d18, d31
    movw        r1, #0x147a
    movt        r1, #0x0006
    vmla.f64    d26, d18, d28
    movw        ip, #0xb851
    movt        ip, #0x0006
    vmla.f64    d27, d18, d29
    vmul.f64    d24, d18, d26
    vmla.f64    d25, d18, d27
    cmp         r2, r1
    cmpge       ip, r2
    vmla.f64    d24, d17, d25
    bge         .LI0
    vsub.f64    d23, d19, d24
    cmp         r3, #0
    bne         .LRet4
.LRet3:
    vmls.f64    d19, d16, d23
    fmrrd       r0,  r1,  d19
    bx          lr
.LRet4:
    vmul.f64    d23, d16, d23
    fmsr        s15, r3 @ int
    vldr        d22, .LDLn2Lo
    vldr        d21, .LDLn2Hi
    fsitod      d20, s15
    vmls.f64    d23, d20, d22
    vmul.f64    d21, d20, d21
    vsub.f64    d23, d23, d19
    vsub.f64    d19, d21, d23
    fmrrd       r0,  r1,  d19
    bx          lr
.LI0:
    fconstd     d18, #0x60
    vmul.f64    d18, d18, d19
    vmul.f64    d18, d18, d19
    cmp         r3,  #0
    bne         .LRet2
.LRet1:
    vadd.f64    d23, d18, d24
    vmls.f64    d18, d16, d23
    vsub.f64    d19, d19, d18
    fmrrd       r0,  r1,  d19
    bx          lr
.LRet2:
    vadd.f64    d23, d18, d24
    fmsr        s15, r3 @ int
    vldr        d22, .LDLn2Lo
    vldr        d21, .LDLn2Hi
    fsitod      d20, s15
    vmul.f64    d23, d16, d23
    vmul.f64    d21, d20, d21
    vmla.f64    d23, d20, d22
    vsub.f64    d23, d18, d23
    vsub.f64    d23, d23, d19
    vsub.f64    d19, d21, d23
    fmrrd       r0,  r1,  d19
    bx          lr

.LLogInfNan:
    fmdrr       d0,  r0,  r1
    vadd.f64    d0,  d0,  d0
    fmrrd       r0,  r1,  d0
    bx          lr
.LLog0:
    vldr        d0,  .LDNegTwo54
    vldr        d1,  .LDZero
    vdiv.f64    d0,  d0,  d1
    fmrrd       r0,  r1,  d0
    bx          lr
.LLogNeg:
    fmdrr       d0,  r0,  r1
    vldr        d1,  .LDZero
    vsub.f64    d0,  d0,  d0
    vdiv.f64    d0,  d0,  d1
    fmrrd       r0,  r1,  d0
    bx          lr
.LSubnormal:
    bic         r2,  r1,  #0x80000000
    orrs        r2,  r0,  r2
    beq         .LLog0
    cmp         r1,  #0
    blt         .LLogNeg
    fmdrr       d0,  r0,  r1
    vldr        d1,  .LDTwo54
    vmul.f64    d0,  d0,  d1
    fmrrd       r0,  r1,  d0

    ubfx        r2, r1, #0, #20
    movw        ip, #0x5f64
    movt        ip, #0x0009
    add         ip, r2, ip
    and         ip, ip, #0x100000
    eor         r3, ip, #0x3FC00000
    eor         r3, r3, #0x00300000
    orr         r3, r2, r3
    fmdrr       d0, r0, r3
    fconstd     d1,  #0x70
    vldr        d31, .LDLG7
    vldr        d30, .LDLG6
    vsub.f64    d19, d0, d1
    vadd.f64    d20, d0, d1
    vldr        d29, .LDLG5
    vldr        d28, .LDLG4
    vdiv.f64    d16, d19, d20
    vldr        d27, .LDLG3
    vldr        d26, .LDLG2
    vldr        d25, .LDLG1
    vmul.f64    d17, d16, d16
    movw        r3, #0x0435
    movt        r3, #0x0000
    vmul.f64    d18, d17, d17
    rsb         r3, r3, r1, asr #20
    add         r3, r3, ip, lsr #20
    vmla.f64    d28, d18, d30
    vmla.f64    d29, d18, d31
    movw        r1, #0x147a
    movt        r1, #0x0006
    vmla.f64    d26, d18, d28
    movw        ip, #0xb851
    movt        ip, #0x0006
    vmla.f64    d27, d18, d29
    vmul.f64    d24, d18, d26
    vmla.f64    d25, d18, d27
    cmp         r2, r1
    cmpge       ip, r2
    vmla.f64    d24, d17, d25
    bge         .LSubnormalI0
    vsub.f64    d23, d19, d24
    cmp         r3, #0
    bne         .LSubnormalRet4
.LSubnormalRet3:
    vmls.f64    d19, d16, d23
    fmrrd       r0,  r1,  d19
    bx          lr
.LSubnormalRet4:
    vmul.f64    d23, d16, d23
    fmsr        s15, r3 @ int
    vldr        d22, .LDLn2Lo
    vldr        d21, .LDLn2Hi
    fsitod      d20, s15
    vmls.f64    d23, d20, d22
    vmul.f64    d21, d20, d21
    vsub.f64    d23, d23, d19
    vsub.f64    d19, d21, d23
    fmrrd       r0,  r1,  d19
    bx          lr
.LSubnormalI0:
    fconstd     d18, #0x60
    vmul.f64    d18, d18, d19
    vmul.f64    d18, d18, d19
    cmp         r3,  #0
    bne         .LSubnormalRet2
.LSubnormalRet1:
    vadd.f64    d23, d18, d24
    vmls.f64    d18, d16, d23
    vsub.f64    d19, d19, d18
    fmrrd       r0,  r1,  d19
    bx          lr
.LSubnormalRet2:
    vadd.f64    d23, d18, d24
    fmsr        s15, r3 @ int
    vldr        d22, .LDLn2Lo
    vldr        d21, .LDLn2Hi
    fsitod      d20, s15
    vmul.f64    d23, d16, d23
    vmul.f64    d21, d20, d21
    vmla.f64    d23, d20, d22
    vsub.f64    d23, d18, d23
    vsub.f64    d23, d23, d19
    vsub.f64    d19, d21, d23
    fmrrd       r0,  r1,  d19
    bx          lr

    .align      8
.LDLG7:
    .word       0xDF3E5244
    .word       0x3FC2F112
.LDLG6:
    .word       0xD078C69F
    .word       0x3FC39A09
.LDLG5:
    .word       0x96CB03DE
    .word       0x3FC74664
.LDLG4:
    .word       0x1D8E78AF
    .word       0x3FCC71C5
.LDLG3:
    .word       0x94229359
    .word       0x3FD24924
.LDLG2:
    .word       0x9997FA04
    .word       0x3FD99999
.LDLG1:
    .word       0x55555593
    .word       0x3FE55555
.LDLn2Hi:
    .word       0xfee00000
    .word       0x3fe62e42
.LDLn2Lo:
    .word       0x35793c76
    .word       0x3dea39ef
.LDNegTwo54:
    .word       0x00000000
    .word       0xC3500000
.LDTwo54:
    .word       0x00000000
    .word       0x43500000
.LDZero:
    .word       0x00000000
    .word       0x00000000

    .fnend
    .size       log, .-log

ALIAS_SYMBOL(logl, log);
