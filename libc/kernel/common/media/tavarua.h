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
#ifndef __LINUX_TAVARUA_H
#define __LINUX_TAVARUA_H

#include <stdint.h>
#include <linux/ioctl.h>
#include <linux/videodev2.h>

#undef FM_DEBUG

#define RDS_BLOCKS_NUM (4)
#define BYTES_PER_BLOCK (3)
#define MAX_PS_LENGTH (96)
#define MAX_RT_LENGTH (64)

#define STD_BUF_SIZE (64)

#define SRCH_DIR_UP (0)
#define SRCH_DIR_DOWN (1)

#define CTRL_ON (1)
#define CTRL_OFF (0)

#define US_LOW_BAND (87.5)
#define US_HIGH_BAND (108)

#define MASK_PI (0x0000FFFF)
#define MASK_PI_MSB (0x0000FF00)
#define MASK_PI_LSB (0x000000FF)
#define MASK_PTY (0x0000001F)
#define MASK_TXREPCOUNT (0x0000000F)

#undef FMDBG
#ifdef FM_DEBUG
#define FMDBG(fmt, args...) printk(KERN_INFO "tavarua_radio: " fmt, ##args)
#else
#define FMDBG(fmt, args...)
#endif

#undef FMDERR
#define FMDERR(fmt, args...) printk(KERN_INFO "tavarua_radio: " fmt, ##args)

#undef FMDBG_I2C
#ifdef FM_DEBUG_I2C
#define FMDBG_I2C(fmt, args...) printk(KERN_INFO "fm_i2c: " fmt, ##args)
#else
#define FMDBG_I2C(fmt, args...)
#endif

#define TAVARUA_AUDIO_OUT_ANALOG_OFF (0)
#define TAVARUA_AUDIO_OUT_ANALOG_ON (1)
#define TAVARUA_AUDIO_OUT_DIGITAL_OFF (0)
#define TAVARUA_AUDIO_OUT_DIGITAL_ON (1)

#define MARIMBA_A0 0x01010013
#define MARIMBA_2_1 0x02010204
#define BAHAMA_1_0 0x0302010A
#define BAHAMA_2_0 0x04020205
#define WAIT_TIMEOUT 2000
#define RADIO_INIT_TIME 15
#define TAVARUA_DELAY 10

#define FREQ_MUL (1000000 / 62.5)

enum v4l2_cid_private_tavarua_t {
 V4L2_CID_PRIVATE_TAVARUA_SRCHMODE = (V4L2_CID_PRIVATE_BASE + 1),
 V4L2_CID_PRIVATE_TAVARUA_SCANDWELL,
 V4L2_CID_PRIVATE_TAVARUA_SRCHON,
 V4L2_CID_PRIVATE_TAVARUA_STATE,
 V4L2_CID_PRIVATE_TAVARUA_TRANSMIT_MODE,
 V4L2_CID_PRIVATE_TAVARUA_RDSGROUP_MASK,
 V4L2_CID_PRIVATE_TAVARUA_REGION,
 V4L2_CID_PRIVATE_TAVARUA_SIGNAL_TH,
 V4L2_CID_PRIVATE_TAVARUA_SRCH_PTY,
 V4L2_CID_PRIVATE_TAVARUA_SRCH_PI,
 V4L2_CID_PRIVATE_TAVARUA_SRCH_CNT,
 V4L2_CID_PRIVATE_TAVARUA_EMPHASIS,
 V4L2_CID_PRIVATE_TAVARUA_RDS_STD,
 V4L2_CID_PRIVATE_TAVARUA_SPACING,
 V4L2_CID_PRIVATE_TAVARUA_RDSON,
 V4L2_CID_PRIVATE_TAVARUA_RDSGROUP_PROC,
 V4L2_CID_PRIVATE_TAVARUA_LP_MODE,
 V4L2_CID_PRIVATE_TAVARUA_ANTENNA,
 V4L2_CID_PRIVATE_TAVARUA_RDSD_BUF,
 V4L2_CID_PRIVATE_TAVARUA_PSALL,

 V4L2_CID_PRIVATE_TAVARUA_TX_SETPSREPEATCOUNT,
 V4L2_CID_PRIVATE_TAVARUA_STOP_RDS_TX_PS_NAME,
 V4L2_CID_PRIVATE_TAVARUA_STOP_RDS_TX_RT
};

enum tavarua_buf_t {
 TAVARUA_BUF_SRCH_LIST,
 TAVARUA_BUF_EVENTS,
 TAVARUA_BUF_RT_RDS,
 TAVARUA_BUF_PS_RDS,
 TAVARUA_BUF_RAW_RDS,
 TAVARUA_BUF_AF_LIST,
 TAVARUA_BUF_MAX
};

