ifneq ($(TARGET_USE_PRIVATE_LIBM),true)
LOCAL_PATH:= $(call my-dir)

# TODO: this comes from from upstream's libc, not libm, but it's an
# implementation detail that should have hidden visibility, so it needs
# to be in whatever library the math code is in.
libm_common_src_files := \
    digittoint.c  \

# TODO: this is not in the BSDs.
libm_common_src_files += \
    significandl.c \
    sincos.c \

libm_common_src_files += \
    upstream-freebsd/lib/msun/bsdsrc/b_exp.c \
    upstream-freebsd/lib/msun/bsdsrc/b_log.c \
    upstream-freebsd/lib/msun/bsdsrc/b_tgamma.c \
    upstream-freebsd/lib/msun/src/catrig.c \
    upstream-freebsd/lib/msun/src/catrigf.c \
    upstream-freebsd/lib/msun/src/e_acosf.c \
    upstream-freebsd/lib/msun/src/e_acosh.c \
    upstream-freebsd/lib/msun/src/e_acoshf.c \
    upstream-freebsd/lib/msun/src/e_asinf.c \
    upstream-freebsd/lib/msun/src/e_atan2f.c \
    upstream-freebsd/lib/msun/src/e_atanh.c \
    upstream-freebsd/lib/msun/src/e_atanhf.c \
    upstream-freebsd/lib/msun/src/e_coshf.c \
    upstream-freebsd/lib/msun/src/e_expf.c \
    upstream-freebsd/lib/msun/src/e_fmod.c \
    upstream-freebsd/lib/msun/src/e_fmodf.c \
    upstream-freebsd/lib/msun/src/e_gamma.c \
    upstream-freebsd/lib/msun/src/e_gammaf.c \
    upstream-freebsd/lib/msun/src/e_gammaf_r.c \
    upstream-freebsd/lib/msun/src/e_gamma_r.c \
    upstream-freebsd/lib/msun/src/e_hypotf.c \
    upstream-freebsd/lib/msun/src/e_j0.c \
    upstream-freebsd/lib/msun/src/e_j0f.c \
    upstream-freebsd/lib/msun/src/e_j1.c \
    upstream-freebsd/lib/msun/src/e_j1f.c \
    upstream-freebsd/lib/msun/src/e_jn.c \
    upstream-freebsd/lib/msun/src/e_jnf.c \
    upstream-freebsd/lib/msun/src/e_lgamma.c \
    upstream-freebsd/lib/msun/src/e_lgammaf.c \
    upstream-freebsd/lib/msun/src/e_lgammaf_r.c \
    upstream-freebsd/lib/msun/src/e_lgamma_r.c \
    upstream-freebsd/lib/msun/src/e_log10f.c \
    upstream-freebsd/lib/msun/src/e_log2.c \
    upstream-freebsd/lib/msun/src/e_log2f.c \
    upstream-freebsd/lib/msun/src/e_logf.c \
    upstream-freebsd/lib/msun/src/e_powf.c \
    upstream-freebsd/lib/msun/src/e_remainder.c \
    upstream-freebsd/lib/msun/src/e_remainderf.c \
    upstream-freebsd/lib/msun/src/e_rem_pio2.c \
    upstream-freebsd/lib/msun/src/e_rem_pio2f.c \
    upstream-freebsd/lib/msun/src/e_scalb.c \
    upstream-freebsd/lib/msun/src/e_scalbf.c \
    upstream-freebsd/lib/msun/src/e_sinhf.c \
    upstream-freebsd/lib/msun/src/imprecise.c \
    upstream-freebsd/lib/msun/src/k_cos.c \
    upstream-freebsd/lib/msun/src/k_cosf.c \
    upstream-freebsd/lib/msun/src/k_exp.c \
    upstream-freebsd/lib/msun/src/k_expf.c \
    upstream-freebsd/lib/msun/src/k_rem_pio2.c \
    upstream-freebsd/lib/msun/src/k_sin.c \
    upstream-freebsd/lib/msun/src/k_sinf.c \
    upstream-freebsd/lib/msun/src/k_tan.c \
    upstream-freebsd/lib/msun/src/k_tanf.c \
    upstream-freebsd/lib/msun/src/s_asinh.c \
    upstream-freebsd/lib/msun/src/s_asinhf.c \
    upstream-freebsd/lib/msun/src/s_atanf.c \
    upstream-freebsd/lib/msun/src/s_carg.c \
    upstream-freebsd/lib/msun/src/s_cargf.c \
    upstream-freebsd/lib/msun/src/s_cargl.c \
    upstream-freebsd/lib/msun/src/s_cbrtf.c \
    upstream-freebsd/lib/msun/src/s_ccosh.c \
    upstream-freebsd/lib/msun/src/s_ccoshf.c \
    upstream-freebsd/lib/msun/src/s_cexp.c \
    upstream-freebsd/lib/msun/src/s_cexpf.c \
    upstream-freebsd/lib/msun/src/s_cimag.c \
    upstream-freebsd/lib/msun/src/s_cimagf.c \
    upstream-freebsd/lib/msun/src/s_cimagl.c \
    upstream-freebsd/lib/msun/src/s_conj.c \
    upstream-freebsd/lib/msun/src/s_conjf.c \
    upstream-freebsd/lib/msun/src/s_conjl.c \
    upstream-freebsd/lib/msun/src/s_copysign.c \
    upstream-freebsd/lib/msun/src/s_copysignf.c \
    upstream-freebsd/lib/msun/src/s_cosf.c \
    upstream-freebsd/lib/msun/src/s_cproj.c \
    upstream-freebsd/lib/msun/src/s_cprojf.c \
    upstream-freebsd/lib/msun/src/s_cprojl.c \
    upstream-freebsd/lib/msun/src/s_creal.c \
    upstream-freebsd/lib/msun/src/s_crealf.c \
    upstream-freebsd/lib/msun/src/s_creall.c \
    upstream-freebsd/lib/msun/src/s_csinh.c \
    upstream-freebsd/lib/msun/src/s_csinhf.c \
    upstream-freebsd/lib/msun/src/s_csqrt.c \
    upstream-freebsd/lib/msun/src/s_csqrtf.c \
    upstream-freebsd/lib/msun/src/s_csqrtl.c \
    upstream-freebsd/lib/msun/src/s_ctanh.c \
    upstream-freebsd/lib/msun/src/s_ctanhf.c \
    upstream-freebsd/lib/msun/src/s_erf.c \
    upstream-freebsd/lib/msun/src/s_erff.c \
    upstream-freebsd/lib/msun/src/s_exp2.c \
    upstream-freebsd/lib/msun/src/s_exp2f.c \
    upstream-freebsd/lib/msun/src/s_expm1f.c \
    upstream-freebsd/lib/msun/src/s_fabs.c \
    upstream-freebsd/lib/msun/src/s_fabsf.c \
    upstream-freebsd/lib/msun/src/s_fdim.c \
    upstream-freebsd/lib/msun/src/s_finite.c \
    upstream-freebsd/lib/msun/src/s_finitef.c \
    upstream-freebsd/lib/msun/src/s_frexp.c \
    upstream-freebsd/lib/msun/src/s_frexpf.c \
    upstream-freebsd/lib/msun/src/s_ilogb.c \
    upstream-freebsd/lib/msun/src/s_ilogbf.c \
    upstream-freebsd/lib/msun/src/s_llround.c \
    upstream-freebsd/lib/msun/src/s_llroundf.c \
    upstream-freebsd/lib/msun/src/s_log1pf.c \
    upstream-freebsd/lib/msun/src/s_logb.c \
    upstream-freebsd/lib/msun/src/s_logbf.c \
    upstream-freebsd/lib/msun/src/s_modf.c \
    upstream-freebsd/lib/msun/src/s_modff.c \
    upstream-freebsd/lib/msun/src/s_nan.c \
    upstream-freebsd/lib/msun/src/s_nearbyint.c \
    upstream-freebsd/lib/msun/src/s_nextafter.c \
    upstream-freebsd/lib/msun/src/s_nextafterf.c \
    upstream-freebsd/lib/msun/src/s_remquo.c \
    upstream-freebsd/lib/msun/src/s_remquof.c \
    upstream-freebsd/lib/msun/src/s_scalbln.c \
    upstream-freebsd/lib/msun/src/s_scalbn.c \
    upstream-freebsd/lib/msun/src/s_scalbnf.c \
    upstream-freebsd/lib/msun/src/s_signgam.c \
    upstream-freebsd/lib/msun/src/s_significand.c \
    upstream-freebsd/lib/msun/src/s_significandf.c \
    upstream-freebsd/lib/msun/src/s_sinf.c \
    upstream-freebsd/lib/msun/src/s_tanf.c \
    upstream-freebsd/lib/msun/src/s_tanhf.c \
    upstream-freebsd/lib/msun/src/s_tgammaf.c \
    upstream-freebsd/lib/msun/src/w_cabs.c \
    upstream-freebsd/lib/msun/src/w_cabsf.c \
    upstream-freebsd/lib/msun/src/w_cabsl.c \
    upstream-freebsd/lib/msun/src/w_drem.c \
    upstream-freebsd/lib/msun/src/w_dremf.c

