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
    .global     exp
    .type       exp, %function
exp:
    .fnstart

.LFilterFIRST:
    fmdrr       d16, r0,  r1
    bic         r3,  r1,  #0x80000000
    mov         r2,  r1,  lsr #31
    movw        ip,  #0xA2B1
    movt        ip,  #0x3FF0
    cmp         r3,  ip
    bls         .LFilterSECOND
    movw        ip,  #0x2E41
    movt        ip,  #0x4086
    cmp         r3,  ip
    bhi         .LRange1

.LRange2:
    cmp         r2,  #0
    vldr        d28, .LDInvLn2
    fconstdeq   d20, #0x60
    fconstdne   d20, #0xE0
    vmla.f64    d20, d28, d16
    vldr        d22, .LDLn2HI_0
    vldr        d24, .LDLn2LO_0
    ftosizd     s15, d20
    fsitod      d20, s15
    vmls.f64    d16, d20, d22
    vmul.f64    d18, d20, d24
    vldr        d31, .LDP5
    vldr        d29, .LDP4
    vsub.f64    d21, d16, d18
    vldr        d27, .LDP3
    vmul.f64    d19, d21, d21
    vldr        d25, .LDP2
    vmla.f64    d29, d19, d31
    vldr        d23, .LDP1
    vmla.f64    d27, d19, d29
    vmov        d17, d21
    vmla.f64    d25, d19, d27
    fconstd     d30, #0x00
    vmla.f64    d23, d19, d25
    fconstd     d28, #0x70
    vmls.f64    d21, d19, d23
    fmrs        r3,  s15 @ int
    vmul.f64    d17, d17, d21
    vsub.f64    d30, d30, d21
    vdiv.f64    d17, d17, d30
    mvn         r2,  #1020
    vsub.f64    d18, d18, d17
    cmp         r3,  r2
    vsub.f64    d18, d18, d16
    vsub.f64    d28, d28, d18
    blt         .LRange2_2
.LRange2_1:
    fmrrd       r0,  r1,  d28
    add         r1,  r1,  r3, asl #20
    bx          lr
.LRange2_2:
    add         r3,  r3,  #1000
    fmrrd       r0,  r1,  d28
    add         r1,  r1,  r3, asl #20
    vldr        d30, .LDTwom1000
    fmdrr       d28, r0,  r1
    vmul.f64    d28, d28, d30
    fmrrd       r0,  r1,  d28
    bx          lr

.LFilterSECOND:
    movw        ip, #0x2e42
    movt        ip, #0x3fd6
    cmp         r3, ip
    bhi         .LRange3

.LRange4:
    vmul.f64    d19, d16, d16
    vldr        d31, .LDP5
    vldr        d29, .LDP4
    vldr        d27, .LDP3
    vmla.f64    d29, d19, d31
    vldr        d25, .LDP2
    vmla.f64    d27, d19, d29
    vldr        d23, .LDP1
    vmla.f64    d25, d19, d27
    vmov        d21, d16
    vmla.f64    d23, d19, d25
    fconstd     d30, #0x00
    vmls.f64    d21, d19, d23
    fconstd     d28, #0x70
    vmul.f64    d17, d16, d21
    vsub.f64    d30, d21, d30
    vdiv.f64    d17, d17, d30
    movw        ip, #0xffff
    movt        ip, #0x3e2f
    cmp         r3, ip
    bls         .LRange5
    vsub.f64    d17, d17, d16
    vsub.f64    d28, d28, d17
    fmrrd       r0,  r1,  d28
    bx          lr

.LRange5:
    vldr        d21, .LDHuge
    vadd.f64    d22, d21, d16
    vcmp.f64    d22, d28
    fmstat
    ble         .LRange5_2
.LRange5_1:
    vadd.f64    d28, d16, d28
    fmrrd       r0,  r1,  d28
    bx          lr
.LRange5_2:
    vsub.f64    d17, d17, d16
    vsub.f64    d28, d28, d17
    fmrrd       r0,  r1,  d28
    bx          lr

.LRange3:
    cmp         r2,  #0
    beq         .LRange3_2
