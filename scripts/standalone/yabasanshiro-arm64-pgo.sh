#!/usr/bin/env bash
# yabasanshiro-arm64-pgo: cores-experimental standalone recipe yabasanshiro-arm64-pgo (c40801e), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-yabasanshiro-pgo:v2 (archive cores-standalone-yabasanshiro-pgo-v2.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1730323839
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/build/yabasanshiro BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
export AR=aarch64-linux-gnu-ar
export STRIP=aarch64-linux-gnu-strip
export PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig
export PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig
export CMAKE_POLICY_VERSION_MINIMUM=3.5
export SKIP_LIBS='linux-vdso|ld-linux|libc\.so|libm\.so|libdl\.so|libpthread\.so|librt\.so|libgcc_s|libstdc\+\+|libSDL2|libasound|libudev|libdrm|libwayland|libEGL|libGLES|libMali|libgomp|libvulkan|libmali|libIMGegl|libsrv_um|libusc|libGL\.so|libGLX|libGLdispatch|libglut'
export WRAP_CROSS=/opt/arm-gnu-10.3/bin/aarch64-none-linux-gnu-
export WRAP_SYSFLAGS='--sysroot=/tmp/focal -idirafter /usr/include/aarch64-linux-gnu -idirafter /usr/include -isystem /tmp/sysinc'
export WRAP_FLAGS='-O3 -flto=8 -fprofile-use -fprofile-correction -Wno-missing-profile -fprofile-partial-training -Wno-error=coverage-mismatch'
export WRAP_KEEP_FLAGS='-flto=8 -fprofile-use -fprofile-correction -Wno-missing-profile -fprofile-partial-training -Wno-error=coverage-mismatch'
export WRAP_LINK='-Wl,--allow-shlib-undefined -L/tmp/deplibs -Wl,-rpath-link=/usr/lib/aarch64-linux-gnu:/lib/aarch64-linux-gnu'
export WRAP_LOG=/output/calls.log
git clone --filter=blob:none --no-checkout https://github.com/sydarn/yabause.git /build/yabasanshiro
git -C /build/yabasanshiro checkout -q a40dace1ae0af3ebd45848549fdf396f40e3930f
test "$(git -C /build/yabasanshiro rev-parse 'HEAD^{tree}')" = 52b40bd06d2f827de62f89da0e3a30dffc3cbb4e
git -C /build/yabasanshiro submodule update --init --recursive --depth 1 -q
git -C /build/yabasanshiro rev-parse HEAD > /output/source-commit.txt
git -C /build/yabasanshiro apply --check /work/patches/yabasanshiro/fix-libchdr-target-name.patch
git -C /build/yabasanshiro apply /work/patches/yabasanshiro/fix-libchdr-target-name.patch
git -C /build/yabasanshiro apply --check /work/patches/yabasanshiro/fix-libpng-neon.patch
git -C /build/yabasanshiro apply /work/patches/yabasanshiro/fix-libpng-neon.patch
git -C /build/yabasanshiro apply --check /work/patches/yabasanshiro/fix-stray-makecurrent.patch
git -C /build/yabasanshiro apply /work/patches/yabasanshiro/fix-stray-makecurrent.patch
git -C /build/yabasanshiro apply --check /work/patches/yabasanshiro/dynarec-fix.patch
git -C /build/yabasanshiro apply /work/patches/yabasanshiro/dynarec-fix.patch
git -C /build/yabasanshiro apply --check /work/patches/yabasanshiro/nopragma.patch
git -C /build/yabasanshiro apply /work/patches/yabasanshiro/nopragma.patch
git -C /build/yabasanshiro apply --check /work/patches/yabasanshiro/rbg-compute-gles.patch
git -C /build/yabasanshiro apply /work/patches/yabasanshiro/rbg-compute-gles.patch
git -C /build/yabasanshiro apply --check /work/patches/yabasanshiro/bench-framelimit-env.patch
git -C /build/yabasanshiro apply /work/patches/yabasanshiro/bench-framelimit-env.patch
cd /build/yabasanshiro
set +u +o pipefail
f=/tmp/focal && mkdir -p "$f/usr" && ln -s /usr/aarch64-linux-gnu/include "$f/usr/include" && for d in usr/lib usr/lib64 lib lib64; do ln -s /usr/aarch64-linux-gnu/lib "$f/$d"; done && ln -s /usr/aarch64-linux-gnu "$f/usr/aarch64-linux-gnu"
mkdir -p /tmp/deplibs && for lib in /usr/lib/aarch64-linux-gnu/*.so /usr/lib/aarch64-linux-gnu/*.a; do case "${lib##*/}" in libc.*|libc_nonshared.a|libm.*|libmvec*|libpthread*|libdl.*|librt.*|libutil.*|libresolv.*|libanl.*|libnsl*|libBrokenLocale*) ;; libstdc++*|libsupc++*|libgcc*|libatomic*|libgomp*|libquadmath*|libitm*|libssp*|lib?san*|libubsan*) ;; *) ln -s "$lib" /tmp/deplibs/ ;; esac; done
for h in pthread.h bits/statx.h; do if [ -f "/usr/aarch64-linux-gnu/include/$h" ]; then install -D -m 0644 "/usr/aarch64-linux-gnu/include/$h" "/tmp/sysinc/$h"; fi; done
mkdir -p /tmp/wrap && for tool in gcc g++; do install -m 0755 /work/patches/yabasanshiro/cc-wrapper-t3.sh "/tmp/wrap/$tool"; done
export CC=/tmp/wrap/gcc CXX=/tmp/wrap/g++
sh /work/patches/yabasanshiro/pgo-merge.sh "${WRAP_CROSS}gcov-tool" /opt/yabasanshiro-pgo/standalone-t3/SmartProS-86-pb-sa-t3-pgogen.tar /opt/yabasanshiro-pgo/standalone-t3/BrickPro-88-pb-sa-t3-pgogen.tar /opt/yabasanshiro-pgo/standalone-t3/XX640480-99-pb-sa-t3-pgogen.tar /opt/yabasanshiro-pgo/standalone-t3/XX720480NoStick-95-pb-sa-t3-pgogen.tar
cc yabause/src/retro_arena/nanogui-sdl/resources/bin2c.c -o bin2c_host
cc yabause/src/musashi/m68kmake.c -o m68kmake_host
sed -i "s|COMMAND \./bin2c|COMMAND $PWD/bin2c_host|g" yabause/src/retro_arena/nanogui-sdl/CMakeLists.txt
sed -i "s|COMMAND \$<TARGET_FILE:bin2c>|COMMAND $PWD/bin2c_host|g" yabause/src/retro_arena/nanogui-sdl/CMakeLists.txt
sed -i "s|add_executable(bin2c resources/bin2c.c)|add_custom_target(bin2c DEPENDS $PWD/bin2c_host)|g" yabause/src/retro_arena/nanogui-sdl/CMakeLists.txt
sed -i "s|COMMAND m68kmake|COMMAND $PWD/m68kmake_host|g" yabause/src/musashi/CMakeLists.txt
sed -i "s|add_executable(m68kmake m68kmake.c)|# m68kmake built as host tool|g" yabause/src/musashi/CMakeLists.txt
sed -i "s|DEPENDS m68kmake.c|DEPENDS|g" yabause/src/musashi/CMakeLists.txt
mkdir -p build && cd build
cmake ../yabause -DCMAKE_TOOLCHAIN_FILE=../yabause/src/retro_arena/n2.cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS=-O3 -DCMAKE_CXX_FLAGS=-O3 -DYAB_PORTS=retro_arena -DYAB_WANT_ARM7=ON -DYAB_WANT_DYNAREC_DEVMIYAX=ON -DYAB_WANT_VULKAN=OFF -DYAB_WANT_OPENAL=OFF -DYAB_MULTIBUILD=OFF -DCMAKE_DISABLE_FIND_PACKAGE_GLUT=TRUE -DCMAKE_C_COMPILER=/tmp/wrap/gcc -DCMAKE_CXX_COMPILER=/tmp/wrap/g++ -DCMAKE_AR="${WRAP_CROSS}gcc-ar" -DCMAKE_RANLIB="${WRAP_CROSS}gcc-ranlib" -DCMAKE_ASM-ATT_COMPILER="${WRAP_CROSS}as" -DCMAKE_LIBRARY_ARCHITECTURE=aarch64-linux-gnu -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
make -j"$(nproc)"
cd /build && mkdir -p /build/out/libs
cp "$(find yabasanshiro/build -name yabasanshiro -type f -executable | head -1)" /build/out/yabasanshiro && cp -p /build/out/yabasanshiro /build/out/yabasanshiro.unstripped && aarch64-linux-gnu-strip -s /build/out/yabasanshiro
collect_deps() {
    aarch64-linux-gnu-readelf -d "$1" 2>/dev/null | grep NEEDED | sed 's/.*\[\(.*\)\]/\1/' | while read -r lib; do
        [ -f "/build/out/libs/$lib" ] && continue
        echo "$lib" | grep -qE "$SKIP_LIBS" && continue
        src=$(find /usr/lib/aarch64-linux-gnu /lib/aarch64-linux-gnu -maxdepth 1 -name "$lib" 2>/dev/null | head -1)
        if [ -n "$src" ]; then cp -L "$src" "/build/out/libs/$lib"; collect_deps "/build/out/libs/$lib"; else echo "WARNING: $lib not found"; fi
    done
}
collect_deps /build/out/yabasanshiro
for lib in /build/out/libs/*.so*; do collect_deps "$lib"; done
for so in /build/out/libs/*.so*; do aarch64-linux-gnu-strip -s "$so" 2>/dev/null || true; done
mkdir -p /output/dist
install -D -m 0755 /build/out/yabasanshiro /output/dist/yabasanshiro
install -D -m 0755 /build/out/yabasanshiro.unstripped /output/dist/symbols/yabasanshiro
mkdir -p "$(dirname /output/dist/libs)"
cp -a /build/out/libs /output/dist/libs
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
