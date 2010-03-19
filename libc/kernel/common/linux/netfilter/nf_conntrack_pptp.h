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
#ifndef _NF_CONNTRACK_PPTP_H
#define _NF_CONNTRACK_PPTP_H

#include <linux/netfilter/nf_conntrack_common.h>

enum pptp_ctrlsess_state {
 PPTP_SESSION_NONE,
 PPTP_SESSION_ERROR,
 PPTP_SESSION_STOPREQ,
 PPTP_SESSION_REQUESTED,
 PPTP_SESSION_CONFIRMED,
};

enum pptp_ctrlcall_state {
 PPTP_CALL_NONE,
 PPTP_CALL_ERROR,
 PPTP_CALL_OUT_REQ,
 PPTP_CALL_OUT_CONF,
 PPTP_CALL_IN_REQ,
 PPTP_CALL_IN_REP,
 PPTP_CALL_IN_CONF,
 PPTP_CALL_CLEAR_REQ,
};

struct nf_ct_pptp_master {
 enum pptp_ctrlsess_state sstate;
 enum pptp_ctrlcall_state cstate;
 __be16 pac_call_id;
 __be16 pns_call_id;

 struct nf_ct_gre_keymap *keymap[IP_CT_DIR_MAX];
};

struct nf_nat_pptp {
 __be16 pns_call_id;
 __be16 pac_call_id;
};

#endif
