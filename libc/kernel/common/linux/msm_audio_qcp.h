/****************************************************************************
 ****************************************************************************
 ***
 ***   This header was automatically generated from a Linux kernel header
 ***   of the same name, to make information necessary for userspace to
 ***   call into the kernel available to libc.  It contains only constants,
 ***   structures, and macros generated from the original header, and thus,
 ***   contains no copyrightable information.
 ***
 ****************************************************************************
 ****************************************************************************/
#ifndef __MSM_AUDIO_QCP_H
#define __MSM_AUDIO_QCP_H

#include <linux/msm_audio.h>

#define CDMA_RATE_BLANK 0x00
#define CDMA_RATE_EIGHTH 0x01
#define CDMA_RATE_QUARTER 0x02
#define CDMA_RATE_HALF 0x03
#define CDMA_RATE_FULL 0x04
#define CDMA_RATE_ERASURE 0x05

struct msm_audio_qcelp_config {
 uint32_t channels;
 uint32_t cdma_rate;
 uint32_t min_bit_rate;
 uint32_t max_bit_rate;
};
struct msm_audio_evrc_config {
 uint32_t channels;
 uint32_t cdma_rate;
 uint32_t min_bit_rate;
 uint32_t max_bit_rate;
 uint8_t bit_rate_reduction;
 uint8_t hi_pass_filter;
 uint8_t noise_suppressor;
 uint8_t post_filter;
};
#endif
