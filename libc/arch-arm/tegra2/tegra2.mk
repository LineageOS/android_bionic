$(call libc-add-cpu-variant-src,MEMCPY,arch-arm/tegra2/bionic/memcpy.S)
$(call libc-add-cpu-variant-src,MEMSET,arch-arm/tegra2/bionic/memset.S)
$(call libc-add-cpu-variant-src,STRCMP,arch-arm/tegra2/bionic/strcmp.S)
$(call libc-add-cpu-variant-src,MEMMOVE,bionic/memmove.c.arm)
$(call libc-add-cpu-variant-src,BCOPY,string/bcopy.c.arm)

# armv7-a (non neon) ones from cm10.1
$(call libc-add-cpu-variant-src,STRLEN,arch-arm/tegra2/bionic/strlen.S)
$(call libc-add-cpu-variant-src,MEMCHR,arch-arm/tegra2/bionic/memchr.S)

