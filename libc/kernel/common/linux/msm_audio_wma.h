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
#ifndef __MSM_AUDIO_WMA_H
#define __MSM_AUDIO_WMA_H

#define AUDIO_GET_WMA_CONFIG _IOR(AUDIO_IOCTL_MAGIC,   (AUDIO_MAX_COMMON_IOCTL_NUM+0), unsigned)
#define AUDIO_SET_WMA_CONFIG _IOW(AUDIO_IOCTL_MAGIC,   (AUDIO_MAX_COMMON_IOCTL_NUM+1), unsigned)

struct msm_audio_wma_config {
 unsigned short armdatareqthr;
 unsigned short channelsdecoded;
 unsigned short wmabytespersec;
 unsigned short wmasamplingfreq;
 unsigned short wmaencoderopts;
};

#endif
