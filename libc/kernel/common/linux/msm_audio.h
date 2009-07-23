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
#ifndef __LINUX_MSM_AUDIO_H
#define __LINUX_MSM_AUDIO_H

#include <linux/types.h>
#include <linux/ioctl.h>
#include <asm/sizes.h>

#define AUDIO_IOCTL_MAGIC 'a'

#define AUDIO_START _IOW(AUDIO_IOCTL_MAGIC, 0, unsigned)
#define AUDIO_STOP _IOW(AUDIO_IOCTL_MAGIC, 1, unsigned)
#define AUDIO_FLUSH _IOW(AUDIO_IOCTL_MAGIC, 2, unsigned)
#define AUDIO_GET_CONFIG _IOR(AUDIO_IOCTL_MAGIC, 3, unsigned)
#define AUDIO_SET_CONFIG _IOW(AUDIO_IOCTL_MAGIC, 4, unsigned)
#define AUDIO_GET_STATS _IOR(AUDIO_IOCTL_MAGIC, 5, unsigned)
#define AUDIO_ENABLE_AUDPP _IOW(AUDIO_IOCTL_MAGIC, 6, unsigned)
#define AUDIO_SET_ADRC _IOW(AUDIO_IOCTL_MAGIC, 7, unsigned)
#define AUDIO_SET_EQ _IOW(AUDIO_IOCTL_MAGIC, 8, unsigned)
#define AUDIO_SET_RX_IIR _IOW(AUDIO_IOCTL_MAGIC, 9, unsigned)
#define AUDIO_SET_VOLUME _IOW(AUDIO_IOCTL_MAGIC, 10, unsigned)
#define AUDIO_PAUSE _IOW(AUDIO_IOCTL_MAGIC, 11, unsigned)
#define AUDIO_PLAY_DTMF _IOW(AUDIO_IOCTL_MAGIC, 12, unsigned)
#define AUDIO_GET_EVENT _IOR(AUDIO_IOCTL_MAGIC, 13, unsigned)
#define AUDIO_ABORT_GET_EVENT _IOW(AUDIO_IOCTL_MAGIC, 14, unsigned)
#define AUDIO_REGISTER_PMEM _IOW(AUDIO_IOCTL_MAGIC, 15, unsigned)
#define AUDIO_DEREGISTER_PMEM _IOW(AUDIO_IOCTL_MAGIC, 16, unsigned)
#define AUDIO_ASYNC_WRITE _IOW(AUDIO_IOCTL_MAGIC, 17, unsigned)
#define AUDIO_ASYNC_READ _IOW(AUDIO_IOCTL_MAGIC, 18, unsigned)
#define AUDIO_GET_PCM_CONFIG _IOR(AUDIO_IOCTL_MAGIC, 30, unsigned)
#define AUDIO_SET_PCM_CONFIG _IOW(AUDIO_IOCTL_MAGIC, 31, unsigned)
#define AUDIO_SWITCH_DEVICE _IOW(AUDIO_IOCTL_MAGIC, 32, unsigned)
#define AUDIO_SET_MUTE _IOW(AUDIO_IOCTL_MAGIC, 33, unsigned)
#define AUDIO_GET_STREAM_INFO _IOR(AUDIO_IOCTL_MAGIC, 34,   struct msm_audio_bitstream_info)
#define AUDIO_SET_PAN _IOW(AUDIO_IOCTL_MAGIC, 35, unsigned)
#define AUDIO_SET_QCONCERT_PLUS _IOW(AUDIO_IOCTL_MAGIC, 36, unsigned)
#define AUDIO_SET_MBADRC _IOW(AUDIO_IOCTL_MAGIC, 37, unsigned)
#define AUDIO_SET_VOLUME_PATH _IOW(AUDIO_IOCTL_MAGIC, 38, struct msm_vol_info)
#define AUDIO_SET_MAX_VOL_ALL _IOW(AUDIO_IOCTL_MAGIC, 39, unsigned)

#define AUDIO_MAX_COMMON_IOCTL_NUM 100

#define AUDIO_ENABLE_AUDPRE _IOW(AUDIO_IOCTL_MAGIC, 11, unsigned)
#define AUDIO_SET_AGC _IOW(AUDIO_IOCTL_MAGIC, 12, unsigned)
#define AUDIO_SET_NS _IOW(AUDIO_IOCTL_MAGIC, 13, unsigned)
#define AUDIO_SET_TX_IIR _IOW(AUDIO_IOCTL_MAGIC, 14, unsigned)

