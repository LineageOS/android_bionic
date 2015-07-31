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

#include <assert.h>
#include <stdint.h>
#include "fd.h"

#define __arm64_mul96(h, l, a, b)  \
    __asm__ __volatile__ ("mul %x0, %x2, %x3\n"   \
                          "umulh %x1, %x2, %x3"   \
          : "=&r"(l), "=&r"(h)                    \
          : "r"(a), "r"(b))

static inline
void __arm64_mulaccum96(uint64_t* h, uint64_t* l, uint64_t x, uint64_t y)
{
    uint64_t o1, o2, ch= *h, cl= *l;
    __arm64_mul96(o2, o1, x, y);
    __asm__ __volatile__ ("adds  %x0, %x0, %x2\n"
                          "cinc  %x1, %x3, cs"
          : "+r"(cl), "=r"(ch)
          : "r"(o1), "r"(o2)
          : "cc" );
    *h= ch;
    *l= cl;
}

static
uint32_t __arm64_rem_pio2(uint64_t x, double *y)
{
    static const uint32_t twooverpi[] = {
        /* We start with two zero words, because they take up less
         * space than the array bounds checking and special-case
         * handling that would have to occur in their absence. */
        0, 0,
        /* 2/pi in hex is 0.a2f9836e... */
        0xa2f9836e, 0x4e441529, 0xfc2757d1, 0xf534ddc0, 0xdb629599,
        0x3c439041, 0xfe5163ab, 0xdebbc561, 0xb7246e3a, 0x424dd2e0,
        0x06492eea, 0x09d1921c, 0xfe1deb1c, 0xb129a73e, 0xe88235f5,
        0x2ebb4484, 0xe99c7026, 0xb45f7e41, 0x3991d639, 0x835339f4,
        0x9c845f8b, 0xbdf9283b, 0x1ff897ff, 0xde05980f, 0xef2f118b,
        0x5a0a6d1f, 0x6d367ecf, 0x27cb09b7, 0x4f463f66, 0x9e5fea2d,
        0x7527bac7, 0xebe5f17b, 0x3d0739f7, 0x8a5292ea, 0x6bfb5fb1,
        0x1f8d5d08,
    };

    uint32_t topbitindex = ((x >> 52) & 0x7ff) - 1013;
    uint32_t shiftup = topbitindex & 31;
    const uint32_t *twooverpi_p =  &twooverpi[(topbitindex >> 5) + 5];
    uint32_t twooverpi_h = twooverpi_p[1];
    double scale3, scale2, scale1, scale0;
    int32_t q;
    uint64_t mant = (x & 0x000fffffffffffffULL) | (1ULL << 52);
    if (shiftup) {

        uint32_t twooverpi_l = *twooverpi_p--;
        // -- 5
        uint64_t word =  (twooverpi_l << shiftup) |
            (twooverpi_h >> (32 - shiftup));

        uint64_t c2;
        uint64_t c1;

        __arm64_mul96( c1, c2, mant, word);

        c2 = ((c1 & ~0) << 32) | (c2 >> 32);

        twooverpi_h= twooverpi_l;
        twooverpi_l= *twooverpi_p--;

        // -- 4
        word =  (twooverpi_l << shiftup) | (twooverpi_h >> (32 - shiftup));

        __arm64_mulaccum96( &c1, &c2, mant, word);

        c2 = ((c1 & ~0U) << 32) | (c2 >> 32);

        twooverpi_h= twooverpi_l;
        twooverpi_l= *twooverpi_p--;

        // -- 3
        word =  (twooverpi_l << shiftup) | (twooverpi_h >> (32 - shiftup));

        __arm64_mulaccum96( &c1, &c2, mant, word);

        scale3 = (double) (uint32_t) c2;
        c2 = ((c1 & ~0) << 32) | (c2 >> 32);

        twooverpi_h= twooverpi_l;
        twooverpi_l= *twooverpi_p--;

        // -- 2
        word =  (twooverpi_l << shiftup) | (twooverpi_h >> (32 - shiftup));

        __arm64_mulaccum96( &c1, &c2, mant, word);

        scale2 = (double) (uint32_t) c2;
        c2 = ((c1 & ~0) << 32) | (c2 >> 32);

        twooverpi_h= twooverpi_l;
        twooverpi_l= *twooverpi_p--;

        // -- 1
        word =  (twooverpi_l << shiftup) | (twooverpi_h >> (32 - shiftup));

        __arm64_mulaccum96( &c1, &c2, mant, word);

        scale1 = (double) (uint32_t) c2;
        c2 = ((c1 & ~0) << 32) | (c2 >> 32);

        twooverpi_h= twooverpi_l;
        twooverpi_l= *twooverpi_p--;

        // -- 0
        word =  (twooverpi_l << shiftup) | (twooverpi_h >> (32 - shiftup));

        __arm64_mulaccum96( &c1, &c2, mant, word);

        scale0 = (double) ((int32_t) c2 <<2);
        q = ((c2 & ~0U) + (1 << 29)) >> 30;
    } else {
        uint32_t twooverpi_l = *twooverpi_p--;
        // -- 5
        uint64_t word =  twooverpi_l;

        uint64_t c2;
        uint64_t c1;
        __arm64_mul96( c1, c2, mant, word);


        c2 = ((c1 & ~0) << 32) | (c2 >> 32);

        twooverpi_l= *twooverpi_p--;

        // -- 4
        word =  twooverpi_l;

        __arm64_mulaccum96( &c1, &c2, mant, word);

        c2 = ((c1 & ~0U) << 32) | (c2 >> 32);

        twooverpi_l= *twooverpi_p--;

        // -- 3
        word =  twooverpi_l;
        __arm64_mulaccum96( &c1, &c2, mant, word);

        scale3 = (double) (uint32_t) c2;
        c2 = ((c1 & ~0) << 32) | (c2 >> 32);

        twooverpi_l= *twooverpi_p--;

        // -- 2
        word =  twooverpi_l;

        __arm64_mulaccum96( &c1, &c2, mant, word);

        scale2 = (double) (uint32_t) c2;
        c2 = ((c1 & ~0) << 32) | (c2 >> 32);

        twooverpi_l= *twooverpi_p--;

        // -- 1
        word =  twooverpi_l;

        __arm64_mulaccum96( &c1, &c2, mant, word);

        scale1 = (double) (uint32_t) c2;
        c2 = ((c1 & ~0) << 32) | (c2 >> 32);

        twooverpi_l= *twooverpi_p--;

        // -- 0
        word =  twooverpi_l;

        __arm64_mulaccum96( &c1, &c2, mant, word);

        scale0 = (double) ((int32_t) c2 << 2);
        q = ((c2 & ~0U) + (1 << 29)) >> 30;
    }

    double f1= scale0;
    double f2= scale1 * 0x1p-30;
    double f3= scale2 * 0x1p-62;
    double f4= scale3 * 0x1p-94;


    __float64 ftop = { .d = f1 + f2 + f3 + f4 };
    ftop.u64 &= 0xffffffff00000000;

    double fbot = f4 - (((ftop.d - f1) - f2) -f3 );

    double ret =    (ftop.d * +0x1.921FB54000000p-32)
                  + (ftop.d * +0x1.10B4611A62633p-62
                       + fbot * +0x1.921FB54442D18p-32);
    if (x & (1ULL << 63)) {
        *y = -ret;
        return -q;
    }
    *y = ret;
    return q;
}


