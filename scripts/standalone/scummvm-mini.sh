#!/usr/bin/env bash
# scummvm-mini: cores-experimental standalone recipe scummvm-mini (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-mini:v1 (archive cores-standalone-mini-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1774998874
export LC_ALL=C.UTF-8
umask 022
export CROSS=arm-linux-gnueabihf SOURCE=/build/scummvm BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export TOOLCHAIN=/opt/miyoomini-toolchain
export SYSROOT=/opt/miyoomini-toolchain/arm-linux-gnueabihf/libc
export CC=arm-linux-gnueabihf-gcc
export CXX=arm-linux-gnueabihf-g++
git clone --filter=blob:none --no-checkout https://github.com/scummvm/scummvm.git /build/scummvm
git -C /build/scummvm checkout -q d21ef2e4cb9a9c979b111375624bdf5b66d91bfa
test "$(git -C /build/scummvm rev-parse 'HEAD^{tree}')" = 96e7c23fab015c2a06189052778841fd2a25ec27
git -C /build/scummvm rev-parse HEAD > /output/source-commit.txt
git clone --filter=blob:none --no-checkout https://github.com/divideconcept/FluidLite.git /tmp/FluidLite
git -C /tmp/FluidLite checkout -q 4a01cf1c67419e71da971d209f2855bbf4f3bab8
test "$(git -C /tmp/FluidLite rev-parse 'HEAD^{tree}')" = dc021a2d5af7fc8aec051b369dc63eb759f7853b
mkdir -p "$(dirname /tmp/libogg-1.3.5.tar.xz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://downloads.xiph.org/releases/ogg/libogg-1.3.5.tar.xz /tmp/libogg-1.3.5.tar.xz
echo 'c4d91be36fc8e54deae7575241e03f4211eb102afb3fc0775fbbc1b740016705  /tmp/libogg-1.3.5.tar.xz' | sha256sum -c -
mkdir -p "$(dirname /tmp/libvorbis-1.3.7.tar.xz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.xz /tmp/libvorbis-1.3.7.tar.xz
echo 'b33cc4934322bcbf6efcbacf49e3ca01aadbea4114ec9589d1b1e9d20f72954b  /tmp/libvorbis-1.3.7.tar.xz' | sha256sum -c -
mkdir -p "$(dirname /tmp/libtheora-1.1.1.tar.bz2)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2 /tmp/libtheora-1.1.1.tar.bz2
echo 'b6ae1ee2fa3d42ac489287d3ec34c5885730b1296f0801ae577a35193d3affbc  /tmp/libtheora-1.1.1.tar.bz2' | sha256sum -c -
mkdir -p "$(dirname /tmp/libjpeg-turbo-3.0.1.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.1/libjpeg-turbo-3.0.1.tar.gz /tmp/libjpeg-turbo-3.0.1.tar.gz
echo '22429507714ae147b3acacd299e82099fce5d9f456882fc28e252e4579ba2a75  /tmp/libjpeg-turbo-3.0.1.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /tmp/giflib-5.2.1.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://sourceforge.net/projects/giflib/files/giflib-5.2.1.tar.gz/download /tmp/giflib-5.2.1.tar.gz
echo '31da5562f44c5f15d63340a09a4fd62b48c45620cd302f77a6d9acf0077879bd  /tmp/giflib-5.2.1.tar.gz' | sha256sum -c -
git -C /build/scummvm apply --check /work/patches/scummvm/common-1-cacert-env.patch
git -C /build/scummvm apply /work/patches/scummvm/common-1-cacert-env.patch
git -C /build/scummvm apply --check /work/patches/scummvm/common-2-sigusr1-save-and-quit.patch
git -C /build/scummvm apply /work/patches/scummvm/common-2-sigusr1-save-and-quit.patch
git -C /build/scummvm apply --check /work/patches/scummvm/mini-1-miyoo-rotation-180.patch
git -C /build/scummvm apply /work/patches/scummvm/mini-1-miyoo-rotation-180.patch
cd /build/scummvm
set +u +o pipefail
cd /tmp && tar xf libogg-1.3.5.tar.xz && cd libogg-1.3.5 && ./configure --host=arm-linux-gnueabihf --build=x86_64-pc-linux-gnu --prefix=$SYSROOT/usr --disable-static --enable-shared && make -j"$(nproc)" && make install
cd /tmp && tar xf libvorbis-1.3.7.tar.xz && cd libvorbis-1.3.7 && PKG_CONFIG_LIBDIR=$SYSROOT/usr/lib/pkgconfig ./configure --host=arm-linux-gnueabihf --build=x86_64-pc-linux-gnu --prefix=$SYSROOT/usr --disable-static --enable-shared && make -j"$(nproc)" && make install
cd /tmp && tar xjf libtheora-1.1.1.tar.bz2 && cd libtheora-1.1.1 && PKG_CONFIG_LIBDIR=$SYSROOT/usr/lib/pkgconfig ./configure --host=arm-linux-gnueabihf --build=x86_64-pc-linux-gnu --prefix=$SYSROOT/usr --disable-static --enable-shared --disable-examples --disable-spec --disable-encode && make -j"$(nproc)" && make install
cd /tmp && tar xzf libjpeg-turbo-3.0.1.tar.gz && mkdir -p libjpeg-turbo-3.0.1/build && cd libjpeg-turbo-3.0.1/build && cmake -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=arm -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_INSTALL_PREFIX=$SYSROOT/usr -DWITH_SIMD=OFF .. && make -j"$(nproc)" && make install
cd /tmp && tar xzf giflib-5.2.1.tar.gz && cd giflib-5.2.1 && make CC=arm-linux-gnueabihf-gcc PREFIX=$SYSROOT/usr -j"$(nproc)" && make CC=arm-linux-gnueabihf-gcc PREFIX=$SYSROOT/usr install
mkdir -p /tmp/FluidLite/build && cd /tmp/FluidLite/build && cmake -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=arm -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_INSTALL_PREFIX=$SYSROOT/usr -DBUILD_SHARED_LIBS=ON .. && make -j"$(nproc)" && make install
cd /build/scummvm
export PATH="$TOOLCHAIN/bin:$SYSROOT/usr/bin:$PATH" CXX="ccache arm-linux-gnueabihf-g++"
./configure --host=miyoomini --enable-release --enable-plugins --default-dynamic --disable-detection-full --enable-fluidlite | tee configure_summary.txt
make -j"$(nproc)"
rm -f base/version.o && SOURCE_DATE_EPOCH=1775000038 make -j"$(nproc)"
mkdir -p /build/out/plugins /build/out/libmini && cp plugins/*.so /build/out/plugins/ && arm-linux-gnueabihf-strip /build/out/plugins/*.so
for lib in libjpeg.so.62 libvorbisfile.so.3 libvorbis.so.0 libogg.so.0 libgif.so.7 libtheoradec.so.1 libfluidlite.so libmad.so.0 libfribidi.so.0; do
    found=$(find "$SYSROOT" -name "${lib}*" -type f 2>/dev/null | head -1)
    if [ -n "$found" ]; then cp -L "$found" "/build/out/libmini/$lib"; fi
done
mkdir -p /output/dist
install -D -m 0755 /build/scummvm/scummvm /output/dist/scummvm.mini
arm-linux-gnueabihf-strip -s /output/dist/scummvm.mini
mkdir -p "$(dirname /output/dist/plugins)"
cp -a /build/out/plugins /output/dist/plugins
mkdir -p "$(dirname /output/dist/libmini)"
cp -a /build/out/libmini /output/dist/libmini
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if arm-linux-gnueabihf-readelf -h "$file" >/dev/null 2>&1; then
    arm-linux-gnueabihf-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
