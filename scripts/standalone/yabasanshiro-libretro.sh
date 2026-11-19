#!/usr/bin/env bash
# yabasanshiro-libretro: cores-experimental standalone recipe yabasanshiro-libretro (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-yabasanshiro-pgo:v2 (archive cores-standalone-yabasanshiro-pgo-v2.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1791907219
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/build/yabause BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export LC_ALL=C
export WRAP_CROSS=/opt/tsps-sdk/opt/ext-toolchain/bin/aarch64-none-linux-gnu-
export WRAP_SYSROOT=/opt/tsps-sdk/aarch64-buildroot-linux-gnu/sysroot
export WRAP_FLAGS='-O3 -flto -fprofile-use -fprofile-correction -Wno-missing-profile -fprofile-partial-training -Wno-error=coverage-mismatch'
export WRAP_KEEP_FLAGS='-flto -fprofile-use -fprofile-correction -Wno-missing-profile -fprofile-partial-training -Wno-error=coverage-mismatch'
export WRAP_SHARED_LINK=-Wl,-z,undefs
export WRAP_LOG=/output/calls.log
git clone --filter=blob:none --no-checkout https://github.com/libretro/yabause.git /build/yabause
git -C /build/yabause checkout -q f448097b69a6037246a08e9dc09eabaa420d7893
test "$(git -C /build/yabause rev-parse 'HEAD^{tree}')" = 44271b2e50ba9d9149cefc0285b09dcf6a4b099b
git -C /build/yabause rev-parse HEAD > /output/source-commit.txt
GIT_COMMITTER_NAME=arkun GIT_COMMITTER_EMAIL=56165886+CatalyticArkun@users.noreply.github.com git -C /build/yabause am -q --committer-date-is-author-date /work/patches/yabasanshiro-libretro/gles-private-glsym.patch
test "$(git -C /build/yabause rev-parse HEAD)" = 85ca715c9466e8b914197293b4423e4f0e75be9d
GIT_COMMITTER_NAME=arkun GIT_COMMITTER_EMAIL=56165886+CatalyticArkun@users.noreply.github.com git -C /build/yabause am -q --committer-date-is-author-date /work/patches/yabasanshiro-libretro/rbg-compute-gles.patch
test "$(git -C /build/yabause rev-parse HEAD)" = 892985a464382b7b419876008728ceaf4be77049
git -C /build/yabause apply --check /work/patches/yabasanshiro-libretro/dynarec-fix-nopragma.patch
git -C /build/yabause apply /work/patches/yabasanshiro-libretro/dynarec-fix-nopragma.patch
cd /build/yabause
export PATH="/opt/tsps-sdk/opt/ext-toolchain/bin:$PATH"
git config core.abbrev 7
mkdir -p /tmp/wrap && for tool in gcc g++; do install -m 0755 /work/patches/yabasanshiro-libretro/cc-wrapper.sh "/tmp/wrap/$tool"; done
sh /work/patches/yabasanshiro/pgo-merge.sh "${WRAP_CROSS}gcov-tool" /opt/yabasanshiro-pgo/libretro-t3/SmartProS-86-pb-t3-o3-generic-lto-fix.tar /opt/yabasanshiro-pgo/libretro-t3/BrickPro-88-pb-t3-o3-generic-lto-fix.tar /opt/yabasanshiro-pgo/libretro-t3/XX640480-99-pb-t3-o3-generic-lto-fix.tar /opt/yabasanshiro-pgo/libretro-t3/XX720480NoStick-95-pb-t3-o3-generic-lto-fix.tar /opt/yabasanshiro-pgo/libretro-t3/Flip-94-pb-t3-o3-generic-lto-fix.tar
cd yabause/src/libretro
make -j"$(nproc)" platform=arm64 FORCE_GLES=1 CC=/tmp/wrap/gcc CXX=/tmp/wrap/g++ AR="${WRAP_CROSS}ar" RANLIB="${WRAP_CROSS}ranlib"
install -D -m 0755 yabasanshiro_libretro.so /build/out/yabasanshiro_libretro.so
"${WRAP_CROSS}strip" --strip-unneeded /build/out/yabasanshiro_libretro.so
mkdir -p /output/dist
install -D -m 0755 /build/out/yabasanshiro_libretro.so /output/dist/yabasanshiro_generic_libretro.so
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