static
int32_t __ieee754_rem_pio2(double _x, double *y) {

    /*
     * invpio2:  53 bits of 2/pi
     * pio2_1:   first 33 bit of pi/2
     * pio2_1t:  pi/2 - pio2_1
     * pio2_2:   second 33 bit of pi/2
     * pio2_2t:  pi/2 - (pio2_1+pio2_2)
     * pio2_3:   third 33 bit of pi/2
     * pio2_3t:  pi/2 - (pio2_1+pio2_2+pio2_3)
     */
    static const double
        zero =  0.00000000000000000000e+00, /* 0x00000000, 0x00000000 */
        two24 =  1.67772160000000000000e+07, /* 0x41700000, 0x00000000 */
        invpio2 =  6.36619772367581382433e-01, /* 0x3FE45F30, 0x6DC9C883 */
        pio2_1  =  1.57079632673412561417e+00, /* 0x3FF921FB, 0x54400000 */
        pio2_1t =  6.07710050650619224932e-11, /* 0x3DD0B461, 0x1A626331 */
        pio2_2  =  6.07710050630396597660e-11, /* 0x3DD0B461, 0x1A600000 */
        pio2_2t =  2.02226624879595063154e-21, /* 0x3BA3198A, 0x2E037073 */
        pio2_3  =  2.02226624871116645580e-21, /* 0x3BA3198A, 0x2E000000 */
        pio2_3t =  8.47842766036889956997e-32; /* 0x397B839A, 0x252049C1 */

    __float64 x = { .d = _x };

    /* High word of |x|. */
    uint32_t hx = getHighAbs(_x);

    if (hx < 0x4002d97c) {                  /* |x| ~<= 3pi/4 */
        if ((x.u64 & (1ULL << 63)) == 0) {
           double z = x.d - pio2_1;
           if (hx == 0x3ff921fb) {         /* |x| is close to pi/2 */
               z -= pio2_2;
               *y = z - pio2_2t;
           } else {
               *y = z - pio2_1t;
           }
           return 1;
       } else {
           double z = x.d + pio2_1;
           if (hx == 0x3ff921fb) {         /* |x| is close to pi/2 */
               z += pio2_2;
               *y = z + pio2_2t;
           } else {
               *y = z + pio2_1t;
           }
           return -1;
       }
    }
    if (hx <= 0x413921fb) {                /* |x| ~< 2^20*(pi/2), medium size */
        double t = __builtin_fabs(x.d);
        double fn = __builtin_trunc(t * invpio2 + 0.5);
        double r = t -  fn * pio2_1;
        double w = fn * pio2_1t;
        int32_t j= hx >> 20;

        __float64 q= {.d = r - w};
        int32_t i= j - ((q.u64 >> 52) & 0x7ff);
        if ( i > 16) {
            t = r;
            w = fn * pio2_2;
            r = t - w;
            w = fn * pio2_2t - ((t - r) - w);

            q.d = r - w;
            i = j - ((q.u64 >> 52) & 0x7ff);
            if (i > 49) {
                t = r;
                w = fn * pio2_3;
                r = t - w;
                w = fn * pio2_3t - ((t - r) - w);
                q.d = r - w;
            }
        }
        if (x.u64 & (1ULL << 63)) {
            *y = -q.d;
            return -(int32_t) fn;
        } else {
            *y = q.d;
            return (int32_t) fn;
        }
    }

    return __arm64_rem_pio2(x.u64, y);
}

