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
#ifndef _NF_CONNTRACK_DCCP_H
#define _NF_CONNTRACK_DCCP_H

enum ct_dccp_states {
 CT_DCCP_NONE,
 CT_DCCP_REQUEST,
 CT_DCCP_RESPOND,
 CT_DCCP_PARTOPEN,
 CT_DCCP_OPEN,
 CT_DCCP_CLOSEREQ,
 CT_DCCP_CLOSING,
 CT_DCCP_TIMEWAIT,
 CT_DCCP_IGNORE,
 CT_DCCP_INVALID,
 __CT_DCCP_MAX
};
#define CT_DCCP_MAX (__CT_DCCP_MAX - 1)

enum ct_dccp_roles {
 CT_DCCP_ROLE_CLIENT,
 CT_DCCP_ROLE_SERVER,
 __CT_DCCP_ROLE_MAX
};
#define CT_DCCP_ROLE_MAX (__CT_DCCP_ROLE_MAX - 1)

#endif
