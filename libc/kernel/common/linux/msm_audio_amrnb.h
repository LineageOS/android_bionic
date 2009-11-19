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
#ifndef __MSM_AUDIO_AMRNB_H
#define __MSM_AUDIO_AMRNB_H

#include <linux/msm_audio.h>

#define AUDIO_GET_AMRNB_ENC_CONFIG _IOW(AUDIO_IOCTL_MAGIC,   (AUDIO_MAX_COMMON_IOCTL_NUM+0), unsigned)
#define AUDIO_SET_AMRNB_ENC_CONFIG _IOR(AUDIO_IOCTL_MAGIC,   (AUDIO_MAX_COMMON_IOCTL_NUM+1), unsigned)

struct msm_audio_amrnb_enc_config {
 unsigned short voicememoencweight1;
 unsigned short voicememoencweight2;
 unsigned short voicememoencweight3;
 unsigned short voicememoencweight4;
 unsigned short dtx_mode_enable;
 unsigned short test_mode_enable;
 unsigned short enc_mode;
};
#endif