libm_common_src_files += \
    fake_long_double.c \
    signbit.c \

libm_ld128_src_files = \
    upstream-freebsd/lib/msun/src/e_acosl.c \
    upstream-freebsd/lib/msun/src/e_acoshl.c \
    upstream-freebsd/lib/msun/src/e_asinl.c \
    upstream-freebsd/lib/msun/src/e_atan2l.c \
    upstream-freebsd/lib/msun/src/e_atanhl.c \
    upstream-freebsd/lib/msun/src/e_fmodl.c \
    upstream-freebsd/lib/msun/src/e_hypotl.c \
    upstream-freebsd/lib/msun/src/e_lgammal.c \
    upstream-freebsd/lib/msun/src/e_remainderl.c \
    upstream-freebsd/lib/msun/src/e_sqrtl.c \
    upstream-freebsd/lib/msun/src/s_asinhl.c \
    upstream-freebsd/lib/msun/src/s_atanl.c \
    upstream-freebsd/lib/msun/src/s_cbrtl.c \
    upstream-freebsd/lib/msun/src/s_ceill.c \
    upstream-freebsd/lib/msun/src/s_copysignl.c \
    upstream-freebsd/lib/msun/src/e_coshl.c \
    upstream-freebsd/lib/msun/src/s_cosl.c \
    upstream-freebsd/lib/msun/src/s_fabsl.c \
    upstream-freebsd/lib/msun/src/s_floorl.c \
    upstream-freebsd/lib/msun/src/s_fmal.c \
    upstream-freebsd/lib/msun/src/s_fmaxl.c \
    upstream-freebsd/lib/msun/src/s_fminl.c \
    upstream-freebsd/lib/msun/src/s_modfl.c \
    upstream-freebsd/lib/msun/src/s_frexpl.c \
    upstream-freebsd/lib/msun/src/s_ilogbl.c \
    upstream-freebsd/lib/msun/src/s_llrintl.c \
    upstream-freebsd/lib/msun/src/s_llroundl.c \
    upstream-freebsd/lib/msun/src/s_logbl.c \
    upstream-freebsd/lib/msun/src/s_lrintl.c \
    upstream-freebsd/lib/msun/src/s_lroundl.c \
    upstream-freebsd/lib/msun/src/s_nextafterl.c \
    upstream-freebsd/lib/msun/src/s_nexttoward.c \
    upstream-freebsd/lib/msun/src/s_nexttowardf.c \
    upstream-freebsd/lib/msun/src/s_remquol.c \
    upstream-freebsd/lib/msun/src/s_rintl.c \
    upstream-freebsd/lib/msun/src/s_roundl.c \
    upstream-freebsd/lib/msun/src/s_scalbnl.c \
    upstream-freebsd/lib/msun/src/e_sinhl.c \
    upstream-freebsd/lib/msun/src/s_sinl.c \
    upstream-freebsd/lib/msun/src/s_tanhl.c \
    upstream-freebsd/lib/msun/src/s_tanl.c \
    upstream-freebsd/lib/msun/src/s_truncl.c \

