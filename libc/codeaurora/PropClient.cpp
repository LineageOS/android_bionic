/*
 * Copyright (c) 2016, The Linux Foundation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above
 *     copyright notice, this list of conditions and the following
 *     disclaimer in the documentation and/or other materials provided
 *     with the distribution.
 *   * Neither the name of The Linux Foundation nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _PROPCLIENT_H_
#define _PROPCLIENT_H_

#ifdef LIBC_STATIC
#error PropClient.cpp should NOT be included in static libc builds.
#endif

#include "private/libc_logging.h"
#include <dlfcn.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include "codeaurora/PropClientDispatch.h"
#include "codeaurora/PropClientDispatchWrite.h"

static pthread_once_t propClientInitOnce = PTHREAD_ONCE_INIT;

template <typename FunctionType>
static void propClientInitFunction(void* handle, const char* symbol, FunctionType* function) {
    typedef void (*InitFunctionType)(FunctionType*);
    InitFunctionType initFunction = reinterpret_cast<InitFunctionType>(dlsym(handle, symbol));
    if (initFunction != NULL) {
        initFunction(function);
    }
}

static void propClientInitImpl() {

    void *propClientHandle = 0;
    typedef bool (*VendorExtFunctionType)();
    bool vendorExtFlag = false;
    propClientHandle = dlopen("libvendorconn.so", RTLD_NOW);

    if (propClientHandle != NULL) {
        VendorExtFunctionType vendorExtFunction = reinterpret_cast<VendorExtFunctionType>(dlsym(propClientHandle, "isVendorExtAvailable"));
        if( vendorExtFunction ) {
            vendorExtFlag = vendorExtFunction();
        }
        if( !vendorExtFlag || !vendorExtFunction ) {
            dlclose(propClientHandle);
            propClientHandle = NULL;
            return;
        }
    } else {
        // If the library is not available, it's not an error. We'll just use
        // default implementations of functions that it would've overridden.
        return;
    }

    propClientInitFunction(propClientHandle, "propClientInitSocket", &__propClientDispatch.propSocket);

    propClientInitFunction(propClientHandle, "propClientInitConnect", &__propClientDispatch.propConnect);

    propClientInitFunction(propClientHandle, "propClientInitWrite", &__propClientDispatchWrite.propWrite);

    propClientInitFunction(propClientHandle, "propClientInitWritev", &__propClientDispatchWrite.propWritev);

    propClientInitFunction(propClientHandle, "propClientInitSendmsg", &__propClientDispatchWrite.propSendmsg);

    propClientInitFunction(propClientHandle, "propClientInitSendto", &__propClientDispatchWrite.propSendto);

    propClientInitFunction(propClientHandle, "propClientInitGetHostByNameForNet", &__propClientDispatch.propGetHostByNameForNet);

    propClientInitFunction(propClientHandle, "propClientInitGetHostByAddrForNet", &__propClientDispatch.propGetHostByAddrForNet);

    propClientInitFunction(propClientHandle, "propClientInitGetAddrInfoForNet", &__propClientDispatch.propGetAddrInfoForNet);

    propClientInitFunction(propClientHandle, "propClientInitSendDnsReport", &__propClientDispatch.propSendDnsReport);

    propClientInitFunction(propClientHandle, "propClientInitClose", &__propClientDispatch.propClose);
}

extern "C" __LIBC_HIDDEN__ void propClientInit() {
    if (pthread_once(&propClientInitOnce, propClientInitImpl)) {
        __libc_format_log(ANDROID_LOG_ERROR, "propClient", "Failed to initialize prop_client");
    }
}

#endif /* !_PROPCLIENT_H_ */
