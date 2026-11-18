#!/usr/bin/env bash
# Build easyrpg_libretro.so in a Cores-spruce image the way cores-experimental does: its pinned sources, built into
# one static dependency prefix, then EasyRPG Player with the same CMake options. Run as root inside the image.
# Usage: build-easyrpg.sh arm64|armhf <Player ref, empty for the latest> <output dir>
set -euo pipefail
ARCH=${1:?usage: build-easyrpg.sh arm64|armhf <ref> <output dir>}
REF=${2-}
OUT=${3:?usage: build-easyrpg.sh arm64|armhf <ref> <output dir>}
HERE=$(cd "$(dirname "$0")/.." && pwd)
INPUTS=https://raw.githubusercontent.com/spruceUI/cores-experimental/bf77711d2a96274536dbad05b8c5a76bd71ed661/toolchain-inputs
case "$ARCH" in
  arm64) HOST=aarch64-linux-gnu PROC=aarch64 MPG_CPU=generic
         LIBDIR=/usr/lib/aarch64-linux-gnu INCDIR=/usr/include HOST_AR=aarch64-linux-gnu-gcc-ar ;;
  armhf) HOST=arm-a30-linux-gnueabihf PROC=arm MPG_CPU=arm_fpu
         SYSROOT=/opt/a30/arm-a30-linux-gnueabihf/sysroot
         LIBDIR=$SYSROOT/usr/lib INCDIR=$SYSROOT/usr/include HOST_AR=ar ;;
  *) echo "usage: build-easyrpg.sh arm64|armhf <ref> <output dir>" >&2; exit 2 ;;
esac
PREFIX=/usr/local/easyrpg-deps-$ARCH
# cores-experimental's images have no CMake toolchain file; the steps below name the cross tools themselves.
unset CMAKE_TOOLCHAIN_FILE
W=$(mktemp -d)
cd "$W"

# Python for mpg123's configure, curl for the inputs; on arm64 also the device-shipped libpng (armhf builds it below).
apt-get update -qq
if [ "$ARCH" = arm64 ]; then apt-get install -y -qq --no-install-recommends python3 curl libpng-dev:arm64
else apt-get install -y -qq --no-install-recommends python3 curl; fi

while read -r sum name; do
  [ "$ARCH" = arm64 ] && [ "$name" = libpng.tar.gz ] && continue
  curl -fsSL --retry 3 -o "$name" "$INPUTS/$name"
  echo "$sum  $name" | sha256sum -c -
done <<'SUMS'
e79216260d5dffe809bda840be48ab0eec7737b2bb9f02d2275c1b46344ea7b7  inih.tar.gz
e804e465d4b109b5ad285a8fb71f0dd3f74f0068f91ce3cdfde618180c174925  libpng.tar.gz
ea1480efada2fd948bc75366f7c349e1c96d3297d09a3fe62626e38e234a625e  pixman.tar.gz
d4cf38d26e21a56654ffe4acd9cd5481164619626802328506a2869afab29ab3  expat.tar.gz
1250e4cc58bf06ee631567523f48848dc4596133e163f02615c97f78bab6c811  fmt.tar.gz
6e24fa9bde081f75c3226c01fc4ccf4f3e7477f77b1f6584e8768711980eba9b  ogg.tar.gz
409110db996f42cc89025d1a715a0b787fb66c89322807f4cd46cf0473f3eac2  vorbis.tar.gz
e8203efface3b2758225b9b385ed8191bb82b5a45ff6817d7799ef1eb96c8ebb  mpg123.tar.gz
9fd68a020440b48888e672679bc5078f4f05ef420b88301958f3da5e242cea5b  sndfile.tar.gz
3a2e7a47604ba702f345878308e6fefeca612ee895cf4a5f222e7955fabfe0c0  icu.tar.gz
3d6b5537c3ef2e1ba8398108e2c2010cfa3593cd0a24c9c28570ace7af1522f6  icudata.tar.gz
ef0d29242cfa7eb9b00fa068ae7d3049516f5bba20d47f815254fb777f7900d1  icu-fix-data.patch
SUMS