libm_ld128_src_files += \
    upstream-freebsd/lib/msun/ld128/invtrig.c \
    upstream-freebsd/lib/msun/ld128/e_lgammal_r.c \
    upstream-freebsd/lib/msun/ld128/k_cosl.c \
    upstream-freebsd/lib/msun/ld128/k_sinl.c \
    upstream-freebsd/lib/msun/ld128/k_tanl.c \
    upstream-freebsd/lib/msun/ld128/s_erfl.c \
    upstream-freebsd/lib/msun/ld128/s_exp2l.c \
    upstream-freebsd/lib/msun/ld128/s_expl.c \
    upstream-freebsd/lib/msun/ld128/s_logl.c \
    upstream-freebsd/lib/msun/ld128/s_nanl.c \

# Arch specific optimizations.

# -----------------------------------------------------------------------------
# arm
# -----------------------------------------------------------------------------
libm_arm_arch_files += \
    arm/fenv.c \
    upstream-freebsd/lib/msun/src/e_acos.c \
    upstream-freebsd/lib/msun/src/e_asin.c \
    upstream-freebsd/lib/msun/src/e_atan2.c \
    upstream-freebsd/lib/msun/src/e_cosh.c \
    upstream-freebsd/lib/msun/src/e_exp.c \
    upstream-freebsd/lib/msun/src/e_hypot.c \
    upstream-freebsd/lib/msun/src/e_log.c \
    upstream-freebsd/lib/msun/src/e_log10.c \
    upstream-freebsd/lib/msun/src/e_pow.c \
    upstream-freebsd/lib/msun/src/e_sinh.c \
    upstream-freebsd/lib/msun/src/s_atan.c \
    upstream-freebsd/lib/msun/src/s_cbrt.c \
    upstream-freebsd/lib/msun/src/s_ceil.c \
    upstream-freebsd/lib/msun/src/s_ceilf.c \
    upstream-freebsd/lib/msun/src/s_floorf.c \
    upstream-freebsd/lib/msun/src/s_fma.c \
    upstream-freebsd/lib/msun/src/s_fmaf.c \
    upstream-freebsd/lib/msun/src/s_fmax.c \
    upstream-freebsd/lib/msun/src/s_fmaxf.c \
    upstream-freebsd/lib/msun/src/s_fmin.c \
    upstream-freebsd/lib/msun/src/s_fminf.c \
    upstream-freebsd/lib/msun/src/s_expm1.c \
    upstream-freebsd/lib/msun/src/s_llrint.c \
    upstream-freebsd/lib/msun/src/s_llrintf.c \
    upstream-freebsd/lib/msun/src/s_log1p.c \
    upstream-freebsd/lib/msun/src/s_lrint.c \
    upstream-freebsd/lib/msun/src/s_lrintf.c \
    upstream-freebsd/lib/msun/src/s_lround.c \
    upstream-freebsd/lib/msun/src/s_lroundf.c \
    upstream-freebsd/lib/msun/src/s_rint.c \
    upstream-freebsd/lib/msun/src/s_rintf.c \
    upstream-freebsd/lib/msun/src/s_round.c \
    upstream-freebsd/lib/msun/src/s_roundf.c \
    upstream-freebsd/lib/msun/src/s_tan.c \
    upstream-freebsd/lib/msun/src/s_tanh.c \
    upstream-freebsd/lib/msun/src/s_trunc.c \
    upstream-freebsd/lib/msun/src/s_truncf.c \

