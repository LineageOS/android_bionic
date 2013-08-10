$(call libc-add-cpu-variant-src,MEMCPY,arch-arm/generic/bionic/memcpy.S)
$(call libc-add-cpu-variant-src,MEMSET,arch-arm/generic/bionic/memset.S)
$(call libc-add-cpu-variant-src,STRCMP,arch-arm/generic/bionic/strcmp.S)
ifeq ($(ARCH_ARM_HAVE_NEON),true)
$(call libc-add-cpu-variant-src,MEMMOVE,arch-arm/generic/bionic/memmove.S)
else
$(call libc-add-cpu-variant-src,MEMMOVE,bionic/memmove.c.arm)
$(call libc-add-cpu-variant-src,BCOPY,string/bcopy.c.arm)
endif
$(call libc-add-cpu-variant-src,STRLEN,arch-arm/generic/bionic/strlen.c)
