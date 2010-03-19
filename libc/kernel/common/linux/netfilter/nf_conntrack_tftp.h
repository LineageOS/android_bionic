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
#ifndef _NF_CONNTRACK_TFTP_H
#define _NF_CONNTRACK_TFTP_H

#define TFTP_PORT 69

struct tftphdr {
 __be16 opcode;
};

#define TFTP_OPCODE_READ 1
#define TFTP_OPCODE_WRITE 2
#define TFTP_OPCODE_DATA 3
#define TFTP_OPCODE_ACK 4
#define TFTP_OPCODE_ERROR 5

#endif
