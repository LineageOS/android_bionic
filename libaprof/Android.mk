#
# libaprof implement the mcount function to enable generate profile
# by `-pg` option.
#

LOCAL_PATH:= $(call my-dir)

#
# There are stubs for functions only, they are actually defined
# in the dynamic linker (aprof.c), and hijacked at runtime.
#

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := debug

LOCAL_SRC_FILES := libaprof_runtime.cpp

LOCAL_SHARED_LIBRARIES := libdl liblog

LOCAL_MODULE := libaprof_runtime

include $(BUILD_SHARED_LIBRARY)


#
# libaprof
#
# The aprof can provide call graph and sample based profiling data
# for shared libraries, static libraries and executable.
#

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := debug

LOCAL_SRC_FILES := libaprof.cpp

LOCAL_MODULE := libaprof

LOCAL_SHARED_LIBRARIES := libaprof_runtime libc

include $(BUILD_SHARED_LIBRARY)

#
# libaprof for mcount
#

include $(CLEAR_VARS)

LOCAL_PRELINK_MODULE := false

LOCAL_MODULE_TAGS := debug

LOCAL_SRC_FILES := libaprof.cpp

LOCAL_MODULE:= libaprof

include $(BUILD_STATIC_LIBRARY)

#
# libaprof for JNI mode
#

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := debug

LOCAL_SRC_FILES := libaprof_jni.cpp

LOCAL_C_INCLUDES := bionic/libc/stdlib

LOCAL_MODULE:= libaprof_jni

include $(BUILD_STATIC_LIBRARY)

#
# libaprof runtime for JNI mode
#

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := debug

LOCAL_SRC_FILES := libaprof_jni_runtime.cpp

LOCAL_C_INCLUDES += \
	$(JNI_H_INCLUDE)

LOCAL_MODULE := libaprof_jni_runtime

LOCAL_SHARED_LIBRARIES := liblog libaprof_runtime

include $(BUILD_SHARED_LIBRARY)

#
# libaprof for static link executable
#
# Implment the simplified version for aprof_init, aprof_fini and aprof_mcount.
#

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := debug

LOCAL_SRC_FILES := libaprof_runtime.cpp

LOCAL_STATIC_LIBRARIES := libc liblog

LOCAL_CFLAGS := -DAPROF_STATIC

LOCAL_MODULE:= libaprof_static

include $(BUILD_STATIC_LIBRARY)

#
# libaprof-aux libraries for register constructor and destructor for aprof
#
include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := debug

LOCAL_SRC_FILES := libaprof_aux.cpp

LOCAL_C_INCLUDES := bionic/libc/stdlib

LOCAL_MODULE:= libaprof_aux

include $(BUILD_STATIC_LIBRARY)
