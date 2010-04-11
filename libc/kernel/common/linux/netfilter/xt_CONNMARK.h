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
#ifndef _XT_CONNMARK_H_target
#define _XT_CONNMARK_H_target

#include <linux/types.h>

enum {
 XT_CONNMARK_SET = 0,
 XT_CONNMARK_SAVE,
 XT_CONNMARK_RESTORE
};

struct xt_connmark_tginfo1 {
 __u32 ctmark, ctmask, nfmask;
 __u8 mode;
};

#endif
