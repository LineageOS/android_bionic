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
#ifndef __MSM_ROTATOR_H__

#include <linux/types.h>
#include <linux/msm_mdp.h>

#define MSM_ROTATOR_IOCTL_MAGIC 'R'

#define MSM_ROTATOR_IOCTL_START   _IOWR(MSM_ROTATOR_IOCTL_MAGIC, 1, struct msm_rotator_img_info)
#define MSM_ROTATOR_IOCTL_ROTATE   _IOW(MSM_ROTATOR_IOCTL_MAGIC, 2, struct msm_rotator_data_info)
#define MSM_ROTATOR_IOCTL_FINISH   _IOW(MSM_ROTATOR_IOCTL_MAGIC, 3, int)

struct msm_rotator_img_info {
 int session_id;
 struct msmfb_img src;
 struct msmfb_img dst;
 struct mdp_rect src_rect;
 unsigned int dst_x;
 unsigned int dst_y;
 unsigned char rotations;
};

struct msm_rotator_data_info {
 int session_id;
 struct msmfb_data src;
 struct msmfb_data dst;
};

#endif

