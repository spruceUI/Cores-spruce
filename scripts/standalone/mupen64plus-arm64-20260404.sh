#!/usr/bin/env bash
# mupen64plus-arm64-20260404: cores-experimental standalone recipe mupen64plus-arm64-20260404 (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-mupen64plus:v1 (archive cores-standalone-mupen64plus-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1775317192
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
git -C /build/core checkout -q 53a08fceb71653000dd6640cac05eb390fba7885
test "$(git -C /build/core rev-parse 'HEAD^{tree}')" = d654b95d8a76df0d50aa681a83827d50112f98dd
git -C /build/core rev-parse HEAD > /output/source-commit.txt
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-ui-console.git /build/ui-console
git -C /build/ui-console checkout -q 83fd61b58043a02ca8d287eece09649484866cf5
test "$(git -C /build/ui-console rev-parse 'HEAD^{tree}')" = 68f5d887221a29bb98d9834ce252901eafbe9023
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-audio-sdl.git /build/audio-sdl
git -C /build/audio-sdl checkout -q 5c58d3f69c8fdcc23b8d9dbd47685ab84bd0e08e
test "$(git -C /build/audio-sdl rev-parse 'HEAD^{tree}')" = 8c22cca201c5ef422c8b14096077ac0a5775c426
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-input-sdl.git /build/input-sdl
git -C /build/input-sdl checkout -q 076f551c9ac63591d8986a5cc07072b4b736ffd9
test "$(git -C /build/input-sdl rev-parse 'HEAD^{tree}')" = 898a4c2cc0b610bb1c030cf2e7bdbacd35c4cf72
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-rsp-hle.git /build/rsp-hle
git -C /build/rsp-hle checkout -q 561e951decbb7d0bd1589c3d8e3453fbed8d585b
test "$(git -C /build/rsp-hle rev-parse 'HEAD^{tree}')" = d9121f921c294ef01240e5147e8acd59f4473c14
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-video-rice.git /build/video-rice
git -C /build/video-rice checkout -q e4927d9f375a4f40f076c0d9ea63c0c119653fec
test "$(git -C /build/video-rice rev-parse 'HEAD^{tree}')" = 7a9000d61110138e5f9f161c3713ae8e12ab48f4
git clone --filter=blob:none --no-checkout https://github.com/mupen64plus/mupen64plus-video-glide64mk2.git /build/video-glide64mk2
git -C /build/video-glide64mk2 checkout -q d7253a71f57561077016d8ed7028c09e6d360302
test "$(git -C /build/video-glide64mk2 rev-parse 'HEAD^{tree}')" = 8134692b12cfed492d087216bebecdfef7d58ced
git clone --filter=blob:none --no-checkout https://github.com/gonetz/GLideN64.git /build/video-gliden64
git -C /build/video-gliden64 checkout -q c8ef81c7d9aede9f67f6ed3d3426c90541f9f13e
test "$(git -C /build/video-gliden64 rev-parse 'HEAD^{tree}')" = cb5f1780c3c8ebb73997b2bcd1e0a790d49d8d26
git -C /build/core apply --check /work/patches/mupen64plus/20260404-1-sigusr1_save_and_quit-core.patch
git -C /build/core apply /work/patches/mupen64plus/20260404-1-sigusr1_save_and_quit-core.patch
cd /build/core
set +u +o pipefail
git -C /build/video-gliden64 config core.abbrev 7
export SDL_CFLAGS="$(pkg-config --cflags sdl2)" SDL_LDLIBS="$(pkg-config --libs sdl2)"
m64p_make() {
    make -C "$1" CROSS_COMPILE=aarch64-linux-gnu- HOST_CPU=aarch64 USE_GLES=1 NEW_DYNAREC=1 VULKAN=0 \
        APIDIR="$APIDIR" SDL_CFLAGS="$SDL_CFLAGS" SDL_LDLIBS="$SDL_LDLIBS" \
        OPTFLAGS="$OPTFLAGS" PREFIX="" V=1 -j"$(nproc)" all
}
cd /build && m64p_make core/projects/unix
m64p_make audio-sdl/projects/unix
m64p_make input-sdl/projects/unix
m64p_make rsp-hle/projects/unix
m64p_make video-rice/projects/unix
m64p_make video-glide64mk2/projects/unix
mkdir -p video-gliden64/src/build && cd video-gliden64/src/build
cmake .. -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 -DCMAKE_BUILD_TYPE=Release -DMUPENPLUSAPI=ON -DEGL=ON -DUSE_SYSTEM_LIBS=ON "-DCMAKE_C_FLAGS=$OPTFLAGS" "-DCMAKE_CXX_FLAGS=$OPTFLAGS" "-DCMAKE_EXE_LINKER_FLAGS=$LDFLAGS" "-DCMAKE_SHARED_LINKER_FLAGS=$LDFLAGS"
make -j"$(nproc)"
cd /build && m64p_make ui-console/projects/unix
mkdir -p /build/out/data
cp ui-console/projects/unix/mupen64plus /build/out/ && cp core/projects/unix/libmupen64plus.so.2.0.0 /build/out/libmupen64plus.so.2
cp audio-sdl/projects/unix/mupen64plus-audio-sdl.so input-sdl/projects/unix/mupen64plus-input-sdl.so rsp-hle/projects/unix/mupen64plus-rsp-hle.so video-rice/projects/unix/mupen64plus-video-rice.so video-glide64mk2/projects/unix/mupen64plus-video-glide64mk2.so video-gliden64/src/build/plugin/Release/mupen64plus-video-GLideN64.so /build/out/
cp core/data/* video-rice/data/* video-glide64mk2/data/* /build/out/data/ && (cp video-gliden64/ini/* /build/out/data/ 2>/dev/null || true)
mkdir -p /output/dist
install -D -m 0755 /build/out/mupen64plus /output/dist/mupen64plus
aarch64-linux-gnu-strip -s /output/dist/mupen64plus
install -D -m 0755 /build/out/libmupen64plus.so.2 /output/dist/libmupen64plus.so.2
aarch64-linux-gnu-strip -s /output/dist/libmupen64plus.so.2
install -D -m 0755 /build/out/mupen64plus-audio-sdl.so /output/dist/mupen64plus-audio-sdl.so
aarch64-linux-gnu-strip -s /output/dist/mupen64plus-audio-sdl.so
install -D -m 0755 /build/out/mupen64plus-input-sdl.so /output/dist/mupen64plus-input-sdl.so
aarch64-linux-gnu-strip -s /output/dist/mupen64plus-input-sdl.so
install -D -m 0755 /build/out/mupen64plus-rsp-hle.so /output/dist/mupen64plus-rsp-hle.so
aarch64-linux-gnu-strip -s /output/dist/mupen64plus-rsp-hle.so
install -D -m 0755 /build/out/mupen64plus-video-rice.so /output/dist/mupen64plus-video-rice.so
aarch64-linux-gnu-strip -s /output/dist/mupen64plus-video-rice.so
install -D -m 0755 /build/out/mupen64plus-video-glide64mk2.so /output/dist/mupen64plus-video-glide64mk2.so
aarch64-linux-gnu-strip -s /output/dist/mupen64plus-video-glide64mk2.so
install -D -m 0755 /build/out/mupen64plus-video-GLideN64.so /output/dist/mupen64plus-video-GLideN64.so
aarch64-linux-gnu-strip -s /output/dist/mupen64plus-video-GLideN64.so
mkdir -p "$(dirname /output/dist/data)"
cp -a /build/out/data /output/dist/data
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
