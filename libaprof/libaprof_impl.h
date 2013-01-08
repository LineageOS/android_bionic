#ifndef _LIBAPROF_IMPL_H
#define _LIBAPROF_IMPL_H

#define LOG_TAG "aprof"
#include <utils/Log.h>

extern "C" {

void aprof_init(void *module_address);
void aprof_fini(void *module_address);
void aprof_mcount(uintptr_t frompc, uintptr_t selfpc);
void aprof_control(int c);

}
#define ERROR(x...) ALOGE(x)

#ifdef APROF_DEBUG
#define DEBUG(x...) ALOGV(x)
#else
#define DEBUG(x...)
#endif

#endif /* _LIBAPROF_IMPL_H */