enum tavarua_xfr_t {
 TAVARUA_XFR_SYNC,
 TAVARUA_XFR_ERROR,
 TAVARUA_XFR_SRCH_LIST,
 TAVARUA_XFR_RT_RDS,
 TAVARUA_XFR_PS_RDS,
 TAVARUA_XFR_AF_LIST,
 TAVARUA_XFR_MAX
};

#define RAW_RDS 0x0F
#define RDS_BLOCK 3

#define MARIMBA_XO_BUFF_CNTRL 0x07
#define RADIO_REGISTERS 0x30
#define XFR_REG_NUM 16
#define STATUS_REG_NUM 3

#define HEADER_SIZE 4
#define TX_ON 0x80
#define TAVARUA_TX_RT RDS_RT_0
#define TAVARUA_TX_PS RDS_PS_0

enum register_t {
 STATUS_REG1 = 0,
 STATUS_REG2,
 STATUS_REG3,
 RDCTRL,
 FREQ,
 TUNECTRL,
 SRCHRDS1,
 SRCHRDS2,
 SRCHCTRL,
 IOCTRL,
 RDSCTRL,
 ADVCTRL,
 AUDIOCTRL,
 RMSSI,
 AUDIOIND = 0x1E,
 XFRCTRL,
 FM_CTL0 = 0xFF,
 LEAKAGE_CNTRL = 0xFE,
};
#define BAHAMA_RBIAS_CTL1 0x07
#define BAHAMA_FM_MODE_REG 0xFD
#define BAHAMA_FM_CTL1_REG 0xFE
#define BAHAMA_FM_CTL0_REG 0xFF
#define BAHAMA_FM_MODE_NORMAL 0x00
#define BAHAMA_LDO_DREG_CTL0 0xF0
#define BAHAMA_LDO_AREG_CTL0 0xF4

#define RDCTRL_STATE_OFFSET 0
#define RDCTRL_STATE_MASK (3 << RDCTRL_STATE_OFFSET)
#define RDCTRL_BAND_OFFSET 2
#define RDCTRL_BAND_MASK (1 << RDCTRL_BAND_OFFSET)
#define RDCTRL_CHSPACE_OFFSET 3
#define RDCTRL_CHSPACE_MASK (3 << RDCTRL_CHSPACE_OFFSET)
#define RDCTRL_DEEMPHASIS_OFFSET 5
#define RDCTRL_DEEMPHASIS_MASK (1 << RDCTRL_DEEMPHASIS_OFFSET)
#define RDCTRL_HLSI_OFFSET 6
#define RDCTRL_HLSI_MASK (3 << RDCTRL_HLSI_OFFSET)

#define TUNE_STATION 0x01
#define ADD_OFFSET (1 << 1)
#define SIGSTATE (1 << 5)
#define MOSTSTATE (1 << 6)
#define RDSSYNC (1 << 7)

#define SRCH_MODE_OFFSET 0
#define SRCH_MODE_MASK (7 << SRCH_MODE_OFFSET)
#define SRCH_DIR_OFFSET 3
#define SRCH_DIR_MASK (1 << SRCH_DIR_OFFSET)
#define SRCH_DWELL_OFFSET 4
#define SRCH_DWELL_MASK (7 << SRCH_DWELL_OFFSET)
#define SRCH_STATE_OFFSET 7
#define SRCH_STATE_MASK (1 << SRCH_STATE_OFFSET)

#define IOC_HRD_MUTE 0x03
#define IOC_SFT_MUTE (1 << 2)
#define IOC_MON_STR (1 << 3)
#define IOC_SIG_BLND (1 << 4)
#define IOC_INTF_BLND (1 << 5)
#define IOC_ANTENNA (1 << 6)
#define IOC_ANTENNA_OFFSET 6
#define IOC_ANTENNA_MASK (1 << IOC_ANTENNA_OFFSET)

#define RDS_ON 0x01
#define RDSCTRL_STANDARD_OFFSET 1
#define RDSCTRL_STANDARD_MASK (1 << RDSCTRL_STANDARD_OFFSET)

#define RDSRTEN (1 << 3)
#define RDSPSEN (1 << 4)

#define AUDIORX_ANALOG_OFFSET 0
#define AUDIORX_ANALOG_MASK (1 << AUDIORX_ANALOG_OFFSET)
#define AUDIORX_DIGITAL_OFFSET 1
#define AUDIORX_DIGITAL_MASK (1 << AUDIORX_DIGITAL_OFFSET)
#define AUDIOTX_OFFSET 2
#define AUDIOTX_MASK (1 << AUDIOTX_OFFSET)
#define I2SCTRL_OFFSET 3
#define I2SCTRL_MASK (1 << I2SCTRL_OFFSET)

