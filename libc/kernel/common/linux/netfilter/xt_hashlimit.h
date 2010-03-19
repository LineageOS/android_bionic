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
#ifndef _XT_HASHLIMIT_H
#define _XT_HASHLIMIT_H

#include <linux/types.h>

#define XT_HASHLIMIT_SCALE 10000

struct xt_hashlimit_htable;

enum {
 XT_HASHLIMIT_HASH_DIP = 1 << 0,
 XT_HASHLIMIT_HASH_DPT = 1 << 1,
 XT_HASHLIMIT_HASH_SIP = 1 << 2,
 XT_HASHLIMIT_HASH_SPT = 1 << 3,
 XT_HASHLIMIT_INVERT = 1 << 4,
};

struct hashlimit_cfg {
 __u32 mode;
 __u32 avg;
 __u32 burst;

 __u32 size;
 __u32 max;
 __u32 gc_interval;
 __u32 expire;
};

struct xt_hashlimit_info {
 char name [IFNAMSIZ];
 struct hashlimit_cfg cfg;

 struct xt_hashlimit_htable *hinfo;
 union {
 void *ptr;
 struct xt_hashlimit_info *master;
 } u;
};

struct hashlimit_cfg1 {
 __u32 mode;
 __u32 avg;
 __u32 burst;

 __u32 size;
 __u32 max;
 __u32 gc_interval;
 __u32 expire;

 __u8 srcmask, dstmask;
};

struct xt_hashlimit_mtinfo1 {
 char name[IFNAMSIZ];
 struct hashlimit_cfg1 cfg;

 struct xt_hashlimit_htable *hinfo __attribute__((aligned(8)));
};

#endif