/* __kernel_sin(x)
 * kernel sin function on ~[-pi/4, pi/4] (except on -0), pi/4 ~ 0.7854
 * Input x is assumed to be bounded by ~pi/4 in magnitude.
 *
 * Algorithm
 *  1. Since sin(-x) = -sin(x), we need only to consider positive x.
 *  2. Callers must return sin(-0) = -0 without calling here since our
 *     odd polynomial is not evaluated in a way that preserves -0.
 *     Callers may do the optimization sin(x) ~ x for tiny x.
 *  3. sin(x) is approximated by a polynomial of degree 13 on
 *     [0,pi/4]
 *                   3            13
 *      sin(x) ~ x + S1*x + ... + S6*x
 *     where
 *
 *  |sin(x)         2     4     6     8     10     12  |     -58
 *  |----- - (1+S1*x +S2*x +S3*x +S4*x +S5*x  +S6*x   )| <= 2
 *  |  x                                               |
 */

static double
__kernel_sin(double x)
{
    static const double
    S1  =  -0x1.5555555555549p-3,       // -1.66666666666666324348e-01
    S2  =  +0x1.111111110F8A6p-7,       // +8.33333333332248946124e-03
    S3  =  -0x1.A01A019C161D5p-13,      // -1.98412698298579493134e-04
    S4  =  +0x1.71DE357B1FE7Dp-19,      // +2.75573137070700676789e-06
    S5  =  -0x1.AE5E68A2B9CEBp-26,      // -2.50507602534068634195e-08
    S6  =  +0x1.5D93A5ACFD57Cp-33;      // +1.58969099521155010221e-10

    double z,r,v,w;

    z = x * x;
    w = z * z;
    r = S2 + z * ((S3 + z * S4) + w * (S5 + z * S6));
    v = z * x;
    return x + v * (S1 + z * r);
}


/*
 * __kernel_cos(x)
 * kernel cos function on [-pi/4, pi/4], pi/4 ~ 0.785398164
 * Input x is assumed to be bounded by ~pi/4 in magnitude.
 *
 * Algorithm
 *  1. Since cos(-x) = cos(x), we need only to consider positive x.
 *  2. if x < 2^-27 (hx<0x3e400000 0), return 1 with inexact if x!=0.
 *  3. cos(x) is approximated by a polynomial of degree 14 on
 *     [0,pi/4]
 *                           4            14
 *      cos(x) ~ 1 - x*x/2 + C1*x + ... + C6*x
 *     where the remez error is
 *
 *  |              2     4     6     8     10    12     14 |     -58
 *  |cos(x)-(1-.5*x +C1*x +C2*x +C3*x +C4*x +C5*x  +C6*x  )| <= 2
 *  |                                                      |
 */

static double
__kernel_cos(double x)
{
    static const double
    C1  = +0x1.555555555554Cp-5,        // +4.16666666666666019037e-02
    C2  = -0x1.6C16C16C15177p-10,       // -1.38888888888741095749e-03
    C3  = +0x1.A01A019CB1590p-16,       // +2.48015872894767294178e-05
    C4  = -0x1.27E4F809C52ADp-22,       // -2.75573143513906633035e-07
    C5  = +0x1.1EE9EBDB4B1C4p-29,       // +2.08757232129817482790e-09
    C6  = -0x1.8FAE9BE8838D4p-37;       // -1.13596475577881948265e-11

    double z= x * x;
    double w= z * z;
    double v= w * w;

    double r0 = C2 + z * C3;
    double r1 = C1 + z * r0;
    double r2 = z * r1;
    double r3 = C5 + z * C6;
    double r4 = C4 + z * r3;
    double r= v * r4 + r2;
    double o = 0x1p0 - 0x1p-1 * z;
    return o + z * r;
}
