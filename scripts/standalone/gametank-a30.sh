#!/usr/bin/env bash
# gametank-a30: cores-experimental standalone recipe gametank-a30 (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-armhf:v1 (archive cores-standalone-armhf-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1790604756
export LC_ALL=C.UTF-8
umask 022
export CROSS=arm-a30-linux-gnueabihf SOURCE=/src BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export CC=arm-a30-linux-gnueabihf-gcc
export CXX=arm-a30-linux-gnueabihf-g++
export PKG_CONFIG_LIBDIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot
git clone --filter=blob:none --no-checkout https://github.com/clydeshaffer/GameTankEmulator.git /src
git -C /src checkout -q 9896544460d5bb7dd89c2d2bc0f5c97a6f31d2e0
test "$(git -C /src rev-parse 'HEAD^{tree}')" = a6136ca7825a87b83583132b9d78964a570bff94
git -C /src submodule update --init --recursive --depth 1 -q
git -C /src rev-parse HEAD > /output/source-commit.txt
git -C /src apply --check /work/patches/gametank/0001-handheld-menu.patch
git -C /src apply /work/patches/gametank/0001-handheld-menu.patch
git -C /src apply --check /work/patches/gametank/0002-nintendo-layout.patch
git -C /src apply /work/patches/gametank/0002-nintendo-layout.patch
git -C /src apply --check /work/patches/gametank/0003-rotate.patch
git -C /src apply /work/patches/gametank/0003-rotate.patch
cd /src
set +u +o pipefail
cd /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib && ln -sf libSDL2-2.0.so.0.2800.5 libSDL2.so
mkdir -p /tmp/bin
printf '%s\n' '#!/bin/sh' 'case "$1" in' '    --cflags) [ -n "$SDL_CFLAGS" ] && echo "$SDL_CFLAGS" || exec pkg-config --cflags sdl2 ;;' '    --libs)   [ -n "$SDL_LIBS" ] && echo "$SDL_LIBS" || exec pkg-config --libs sdl2 ;;' 'esac' > /tmp/bin/sdl2-config && chmod +x /tmp/bin/sdl2-config
export PATH="/tmp/bin:$PATH"
export SDL_CFLAGS="-I/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/include/SDL2 -D_REENTRANT"
export SDL_LIBS="-lSDL2 -lpthread"
cd "$SOURCE"
make -j"$(nproc)" bin CC="ccache $CC" CPPC="ccache $CXX" OPTIM_FLAGS="-O2 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard" LIBRARY_PATHS="-static-libstdc++ -static-libgcc" SRCS='src/imgui/imgui_demo.cpp src/imgui/imgui_widgets.cpp src/imgui/ext/implot/implot_items.cpp src/imgui/ext/implot/implot_demo.cpp src/imgui/ext/implot/implot.cpp src/imgui/imgui_tables.cpp src/imgui/imgui.cpp src/imgui/backends/imgui_impl_sdlrenderer2.cpp src/imgui/backends/imgui_impl_sdl2.cpp src/imgui/imgui_draw.cpp src/font.cpp src/blitter.cpp src/timekeeper.cpp src/ui/ui_utils.cpp src/game_config.cpp src/emulator_config.cpp src/palette.cpp src/audio_coprocessor.cpp src/devtools/disassembler.cpp src/devtools/vram_window.cpp src/devtools/mem_browser_window.cpp src/devtools/memory_map.cpp src/devtools/debug_window.cpp src/devtools/base_window.cpp src/devtools/controller_options_window.cpp src/devtools/profiler.cpp src/devtools/patching_window.cpp src/devtools/source_map.cpp src/devtools/breakpoints.cpp src/devtools/profiler_window.cpp src/devtools/imgui-combo-filter.cpp src/devtools/stepping_window.cpp src/gte.cpp src/paddle.cpp src/mos6502/mos6502.cpp src/joystick_config.cpp src/joystick_adapter.cpp'
mkdir -p /output/dist
install -D -m 0755 /src/build/GameTankEmulator /output/dist/GameTankEmulator
arm-a30-linux-gnueabihf-strip -s /output/dist/GameTankEmulator
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if arm-a30-linux-gnueabihf-readelf -h "$file" >/dev/null 2>&1; then
    arm-a30-linux-gnueabihf-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
