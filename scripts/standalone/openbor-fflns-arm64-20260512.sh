#!/usr/bin/env bash
# openbor-fflns-arm64-20260512: cores-experimental standalone recipe openbor-fflns-arm64-20260512 (c40801e), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-openbor-fflns:v1 (archive cores-standalone-openbor-fflns-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1778573518
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/build/openbor BUILD_DIR=/tmp/standalone-build DIST=/output/dist
git clone --filter=blob:none --no-checkout https://github.com/gonzalomvp/openbor.git /build/openbor
git -C /build/openbor checkout -q 4c8677c2a747b13dbf0e2f9162509ac14a138c9c
test "$(git -C /build/openbor rev-parse 'HEAD^{tree}')" = 4f3feedcafb89a9eda3323b5d2deba78f865db4c
git -C /build/openbor rev-parse HEAD > /output/source-commit.txt
mkdir -p "$(dirname /tmp/001-default-fflns-cfg.patch)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://raw.githubusercontent.com/ljhmd0825/OpenBoR-spruce/53ba41006f2aa571b5d65e78fd99b7e2f3919c83/patches/fflns/001-default-fflns-cfg.patch /tmp/001-default-fflns-cfg.patch
echo 'b1c7a1bfe8fa5e7de5e789ef1d4027599c7f80065f9f4744e1921a4c1f6714ef  /tmp/001-default-fflns-cfg.patch' | sha256sum -c -
cd /build/openbor
set +u
export CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ AR=aarch64-linux-gnu-ar PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig CCACHE_DIR=/tmp/ccache PATH=/usr/lib/ccache:$PATH
ln -sf /usr/bin/ccache /usr/local/bin/aarch64-linux-gnu-gcc && ln -sf /usr/bin/ccache /usr/local/bin/aarch64-linux-gnu-g++
patch -p1 < /tmp/001-default-fflns-cfg.patch
cd engine
bash version.sh
make BUILD_LINUX=1 BUILD_OPENGL=0 BUILD_LOADGL=0 CC=aarch64-linux-gnu-gcc GCC_TARGET=aarch64-linux-gnu ARCHFLAGS="" BUILD_AMD64=1 NO_STRIP=1 SDKPATH=/usr LIBRARIES=/usr/lib/aarch64-linux-gnu -j"$(nproc)"
aarch64-linux-gnu-strip OpenBOR.elf -o OpenBOR
mkdir -p /tmp/libs && cp -L /usr/lib/aarch64-linux-gnu/libpng16.so.16 /lib/aarch64-linux-gnu/libz.so.1 /tmp/libs/
mkdir -p /output/dist
install -D -m 0755 /build/openbor/engine/OpenBOR /output/dist/OpenBOR_64_mod
install -D -m 0644 /tmp/libs/libpng16.so.16 /output/dist/lib64mod/libpng16.so.16
install -D -m 0644 /tmp/libs/libz.so.1 /output/dist/lib64mod/libz.so.1
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
