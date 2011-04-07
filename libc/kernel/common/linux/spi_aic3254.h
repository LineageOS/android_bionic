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
#ifndef __SPI_AIC3254_H__
#define __SPI_AIC3254_H__

#include <linux/ioctl.h>

typedef struct _CODEC_SPI_CMD {
 unsigned char act;
 unsigned char reg;
 unsigned char data;
} CODEC_SPI_CMD;

struct AIC3254_PARAM {
 unsigned int row_num;
 unsigned int col_num;
 void *cmd_data;
};

struct CODEC_CFG {
 unsigned char tb_idx;
 unsigned char index;
};

#define AIC3254_IOCTL_MAGIC 's'
#define AIC3254_SET_TX_PARAM _IOW(AIC3254_IOCTL_MAGIC, 0x10, unsigned)
#define AIC3254_SET_RX_PARAM _IOW(AIC3254_IOCTL_MAGIC, 0x11, unsigned)
#define AIC3254_CONFIG_TX _IOW(AIC3254_IOCTL_MAGIC, 0x12, unsigned int)
#define AIC3254_CONFIG_RX _IOW(AIC3254_IOCTL_MAGIC, 0x13, unsigned int)
#define AIC3254_SET_DSP_PARAM _IOW(AIC3254_IOCTL_MAGIC, 0x20, unsigned)
#define AIC3254_CONFIG_MEDIA _IOW(AIC3254_IOCTL_MAGIC, 0x21, unsigned int)
#define AIC3254_CONFIG_VOICE _IOW(AIC3254_IOCTL_MAGIC, 0x22, unsigned int)
#define AIC3254_CONFIG_VOLUME_L _IOW(AIC3254_IOCTL_MAGIC, 0x23, unsigned int)
#define AIC3254_CONFIG_VOLUME_R _IOW(AIC3254_IOCTL_MAGIC, 0x24, unsigned int)
#define AIC3254_POWERDOWN _IOW(AIC3254_IOCTL_MAGIC, 0x25, unsigned int)
#define AIC3254_DUMP_PAGES _IOW(AIC3254_IOCTL_MAGIC, 0x30, unsigned int)
#define AIC3254_READ_REG _IOWR(AIC3254_IOCTL_MAGIC, 0x31, unsigned)
#define AIC3254_WRITE_REG _IOW(AIC3254_IOCTL_MAGIC, 0x32, unsigned)

#define AIC3254_MAX_PAGES 255
#define AIC3254_MAX_REGS 128
#define AIC3254_MAX_RETRY 10

#define IO_CTL_ROW_MAX 64
#define IO_CTL_COL_MAX 1024
#define MINIDSP_ROW_MAX 32
#define MINIDSP_COL_MAX 16384

enum aic3254_uplink_mode {
 INITIAL = 0,
 CALL_UPLINK_IMIC_RECEIVER = 1,
 CALL_UPLINK_EMIC_HEADSET,
 CALL_UPLINK_IMIC_HEADSET,
 CALL_UPLINK_IMIC_SPEAKER,
 VOICERECORD_IMIC = 15,
 VOICERECORD_EMIC,
 UPLINK_OFF = 29,
 UPLINK_WAKEUP,
 POWER_OFF,
};

enum aic3254_downlink_mode {
 PLAYBACK_SPEAKER = 13,
 FM_OUT_SPEAKER = 21,
 FM_OUT_HEADSET,
 DOWNLINK_OFF = 29,
 DOWNLINK_WAKEUP,
};

struct aic3254_ctl_ops {
 void (*tx_amp_enable)(int en);
 void (*rx_amp_enable)(int en);
 int (*panel_sleep_in)(void);
};

#endif

