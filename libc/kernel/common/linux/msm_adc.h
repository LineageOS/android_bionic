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
#ifndef __MSM_ADC_H
#define __MSM_ADC_H

#define MSM_ADC_MAX_CHAN_STR 64

#define MSM_ADC_DEV_MAX_INFLIGHT 9

#define MSM_ADC_IOCTL_CODE 0x90

struct msm_adc_conversion {

 uint32_t chan;

 int result;
};

#define MSM_ADC_REQUEST _IOWR(MSM_ADC_IOCTL_CODE, 1,   struct msm_adc_conversion)

#define MSM_ADC_AIO_REQUEST _IOWR(MSM_ADC_IOCTL_CODE, 2,   struct msm_adc_conversion)

#define MSM_ADC_AIO_REQUEST_BLOCK_RES _IOWR(MSM_ADC_IOCTL_CODE, 3,   struct msm_adc_conversion)

#define MSM_ADC_AIO_POLL _IOR(MSM_ADC_IOCTL_CODE, 4,   uint32_t)

struct msm_adc_aio_result {
 uint32_t chan;
 int result;
};

#define MSM_ADC_AIO_READ _IOR(MSM_ADC_IOCTL_CODE, 5,   struct msm_adc_aio_result)

struct msm_adc_lookup {

 char name[MSM_ADC_MAX_CHAN_STR];

 uint32_t chan_idx;
};

#define MSM_ADC_LOOKUP _IOWR(MSM_ADC_IOCTL_CODE, 6,   struct msm_adc_lookup)

struct msm_adc_platform_data {
 uint32_t num_adc;
 uint32_t chan_per_adc;
 char **dev_names;
};

#endif

