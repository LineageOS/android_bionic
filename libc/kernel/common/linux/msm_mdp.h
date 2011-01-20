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
#ifndef _MSM_MDP_H_
#define _MSM_MDP_H_

#include <linux/types.h>
#include <linux/fb.h>

#define MSMFB_IOCTL_MAGIC 'm'
#define MSMFB_GRP_DISP _IOW(MSMFB_IOCTL_MAGIC, 1, unsigned int)
#define MSMFB_BLIT _IOW(MSMFB_IOCTL_MAGIC, 2, unsigned int)
#define MSMFB_SUSPEND_SW_REFRESHER _IOW(MSMFB_IOCTL_MAGIC, 128, unsigned int)
#define MSMFB_RESUME_SW_REFRESHER _IOW(MSMFB_IOCTL_MAGIC, 129, unsigned int)
#define MSMFB_CURSOR _IOW(MSMFB_IOCTL_MAGIC, 130, struct fb_cursor)
#define MSMFB_SET_LUT _IOW(MSMFB_IOCTL_MAGIC, 131, struct fb_cmap)
#define MSMFB_HISTOGRAM _IOWR(MSMFB_IOCTL_MAGIC, 132, struct mdp_histogram)

#define MSMFB_GET_CCS_MATRIX _IOWR(MSMFB_IOCTL_MAGIC, 133, struct mdp_ccs)
#define MSMFB_SET_CCS_MATRIX _IOW(MSMFB_IOCTL_MAGIC, 134, struct mdp_ccs)
#define MSMFB_OVERLAY_SET _IOWR(MSMFB_IOCTL_MAGIC, 135,   struct mdp_overlay)
#define MSMFB_OVERLAY_UNSET _IOW(MSMFB_IOCTL_MAGIC, 136, unsigned int)
#define MSMFB_OVERLAY_PLAY _IOW(MSMFB_IOCTL_MAGIC, 137,   struct msmfb_overlay_data)
#define MSMFB_GET_PAGE_PROTECTION _IOR(MSMFB_IOCTL_MAGIC, 138,   struct mdp_page_protection)
#define MSMFB_SET_PAGE_PROTECTION _IOW(MSMFB_IOCTL_MAGIC, 139,   struct mdp_page_protection)
#define MSMFB_OVERLAY_GET _IOR(MSMFB_IOCTL_MAGIC, 140,   struct mdp_overlay)
#define MSMFB_OVERLAY_PLAY_ENABLE _IOW(MSMFB_IOCTL_MAGIC, 141, unsigned int)
#define MSMFB_OVERLAY_BLT _IOWR(MSMFB_IOCTL_MAGIC, 142,   struct msmfb_overlay_blt)
#define MSMFB_OVERLAY_BLT_OFFSET _IOW(MSMFB_IOCTL_MAGIC, 143, unsigned int)
#define MSMFB_HISTOGRAM_START _IO(MSMFB_IOCTL_MAGIC, 144)
#define MSMFB_HISTOGRAM_STOP _IO(MSMFB_IOCTL_MAGIC, 145)

#define MDP_IMGTYPE2_START 0x10000

enum {
 MDP_RGB_565,
 MDP_XRGB_8888,
 MDP_Y_CBCR_H2V2,
 MDP_ARGB_8888,
 MDP_RGB_888,
 MDP_Y_CRCB_H2V2,
 MDP_YCRYCB_H2V1,
 MDP_Y_CRCB_H2V1,
 MDP_Y_CBCR_H2V1,
 MDP_RGBA_8888,
 MDP_BGRA_8888,
 MDP_RGBX_8888,
 MDP_Y_CRCB_H2V2_TILE,
 MDP_Y_CBCR_H2V2_TILE,
 MDP_Y_CR_CB_H2V2,
 MDP_Y_CB_CR_H2V2,
 MDP_IMGTYPE_LIMIT,
 MDP_BGR_565 = MDP_IMGTYPE2_START,
 MDP_FB_FORMAT,
 MDP_IMGTYPE_LIMIT2
};

enum {
 PMEM_IMG,
 FB_IMG,
};

