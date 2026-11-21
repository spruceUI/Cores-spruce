#!/usr/bin/env bash
# flycast-standalone-t3-lto: cores-experimental standalone recipe flycast-standalone-t3-lto (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-arm64-standalone:v2 (archive cores-arm64-standalone-v2.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1786747058
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/src BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export PKG_CONFIG_PATH=/opt/flycast-standalone-deps-arm64/lib/pkgconfig
export PKG_CONFIG_LIBDIR=/opt/flycast-standalone-deps-arm64/lib/pkgconfig:/usr/lib/aarch64-linux-gnu/pkgconfig
export WRAP_CROSS=/opt/arm-gnu-10.3/bin/aarch64-none-linux-gnu-
export WRAP_SYSFLAGS='--sysroot=/tmp/focal -idirafter /usr/include/aarch64-linux-gnu -idirafter /usr/include -isystem /tmp/sysinc'
export WRAP_FLAGS='-O3 -flto=8'
export WRAP_KEEP_FLAGS=-flto=8
export WRAP_LINK='-Wl,--allow-shlib-undefined -L/tmp/deplibs -Wl,-rpath-link=/usr/lib/aarch64-linux-gnu:/lib/aarch64-linux-gnu'
export WRAP_LOG=/output/calls.log
git clone --filter=blob:none --no-checkout https://github.com/flyinghead/flycast.git /src
git -C /src checkout -q 5aa091fde632fb332c8d8c34e280d62dc951954c
test "$(git -C /src rev-parse 'HEAD^{tree}')" = 6384bacac6a2be89164a923372052a7ad1dff05a
git -C /src submodule update --init --recursive --depth 1 -q
git -C /src rev-parse HEAD > /output/source-commit.txt
cd /src
set +u +o pipefail
f=/tmp/focal && mkdir -p "$f/usr" && ln -s /usr/aarch64-linux-gnu/include "$f/usr/include" && for d in usr/lib usr/lib64 lib lib64; do ln -s /usr/aarch64-linux-gnu/lib "$f/$d"; done && ln -s /usr/aarch64-linux-gnu "$f/usr/aarch64-linux-gnu"
mkdir -p /tmp/deplibs && for lib in /usr/lib/aarch64-linux-gnu/*.so /usr/lib/aarch64-linux-gnu/*.a; do case "${lib##*/}" in libc.*|libc_nonshared.a|libm.*|libmvec*|libpthread*|libdl.*|librt.*|libutil.*|libresolv.*|libanl.*|libnsl*|libBrokenLocale*) ;; libstdc++*|libsupc++*|libgcc*|libatomic*|libgomp*|libquadmath*|libitm*|libssp*|lib?san*|libubsan*) ;; *) ln -s "$lib" /tmp/deplibs/ ;; esac; done
for h in pthread.h bits/statx.h; do if [ -f "/usr/aarch64-linux-gnu/include/$h" ]; then install -D -m 0644 "/usr/aarch64-linux-gnu/include/$h" "/tmp/sysinc/$h"; fi; done
mkdir -p /tmp/wrap && cat > /tmp/wrap/gcc <<'WRAP'
#!/bin/bash
# Installed as /tmp/wrap/gcc and g++: $WRAP_CROSS<name> with $WRAP_FLAGS last (-O0 calls get $WRAP_KEEP_FLAGS), and as
# Ubuntu's GCC does: -fPIE unless PIC is asked for, -pie on executable links, --as-needed ahead of a link's libraries.
tool=${0##*/}
case " $* " in
    *" -c "*|*" -E "*|*" -S "*) kind=compile ;;
    *" -shared "*) kind=shared ;;
    *) kind=exe ;;
esac
pie=""
if [ "$kind" != shared ]; then
    case " $* " in *" -fPIC "*|*" -fpic "*) ;; *) pie="-fPIE" ;; esac
    [ "$kind" = exe ] && pie="$pie -pie"
fi
link=""
first=""
if [ "$kind" != compile ]; then
    link="$WRAP_LINK"
    first="-Wl,--as-needed"
