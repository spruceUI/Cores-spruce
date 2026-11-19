#!/usr/bin/env bash
# flycast-libretro-t3: cores-experimental standalone recipe flycast-libretro-t3 (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-yabasanshiro-pgo:v2 (archive cores-standalone-yabasanshiro-pgo-v2.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1767792512
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/build/flycast BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export LC_ALL=C
export WRAP_CROSS=/opt/tsps-sdk/opt/ext-toolchain/bin/aarch64-none-linux-gnu-
export WRAP_SYSROOT=/opt/tsps-sdk/aarch64-buildroot-linux-gnu/sysroot
export WRAP_LOG=/output/calls.log
git clone --filter=blob:none --no-checkout https://github.com/flyinghead/flycast.git /build/flycast
git -C /build/flycast checkout -q 392a429e8b040b3e5bf6696cb4f984274fc44123
test "$(git -C /build/flycast rev-parse 'HEAD^{tree}')" = 712e00d5a9c99abc949bcce2bf02800492de869d
git -C /build/flycast submodule update --init --recursive --depth 1 -q
git -C /build/flycast rev-parse HEAD > /output/source-commit.txt
cd /build/flycast
mkdir -p /tmp/wrap && cat > /tmp/wrap/gcc <<'WRAP'
#!/bin/sh
# Installed as /tmp/wrap/gcc and g++: $WRAP_CROSS<name> with the sysroot last, as the research build ran it.
[ -z "${WRAP_LOG:-}" ] || printf '%s\n' "$* --sysroot=$WRAP_SYSROOT" >> "$WRAP_LOG"
exec "$WRAP_CROSS${0##*/}" "$@" --sysroot="$WRAP_SYSROOT"
WRAP
cp /tmp/wrap/gcc /tmp/wrap/g++ && chmod 0755 /tmp/wrap/gcc /tmp/wrap/g++
mkdir -p build && cd build
cmake .. -G 'Unix Makefiles' -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 -DCMAKE_C_COMPILER=/tmp/wrap/gcc -DCMAKE_CXX_COMPILER=/tmp/wrap/g++ -DCMAKE_AR="${WRAP_CROSS}gcc-ar" -DCMAKE_RANLIB="${WRAP_CROSS}gcc-ranlib" -DCMAKE_C_COMPILER_AR="${WRAP_CROSS}gcc-ar" -DCMAKE_CXX_COMPILER_AR="${WRAP_CROSS}gcc-ar" -DCMAKE_C_COMPILER_RANLIB="${WRAP_CROSS}gcc-ranlib" -DCMAKE_CXX_COMPILER_RANLIB="${WRAP_CROSS}gcc-ranlib" -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE -DLIBRETRO=ON -DUSE_HOST_LIBZIP=OFF -DUSE_OPENMP=OFF -DUSE_GLES=ON -DUSE_VULKAN=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make -j"$(nproc)" flycast_libretro
install -D -m 0755 flycast_libretro.so /build/out/flycast_libretro.so
"${WRAP_CROSS}strip" --strip-unneeded /build/out/flycast_libretro.so
mkdir -p /output/dist
install -D -m 0755 /build/out/flycast_libretro.so /output/dist/flycast_libretro.so
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