enum search_t {
 SEEK,
 SCAN,
 SCAN_FOR_STRONG,
 SCAN_FOR_WEAK,
 RDS_SEEK_PTY,
 RDS_SCAN_PTY,
 RDS_SEEK_PI,
 RDS_AF_JUMP,
};

#define SRCH_MODE 0x07
#define SRCH_DIR 0x08  
#define SCAN_DWELL 0x70
#define SRCH_ON 0x80

#define RDS_CONFIG_PSALL 0x01

#define FM_ENABLE 0x22
#define SET_REG_FIELD(reg, val, offset, mask)   (reg = (reg & ~mask) | (((val) << offset) & mask))
#define GET_REG_FIELD(reg, offset, mask) ((reg & mask) >> offset)

enum radio_state_t {
 FM_OFF,
 FM_RECV,
 FM_TRANS,
 FM_RESET,
};

#define XFRCTRL_WRITE (1 << 7)

#define READY (1 << 0)  
#define TUNE (1 << 1)  
#define SEARCH (1 << 2)  
#define SCANNEXT (1 << 3)  
#define SIGNAL (1 << 4)  
#define INTF (1 << 5)  
#define SYNC (1 << 6)  
#define AUDIO (1 << 7)  

#define RDSDAT (1 << 0)  
#define BLOCKB (1 << 1)  
#define PROGID (1 << 2)  
#define RDSPS (1 << 3)  
#define RDSRT (1 << 4)  
#define RDSAF (1 << 5)  
#define TXRDSDAT (1 << 6)  
#define TXRDSDONE (1 << 7)  

#define TRANSFER (1 << 0)  
#define RDSPROC (1 << 1)  
#define ERROR (1 << 7)  

enum tavarua_xfr_ctrl_t {
 RDS_PS_0 = 0x01,
 RDS_PS_1,
 RDS_PS_2,
 RDS_PS_3,
 RDS_PS_4,
 RDS_PS_5,
 RDS_PS_6,
 RDS_RT_0,
 RDS_RT_1,
 RDS_RT_2,
 RDS_RT_3,
 RDS_RT_4,
 RDS_AF_0,
 RDS_AF_1,
 RDS_CONFIG,
 RDS_TX_GROUPS,
 RDS_COUNT_0,
 RDS_COUNT_1,
 RDS_COUNT_2,
 RADIO_CONFIG,
 RX_CONFIG,
 RX_TIMERS,
 RX_STATIONS_0,
 RX_STATIONS_1,
 INT_CTRL,
 ERROR_CODE,
 CHIPID,
 CAL_DAT_0 = 0x20,
 CAL_DAT_1,
 CAL_DAT_2,
 CAL_DAT_3,
 CAL_CFG_0,
 CAL_CFG_1,
 DIG_INTF_0,
 DIG_INTF_1,
 DIG_AGC_0,
 DIG_AGC_1,
 DIG_AGC_2,
 DIG_AUDIO_0,
 DIG_AUDIO_1,
 DIG_AUDIO_2,
 DIG_AUDIO_3,
 DIG_AUDIO_4,
 DIG_RXRDS,
 DIG_DCC,
 DIG_SPUR,
 DIG_MPXDCC,
 DIG_PILOT,
 DIG_DEMOD,
 DIG_MOST,
 DIG_TX_0,
 DIG_TX_1,
 PHY_CONFIG = 0x3C,
 PHY_TXBLOCK,
 PHY_TCB,
 TAVARUA_XFR_CTRL_MAX
};

enum tavarua_evt_t {
 TAVARUA_EVT_RADIO_READY,
 TAVARUA_EVT_TUNE_SUCC,
 TAVARUA_EVT_SEEK_COMPLETE,
 TAVARUA_EVT_SCAN_NEXT,
 TAVARUA_EVT_NEW_RAW_RDS,
 TAVARUA_EVT_NEW_RT_RDS,
 TAVARUA_EVT_NEW_PS_RDS,
 TAVARUA_EVT_ERROR,
 TAVARUA_EVT_BELOW_TH,
 TAVARUA_EVT_ABOVE_TH,
 TAVARUA_EVT_STEREO,
 TAVARUA_EVT_MONO,
 TAVARUA_EVT_RDS_AVAIL,
 TAVARUA_EVT_RDS_NOT_AVAIL,
 TAVARUA_EVT_NEW_SRCH_LIST,
 TAVARUA_EVT_NEW_AF_LIST,
 TAVARUA_EVT_TXRDSDAT,
 TAVARUA_EVT_TXRDSDONE
};

enum tavarua_region_t {
 TAVARUA_REGION_US,
 TAVARUA_REGION_EU,
 TAVARUA_REGION_JAPAN,
 TAVARUA_REGION_JAPAN_WIDE,
 TAVARUA_REGION_OTHER
};

#endif