# s_floor.S requires neon instructions.
ifdef TARGET_2ND_ARCH
arch_variant := $(TARGET_2ND_ARCH_VARIANT)
else
arch_variant := $(TARGET_ARCH_VARIANT)
endif

# Use the C version on armv7-a since it doesn't support neon instructions.
ifeq ($(arch_variant),armv7-a)
libm_arm_arch_files += \
    upstream-freebsd/lib/msun/src/s_cos.c \
    upstream-freebsd/lib/msun/src/s_sin.c \
    upstream-freebsd/lib/msun/src/e_sqrt.c \
    upstream-freebsd/lib/msun/src/e_sqrtf.c \
    upstream-freebsd/lib/msun/src/s_floor.c \

else
libm_arm_arch_files += \
    arm/cos.S \
    arm/sin.S \
    arm/sqrt.S \
    arm/floor.S \

libm_arm_arch_cflags += -DQCOM_NEON_OPTIMIZATION -fno-if-conversion
endif

# -----------------------------------------------------------------------------
# arm64
# -----------------------------------------------------------------------------
libm_arm64_arch_files += \
    upstream-freebsd/lib/msun/src/s_cos.c \
    upstream-freebsd/lib/msun/src/s_sin.c \
    arm64/ceil.S \
    arm64/fma.S \
    arm64/fmax.S \
    arm64/fmin.S \
    arm64/floor.S \
    arm64/lrint.S \
    arm64/lround.S \
    arm64/rint.S \
    arm64/round.S \
    arm64/sqrt.S \
    arm64/trunc.S \
    upstream-freebsd/lib/msun/src/e_acos.c \
    upstream-freebsd/lib/msun/src/e_asin.c \
    upstream-freebsd/lib/msun/src/e_atan2.c \
    upstream-freebsd/lib/msun/src/e_cosh.c \
    upstream-freebsd/lib/msun/src/e_exp.c \
    upstream-freebsd/lib/msun/src/e_hypot.c \
    upstream-freebsd/lib/msun/src/e_log.c \
    upstream-freebsd/lib/msun/src/e_log10.c \
    upstream-freebsd/lib/msun/src/e_pow.c \
    upstream-freebsd/lib/msun/src/e_sinh.c \
    upstream-freebsd/lib/msun/src/s_atan.c \
    upstream-freebsd/lib/msun/src/s_cbrt.c \
    upstream-freebsd/lib/msun/src/s_cos.c \
    upstream-freebsd/lib/msun/src/s_expm1.c \
    upstream-freebsd/lib/msun/src/s_log1p.c \
    upstream-freebsd/lib/msun/src/s_sin.c \
    upstream-freebsd/lib/msun/src/s_tan.c \
    upstream-freebsd/lib/msun/src/s_tanh.c \

