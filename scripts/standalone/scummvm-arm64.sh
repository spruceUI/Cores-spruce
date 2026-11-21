#!/usr/bin/env bash
# scummvm-arm64: cores-experimental standalone recipe scummvm-arm64 (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-scummvm:v1 (archive cores-standalone-scummvm-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1774942450
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/build/scummvm BUILD_DIR=/tmp/standalone-build DIST=/output/dist
git clone --filter=blob:none --no-checkout https://github.com/scummvm/scummvm.git /build/scummvm
git -C /build/scummvm checkout -q d21ef2e4cb9a9c979b111375624bdf5b66d91bfa
test "$(git -C /build/scummvm rev-parse 'HEAD^{tree}')" = 96e7c23fab015c2a06189052778841fd2a25ec27
git -C /build/scummvm rev-parse HEAD > /output/source-commit.txt
git clone --filter=blob:none --no-checkout https://github.com/FluidSynth/fluidsynth.git /tmp/fluidsynth
git -C /tmp/fluidsynth checkout -q 5ecdc4568e45123216c6888892caad07918ef127
test "$(git -C /tmp/fluidsynth rev-parse 'HEAD^{tree}')" = 6c38f489f295f56db87617b10481bea966683bd0
mkdir -p "$(dirname /tmp/release-2.26.2.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.26.2.tar.gz /tmp/release-2.26.2.tar.gz
echo '80c4e6fb32ed753272e2341b4b902eba305048e628556262f1e14dc6e514751c  /tmp/release-2.26.2.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /tmp/release-2.2.0.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://github.com/libsdl-org/SDL_net/archive/refs/tags/release-2.2.0.tar.gz /tmp/release-2.2.0.tar.gz
echo '08d741282c0c22b82ed134f09cd319803132289cae06fb47b5ada2752faf0493  /tmp/release-2.2.0.tar.gz' | sha256sum -c -
git -C /build/scummvm apply --check /work/patches/scummvm/common-1-cacert-env.patch
git -C /build/scummvm apply /work/patches/scummvm/common-1-cacert-env.patch
git -C /build/scummvm apply --check /work/patches/scummvm/common-2-sigusr1-save-and-quit.patch
git -C /build/scummvm apply /work/patches/scummvm/common-2-sigusr1-save-and-quit.patch
git -C /build/scummvm apply --check /work/patches/scummvm/arm64-1-detection-order.patch
git -C /build/scummvm apply /work/patches/scummvm/arm64-1-detection-order.patch
cd /build/scummvm
set +u +o pipefail
printf '%s\n' 'set(CMAKE_SYSTEM_NAME Linux)' 'set(CMAKE_SYSTEM_PROCESSOR aarch64)' 'set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)' 'set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)' 'set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu /usr)' 'set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)' 'set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)' 'set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)' 'set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)' 'set(PKG_CONFIG_EXECUTABLE /usr/bin/pkg-config)' 'set(ENV{PKG_CONFIG_PATH} "/usr/lib/aarch64-linux-gnu/pkgconfig")' 'set(ENV{PKG_CONFIG_LIBDIR} "/usr/lib/aarch64-linux-gnu/pkgconfig")' > /tmp/aarch64-toolchain.cmake
cd /tmp && rm -rf /usr/lib/aarch64-linux-gnu/libSDL2* /usr/include/SDL2 && tar -xzf release-2.26.2.tar.gz && cd SDL-release-2.26.2
CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig ./configure --host=aarch64-linux-gnu --build=x86_64-pc-linux-gnu --prefix=/usr --libdir=/usr/lib/aarch64-linux-gnu --disable-video-x11 --disable-pulseaudio --disable-esd --enable-video-kmsdrm --enable-video-opengles --disable-video-wayland
make -j"$(nproc)" && make install
cd /tmp && tar -xzf release-2.2.0.tar.gz && cd SDL_net-release-2.2.0
CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig ./configure --host=aarch64-linux-gnu --build=x86_64-pc-linux-gnu --prefix=/usr --libdir=/usr/lib/aarch64-linux-gnu --disable-sdltest
make -j"$(nproc)" && make install
mkdir -p /tmp/fluidsynth/build && cd /tmp/fluidsynth/build
cmake -DCMAKE_TOOLCHAIN_FILE=/tmp/aarch64-toolchain.cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib/aarch64-linux-gnu -Denable-libsndfile=off -Denable-dbus=off -Denable-pulseaudio=off -Denable-jack=off -Denable-pipewire=off -Denable-readline=off -Denable-sdl2=on ..
make -j"$(nproc)" && make install
cd /build/scummvm
export CC="ccache aarch64-linux-gnu-gcc" CXX="ccache aarch64-linux-gnu-g++" AR=aarch64-linux-gnu-ar STRIP=aarch64-linux-gnu-strip PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig
./configure --host=aarch64-linux-gnu --backend=sdl --opengl-mode=gles2 --enable-all-engines --enable-optimizations --enable-release --disable-debug --disable-eventrecorder --enable-vkeybd --enable-openmpt --enable-fluidsynth | tee configure_summary.txt
make -j"$(nproc)"
rm -f base/version.o && SOURCE_DATE_EPOCH=1774944173 make -j"$(nproc)"
mkdir -p /build/out/lib
for lib in liba52-0.7.4.so libasn1.so.8 libasound.so.2 libbrotlicommon.so.1 libbrotlidec.so.1 libbsd.so.0 libcom_err.so.2 libcrypt.so.1 libcrypto.so.1.1 libcurl.so.4 libcurl-gnutls.so.4 libfaad.so.2 libffi.so.7 libFLAC.so.8 libfluidsynth.so.3 libfreetype.so.6 libfribidi.so.0 libgif.so.7 libgmp.so.10 libgnutls.so.30 libgssapi.so.3 libgssapi_krb5.so.2 libhcrypto.so.4 libheimbase.so.1 libheimntlm.so.0 libhogweed.so.5 libhx509.so.5 libidn2.so.0 libk5crypto.so.3 libkeyutils.so.1 libkrb5.so.3 libkrb5.so.26 libkrb5support.so.0 liblber-2.4.so.2 libldap_r-2.4.so.2 liblzma.so.5 libmpeg2.so.0 libnettle.so.7 libnghttp2.so.14 libp11-kit.so.0 libpng16.so.16 libpsl.so.5 libroken.so.18 librtmp.so.1 libsasl2.so.2 libsndio.so.7.0 libspeechd.so.2 libsqlite3.so.0 libssh.so.4 libssl.so.1.1 libtasn1.so.6 libreadline.so.8 libunistring.so.2 libwind.so.0 libz.so.1 libvpx.so.6 libopenmpt.so.0; do
    target=$(find /usr/lib/aarch64-linux-gnu -name "$lib*" -print -quit)
    if [ -n "$target" ]; then cp -L "$target" "/build/out/lib/$lib"; fi
done
mkdir -p /output/dist
install -D -m 0755 /build/scummvm/scummvm /output/dist/scummvm.64
aarch64-linux-gnu-strip -s /output/dist/scummvm.64
mkdir -p "$(dirname /output/dist/lib)"
cp -a /build/out/lib /output/dist/lib
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
