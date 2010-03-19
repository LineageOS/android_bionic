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
#ifndef _NF_CONNTRACK_HELPER_H323_ASN1_H_
#define _NF_CONNTRACK_HELPER_H323_ASN1_H_

#include "nf_conntrack_h323_types.h"

typedef struct {
 enum {
 Q931_NationalEscape = 0x00,
 Q931_Alerting = 0x01,
 Q931_CallProceeding = 0x02,
 Q931_Connect = 0x07,
 Q931_ConnectAck = 0x0F,
 Q931_Progress = 0x03,
 Q931_Setup = 0x05,
 Q931_SetupAck = 0x0D,
 Q931_Resume = 0x26,
 Q931_ResumeAck = 0x2E,
 Q931_ResumeReject = 0x22,
 Q931_Suspend = 0x25,
 Q931_SuspendAck = 0x2D,
 Q931_SuspendReject = 0x21,
 Q931_UserInformation = 0x20,
 Q931_Disconnect = 0x45,
 Q931_Release = 0x4D,
 Q931_ReleaseComplete = 0x5A,
 Q931_Restart = 0x46,
 Q931_RestartAck = 0x4E,
 Q931_Segment = 0x60,
 Q931_CongestionCtrl = 0x79,
 Q931_Information = 0x7B,
 Q931_Notify = 0x6E,
 Q931_Status = 0x7D,
 Q931_StatusEnquiry = 0x75,
 Q931_Facility = 0x62
 } MessageType;
 H323_UserInformation UUIE;
} Q931;

#define H323_ERROR_NONE 0  
#define H323_ERROR_STOP 1  
#define H323_ERROR_BOUND -1
#define H323_ERROR_RANGE -2

#endif