libm_arm64_arch_cflags += -DQCOM_NEON_OPTIMIZATION

# -----------------------------------------------------------------------------
# mips
# -----------------------------------------------------------------------------
libm_mips_arch_files += \
    mips/fenv.c \
    upstream-freebsd/lib/msun/src/e_acos.c \
    upstream-freebsd/lib/msun/src/e_asin.c \
    upstream-freebsd/lib/msun/src/e_atan2.c \
    upstream-freebsd/lib/msun/src/e_cosh.c \
    upstream-freebsd/lib/msun/src/e_exp.c \
    upstream-freebsd/lib/msun/src/e_hypot.c \
    upstream-freebsd/lib/msun/src/e_log.c \
    upstream-freebsd/lib/msun/src/e_log10.c \
    upstream-freebsd/lib/msun/src/e_pow.c \
    upstream-freebsd/lib/msun/src/e_sinh.c \
    upstream-freebsd/lib/msun/src/e_sqrt.c \
    upstream-freebsd/lib/msun/src/e_sqrtf.c \
    upstream-freebsd/lib/msun/src/s_atan.c \
    upstream-freebsd/lib/msun/src/s_cbrt.c \
    upstream-freebsd/lib/msun/src/s_ceil.c \
    upstream-freebsd/lib/msun/src/s_ceilf.c \
    upstream-freebsd/lib/msun/src/s_cos.c \
    upstream-freebsd/lib/msun/src/s_floor.c \
    upstream-freebsd/lib/msun/src/s_floorf.c \
    upstream-freebsd/lib/msun/src/s_fma.c \
    upstream-freebsd/lib/msun/src/s_fmaf.c \
    upstream-freebsd/lib/msun/src/s_fmax.c \
    upstream-freebsd/lib/msun/src/s_fmaxf.c \
    upstream-freebsd/lib/msun/src/s_fmin.c \
    upstream-freebsd/lib/msun/src/s_fminf.c \
    upstream-freebsd/lib/msun/src/s_expm1.c \
    upstream-freebsd/lib/msun/src/s_llrint.c \
    upstream-freebsd/lib/msun/src/s_llrintf.c \
    upstream-freebsd/lib/msun/src/s_log1p.c \
    upstream-freebsd/lib/msun/src/s_lrint.c \
    upstream-freebsd/lib/msun/src/s_lrintf.c \
    upstream-freebsd/lib/msun/src/s_lround.c \
    upstream-freebsd/lib/msun/src/s_lroundf.c \
    upstream-freebsd/lib/msun/src/s_rint.c \
    upstream-freebsd/lib/msun/src/s_rintf.c \
    upstream-freebsd/lib/msun/src/s_round.c \
    upstream-freebsd/lib/msun/src/s_roundf.c \
    upstream-freebsd/lib/msun/src/s_sin.c \
    upstream-freebsd/lib/msun/src/s_tan.c \
    upstream-freebsd/lib/msun/src/s_tanh.c \
    upstream-freebsd/lib/msun/src/s_trunc.c \
    upstream-freebsd/lib/msun/src/s_truncf.c \


