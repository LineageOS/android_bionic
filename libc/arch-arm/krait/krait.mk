libc_bionic_src_files_arm += \
    arch-arm/krait/bionic/memset.S \
    arch-arm/krait/bionic/strcmp.S \
    arch-arm/krait/bionic/__strcat_chk.S \
    arch-arm/krait/bionic/__strcpy_chk.S \
    arch-arm/krait/bionic/memmove.S

#For some targets we don't need this optimization.
#Corresponding flag is defined in device specific folder.
ifeq ($(TARGET_CPU_MEMCPY_BASE_OPT_DISABLE),true)
libc_bionic_src_files_arm += \
    arch-arm/cortex-a15/bionic/memcpy.S
else
libc_bionic_src_files_arm += \
    arch-arm/krait/bionic/memcpy.S
endif

# Use cortex-a15 versions of strcat/strcpy/strlen and standard memmove
libc_bionic_src_files_arm += \
    arch-arm/cortex-a15/bionic/stpcpy.S \
    arch-arm/cortex-a15/bionic/strcat.S \
    arch-arm/cortex-a15/bionic/strcpy.S \
    arch-arm/cortex-a15/bionic/strlen.S \

libc_bionic_src_files_arm += \
    arch-arm/generic/bionic/memchr.S \
    arch-arm/generic/bionic/memcmp.S \