#define HANDSET_MIC 0x01
#define HANDSET_SPKR 0x02
#define HEADSET_MIC 0x03
#define HEADSET_SPKR_MONO 0x04
#define HEADSET_SPKR_STEREO 0x05
#define SPKR_PHONE_MIC 0x06
#define SPKR_PHONE_MONO 0x07
#define SPKR_PHONE_STEREO 0x08
#define BT_SCO_MIC 0x09
#define BT_SCO_SPKR 0x0A
#define BT_A2DP_SPKR 0x0B
#define TTY_HEADSET_MIC 0x0C
#define TTY_HEADSET_SPKR 0x0D

#define DEFAULT_TX 0x0E
#define DEFAULT_RX 0x0F

#define BT_A2DP_TX 0x10

#define HEADSET_MONO_PLUS_SPKR_MONO_RX         0x11
#define HEADSET_MONO_PLUS_SPKR_STEREO_RX       0x12
#define HEADSET_STEREO_PLUS_SPKR_MONO_RX       0x13
#define HEADSET_STEREO_PLUS_SPKR_STEREO_RX     0x14

#define I2S_RX 0x20
#define I2S_TX 0x21

#define ADRC_ENABLE 0x0001
#define EQ_ENABLE 0x0002
#define IIR_ENABLE 0x0004
#define QCONCERT_PLUS_ENABLE 0x0008
#define MBADRC_ENABLE 0x0010

#define AGC_ENABLE 0x0001
#define NS_ENABLE 0x0002
#define TX_IIR_ENABLE 0x0004

struct msm_audio_config {
 uint32_t buffer_size;
 uint32_t buffer_count;
 uint32_t channel_count;
 uint32_t sample_rate;
 uint32_t type;
 uint32_t meta_field;
 uint32_t unused[3];
};

struct msm_audio_stats {
 uint32_t byte_count;
 uint32_t sample_count;
 uint32_t unused[2];
};

struct msm_audio_pmem_info {
 int fd;
 void *vaddr;
};

struct msm_audio_aio_buf {
 void *buf_addr;
 uint32_t buf_len;
 uint32_t data_len;
 void *private_data;
};

#define SND_IOCTL_MAGIC 's'

#define SND_MUTE_UNMUTED 0
#define SND_MUTE_MUTED 1

struct msm_mute_info {
 uint32_t mute;
 uint32_t path;
};

struct msm_vol_info {
 uint32_t vol;
 uint32_t path;
};

struct msm_snd_device_config {
 uint32_t device;
 uint32_t ear_mute;
 uint32_t mic_mute;
};

#define SND_SET_DEVICE _IOW(SND_IOCTL_MAGIC, 2, struct msm_device_config *)

#define SND_METHOD_VOICE 0

struct msm_snd_volume_config {
 uint32_t device;
 uint32_t method;
 uint32_t volume;
};

#define SND_SET_VOLUME _IOW(SND_IOCTL_MAGIC, 3, struct msm_snd_volume_config *)

#define SND_GET_NUM_ENDPOINTS _IOR(SND_IOCTL_MAGIC, 4, unsigned *)

struct msm_snd_endpoint {
 int id;
 char name[64];
};

#define SND_GET_ENDPOINT _IOWR(SND_IOCTL_MAGIC, 5, struct msm_snd_endpoint *)

#define SND_AVC_CTL _IOW(SND_IOCTL_MAGIC, 6, unsigned *)
#define SND_AGC_CTL _IOW(SND_IOCTL_MAGIC, 7, unsigned *)

struct msm_audio_pcm_config {
 uint32_t pcm_feedback;
 uint32_t buffer_count;
 uint32_t buffer_size;
};

#define AUDIO_EVENT_SUSPEND 0
#define AUDIO_EVENT_RESUME 1
#define AUDIO_EVENT_WRITE_DONE 2
#define AUDIO_EVENT_READ_DONE 3
#define AUDIO_EVENT_STREAM_INFO 4

#define AUDIO_CODEC_TYPE_MP3 0
#define AUDIO_CODEC_TYPE_AAC 1

struct msm_audio_bitstream_info {
 uint32_t codec_type;
 uint32_t chan_info;
 uint32_t sample_rate;
 uint32_t bit_stream_info;
 uint32_t bit_rate;
 uint32_t unused[3];
};

union msm_audio_event_payload {
 struct msm_audio_aio_buf aio_buf;
 struct msm_audio_bitstream_info stream_info;
 int reserved;
};

struct msm_audio_event {
 int event_type;
 int timeout_ms;
 union msm_audio_event_payload event_payload;
};
#endif
