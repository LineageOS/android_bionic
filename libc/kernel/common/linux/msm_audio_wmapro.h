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
#ifndef __MSM_AUDIO_WMAPRO_H
#define __MSM_AUDIO_WMAPRO_H

#define AUDIO_GET_WMAPRO_CONFIG _IOR(AUDIO_IOCTL_MAGIC,   (AUDIO_MAX_COMMON_IOCTL_NUM+0), unsigned)
#define AUDIO_SET_WMAPRO_CONFIG _IOW(AUDIO_IOCTL_MAGIC,   (AUDIO_MAX_COMMON_IOCTL_NUM+1), unsigned)

struct msm_audio_wmapro_config {
 uint16_t armdatareqthr;
 uint8_t validbitspersample;
 uint8_t numchannels;
 uint16_t formattag;
 uint16_t samplingrate;
 uint16_t avgbytespersecond;
 uint16_t asfpacketlength;
 uint16_t channelmask;
 uint16_t encodeopt;
 uint16_t advancedencodeopt;
 uint32_t advancedencodeopt2;
};
#endif
