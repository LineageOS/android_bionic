libc_bionic_src_files_arm += \
    arch-arm/krait/bionic/strcmp.S \
    arch-arm/krait/bionic/__strcat_chk.S \
    arch-arm/krait/bionic/__strcpy_chk.S \

# Memset from A53/A7
libc_bionic_src_files_arm += \
    arch-arm/cortex-a7/bionic/memset.S

# Memmove from Denver
libc_bionic_src_files_arm += \
    arch-arm/denver/bionic/memmove.S

# Krait optimized memcpy brings the best metrics on kryo
libc_bionic_src_files_arm += \
    arch-arm/krait/bionic/memcpy.S

# Use cortex-a15 versions of strcat/strcpy/strlen
libc_bionic_src_files_arm += \
    arch-arm/cortex-a15/bionic/stpcpy.S \
    arch-arm/cortex-a15/bionic/strcat.S \
    arch-arm/cortex-a15/bionic/strcpy.S \
    arch-arm/cortex-a15/bionic/strlen.S \

libc_bionic_src_files_arm += \
    arch-arm/generic/bionic/memchr.S \
    arch-arm/generic/bionic/memcmp.S \