fi
case " $* " in *" -O0 "*) opt="$WRAP_KEEP_FLAGS" ;; *) opt="$WRAP_FLAGS" ;; esac
[ -z "${WRAP_LOG:-}" ] || printf '%s\n' "$first $* $WRAP_SYSFLAGS $opt $pie $link" >> "$WRAP_LOG"
exec "$WRAP_CROSS$tool" $first "$@" $WRAP_SYSFLAGS $opt $pie $link
WRAP
cp /tmp/wrap/gcc /tmp/wrap/g++ && chmod 0755 /tmp/wrap/gcc /tmp/wrap/g++
git config core.abbrev 8
cmake -S /src -B /tmp/standalone-build -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_SYSTEM_NAME:STRING=Linux -DCMAKE_SYSTEM_PROCESSOR:STRING=aarch64 -DCMAKE_C_COMPILER:FILEPATH=/tmp/wrap/gcc -DCMAKE_CXX_COMPILER:FILEPATH=/tmp/wrap/g++ -DCMAKE_AR:FILEPATH="${WRAP_CROSS}gcc-ar" -DCMAKE_RANLIB:FILEPATH="${WRAP_CROSS}gcc-ranlib" -DCMAKE_STRIP:FILEPATH=/usr/bin/aarch64-linux-gnu-strip '-DCMAKE_FIND_ROOT_PATH:STRING=/usr/aarch64-linux-gnu;/opt/flycast-standalone-deps-arm64;/usr' '-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY:STRING=ONLY' '-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE:STRING=BOTH' '-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM:STRING=NEVER' '-DCMAKE_LIBRARY_PATH:STRING=/usr/lib/aarch64-linux-gnu;/opt/flycast-standalone-deps-arm64/lib' '-DCMAKE_INCLUDE_PATH:STRING=/usr/include;/opt/flycast-standalone-deps-arm64/include' '-DCMAKE_PREFIX_PATH:STRING=/opt/flycast-standalone-deps-arm64' '-DCMAKE_C_FLAGS:STRING=-O3 -I/opt/flycast-standalone-deps-arm64/include' '-DCMAKE_CXX_FLAGS:STRING=-O3 -I/opt/flycast-standalone-deps-arm64/include' '-DCMAKE_EXE_LINKER_FLAGS:STRING=-L/opt/flycast-standalone-deps-arm64/lib -L/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,/opt/flycast-standalone-deps-arm64/lib -Wl,-rpath-link,/usr/lib/aarch64-linux-gnu' -DLIBRETRO=OFF -DUSE_HOST_SDL=ON -DUSE_OPENGL=ON -DUSE_GLES=ON -DUSE_VULKAN=ON -DUSE_ALSA=ON -DUSE_HOST_LIBZIP=OFF -DUSE_OPENMP=OFF -DUSE_PULSEAUDIO=OFF -DUSE_LIBAO=OFF -DUSE_LUA=OFF -DUSE_DISCORD=OFF -DENABLE_CTEST=OFF -DFT_DISABLE_PNG=ON -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BROTLI=ON -DFT_DISABLE_BZIP2=ON
cmake --build /tmp/standalone-build -j "$(nproc)" --target flycast
mkdir -p /output/dist
install -D -m 0755 /tmp/standalone-build/flycast /output/dist/flycast
aarch64-linux-gnu-strip -s /output/dist/flycast
install -D -m 0755 /opt/flycast-standalone-deps-arm64/lib/libcurl.so.4 /output/dist/lib64/libcurl.so.4
aarch64-linux-gnu-strip -s /output/dist/lib64/libcurl.so.4
install -D -m 0755 /opt/flycast-standalone-deps-arm64/lib/libssl.so.1.1 /output/dist/lib64/libssl.so.1.1
aarch64-linux-gnu-strip -s /output/dist/lib64/libssl.so.1.1
install -D -m 0755 /opt/flycast-standalone-deps-arm64/lib/libcrypto.so.1.1 /output/dist/lib64/libcrypto.so.1.1
aarch64-linux-gnu-strip -s /output/dist/lib64/libcrypto.so.1.1
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