# -----------------------------------------------------------------------------
# x86
# -----------------------------------------------------------------------------
libm_x86_arch_files += \
    upstream-freebsd/lib/msun/src/s_cos.c \
    upstream-freebsd/lib/msun/src/s_fma.c \
    upstream-freebsd/lib/msun/src/s_fmaf.c \
    upstream-freebsd/lib/msun/src/s_fmax.c \
    upstream-freebsd/lib/msun/src/s_fmaxf.c \
    upstream-freebsd/lib/msun/src/s_fmin.c \
    upstream-freebsd/lib/msun/src/s_fminf.c \
    upstream-freebsd/lib/msun/src/s_llrint.c \
    upstream-freebsd/lib/msun/src/s_llrintf.c \
    x86/lrint.S \
    x86/lrintf.S \
    upstream-freebsd/lib/msun/src/s_lround.c \
    upstream-freebsd/lib/msun/src/s_lroundf.c \
    upstream-freebsd/lib/msun/src/s_round.c \
    upstream-freebsd/lib/msun/src/s_roundf.c \
    upstream-freebsd/lib/msun/src/s_sin.c \
    x86/sqrt.S \
    x86/sqrtf.S \
    x86/e_acos.S \
    x86/e_asin.S \
    x86/e_atan2.S \
    x86/e_cosh.S \
    x86/e_exp.S \
    x86/e_hypot.S \
    x86/e_log10.S \
    x86/e_log.S \
    x86/e_pow.S \
    x86/e_sinh.S \
    x86/libm_reduce_pi04l.S \
    x86/libm_sincos_huge.S \
    x86/libm_tancot_huge.S \
    x86/s_atan.S \
    x86/s_cbrt.S \
    x86/s_cos.S \
    x86/s_expm1.S \
    x86/s_log1p.S \
    x86/s_sin.S \
    x86/s_tanh.S \
    x86/s_tan.S \

ifeq ($(ARCH_X86_HAVE_SSE4_1),true)
LOCAL_SRC_FILES_x86 += \
    x86/ceil.S \
    x86/ceilf.S \
    x86/floor.S \
    x86/floorf.S \
    x86/rint.S \
    x86/rintf.S \
    x86/trunc.S \
    x86/truncf.S \

else
LOCAL_SRC_FILES_x86 += \
    upstream-freebsd/lib/msun/src/s_ceil.c \
    upstream-freebsd/lib/msun/src/s_ceilf.c \
    upstream-freebsd/lib/msun/src/s_floor.c \
    upstream-freebsd/lib/msun/src/s_floorf.c \
    upstream-freebsd/lib/msun/src/s_rint.c \
    upstream-freebsd/lib/msun/src/s_rintf.c \
    upstream-freebsd/lib/msun/src/s_trunc.c \
    upstream-freebsd/lib/msun/src/s_truncf.c \

endif

# -----------------------------------------------------------------------------
# x86_64
# -----------------------------------------------------------------------------
libm_x86_64_arch_files += \
    upstream-freebsd/lib/msun/src/s_cos.c \
    upstream-freebsd/lib/msun/src/s_fma.c \
    upstream-freebsd/lib/msun/src/s_fmaf.c \
    upstream-freebsd/lib/msun/src/s_fmax.c \
    upstream-freebsd/lib/msun/src/s_fmaxf.c \
    upstream-freebsd/lib/msun/src/s_fmin.c \
    upstream-freebsd/lib/msun/src/s_fminf.c \
    x86_64/lrint.S \
    x86_64/lrintf.S \
    upstream-freebsd/lib/msun/src/s_lround.c \
    upstream-freebsd/lib/msun/src/s_lroundf.c \
    upstream-freebsd/lib/msun/src/s_round.c \
    upstream-freebsd/lib/msun/src/s_roundf.c \
    upstream-freebsd/lib/msun/src/s_sin.c \
    x86_64/sqrt.S \
    x86_64/sqrtf.S \
    x86_64/e_acos.S \
    x86_64/e_asin.S \
    x86_64/e_atan2.S \
    x86_64/e_cosh.S \
    x86_64/e_exp.S \
    x86_64/e_hypot.S \
    x86_64/e_log10.S \
    x86_64/e_log.S \
    x86_64/e_pow.S \
    x86_64/e_sinh.S \
    x86_64/s_atan.S \
    x86_64/s_cbrt.S \
    x86_64/s_cos.S \
    x86_64/s_expm1.S \
    x86_64/s_log1p.S \
    x86_64/s_sin.S \
    x86_64/s_tanh.S \
    x86_64/s_tan.S \

