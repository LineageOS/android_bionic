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
#ifndef _XT_SECMARK_H_target
#define _XT_SECMARK_H_target

#include <linux/types.h>

#define SECMARK_MODE_SEL 0x01  
#define SECMARK_SELCTX_MAX 256

struct xt_secmark_target_selinux_info {
 __u32 selsid;
 char selctx[SECMARK_SELCTX_MAX];
};

struct xt_secmark_target_info {
 __u8 mode;
 union {
 struct xt_secmark_target_selinux_info sel;
 } u;
};

#endif
