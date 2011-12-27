/*-
 * Copyright (c) 2010 The Android Open Source Project
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */
#define _GNU_SOURCE 1
#include <math.h>
#define INLINE_KERNEL_COSDF
#define INLINE_KERNEL_SINDF
#include "src/math_private.h"
#include "src/k_cosf.c"
#include "src/k_sinf.c"

/* Small multiples of pi/2 rounded to double precision. */
static const double
s1pio2 = 1*M_PI_2,            /* 0x3FF921FB, 0x54442D18 */
s2pio2 = 2*M_PI_2,            /* 0x400921FB, 0x54442D18 */
s3pio2 = 3*M_PI_2,            /* 0x4012D97C, 0x7F3321D2 */
s4pio2 = 4*M_PI_2;            /* 0x401921FB, 0x54442D18 */

/* For implementation details, see src/s_sin.c, src/s_cos.c */
void  sincos(double x, double *psin, double *pcos)
{
    double y[2], z=0.0;
    int32_t n, ix;

    /* High word of x. */
    GET_HIGH_WORD(ix, x);

    /* |x| ~< pi/4 */
    ix &= 0x7fffffff;
    if(ix <= 0x3fe921fb) {
        if(ix < 0x3e400000) { /* \x\ < 2**-27 */
            if((int)x==0) { /* generate inexact */
                *psin = x;
                *pcos = 1.0;
                return;
            }
        }
        *psin = __kernel_sin(x, z, 0);
        *pcos = __kernel_cos(x, z);
        return;
    } else if(ix>=0x7ff00000) { /* sin(Inf or NaN) and cos(Inf or NaN) is NaN */
        *psin = *pcos = x-x;
        return;
    } else {
        n = __ieee754_rem_pio2(x, y);
        switch(n&3) {
            case 0:
                *psin = __kernel_sin(y[0],y[1],1);
                *pcos = __kernel_cos(y[0],y[1]);
                return;
            case 1:
                *psin = __kernel_cos(y[0],y[1]);
                *pcos = -__kernel_sin(y[0],y[1],1);
                return;
            case 2:
                *psin = -__kernel_sin(y[0],y[1],1);
                *pcos = -__kernel_cos(y[0],y[1]);
                return;
            default:
                *psin = -__kernel_cos(y[0],y[1]);
                *pcos = __kernel_sin(y[0],y[1],1);
                return;
        }
    }
}

/* For implementation details, see src/s_sinf.c, src/s_cosf.c */
void  sincosf(float x, float *psin, float *pcos)
{
    float y[2];
    int32_t n, hx, ix;

    GET_FLOAT_WORD(hx, x);
    ix = hx & 0x7fffffff;

    if(ix <= 0x3f490fda) {            /* |x| ~<= pi/4 */
        if(ix < 0x39800000) {        /* |x| < 2**-12 */
            if(((int)x)==0) {    /* x with inexact if x != 0 */
                *psin = x;
                *pcos = 1.0;
                return;
            }
        }
        *psin = __kernel_sindf(x);
        *pcos = __kernel_cosdf(x);
        return;
    } else if(ix <= 0x407b53d1) {        /* |x| ~<= 5*pi/4 */
        if(ix <= 0x4016cbe3) {        /* |x| ~<= 3pi/4 */
            if(hx>0) {
                *psin = __kernel_cosdf(x - s1pio2);
                *pcos = __kernel_sindf(s1pio2 - x);
                return;
            } else {
                *psin = -__kernel_cosdf(x + s1pio2);
                *pcos = __kernel_sindf(x + s1pio2);
                return;
            }
        } else {
            *psin = __kernel_sindf((hx > 0 ? s2pio2 : -s2pio2) - x);
            *pcos = -__kernel_cosdf(x + (hx > 0 ? -s2pio2 : s2pio2));
            return;
        }
    } else if(ix <= 0x40e231d5) {        /* |x| ~<= 9*pi/4 */
        if(ix <= 0x40afeddf) {        /* |x| ~<= 7*pi/4 */
            if(hx>0) {
                *psin = -__kernel_cosdf(x - s3pio2);
                *pcos = __kernel_sindf(x - s3pio2);
                return;
            } else {
                *psin = __kernel_cosdf(x + s3pio2);
                *pcos = __kernel_sindf(-s3pio2 - x);
                return;
            }
        } else {
            *psin = __kernel_sindf(x + (hx > 0 ? -s4pio2 : s4pio2));
            *pcos = __kernel_cosdf(x + (hx > 0 ? -s4pio2 : s4pio2));
            return;
        }
    } else if(ix>=0x7f800000) {        /* sin and cos (Inf or NaN) is NaN */
        *psin = *pcos = x-x;
        return;
    } else {
        n = __ieee754_rem_pio2f(x,y);
        switch(n&3) {
        case 0:
            *psin = __kernel_sindf((double)y[0]+y[1]);
            *pcos = __kernel_cosdf((double)y[0]+y[1]);
            return;
        case 1:
            *psin = __kernel_cosdf((double)y[0]+y[1]);
            *pcos = __kernel_sindf(-(double)y[0]-y[1]);
            return;
        case 2:
            *psin = __kernel_sindf(-(double)y[0]-y[1]);
            *pcos = -__kernel_cosdf((double)y[0]+y[1]);
            return;
        default:
            *psin = -__kernel_cosdf((double)y[0]+y[1]);
            *pcos = __kernel_sindf((double)y[0]+y[1]);
            return;
        }
    }
}

void  sincosl(long double x, long double *psin, long double *pcos)
{
    *psin = sin(x);
    *pcos = cos(x);
}
