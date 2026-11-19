#!/usr/bin/env bash
# azahar-libretro: cores-experimental standalone recipe azahar-libretro (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-azahar:v1 (archive cores-standalone-azahar-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1793263886
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/home/ark/rk3566_core_builds/azahar BUILD_DIR=/tmp/standalone-build DIST=/output/dist
git clone --filter=blob:none --no-checkout https://github.com/azahar-emu/azahar.git /home/ark/rk3566_core_builds/azahar
git -C /home/ark/rk3566_core_builds/azahar checkout -q 219d743a1e698101fe1ab8bef43e6563126c3c27
test "$(git -C /home/ark/rk3566_core_builds/azahar rev-parse 'HEAD^{tree}')" = a4ed1d9530bee1a98b168d782b3540b2585433ba
git -C /home/ark/rk3566_core_builds/azahar submodule update --init --recursive --depth 1 -q
git -C /home/ark/rk3566_core_builds/azahar rev-parse HEAD > /output/source-commit.txt
mkdir -p "$(dirname /home/ark/rk3566_core_builds/pgo/azahar-nano-merged-20261020.profdata.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://raw.githubusercontent.com/christianhaitian/rk3566_core_builds/e76af8133b07c4faf75c203e029a94531fc1420e/pgo/azahar-nano-merged-20261020.profdata.gz /home/ark/rk3566_core_builds/pgo/azahar-nano-merged-20261020.profdata.gz
echo '6709d16b1345ec79ce3a91b842b6cf435093f530c93fd592a755cd5a61888df0  /home/ark/rk3566_core_builds/pgo/azahar-nano-merged-20261020.profdata.gz' | sha256sum -c -
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-000-gammaos-azahar-nano.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-000-gammaos-azahar-nano.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-001-large-screen-layout.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-001-large-screen-layout.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-002-gammaos-switches-on-linux.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-002-gammaos-switches-on-linux.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-003-libretro-present-window.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-003-libretro-present-window.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-004-jit-warmup-steady-clock.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-004-jit-warmup-steady-clock.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-005-states-from-other-builds.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-005-states-from-other-builds.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-006-gammaos-defaults-as-core-options.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-006-gammaos-defaults-as-core-options.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-007-mali-and-frontend-as-gammaos.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-007-mali-and-frontend-as-gammaos.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-008-large-screen-buffer-panel-size.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-008-large-screen-buffer-panel-size.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-009-gammaos-nano-20261020.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-009-gammaos-nano-20261020.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-010-simd-texture-codec.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-010-simd-texture-codec.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-011-swap-on-back.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-011-swap-on-back.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-012-savestates-streamed.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-012-savestates-streamed.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-013-castlevania-stereo.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-013-castlevania-stereo.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-014-stereo-switches-as-core-options.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-014-stereo-switches-as-core-options.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-015-offscreen-draws-never-skipped.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-015-offscreen-draws-never-skipped.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-016-realtime-audio-option.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-016-realtime-audio-option.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-017-shared-cheats.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-017-shared-cheats.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-018-gpu-timer-on-request.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-018-gpu-timer-on-request.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-019-framebuffers-retired.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-019-framebuffers-retired.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-020-right-eye-by-framebuffer.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-020-right-eye-by-framebuffer.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-021-shader-jit-masked-writes.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-021-shader-jit-masked-writes.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-022-vk-skip-zero-area-renderpasses.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-022-vk-skip-zero-area-renderpasses.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-023-skip-zero-area-renderpasses-area.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-023-skip-zero-area-renderpasses-area.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-024-vk-null-descriptors.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-024-vk-null-descriptors.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-025-spirv-shadows.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-025-spirv-shadows.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-026-blit-nearest.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-026-blit-nearest.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-027-shader-cache-progress.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-027-shader-cache-progress.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-028-upload-buffer-128mib.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-028-upload-buffer-128mib.patch
git -C /home/ark/rk3566_core_builds/azahar apply --check /work/patches/azahar/azahar-patch-029-deferred-storage-usage.patch
git -C /home/ark/rk3566_core_builds/azahar apply /work/patches/azahar/azahar-patch-029-deferred-storage-usage.patch
cd /home/ark/rk3566_core_builds/azahar
git -C "$SOURCE" config core.abbrev 7
gunzip -c /home/ark/rk3566_core_builds/pgo/azahar-nano-merged-20261020.profdata.gz > "$SOURCE/azahar.profdata"
mkdir -p "$SOURCE/build" && cd "$SOURCE/build"
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 -DCMAKE_C_COMPILER=/usr/bin/clang-19 -DCMAKE_CXX_COMPILER=/usr/bin/clang++-19 -DCMAKE_C_COMPILER_TARGET=aarch64-linux-gnu -DCMAKE_CXX_COMPILER_TARGET=aarch64-linux-gnu -DCMAKE_AR=/usr/bin/aarch64-linux-gnu-ar -DCMAKE_RANLIB=/usr/bin/aarch64-linux-gnu-ranlib -DENABLE_LIBRETRO=ON -DENABLE_OPENGL=ON -DENABLE_VULKAN=ON -DENABLE_TESTS=OFF -DENABLE_LTO=OFF -DCITRA_WARNINGS_AS_ERRORS=OFF "-DCMAKE_C_FLAGS=-fprofile-use=/home/ark/rk3566_core_builds/azahar/azahar.profdata -Wno-profile-instr-unprofiled -Wno-profile-instr-out-of-date -Wno-backend-plugin" "-DCMAKE_CXX_FLAGS=-DUSING_GLES -fprofile-use=/home/ark/rk3566_core_builds/azahar/azahar.profdata -Wno-profile-instr-unprofiled -Wno-profile-instr-out-of-date -Wno-backend-plugin"
ninja -j"$(nproc)" citra_libretro
mkdir -p /output/dist
install -D -m 0755 /home/ark/rk3566_core_builds/azahar/build/bin/Release/azahar_libretro.so /output/dist/azahar_libretro.so
aarch64-linux-gnu-strip -s /output/dist/azahar_libretro.so
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