#define MDP_ROT_NOP 0
#define MDP_FLIP_LR 0x1
#define MDP_FLIP_UD 0x2
#define MDP_ROT_90 0x4
#define MDP_ROT_180 (MDP_FLIP_UD|MDP_FLIP_LR)
#define MDP_ROT_270 (MDP_ROT_90|MDP_FLIP_UD|MDP_FLIP_LR)
#define MDP_DITHER 0x8
#define MDP_BLUR 0x10
#define MDP_BLEND_FG_PREMULT 0x20000
#define MDP_DEINTERLACE 0x80000000
#define MDP_SHARPENING 0x40000000
#define MDP_NO_DMA_BARRIER_START 0x20000000
#define MDP_NO_DMA_BARRIER_END 0x10000000
#define MDP_NO_BLIT 0x08000000
#define MDP_BLIT_WITH_DMA_BARRIERS 0x000
#define MDP_BLIT_WITH_NO_DMA_BARRIERS   (MDP_NO_DMA_BARRIER_START | MDP_NO_DMA_BARRIER_END)
#define MDP_BLIT_SRC_GEM 0x04000000
#define MDP_BLIT_DST_GEM 0x02000000
#define MDP_BLIT_NON_CACHED 0x01000000
#define MDP_OV_PIPE_SHARE 0x00800000
#define MDP_DEINTERLACE_ODD 0x00400000
#define MDP_OV_PLAY_NOWAIT 0x00200000

#define MDP_TRANSP_NOP 0xffffffff
#define MDP_ALPHA_NOP 0xff

#define MDP_FB_PAGE_PROTECTION_NONCACHED (0)
#define MDP_FB_PAGE_PROTECTION_WRITECOMBINE (1)
#define MDP_FB_PAGE_PROTECTION_WRITETHROUGHCACHE (2)
#define MDP_FB_PAGE_PROTECTION_WRITEBACKCACHE (3)
#define MDP_FB_PAGE_PROTECTION_WRITEBACKWACACHE (4)

#define MDP_FB_PAGE_PROTECTION_INVALID (5)

#define MDP_NUM_FB_PAGE_PROTECTION_VALUES (5)

struct mdp_rect {
 uint32_t x;
 uint32_t y;
 uint32_t w;
 uint32_t h;
};

struct mdp_img {
 uint32_t width;
 uint32_t height;
 uint32_t format;
 uint32_t offset;
 int memory_id;
 uint32_t priv;
};

#define MDP_CCS_RGB2YUV 0
#define MDP_CCS_YUV2RGB 1

#define MDP_CCS_SIZE 9
#define MDP_BV_SIZE 3

struct mdp_ccs {
 int direction;
 uint16_t ccs[MDP_CCS_SIZE];
 uint16_t bv[MDP_BV_SIZE];
};

#define MDP_BLIT_REQ_VERSION 2

struct mdp_blit_req {
 struct mdp_img src;
 struct mdp_img dst;
 struct mdp_rect src_rect;
 struct mdp_rect dst_rect;
 uint32_t alpha;
 uint32_t transp_mask;
 uint32_t flags;
 int sharpening_strength;
};

struct mdp_blit_req_list {
 uint32_t count;
 struct mdp_blit_req req[];
};

#define MSMFB_DATA_VERSION 2

struct msmfb_data {
 uint32_t offset;
 int memory_id;
 int id;
 uint32_t flags;
 uint32_t priv;
};

#define MSMFB_NEW_REQUEST -1

struct msmfb_overlay_data {
 uint32_t id;
 struct msmfb_data data;
};

struct msmfb_img {
 uint32_t width;
 uint32_t height;
 uint32_t format;
};

struct mdp_overlay {
 struct msmfb_img src;
 struct mdp_rect src_rect;
 struct mdp_rect dst_rect;
 uint32_t z_order;
 uint32_t is_fg;
 uint32_t alpha;
 uint32_t transp_mask;
 uint32_t flags;
 uint32_t id;
 uint32_t user_data[8];
};

struct msmfb_overlay_blt {
 uint32_t enable;
 struct msmfb_data data;
};

struct mdp_histogram {
 uint32_t frame_cnt;
 uint32_t bin_cnt;
 uint32_t *r;
 uint32_t *g;
 uint32_t *b;
};

struct mdp_page_protection {
 uint32_t page_protection;
};

#endif

