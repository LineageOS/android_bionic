/* Copyright (C) 2013 The Android Open Source Project
 * Copyright (c) 2013, NVIDIA CORPORATION.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "math.h"
#include "math_private.h"

static const double two24 = 1.67772160000000000000e+07;

int __rem_pio2_large(double x, int32_t ix, double *y)
{
    double z, tx[3], ty[2];
    int32_t e0, i, nx, n, hx;
    u_int32_t low;

    GET_HIGH_WORD(hx, x);

    if (ix >= 0x7ff00000) {             /* x is inf or NaN */
        y[0] = y[1] = x - x;
        return 0;
    }

    /* set z = scalbn(|x|, ilogb(x)-23) */
    GET_LOW_WORD(low, x);
    e0 = (ix >> 20) - 1046;             /* e0 = ilogb(z) - 23; */
    INSERT_WORDS(z, ix - ((int32_t)(e0 << 20)), low);
    for (i = 0; i < 2; i++) {
        tx[i] = (double)((int32_t)(z));
        z = (z - tx[i]) * two24;
    }

    tx[2] = z;
    nx = 3;
    while (tx[nx - 1] == 0.0)
        nx--;       /* skip zero term */
    n =  __kernel_rem_pio2(tx, ty, e0, nx, 1);
    if (hx < 0) {
        y[0] = -ty[0];
        y[1] = -ty[1];
        return -n;
    }
    y[0] = ty[0];
    y[1] = ty[1];
    return n;
}
