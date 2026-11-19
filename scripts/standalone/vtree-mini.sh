#!/usr/bin/env bash
# vtree-mini: cores-experimental standalone recipe vtree-mini (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-miyoomini:v1 (archive cores-standalone-miyoomini-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1776744729
export LC_ALL=C.UTF-8
umask 022
export CROSS=arm-linux-gnueabihf SOURCE=/build/vtree BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export CC=arm-linux-gnueabihf-gcc
export STRIP=arm-linux-gnueabihf-strip
git clone --filter=blob:none --no-checkout https://github.com/MustardOS/vtree.git /build/vtree
git -C /build/vtree checkout -q 560205b6198ac9e0e28975d42fcaee4c28989015
test "$(git -C /build/vtree rev-parse 'HEAD^{tree}')" = 8c9a367d5c97f4011f81807b5c3f36a011cb9276
git -C /build/vtree rev-parse HEAD > /output/source-commit.txt
git clone --filter=blob:none --no-checkout https://github.com/libsdl-org/SDL.git /tmp/SDL_src
git -C /tmp/SDL_src checkout -q 9c821dc21ccbd69b2bda421fdb35cb4ae2da8f5e
test "$(git -C /tmp/SDL_src rev-parse 'HEAD^{tree}')" = 8ee44e4aa6c3508e99a596d4c09875d3313657f6
git clone --filter=blob:none --no-checkout https://github.com/libsdl-org/SDL_ttf.git /tmp/SDL_ttf_src
git -C /tmp/SDL_ttf_src checkout -q 4a318f8dfaa1bb6f10e0c5e54052e25d3c7f3440
test "$(git -C /tmp/SDL_ttf_src rev-parse 'HEAD^{tree}')" = 6c0753a1d7b377fe988f018c2e0ca9186d341133
git clone --filter=blob:none --no-checkout https://github.com/libsdl-org/SDL_image.git /tmp/SDL_image_src
git -C /tmp/SDL_image_src checkout -q abcf63aa71b4e3ac32120fa9870a6500ddcdcc89
test "$(git -C /tmp/SDL_image_src rev-parse 'HEAD^{tree}')" = bfc0eb8d1a8d8e5f1b4aa1e4c494655972b3a045
mkdir -p "$(dirname /opt/spruce-mini-libs/libSDL2-2.0.so.0)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://raw.githubusercontent.com/spruceUI/spruceOS/3d270cca68360c16a501f315a12da4a0a902f033/spruce/miyoomini/lib/libSDL2-2.0.so.0 /opt/spruce-mini-libs/libSDL2-2.0.so.0
echo 'f55f2f1a092e3f1d99966b82dc3f07372d16b3f8ac2a14a021fb7d291ef71f54  /opt/spruce-mini-libs/libSDL2-2.0.so.0' | sha256sum -c -
mkdir -p "$(dirname /opt/spruce-mini-libs/libSDL2_ttf-2.0.so.0)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://raw.githubusercontent.com/spruceUI/spruceOS/3d270cca68360c16a501f315a12da4a0a902f033/spruce/miyoomini/lib/libSDL2_ttf-2.0.so.0 /opt/spruce-mini-libs/libSDL2_ttf-2.0.so.0
echo 'b56f3b6ded400854408ff09bd8db0dd9d4e9fcc7300a628a4354277973101da3  /opt/spruce-mini-libs/libSDL2_ttf-2.0.so.0' | sha256sum -c -
mkdir -p "$(dirname /opt/spruce-mini-libs/libSDL2_image-2.0.so.0)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://raw.githubusercontent.com/spruceUI/spruceOS/3d270cca68360c16a501f315a12da4a0a902f033/spruce/miyoomini/lib/libSDL2_image-2.0.so.0 /opt/spruce-mini-libs/libSDL2_image-2.0.so.0
echo '6f46901b2655fbeba738a7e20ed2eca646111035e58472b04ddaad27deef4cb8  /opt/spruce-mini-libs/libSDL2_image-2.0.so.0' | sha256sum -c -
git -C /build/vtree apply --check /work/patches/vtree/0001-nintendo-button-labels.patch
git -C /build/vtree apply /work/patches/vtree/0001-nintendo-button-labels.patch
git -C /build/vtree apply --check /work/patches/vtree/miyoomini-1-kbd-to-controller.patch
git -C /build/vtree apply /work/patches/vtree/miyoomini-1-kbd-to-controller.patch
cd /build/vtree
set +u +o pipefail
cd /opt/spruce-mini-libs && ln -sf libSDL2-2.0.so.0 libSDL2.so && ln -sf libSDL2_ttf-2.0.so.0 libSDL2_ttf.so && ln -sf libSDL2_image-2.0.so.0 libSDL2_image.so
PREFIX=/build/local SPRUCE_LIBS=/opt/spruce-mini-libs && mkdir -p "$PREFIX/include/SDL2"
cp /tmp/SDL_src/include/*.h "$PREFIX/include/SDL2/" && cp /tmp/SDL_src/include/SDL_config_minimal.h "$PREFIX/include/SDL2/SDL_config.h"
cp /tmp/SDL_ttf_src/SDL_ttf.h "$PREFIX/include/SDL2/"
cp /tmp/SDL_image_src/include/SDL_image.h "$PREFIX/include/SDL2/" 2>/dev/null || cp /tmp/SDL_image_src/SDL_image.h "$PREFIX/include/SDL2/"
cd /build/vtree
printf '%s\n' '#include <stdio.h>' '#ifndef SDL_clamp' '#define SDL_clamp(x, a, b) (((x) < (a)) ? (a) : (((x) > (b)) ? (b) : (x)))' '#endif' > sdl_compat.h
CFLAGS_COMMON="-O2 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -fomit-frame-pointer -ffunction-sections -fdata-sections"
SDL_CFLAGS="-I$PREFIX/include -I$PREFIX/include/SDL2 -D_REENTRANT -include ./sdl_compat.h"
make release CC=arm-linux-gnueabihf-gcc SDL2_CFLAGS="$SDL_CFLAGS" SDL2_LIBS="-L$SPRUCE_LIBS -Wl,-rpath-link,$SPRUCE_LIBS -lSDL2_ttf -lSDL2_image -lSDL2 -lm" CFLAGS_REL="-Wall -Wextra -std=c99 $SDL_CFLAGS -DSDL_MAIN_HANDLED -D_POSIX_C_SOURCE=200809L -O2 -DNDEBUG $CFLAGS_COMMON" LDFLAGS_REL="-Wl,--gc-sections -Wl,--allow-shlib-undefined"
mkdir -p /output/dist
install -D -m 0755 /build/vtree/vtree /output/dist/vtree.mini
arm-linux-gnueabihf-strip -s /output/dist/vtree.mini
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if arm-linux-gnueabihf-readelf -h "$file" >/dev/null 2>&1; then
    arm-linux-gnueabihf-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
