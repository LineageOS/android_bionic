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

/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */

#include <stdint.h>
#include <float.h>
#include <math.h>

#include "ksincos.c"

/* cos(x)
 * Return cosine function of x.
 *
 * kernel function:
 *  __kernel_sin        ... sine function on [-pi/4,pi/4]
 *  __kernel_cos        ... cosine function on [-pi/4,pi/4]
 *  __ieee754_rem_pio2  ... argument reduction routine
 *
 * Method.
 *      Let S,C and T denote the sin, cos and tan respectively on
 *  [-PI/4, +PI/4]. Reduce the argument x to x' = x-k*pi/2
 *  in [-pi/4 , +pi/4], and let n = k mod 4.
 *  We have
 *
 *      n        sin(x)      cos(x)        tan(x)
 *     ----------------------------------------------------------
 *      0          S          C             T
 *      1          C         -S            -1/T
 *      2         -S         -C             T
 *      3         -C          S            -1/T
 *     ----------------------------------------------------------
 *
 * Special cases:
 *      Let trig be any of sin, cos, or tan.
 *      trig(+-INF)  is NaN, with signals;
 *      trig(NaN)    is that NaN;
 *
 * Accuracy:
 *  TRIG(x) returns trig(x) nearly rounded
 */

double
cos(double x)
{
    double y;
    int32_t n, ix;

    /* High word of x. */
    ix = getHighAbs(x);

    if(ix <= 0x3fe921fb) {          /* |x| ~< pi/4 */
        if(ix<0x3e46a09e)           /* if x < 2**-27 * sqrt(2) */
            if(x == 0) return 1.0;  /* generate inexact */
        return __kernel_cos(x);
    }
    /* cos(Inf or NaN) is NaN */
    else if (ix>=0x7ff00000) return x-x;
    /* argument reduction needed */
    else {
        n = __ieee754_rem_pio2(x, &y);
        switch(n&3) {
            case 0: return  __kernel_cos(y);
            case 1: return -__kernel_sin(y);
            case 2: return -__kernel_cos(y);
            default:
                return  __kernel_sin(y);
        }
    }
}

#if (LDBL_MANT_DIG == 53)
__weak_reference(cos, cosl);
#endif