.LRange3_1:
    vldr        d20, .LDLn2HI_1
    vldr        d18, .LDLn2LO_1
    vsub.f64    d16, d16, d20
    vldr        d31, .LDP5
    vldr        d29, .LDP4
    vsub.f64    d21, d16, d18
    vldr        d27, .LDP3
    vmul.f64    d19, d21, d21
    vldr        d25, .LDP2
    vmla.f64    d29, d19, d31
    vldr        d23, .LDP1
    vmla.f64    d27, d19, d29
    fconstd     d30, #0x00
    vmla.f64    d25, d19, d27
    fconstd     d28, #0x70
    vmla.f64    d23, d19, d25
    vmov        d17, d21
    vmls.f64    d21, d19, d23
    vmul.f64    d17, d17, d21
    vsub.f64    d30, d30, d21
    vdiv.f64    d17, d17, d30
    vsub.f64    d18, d18, d17
    vsub.f64    d18, d18, d16
    vsub.f64    d28, d28, d18
    fmrrd       r0,  r1,  d28
    add         r1,  #0xFFF00000
    bx          lr
.LRange3_2:
    vldr        d20, .LDLn2HI_0
    vldr        d18, .LDLn2LO_0
    vsub.f64    d16, d16, d20
    vldr        d31, .LDP5
    vldr        d29, .LDP4
    vsub.f64    d21, d16, d18
    vldr        d27, .LDP3
    vmul.f64    d19, d21, d21
    vldr        d25, .LDP2
    vmla.f64    d29, d19, d31
    vldr        d23, .LDP1
    vmla.f64    d27, d19, d29
    fconstd     d30, #0x00
    vmla.f64    d25, d19, d27
    fconstd     d28, #0x70
    vmla.f64    d23, d19, d25
    vmov        d17, d21
    vmls.f64    d21, d19, d23
    vmul.f64    d17, d17, d21
    vsub.f64    d30, d30, d21
    vdiv.f64    d17, d17, d30
    vsub.f64    d18, d18, d17
    vsub.f64    d18, d18, d16
    vsub.f64    d28, d28, d18
    fmrrd       r0,  r1,  d28
    add         r1,  #0x00100000
    bx          lr

.LRange1:
    movw        ip,  #0xffff
    movt        ip,  #0x7fef
    cmp         r3,  ip
    bls         .LRange1_udflow
    ubfx        r3,  r3,  #0,  #20
    orrs        r3,  r3,  r0
    bne         .LRange1_2
    cmp         r2, #0
    beq         .LRange1_3
.LRange1_1:
    movw        r0, #0x0000
    movw        r1, #0x0000
    bx          lr
.LRange1_2:
    vadd.f64    d16, d16, d16
.LRange1_3:
    fmrrd       r0,  r1,  d16
    bx          lr
.LRange1_udflow:
    vldr        d17, .LDOverFlow
    vcmp.f64    d16, d17
    fmstat
    bgt         .LRange1_4
    vldr        d18, .LDUnderFlow
    vcmp.f64    d16, d18
    fmstat
    bmi         .LRange1_5
    b           .LRange2
.LRange1_4:
    vldr        d16, .LDHuge
    vmul.f64    d16, d16, d16
    fmrrd       r0,  r1,  d16
    bx          lr
.LRange1_5:
    vldr        d16, .LDTwom1000
    vmul.f64    d16, d16, d16
    fmrrd       r0,  r1,  d16
    bx          lr

    .align      8
.LDInvLn2:
    .word       0x652b82fe
    .word       0x3ff71547
.LDLn2HI_0:
    .word       0xfee00000
    .word       0x3fe62e42
.LDLn2LO_0:
    .word       0x35793c76
    .word       0x3dea39ef
.LDLn2HI_1:
    .word       0xfee00000
    .word       0xbfe62e42
.LDLn2LO_1:
    .word       0x35793c76
    .word       0xbdea39ef
.LDP5:
    .word       0x72BEA4D0
    .word       0x3E663769
.LDP4:
    .word       0xC5D26BF1
    .word       0xBEBBBD41
.LDP3:
    .word       0xAF25DE2C
    .word       0x3F11566A
.LDP2:
    .word       0x16BEBD93
    .word       0xBF66C16C
.LDP1:
    .word       0x5555553E
    .word       0x3FC55555
.LDTwom1000:
    .word       0x00000000
    .word       0x01700000
.LDHuge:
    .word       0x8800759C
    .word       0x7E37E43C
.LDOverFlow:
    .word       0xFEFA39EF
    .word       0x40862E42
.LDUnderFlow:
    .word       0xD52D3051
    .word       0xc0874910
    .fnend
    .size       exp, .-exp

ALIAS_SYMBOL(expl, exp);