ifeq ($(ARCH_X86_HAVE_SSE4_1),true)
LOCAL_SRC_FILES_x86_64 += \
    x86_64/ceil.S \
    x86_64/ceilf.S \
    x86_64/floor.S \
    x86_64/floorf.S \
    x86_64/rint.S \
    x86_64/rintf.S \
    x86_64/trunc.S \
    x86_64/truncf.S \

else
LOCAL_SRC_FILES_x86_64 += \
    upstream-freebsd/lib/msun/src/s_ceil.c \
    upstream-freebsd/lib/msun/src/s_ceilf.c \
    upstream-freebsd/lib/msun/src/s_floor.c \
    upstream-freebsd/lib/msun/src/s_floorf.c \
    upstream-freebsd/lib/msun/src/s_rint.c \
    upstream-freebsd/lib/msun/src/s_rintf.c \
    upstream-freebsd/lib/msun/src/s_trunc.c \
    upstream-freebsd/lib/msun/src/s_truncf.c \

endif

# TODO: re-enable i387/e_sqrtf.S for x86, and maybe others.

libm_common_cflags := \
    -DFLT_EVAL_METHOD=0 \
    -std=c99 \
    -O3 \
    -include $(LOCAL_PATH)/freebsd-compat.h \
    -Wno-missing-braces \
    -Wno-parentheses \
    -Wno-sign-compare \
    -Wno-uninitialized \
    -Wno-unknown-pragmas \
    -fvisibility=hidden \

# Workaround the GCC "(long)fn -> lfn" optimization bug which will result in
# self recursions for lrint, lrintf, and lrintl.
# BUG: 14225968
libm_common_cflags += -fno-builtin-rint -fno-builtin-rintf -fno-builtin-rintl
libm_common_includes += $(LOCAL_PATH)/upstream-freebsd/lib/msun/src/

libm_ld_includes += $(LOCAL_PATH)/upstream-freebsd/lib/msun/ld128/

#
# libm.a for target.
#
include $(CLEAR_VARS)
LOCAL_MODULE:= libm
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_ARM_MODE := arm
LOCAL_CFLAGS := $(libm_common_cflags)
LOCAL_C_INCLUDES += $(libm_common_includes)
LOCAL_SRC_FILES := $(libm_common_src_files)
LOCAL_SYSTEM_SHARED_LIBRARIES := libc

LOCAL_ASFLAGS := \
    -Ibionic/libc \

# arch-specific settings
LOCAL_CFLAGS_arm := $(libm_arm_arch_cflags)
LOCAL_C_INCLUDES_arm := $(LOCAL_PATH)/arm $(libm_arm_arch_includes)
LOCAL_SRC_FILES_arm := $(libm_arm_arch_files)

LOCAL_CFLAGS_arm64 := $(libm_arm64_arch_cflags)
LOCAL_C_INCLUDES_arm64 := $(libm_ld_includes) $(libm_arm64_arch_includes)
LOCAL_SRC_FILES_arm64 := $(libm_ld128_src_files) $(libm_arm64_arch_files)

LOCAL_C_INCLUDES_x86 := $(LOCAL_PATH)/i387
LOCAL_SRC_FILES_x86 := $(libm_x86_arch_files)

LOCAL_C_INCLUDES_x86_64 := $(libm_ld_includes)
LOCAL_SRC_FILES_x86_64 := $(libm_ld128_src_files) $(libm_x86_64_arch_files)

LOCAL_SRC_FILES_mips += $(libm_mips_arch_files)

LOCAL_C_INCLUDES_mips64 := $(libm_ld_includes)
LOCAL_SRC_FILES_mips64 := $(libm_ld128_src_files)
LOCAL_SRC_FILES_mips64 += $(libm_mips_arch_files)

include $(BUILD_STATIC_LIBRARY)

#
# libm.so for target.
#
include $(CLEAR_VARS)
LOCAL_MODULE:= libm
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_SYSTEM_SHARED_LIBRARIES := libc
LOCAL_WHOLE_STATIC_LIBRARIES := libm

# We'd really like to do this for all architectures, but since this wasn't done
# before, these symbols must continue to be exported on LP32 for binary
# compatibility.
LOCAL_LDFLAGS_arm64 := -Wl,--exclude-libs,libgcc.a
LOCAL_LDFLAGS_mips64 := -Wl,--exclude-libs,libgcc.a
LOCAL_LDFLAGS_x86_64 := -Wl,--exclude-libs,libgcc.a
include $(BUILD_SHARED_LIBRARY)
endif