# inih r58, static, where cores-experimental's images put it.
mkdir inih && tar -xzf inih.tar.gz -C inih --strip-components=1
"$HOST-gcc" -O2 -fPIC -c inih/ini.c -o inih/ini.o
"$HOST_AR" rcs inih/libinih.a inih/ini.o
install -m 0644 inih/libinih.a "$LIBDIR/libinih.a"
install -m 0644 inih/ini.h "$INCDIR/ini.h"

# armhf: libpng 1.6.43, static and PIC, into the A30 sysroot (the SDK's shared one needs a newer glibc than the Mini).
if [ "$ARCH" = armhf ]; then
  mkdir libpng && tar -xzf libpng.tar.gz -C libpng --strip-components=1
  (cd libpng && ./configure --host="$HOST" --prefix=/usr --disable-shared --enable-static CFLAGS="-O2 -fPIC" &&
    make -j"$(nproc)" && make install DESTDIR="$SYSROOT")
fi

autotools() {  # <dir> [configure args...]
  local dir=$1; shift
  mkdir "$dir" && tar -xzf "$dir.tar.gz" -C "$dir" --strip-components=1
  (cd "$dir" && ./configure --host="$HOST" --prefix="$PREFIX" --disable-shared --enable-static CFLAGS="-O2 -fPIC" "$@" &&
    make -j"$(nproc)" && make install)
}
cmake_dep() {  # <dir> [cmake args...]
  local dir=$1; shift
  mkdir "$dir" && tar -xzf "$dir.tar.gz" -C "$dir" --strip-components=1
  CC="$HOST-gcc" CXX="$HOST-g++" cmake -B "$dir-build" -S "$dir" -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR="$PROC" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_POSITION_INDEPENDENT_CODE=ON "$@"
  cmake --build "$dir-build" -j"$(nproc)"
  cmake --install "$dir-build"
}
autotools pixman
cmake_dep expat -DEXPAT_SHARED_LIBS=OFF -DEXPAT_BUILD_TOOLS=OFF -DEXPAT_BUILD_EXAMPLES=OFF -DEXPAT_BUILD_TESTS=OFF \
  -DEXPAT_BUILD_DOCS=OFF
cmake_dep fmt -DBUILD_SHARED_LIBS=OFF -DFMT_TEST=OFF -DFMT_DOC=OFF
autotools ogg
autotools vorbis --with-ogg="$PREFIX"
autotools mpg123 --with-cpu="$MPG_CPU" --disable-fifo --disable-ipv6 --disable-network --disable-int-quality \
  --with-default-audio=dummy --with-optimization=2 --disable-components --enable-libmpg123
autotools sndfile --disable-alsa --disable-sqlite --disable-full-suite --disable-external-libs --disable-mpeg

# ICU 78: a host build for its tools, then the cross build, with the data packaged static.
mkdir icu && tar -xzf icu.tar.gz -C icu --strip-components=1
(cd icu && git apply -p2 ../icu-fix-data.patch)
tar -xzf icudata.tar.gz icudt78l.dat && cp icudt78l.dat icu/source/data/in/
ICU_ARGS=(--enable-strict=no --disable-tests --disable-samples --disable-dyload --disable-extras --disable-icuio
  --disable-layout --disable-layoutex --enable-draft=no --with-data-packaging=static)
mkdir icu-host && (cd icu-host && ../icu/source/runConfigureICU Linux --prefix="$W/icu-host-install" "${ICU_ARGS[@]}" &&
  make -j"$(nproc)")
