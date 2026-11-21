#!/usr/bin/env bash
# mupen64plus-arm64-gliden64-ovl: cores-experimental standalone recipe mupen64plus-arm64-gliden64-ovl (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-mupen64plus:v1 (archive cores-standalone-mupen64plus-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1789086248
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/build/core BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
export AR=aarch64-linux-gnu-ar
export STRIP=aarch64-linux-gnu-strip
export PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig
export PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig
export OPTFLAGS='-O3 -ffunction-sections -fdata-sections -flto=auto'
export LDFLAGS='-Wl,--gc-sections -flto=auto'
export APIDIR=/build/core/src/api
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-core.git /build/core
git -C /build/core checkout -q cf00a1d1b4138a8e04cde47aabcd00ea9a047f57
test "$(git -C /build/core rev-parse 'HEAD^{tree}')" = bb085e88da11ba9cb298e0d39ed401a3e74aa7a8
git -C /build/core rev-parse HEAD > /output/source-commit.txt
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-ui-console.git /build/ui-console
git -C /build/ui-console checkout -q c8ac4862a019d7885b24927d9b4db5dd3e42a528
test "$(git -C /build/ui-console rev-parse 'HEAD^{tree}')" = 6cf316ede8bbf2d16c7e7e8136d4a6060957c976
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-audio-sdl.git /build/audio-sdl
git -C /build/audio-sdl checkout -q 2faed1c7e62c5f292948e7cd2398c184970cf794
test "$(git -C /build/audio-sdl rev-parse 'HEAD^{tree}')" = b64e60cd12152fab64901e8c8da529501c60e2da
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-input-sdl.git /build/input-sdl
git -C /build/input-sdl checkout -q 842c39e89749aa3a8d02202b2afddd20b29cdfdb
test "$(git -C /build/input-sdl rev-parse 'HEAD^{tree}')" = 4bb5cd0e9c4e34a6e27bf881538a4ff0fca13be4
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-rsp-hle.git /build/rsp-hle
git -C /build/rsp-hle checkout -q 8a7a472a7172eb2c8725b305eae26818ed7b51a2
test "$(git -C /build/rsp-hle rev-parse 'HEAD^{tree}')" = 4a38979d0001a13a5c006cd632e4a63201ce4308
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-video-rice.git /build/video-rice
git -C /build/video-rice checkout -q 038882dd2e7cb660fd7512c0745032f17edd0bfa
test "$(git -C /build/video-rice rev-parse 'HEAD^{tree}')" = aa4255ba1d276ebb8722a44cf85bc8a6c6dd99d0
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-video-glide64mk2.git /build/video-glide64mk2
git -C /build/video-glide64mk2 checkout -q b07cb0bc8f29d6ee43efdf0a4d5a1b878ba98393
test "$(git -C /build/video-glide64mk2 rev-parse 'HEAD^{tree}')" = c8953f943c1ee229823eb050651ad6722212fb3a
git clone --filter=blob:none --no-checkout https://github.com/gonetz/GLideN64.git /build/video-gliden64
git -C /build/video-gliden64 checkout -q c8ef81c7d9aede9f67f6ed3d3426c90541f9f13e
test "$(git -C /build/video-gliden64 rev-parse 'HEAD^{tree}')" = cb5f1780c3c8ebb73997b2bcd1e0a790d49d8d26
git clone --filter=blob:none --no-checkout https://github.com/spruceUI/mupen64plus-spruce.git /wrapper
git -C /wrapper checkout -q b3cbeb9253ab8d683e2763b87c17d8d6a9313a32
test "$(git -C /wrapper rev-parse 'HEAD^{tree}')" = ed65ac66dc524dff7970e7d78ba5a23a89acf387
git -C /build/core apply --check /work/patches/mupen64plus/1-sigusr1_save_and_quit-core.patch
git -C /build/core apply /work/patches/mupen64plus/1-sigusr1_save_and_quit-core.patch
git -C /build/video-glide64mk2 apply --check /work/patches/mupen64plus/2-center_viewport-video-glide64mk2.patch
git -C /build/video-glide64mk2 apply /work/patches/mupen64plus/2-center_viewport-video-glide64mk2.patch
git -C /build/video-rice apply --check /work/patches/mupen64plus/2-center_viewport-video-rice.patch
git -C /build/video-rice apply /work/patches/mupen64plus/2-center_viewport-video-rice.patch
git -C /build/video-glide64mk2 apply --check /work/patches/mupen64plus/3-overlay_glide64mk2-video-glide64mk2.patch
git -C /build/video-glide64mk2 apply /work/patches/mupen64plus/3-overlay_glide64mk2-video-glide64mk2.patch
git -C /build/video-gliden64 apply --check /work/patches/mupen64plus/4-overlay_gliden64-video-gliden64.patch
git -C /build/video-gliden64 apply /work/patches/mupen64plus/4-overlay_gliden64-video-gliden64.patch
git -C /build/video-rice apply --check /work/patches/mupen64plus/5-overlay_rice-video-rice.patch
git -C /build/video-rice apply /work/patches/mupen64plus/5-overlay_rice-video-rice.patch
git -C /build/video-gliden64 apply --check /work/patches/mupen64plus/6-gles_link-video-gliden64.patch
git -C /build/video-gliden64 apply /work/patches/mupen64plus/6-gles_link-video-gliden64.patch
git -C /build/video-gliden64 apply --check /work/patches/mupen64plus/7-egl_proc-video-gliden64.patch
git -C /build/video-gliden64 apply /work/patches/mupen64plus/7-egl_proc-video-gliden64.patch
git -C /build/video-gliden64 apply --check /work/patches/mupen64plus/8-overlay_thread-video-gliden64.patch
git -C /build/video-gliden64 apply /work/patches/mupen64plus/8-overlay_thread-video-gliden64.patch
git -C /wrapper apply --check /work/patches/mupen64plus/9-overlay_retry-wrapper.patch
git -C /wrapper apply /work/patches/mupen64plus/9-overlay_retry-wrapper.patch
cd /build/core
set +u +o pipefail
cd /build && cp -r /wrapper/overlay /overlay
git -C /build/video-gliden64 config core.abbrev 7
export SDL_CFLAGS="$(pkg-config --cflags sdl2)" SDL_LDLIBS="$(pkg-config --libs sdl2)"
mkdir -p video-gliden64/src/build && cd video-gliden64/src/build
cmake .. -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 -DCMAKE_BUILD_TYPE=Release -DMUPENPLUSAPI=ON -DEGL=ON -DUSE_SYSTEM_LIBS=ON "-DCMAKE_C_FLAGS=$OPTFLAGS" "-DCMAKE_CXX_FLAGS=$OPTFLAGS" "-DCMAKE_EXE_LINKER_FLAGS=$LDFLAGS" "-DCMAKE_SHARED_LINKER_FLAGS=$LDFLAGS -Wl,--no-undefined"
make -j"$(nproc)"
cd /build && mkdir -p /build/out && cp video-gliden64/src/build/plugin/Release/mupen64plus-video-GLideN64.so /build/out/
mkdir -p /output/dist
install -D -m 0755 /build/out/mupen64plus-video-GLideN64.so /output/dist/mupen64plus-video-GLideN64.so
aarch64-linux-gnu-strip -s /output/dist/mupen64plus-video-GLideN64.so
install -D -m 0755 /build/out/mupen64plus-video-GLideN64.so /output/dist/mupen64plus-video-GLideN64.so.debug
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
