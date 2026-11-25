#!/usr/bin/env bash
# moonlight: cores-experimental standalone recipe moonlight (c40801e), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-moonlight:v1 (archive cores-standalone-moonlight-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1775779635
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/build/moonlight BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export STRIP=aarch64-linux-gnu-strip
export PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig
export PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig
export OPTFLAGS='-O3 -ffunction-sections -fdata-sections -flto=auto'
export LDFLAGS='-Wl,--gc-sections -flto=auto'
export SKIP_LIBS='linux-vdso|ld-linux|libc\.so|libm\.so|libdl\.so|libpthread\.so|librt\.so|libgcc_s|libstdc\+\+|libSDL2|libasound|libudev|libdrm|libwayland|libEGL|libGLES|libMali|libz\.so'
git clone --filter=blob:none --no-checkout https://github.com/moonlight-stream/moonlight-embedded.git /build/moonlight
git -C /build/moonlight checkout -q 274d3db34da764344a7a402ee74e6080350ac0cd
test "$(git -C /build/moonlight rev-parse 'HEAD^{tree}')" = 26b685f56faaf8998756c020b50822907441b572
git -C /build/moonlight submodule update --init --recursive --depth 1 -q
git -C /build/moonlight rev-parse HEAD > /output/source-commit.txt
mkdir -p "$(dirname /build/openssl-3.3.1.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://github.com/openssl/openssl/releases/download/openssl-3.3.1/openssl-3.3.1.tar.gz /build/openssl-3.3.1.tar.gz
echo '777cd596284c883375a2a7a11bf5d2786fc5413255efab20c50d6ffe6d020b7e  /build/openssl-3.3.1.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /build/curl-8.7.1.tar.xz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://curl.se/download/curl-8.7.1.tar.xz /build/curl-8.7.1.tar.xz
echo '6fea2aac6a4610fbd0400afb0bcddbe7258a64c63f1f68e5855ebc0c659710cd  /build/curl-8.7.1.tar.xz' | sha256sum -c -
mkdir -p "$(dirname /build/ffmpeg-4.4.5.tar.xz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://ffmpeg.org/releases/ffmpeg-4.4.5.tar.xz /build/ffmpeg-4.4.5.tar.xz
echo 'f9514e0d3515aee5a271283df71636e1d1ff7274b15853bcd84e144be416ab07  /build/ffmpeg-4.4.5.tar.xz' | sha256sum -c -
cd /build/moonlight
set +u +o pipefail
cd /build && tar xf openssl-3.3.1.tar.gz && cd openssl-3.3.1
./Configure linux-aarch64 --cross-compile-prefix=aarch64-linux-gnu- --prefix=/build/local --libdir=lib shared no-tests -O3
make -j"$(nproc)" && make install_sw
export CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ AR=aarch64-linux-gnu-ar
cd /build && tar xf curl-8.7.1.tar.xz && cd curl-8.7.1
./configure --host=aarch64-linux-gnu --build=x86_64-pc-linux-gnu --prefix=/build/local --with-openssl=/build/local --without-libpsl --disable-manual --disable-ldap --enable-shared --disable-static CFLAGS="$OPTFLAGS" LDFLAGS="$LDFLAGS -Wl,-rpath-link,/build/local/lib"
make -j"$(nproc)" && make install
cd /build && tar xf ffmpeg-4.4.5.tar.xz && cd ffmpeg-4.4.5
./configure --prefix=/build/local --cross-prefix=aarch64-linux-gnu- --arch=aarch64 --target-os=linux --enable-cross-compile --enable-shared --disable-static --disable-programs --disable-doc --disable-everything --enable-decoder=h264 --enable-decoder=hevc --enable-decoder=opus --enable-decoder=aac --enable-decoder=pcm_s16le --enable-parser=h264 --enable-parser=hevc --enable-parser=opus --enable-parser=aac --enable-demuxer=h264 --enable-demuxer=hevc --enable-demuxer=rtp --enable-demuxer=rtsp --enable-protocol=rtp --enable-protocol=udp --enable-protocol=tcp --enable-swresample --enable-avcodec --enable-avutil --extra-cflags="$OPTFLAGS" --extra-ldflags="$LDFLAGS"
make -j"$(nproc)" && make install
mkdir -p /build/moonlight/build && cd /build/moonlight/build
cmake .. -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ "-DCMAKE_FIND_ROOT_PATH=/usr/aarch64-linux-gnu;/build/local;/usr" -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER "-DCMAKE_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu;/build/local/lib" "-DCMAKE_INCLUDE_PATH=/usr/include;/build/local/include" -DCMAKE_PREFIX_PATH=/build/local -DCMAKE_BUILD_TYPE=Release "-DCMAKE_C_FLAGS=$OPTFLAGS -I/build/local/include" "-DCMAKE_EXE_LINKER_FLAGS=$LDFLAGS -L/build/local/lib -L/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,/build/local/lib -Wl,-rpath-link,/usr/lib/aarch64-linux-gnu" "-DCMAKE_SHARED_LINKER_FLAGS=$LDFLAGS -L/build/local/lib -L/usr/lib/aarch64-linux-gnu -Wl,-rpath-link,/build/local/lib -Wl,-rpath-link,/usr/lib/aarch64-linux-gnu" -DENABLE_X11=OFF
make -j"$(nproc)"
cd /build && mkdir -p /build/out/libs
cp moonlight/build/moonlight /build/out/ && aarch64-linux-gnu-strip -s /build/out/moonlight
for lib in moonlight/build/libgamestream/libmoonlight-common.so* moonlight/build/libgamestream/libgamestream.so*; do [ -f "$lib" ] && cp "$lib" /build/out/libs/; done
cp /build/local/lib/libssl.so.3 /build/local/lib/libcrypto.so.3 /build/local/lib/libcurl.so.4 /build/local/lib/libavcodec.so* /build/local/lib/libavutil.so* /build/local/lib/libswresample.so* /build/out/libs/
collect_deps() {
    aarch64-linux-gnu-readelf -d "$1" 2>/dev/null | grep NEEDED | sed 's/.*\[\(.*\)\]/\1/' | while read -r lib; do
        [ -f "/build/out/libs/$lib" ] && continue
        echo "$lib" | grep -qE "$SKIP_LIBS" && continue
        src=$(find /build/local/lib /usr/lib/aarch64-linux-gnu /lib/aarch64-linux-gnu -maxdepth 1 -name "$lib" 2>/dev/null | head -1)
        if [ -n "$src" ]; then cp -L "$src" "/build/out/libs/$lib"; collect_deps "/build/out/libs/$lib"; else echo "WARNING: $lib not found"; fi
    done
}
collect_deps /build/out/moonlight
for lib in /build/out/libs/*.so*; do collect_deps "$lib"; done
for so in /build/out/libs/*.so*; do aarch64-linux-gnu-strip -s "$so" 2>/dev/null || true; done
mkdir -p /output/dist
install -D -m 0755 /build/out/moonlight /output/dist/moonlight
mkdir -p "$(dirname /output/dist/libs)"
cp -a /build/out/libs /output/dist/libs
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