mkdir icu-target && (cd icu-target && ../icu/source/configure --host="$HOST" --prefix="$PREFIX" \
  --with-cross-build="$W/icu-host" "${ICU_ARGS[@]}" --enable-static --disable-shared \
  CFLAGS="-O2 -fPIC" CXXFLAGS="-O2 -fPIC" && make -j"$(nproc)" && make install)

# EasyRPG Player at the pinned commit, with the patch that pins the liblcf it clones.
git init -q player && git -C player remote add origin https://github.com/EasyRPG/Player.git
if [ -n "$REF" ]; then git -C player fetch -q --depth 1 origin "$REF"; else git -C player fetch -q --depth 1 origin HEAD; fi
git -C player checkout -q --detach FETCH_HEAD
git -C player submodule update -q --init --recursive
git -C player apply --reverse --check "$HERE/patches/easyrpg/liblcf-pinned-clone.patch" 2>/dev/null ||
  git -C player apply "$HERE/patches/easyrpg/liblcf-pinned-clone.patch"
EXTRA=(-DCMAKE_PREFIX_PATH="$PREFIX")
if [ "$ARCH" = armhf ]; then
  # libpng from the sysroot, and GCC 13's libstdc++ linked in and hidden, as the shipped armhf core is.
  RUNTIME="-static-libstdc++ -static-libgcc -Wl,--exclude-libs,ALL"
  # Without a toolchain file CMake does not search the sysroot, so name its zlib and the libpng headers.
  ZLIB_LIB=
  for z in "$SYSROOT/usr/lib/libz.so" "$SYSROOT/lib/libz.so" "$SYSROOT/usr/lib/libz.a"; do
    [ -e "$z" ] && { ZLIB_LIB=$z; break; }
  done
  [ -n "$ZLIB_LIB" ] || { echo "no zlib in $SYSROOT" >&2; exit 1; }
  EXTRA+=(-DPNG_LIBRARY_RELEASE="$SYSROOT/usr/lib/libpng16.a" -DPNG_PNG_INCLUDE_DIR="$SYSROOT/usr/include"
    -DZLIB_LIBRARY="$ZLIB_LIB" -DZLIB_INCLUDE_DIR="$SYSROOT/usr/include"
    -DCMAKE_SHARED_LINKER_FLAGS="$RUNTIME" -DCMAKE_MODULE_LINKER_FLAGS="$RUNTIME")
fi
cmake -S player -B player-build -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR="$PROC" -DCMAKE_C_COMPILER="$(command -v "$HOST-gcc")" \
  -DCMAKE_CXX_COMPILER="$(command -v "$HOST-g++")" -DCMAKE_AR="$(command -v "$HOST-ar")" \
  -DCMAKE_RANLIB="$(command -v "$HOST-ranlib")" -DCMAKE_STRIP="$(command -v "$HOST-strip")" \
  -DLIBLCF_WITH_ICU=ON -DLIBLCF_WITH_XML=ON -DPLAYER_BUILD_LIBLCF=ON -DPLAYER_ENABLE_TESTS=OFF \
  -DPLAYER_TARGET_PLATFORM=libretro -DPLAYER_WITH_FLUIDLITE=OFF -DPLAYER_WITH_FLUIDSYNTH=OFF \
  -DPLAYER_WITH_FREETYPE=OFF -DPLAYER_WITH_LHASA=OFF -DPLAYER_WITH_LIBSNDFILE=ON -DPLAYER_WITH_MPG123=ON \
  -DPLAYER_WITH_OGGVORBIS=ON -DPLAYER_WITH_OPUS=OFF -DPLAYER_WITH_SAMPLERATE=OFF -DPLAYER_WITH_SPEEXDSP=OFF \
  -DPLAYER_WITH_WILDMIDI=OFF -DPLAYER_WITH_XMP=OFF "${EXTRA[@]}"
cmake --build player-build --target easyrpg_libretro --parallel "$(nproc)"
install -m 0644 player-build/easyrpg_libretro.so "$OUT/easyrpg_libretro.so"
