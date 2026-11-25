#!/usr/bin/env bash
# advmame-arm64-20260328: cores-experimental standalone recipe advmame-arm64-20260328 (c40801e), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-advmame:v1 (archive cores-standalone-advmame-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1774660735
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/build/advancemame BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export GIT_CONFIG_SYSTEM=/dev/null
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_PARAMETERS=''"'"'core.abbrev=8'"'"''
git clone --filter=blob:none --no-checkout https://github.com/amadvance/advancemame.git /build/advancemame
git -C /build/advancemame checkout -q 8da8d34e082380f89a60298778aac72a533b28a4
test "$(git -C /build/advancemame rev-parse 'HEAD^{tree}')" = 54302d95baf4b56133742bdae79fbd1d946b82fb
git -C /build/advancemame rev-parse HEAD > /output/source-commit.txt
cd /build/advancemame
set +u
test "$(git describe --match 'v*')" = v5.0-90-g8da8d34e
patch -p1 < /patches/iremga20_fix.patch
export CCACHE_DIR=/tmp/ccache CC='ccache aarch64-linux-gnu-gcc' CXX='ccache aarch64-linux-gnu-g++' AR=aarch64-linux-gnu-ar STRIP=aarch64-linux-gnu-strip PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig
ccache -M 5G && ccache -z
aclocal && automake --add-missing --copy --foreign || true
autoheader && autoconf
./configure --build=x86_64-pc-linux-gnu --host=aarch64-linux-gnu
make -j"$(nproc)" CC="$CC" CXX="$CXX"
mkdir -p /tmp/out && cp obj/mame/linux/blend/advmame /tmp/out/advmame && $STRIP /tmp/out/advmame
touch -d @1774660751 /tmp/out/advmame
cd /tmp/out && 7z a -t7z -m0=lzma2 -mx=9 advmame.7z advmame
mkdir -p /output/dist
install -D -m 0644 /tmp/out/advmame.7z /output/dist/advmame.7z
install -D -m 0755 /tmp/out/advmame /output/dist/advmame
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
