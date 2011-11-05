#ifndef __DNSPROXYD_LOCK
#define __DNSPROXYD_LOCK

#include <pthread.h>

/*
 * Since there can be multiple processes and threads trying to call getaddrinfo
 * and gethostbyaddr, but the proxy tries to use /dev/socket/dnsproxyd, this
 * mutex should be used to prevent these threads from using the same thread at
 * the same time.
 */

static pthread_mutex_t dnsproxyd_lock = PTHREAD_MUTEX_INITIALIZER;

#endif
