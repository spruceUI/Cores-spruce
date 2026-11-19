#!/usr/bin/env bash
# vtree-arm64: cores-experimental standalone recipe vtree-arm64 (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-vtree:v1 (archive cores-standalone-vtree-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1776730893
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/src BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig
export PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig
git clone --filter=blob:none --no-checkout https://github.com/MustardOS/vtree.git /src
git -C /src checkout -q 560205b6198ac9e0e28975d42fcaee4c28989015
test "$(git -C /src rev-parse 'HEAD^{tree}')" = 8c9a367d5c97f4011f81807b5c3f36a011cb9276
git -C /src rev-parse HEAD > /output/source-commit.txt
git -C /src apply --check /work/patches/vtree/0001-nintendo-button-labels.patch
git -C /src apply /work/patches/vtree/0001-nintendo-button-labels.patch
git -C /src apply --check /work/patches/vtree/0002-rgb30-gles-context.patch
git -C /src apply /work/patches/vtree/0002-rgb30-gles-context.patch
cd /src
printf '%s\n' '#ifndef SDL_clamp' '#define SDL_clamp(x, a, b) (((x) < (a)) ? (a) : (((x) > (b)) ? (b) : (x)))' '#endif' > sdl_compat.h
make release CC=aarch64-linux-gnu-gcc SDL2_CFLAGS="$(pkg-config --cflags sdl2 SDL2_ttf SDL2_image) -include ./sdl_compat.h"
mkdir -p /output/dist
install -D -m 0755 /src/vtree /output/dist/vtree.aarch64
aarch64-linux-gnu-strip -s /output/dist/vtree.aarch64
mkdir -p "$(dirname /output/dist/res)"
cp -a /src/res /output/dist/res
mkdir -p "$(dirname /output/dist/fonts)"
cp -a /src/fonts /output/dist/fonts
mkdir -p "$(dirname /output/dist/glyph)"
cp -a /src/glyph /output/dist/glyph
mkdir -p "$(dirname /output/dist/lang)"
cp -a /src/lang /output/dist/lang
mkdir -p "$(dirname /output/dist/theme)"
cp -a /src/theme /output/dist/theme
install -D -m 0644 /src/config.ini /output/dist/config.ini
install -D -m 0644 /src/mux_lang.ini /output/dist/mux_lang.ini
install -D -m 0644 /src/LICENSE /output/dist/LICENSE
install -D -m 0644 /src/README.md /output/dist/README.md
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
