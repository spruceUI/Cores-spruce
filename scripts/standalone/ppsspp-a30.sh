#!/usr/bin/env bash
# ppsspp-a30: cores-experimental standalone recipe ppsspp-a30 (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-armhf:v1 (archive cores-standalone-armhf-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1776009930
export LC_ALL=C.UTF-8
umask 022
export CROSS=arm-a30-linux-gnueabihf SOURCE=/build/ppsspp BUILD_DIR=/tmp/standalone-build DIST=/output/dist
git clone --filter=blob:none --no-checkout https://github.com/hrydgard/ppsspp.git /build/ppsspp
git -C /build/ppsspp checkout -q d357e6a32934800d3d80b49f910a603e1b069751
test "$(git -C /build/ppsspp rev-parse 'HEAD^{tree}')" = 398ebc8529b78bb1773dafdca7bb7ab6e97dc5ec
git -C /build/ppsspp submodule update --init --recursive --depth 1 -q
git -C /build/ppsspp rev-parse HEAD > /output/source-commit.txt
git -C /build/ppsspp apply --check /work/patches/ppsspp/common-1-fullscreen.patch
git -C /build/ppsspp apply /work/patches/ppsspp/common-1-fullscreen.patch
git -C /build/ppsspp apply --check /work/patches/ppsspp/common-2-hide-cursor.patch
git -C /build/ppsspp apply /work/patches/ppsspp/common-2-hide-cursor.patch
git -C /build/ppsspp apply --check /work/patches/ppsspp/common-3-no-mute-secondary.patch
git -C /build/ppsspp apply /work/patches/ppsspp/common-3-no-mute-secondary.patch
git -C /build/ppsspp apply --check /work/patches/ppsspp/common-4-remap-pause-menu.patch
git -C /build/ppsspp apply /work/patches/ppsspp/common-4-remap-pause-menu.patch
git -C /build/ppsspp apply --check /work/patches/ppsspp/common-5-sigusr1-save-and-quit.patch
git -C /build/ppsspp apply /work/patches/ppsspp/common-5-sigusr1-save-and-quit.patch
git -C /build/ppsspp apply --check /work/patches/ppsspp/common-6-sigusr2-toggle-pause-menu.patch
git -C /build/ppsspp apply /work/patches/ppsspp/common-6-sigusr2-toggle-pause-menu.patch
git -C /build/ppsspp apply --check /work/patches/ppsspp/common-7-skip-vulkan-probe.patch
git -C /build/ppsspp apply /work/patches/ppsspp/common-7-skip-vulkan-probe.patch
git -C /build/ppsspp apply --check /work/patches/ppsspp/a30-1-display-rotation.patch
git -C /build/ppsspp apply /work/patches/ppsspp/a30-1-display-rotation.patch
git -C /build/ppsspp apply --check /work/patches/ppsspp/a30-2-pause-menu-compact.patch
git -C /build/ppsspp apply /work/patches/ppsspp/a30-2-pause-menu-compact.patch
cd /build/ppsspp
set +u +o pipefail
cd /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib && ln -sf libSDL2-2.0.so.0.2800.5 libSDL2.so && ln -sf libMali.so libEGL.so && ln -sf libMali.so libGLESv2.so && ln -sf libasound.so.2.0.0 libasound.so && ln -sf libfreetype.so.6.20.1 libfreetype.so
printf '%s\n' 'set(CMAKE_SYSTEM_NAME Linux)' 'set(CMAKE_SYSTEM_PROCESSOR arm)' 'set(CMAKE_C_COMPILER /opt/a30/bin/arm-a30-linux-gnueabihf-gcc)' 'set(CMAKE_CXX_COMPILER /opt/a30/bin/arm-a30-linux-gnueabihf-g++)' 'set(CMAKE_SYSROOT /opt/a30/arm-a30-linux-gnueabihf/sysroot)' 'set(CMAKE_FIND_ROOT_PATH /opt/a30/arm-a30-linux-gnueabihf/sysroot)' 'set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)' 'set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)' 'set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)' 'set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)' 'set(PKG_CONFIG_EXECUTABLE /usr/bin/pkg-config)' 'set(ENV{PKG_CONFIG_SYSROOT_DIR} "/opt/a30/arm-a30-linux-gnueabihf/sysroot")' 'set(ENV{PKG_CONFIG_LIBDIR} "/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/pkgconfig")' 'set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)' > /tmp/a30-toolchain.cmake
printf '%s\n' '#include <stdarg.h>' '#include <fcntl.h>' 'int fcntl64(int fd, int cmd, ...) {' '    va_list ap;' '    va_start(ap, cmd);' '    void *arg = va_arg(ap, void *);' '    va_end(ap);' '    return fcntl(fd, cmd, arg);' '}' > /tmp/fcntl64_compat.c
arm-a30-linux-gnueabihf-gcc -c /tmp/fcntl64_compat.c -o /tmp/fcntl64_compat.o -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard
arm-a30-linux-gnueabihf-ar rcs /tmp/libfcntl64_compat.a /tmp/fcntl64_compat.o
mkdir -p /build/ppsspp/build && cd /build/ppsspp/build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/tmp/a30-toolchain.cmake -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache "-DCMAKE_C_FLAGS=-Ofast -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -ffunction-sections -fdata-sections -fomit-frame-pointer -flto=auto -Wno-error -DHWCAP2_AES=1 -DHWCAP2_SHA1=4 -DHWCAP2_SHA2=8 -DHWCAP2_CRC32=16" "-DCMAKE_CXX_FLAGS=-Ofast -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -ffunction-sections -fdata-sections -fomit-frame-pointer -flto=auto -Wno-error" "-DCMAKE_EXE_LINKER_FLAGS=-Wl,--gc-sections -static-libstdc++ -L/tmp -Wl,--whole-archive -lfcntl64_compat -Wl,--no-whole-archive -flto=auto" -DUSING_GLES2=ON -DUSING_EGL=OFF -DUSING_FBDEV=ON -DVULKAN=OFF -DUSING_X11_VULKAN=OFF -DUSE_WAYLAND_WSI=OFF -DBUILD_SHARED_LIBS=OFF -DUSE_SYSTEM_LIBPNG=OFF -DUSE_SYSTEM_FFMPEG=OFF -DUSE_DISCORD=OFF -DUSE_MINIUPNPC=OFF -DHEADLESS=OFF -DUNITTEST=OFF -DCMAKE_DISABLE_FIND_PACKAGE_SDL2_ttf=ON -DCMAKE_DISABLE_FIND_PACKAGE_Fontconfig=ON -DCMAKE_DISABLE_FIND_PACKAGE_X11=ON -DARM=ON -DARMV7=ON -DUSING_ARM_NEON=ON
find . \( -name 'flags.make' -o -name 'build.ninja' \) -exec sed -i 's|-isystem |-I|g' {} +
make -j"$(nproc)" PPSSPPSDL
mkdir -p /output/dist
install -D -m 0755 /build/ppsspp/build/PPSSPPSDL /output/dist/PPSSPPSDL_A30
arm-a30-linux-gnueabihf-strip -s /output/dist/PPSSPPSDL_A30
mkdir -p "$(dirname /output/dist/assets)"
cp -a /build/ppsspp/assets /output/dist/assets
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if arm-a30-linux-gnueabihf-readelf -h "$file" >/dev/null 2>&1; then
    arm-a30-linux-gnueabihf-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
