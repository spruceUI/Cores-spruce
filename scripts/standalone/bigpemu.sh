#!/usr/bin/env bash
# bigpemu: cores-experimental standalone recipe bigpemu (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-gl4es:v1 (archive cores-standalone-gl4es-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1787970282
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/build/gl4es BUILD_DIR=/tmp/standalone-build DIST=/output/dist
git clone --filter=blob:none --no-checkout https://github.com/ptitSeb/gl4es.git /build/gl4es
git -C /build/gl4es checkout -q 81547d986798e876de8b434193920b606a72363f
test "$(git -C /build/gl4es rev-parse 'HEAD^{tree}')" = 54e8b23d105d6347f76479dcfb9e22cca844ef63
git -C /build/gl4es rev-parse HEAD > /output/source-commit.txt
git clone --filter=blob:none --no-checkout https://github.com/spruceUI/BigPEmu-spruce.git /pkg
git -C /pkg checkout -q c572022beac5fe1f3bda5fadb982f4e5696b694a
test "$(git -C /pkg rev-parse 'HEAD^{tree}')" = 560e4257e8021d5ff01f8da8dcf0f98403a87404
mkdir -p "$(dirname /tmp/bigpemu.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://www.richwhitehouse.com/jaguar/builds/BigPEmu_LinuxARM64_v1221.tar.gz /tmp/bigpemu.tar.gz
echo 'a73cb33b27cf1178e487c9eb5b784bdcaac2209fe92a8ed85d3905d52a37a7e4  /tmp/bigpemu.tar.gz' | sha256sum -c -
cd /build/gl4es
set +u +o pipefail
printf '%s\n' 'set(CMAKE_SYSTEM_NAME Linux)' 'set(CMAKE_SYSTEM_PROCESSOR aarch64)' 'set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)' 'set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)' 'set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)' 'set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)' 'set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)' > /tmp/aarch64-toolchain.cmake
mkdir -p /build/gl4es/build && cd /build/gl4es/build
cmake .. -DCMAKE_TOOLCHAIN_FILE=/tmp/aarch64-toolchain.cmake -DODROID=1 -DNOX11=1 -DNOEGL=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j"$(nproc)"
aarch64-linux-gnu-strip ../lib/libGL.so.1
OUT=/build/out/bigpemu && mkdir -p "$OUT" && cp ../lib/libGL.so.1 "$OUT/libGL.so.1"
ln -sf libGL.so.1 "$OUT/libOpenGL.so" && ln -sf libOpenGL.so "$OUT/libOpenGL.so.0"
mkdir -p /tmp/bp && tar xzf /tmp/bigpemu.tar.gz -C /tmp/bp
BPDIR="$(dirname "$(find /tmp/bp -name bigpemu -type f | head -1)")" && cp -rf "$BPDIR"/* "$OUT/" && chmod 0755 "$OUT/bigpemu"
cp /pkg/scripts/bigpemu.sh "$OUT/bigpemu.sh" && chmod 0755 "$OUT/bigpemu.sh"
mkdir -p "$OUT/defaultconfigs" && cp /pkg/config/BigPEmuConfig.bigpcfg "$OUT/defaultconfigs/BigPEmuConfig.bigpcfg"
mkdir -p /output/dist
mkdir -p "$(dirname /output/dist/bigpemu)"
cp -a /build/out/bigpemu /output/dist/bigpemu
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
