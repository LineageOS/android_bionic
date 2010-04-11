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
#ifndef _IPT_ADDRTYPE_H
#define _IPT_ADDRTYPE_H

enum {
 IPT_ADDRTYPE_INVERT_SOURCE = 0x0001,
 IPT_ADDRTYPE_INVERT_DEST = 0x0002,
 IPT_ADDRTYPE_LIMIT_IFACE_IN = 0x0004,
 IPT_ADDRTYPE_LIMIT_IFACE_OUT = 0x0008,
};

struct ipt_addrtype_info_v1 {
 u_int16_t source;
 u_int16_t dest;
 u_int32_t flags;
};

struct ipt_addrtype_info {
 u_int16_t source;
 u_int16_t dest;
 u_int32_t invert_source;
 u_int32_t invert_dest;
};

#endif
