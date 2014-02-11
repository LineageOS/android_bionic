/*
 * Copyright (C) 2013 The Android Open Source Project
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

#include "benchmark.h"

#include <math.h>

// Avoid optimization.
double d;
double v;
float f;
float fv;

static void BM_math_sqrt(int iters) {
  StartBenchmarkTiming();

  d = 0.0;
  v = 2.0;
  for (int i = 0; i < iters; ++i) {
    d += sqrt(v);
  }

  StopBenchmarkTiming();
}
BENCHMARK(BM_math_sqrt);

static void BM_math_sqrtf(int iters) {
  StartBenchmarkTiming();

  f = 0.0;
  fv = 2.0;
  for (int i = 0; i < iters; ++i) {
    f += sqrtf(fv);
  }

  StopBenchmarkTiming();
}
BENCHMARK(BM_math_sqrtf);

static void BM_math_log10(int iters) {
  StartBenchmarkTiming();

  d = 0.0;
  v = 1234.0;
  for (int i = 0; i < iters; ++i) {
    d += log10(v);
  }

  StopBenchmarkTiming();
}
BENCHMARK(BM_math_log10);

static void BM_math_logb(int iters) {
  StartBenchmarkTiming();

  d = 0.0;
  v = 1234.0;
  for (int i = 0; i < iters; ++i) {
    d += logb(v);
  }

  StopBenchmarkTiming();
}
BENCHMARK(BM_math_logb);

static void BM_math_pow(int iters) {
  StartBenchmarkTiming();

  d = 0.0;
  v = 4.0;
  for (int i = 0; i < iters; ++i) {
    d += pow(v,v);
  }

  StopBenchmarkTiming();
}
BENCHMARK(BM_math_pow);

static void BM_math_sin(int iters) {
  StartBenchmarkTiming();

  d = 0.0;
  v = 1234.0;
  for (int i = 0; i < iters; ++i) {
    d += sin(v);
  }

  StopBenchmarkTiming();
}
BENCHMARK(BM_math_sin);

static void BM_math_cos(int iters) {
  StartBenchmarkTiming();

  d = 0.0;
  v = 1234.0;
  for (int i = 0; i < iters; ++i) {
    d += cos(v);
  }

  StopBenchmarkTiming();
}
BENCHMARK(BM_math_cos);
