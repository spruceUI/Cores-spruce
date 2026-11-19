#!/usr/bin/env bash
# vtree-a30: cores-experimental standalone recipe vtree-a30 (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-armhf:v1 (archive cores-standalone-armhf-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1776744729
export LC_ALL=C.UTF-8
umask 022
export CROSS=arm-a30-linux-gnueabihf SOURCE=/build/vtree BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export CC=arm-a30-linux-gnueabihf-gcc
export CXX=arm-a30-linux-gnueabihf-g++
export AR=arm-a30-linux-gnueabihf-ar
export STRIP=arm-a30-linux-gnueabihf-strip
export PKG_CONFIG_PATH=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/pkgconfig
export PKG_CONFIG_LIBDIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot
git clone --filter=blob:none --no-checkout https://github.com/MustardOS/vtree.git /build/vtree
git -C /build/vtree checkout -q 560205b6198ac9e0e28975d42fcaee4c28989015
test "$(git -C /build/vtree rev-parse 'HEAD^{tree}')" = 8c9a367d5c97f4011f81807b5c3f36a011cb9276
git -C /build/vtree rev-parse HEAD > /output/source-commit.txt
git clone --filter=blob:none --no-checkout https://github.com/libsdl-org/SDL_ttf.git /build/SDL_ttf
git -C /build/SDL_ttf checkout -q 4a318f8dfaa1bb6f10e0c5e54052e25d3c7f3440
test "$(git -C /build/SDL_ttf rev-parse 'HEAD^{tree}')" = 6c0753a1d7b377fe988f018c2e0ca9186d341133
git clone --filter=blob:none --no-checkout https://github.com/libsdl-org/SDL_image.git /build/SDL_image
git -C /build/SDL_image checkout -q abcf63aa71b4e3ac32120fa9870a6500ddcdcc89
test "$(git -C /build/SDL_image rev-parse 'HEAD^{tree}')" = bfc0eb8d1a8d8e5f1b4aa1e4c494655972b3a045
git -C /build/vtree apply --check /work/patches/vtree/0001-nintendo-button-labels.patch
git -C /build/vtree apply /work/patches/vtree/0001-nintendo-button-labels.patch
cd /build/vtree
set +u +o pipefail
cd /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib && ln -sf libSDL2-2.0.so.0.2800.5 libSDL2.so && ln -sf libfreetype.so.6.20.1 libfreetype.so
SYSROOT=/opt/a30/arm-a30-linux-gnueabihf/sysroot PREFIX=/build/local && mkdir -p "$PREFIX"
CFLAGS_COMMON="-O2 --sysroot=$SYSROOT -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -fomit-frame-pointer -ffunction-sections -fdata-sections"
LDFLAGS_COMMON="--sysroot=$SYSROOT -L$SYSROOT/usr/lib -Wl,--gc-sections"
mkdir -p /build/SDL_ttf/build && cd /build/SDL_ttf/build
cmake .. -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=arm -DCMAKE_C_COMPILER=arm-a30-linux-gnueabihf-gcc "-DCMAKE_FIND_ROOT_PATH=$SYSROOT;$PREFIX" -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER "-DCMAKE_PREFIX_PATH=$SYSROOT/usr;$PREFIX" "-DCMAKE_INSTALL_PREFIX=$PREFIX" -DCMAKE_BUILD_TYPE=Release "-DCMAKE_C_FLAGS=$CFLAGS_COMMON" "-DCMAKE_EXE_LINKER_FLAGS=$LDFLAGS_COMMON" "-DCMAKE_SHARED_LINKER_FLAGS=$LDFLAGS_COMMON" -DSDL2TTF_VENDORED=OFF -DSDL2TTF_SAMPLES=OFF
make -j"$(nproc)" && make install
mkdir -p /build/SDL_image/build && cd /build/SDL_image/build
cmake .. -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=arm -DCMAKE_C_COMPILER=arm-a30-linux-gnueabihf-gcc "-DCMAKE_FIND_ROOT_PATH=$SYSROOT;$PREFIX" -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER "-DCMAKE_PREFIX_PATH=$SYSROOT/usr;$PREFIX" "-DCMAKE_INSTALL_PREFIX=$PREFIX" -DCMAKE_BUILD_TYPE=Release "-DCMAKE_C_FLAGS=$CFLAGS_COMMON" "-DCMAKE_EXE_LINKER_FLAGS=$LDFLAGS_COMMON" "-DCMAKE_SHARED_LINKER_FLAGS=$LDFLAGS_COMMON" -DSDL2IMAGE_VENDORED=ON -DSDL2IMAGE_SAMPLES=OFF -DSDL2IMAGE_TESTS=OFF
make -j"$(nproc)" && make install
cd /build/vtree
printf '%s\n' '#ifndef SDL_clamp' '#define SDL_clamp(x, a, b) (((x) < (a)) ? (a) : (((x) > (b)) ? (b) : (x)))' '#endif' > sdl_compat.h
SDL_CFLAGS="-I$SYSROOT/usr/include -I$SYSROOT/usr/include/SDL2 -I$PREFIX/include -I$PREFIX/include/SDL2 -D_REENTRANT -include ./sdl_compat.h"
make release CC=arm-a30-linux-gnueabihf-gcc SDL2_CFLAGS="$SDL_CFLAGS" SDL2_LIBS="-L$PREFIX/lib -lSDL2_ttf -lSDL2_image -lSDL2 -lm" CFLAGS_REL="-Wall -Wextra -std=c99 $SDL_CFLAGS -DSDL_MAIN_HANDLED -D_POSIX_C_SOURCE=200809L -O2 -DNDEBUG $CFLAGS_COMMON"
mkdir -p /output/dist
install -D -m 0755 /build/vtree/vtree /output/dist/vtree.a30
arm-a30-linux-gnueabihf-strip -s /output/dist/vtree.a30
install -D -m 0755 /build/local/lib/libSDL2_ttf-2.0.so.0 /output/dist/lib-A30/libSDL2_ttf-2.0.so.0
arm-a30-linux-gnueabihf-strip -s /output/dist/lib-A30/libSDL2_ttf-2.0.so.0
install -D -m 0755 /build/local/lib/libSDL2_image-2.0.so.0 /output/dist/lib-A30/libSDL2_image-2.0.so.0
arm-a30-linux-gnueabihf-strip -s /output/dist/lib-A30/libSDL2_image-2.0.so.0
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if arm-a30-linux-gnueabihf-readelf -h "$file" >/dev/null 2>&1; then
    arm-a30-linux-gnueabihf-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
