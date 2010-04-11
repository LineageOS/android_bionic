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
#ifndef _XT_TPROXY_H_target
#define _XT_TPROXY_H_target

struct xt_tproxy_target_info {
 u_int32_t mark_mask;
 u_int32_t mark_value;
 __be32 laddr;
 __be16 lport;
};

#endif
