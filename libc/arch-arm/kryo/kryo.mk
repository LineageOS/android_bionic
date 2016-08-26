libc_bionic_src_files_arm += \
    arch-arm/krait/bionic/strcmp.S \
    bionic/__strcat_chk.cpp \
    bionic/__strcpy_chk.cpp \

# Memset from A53/A7
libc_bionic_src_files_arm += \
    arch-arm/cortex-a7/bionic/memset.S

libc_bionic_src_files_arm += \
    arch-arm/kryo/bionic/memcpy.S \
    arch-arm/kryo/bionic/memmove.S

# Use cortex-a15 versions of strcat/strcpy/strlen
libc_bionic_src_files_arm += \
    arch-arm/cortex-a15/bionic/stpcpy.S \
    arch-arm/cortex-a15/bionic/strcat.S \
    arch-arm/cortex-a15/bionic/strcpy.S \
    arch-arm/cortex-a15/bionic/strlen.S \

libc_bionic_src_files_arm += \
    arch-arm/generic/bionic/memchr.S \
    arch-arm/generic/bionic/memcmp.S \
