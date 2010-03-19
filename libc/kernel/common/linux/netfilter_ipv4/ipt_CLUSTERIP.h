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
#ifndef _IPT_CLUSTERIP_H_target
#define _IPT_CLUSTERIP_H_target

enum clusterip_hashmode {
 CLUSTERIP_HASHMODE_SIP = 0,
 CLUSTERIP_HASHMODE_SIP_SPT,
 CLUSTERIP_HASHMODE_SIP_SPT_DPT,
};

#define CLUSTERIP_HASHMODE_MAX CLUSTERIP_HASHMODE_SIP_SPT_DPT

#define CLUSTERIP_MAX_NODES 16

#define CLUSTERIP_FLAG_NEW 0x00000001

struct clusterip_config;

struct ipt_clusterip_tgt_info {

 u_int32_t flags;

 u_int8_t clustermac[6];
 u_int16_t num_total_nodes;
 u_int16_t num_local_nodes;
 u_int16_t local_nodes[CLUSTERIP_MAX_NODES];
 u_int32_t hash_mode;
 u_int32_t hash_initval;

 struct clusterip_config *config;
};

#endif
