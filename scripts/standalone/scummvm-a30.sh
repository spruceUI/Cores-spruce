#!/usr/bin/env bash
# scummvm-a30: cores-experimental standalone recipe scummvm-a30 (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-armhf:v1 (archive cores-standalone-armhf-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1774998507
export LC_ALL=C.UTF-8
umask 022
export CROSS=arm-a30-linux-gnueabihf SOURCE=/build/scummvm BUILD_DIR=/tmp/standalone-build DIST=/output/dist
git clone --filter=blob:none --no-checkout https://github.com/scummvm/scummvm.git /build/scummvm
git -C /build/scummvm checkout -q d21ef2e4cb9a9c979b111375624bdf5b66d91bfa
test "$(git -C /build/scummvm rev-parse 'HEAD^{tree}')" = 96e7c23fab015c2a06189052778841fd2a25ec27
git -C /build/scummvm rev-parse HEAD > /output/source-commit.txt
git clone --filter=blob:none --no-checkout https://github.com/divideconcept/FluidLite.git /tmp/FluidLite
git -C /tmp/FluidLite checkout -q 4a01cf1c67419e71da971d209f2855bbf4f3bab8
test "$(git -C /tmp/FluidLite rev-parse 'HEAD^{tree}')" = dc021a2d5af7fc8aec051b369dc63eb759f7853b
mkdir -p "$(dirname /tmp/libmad-0.15.1b.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://downloads.sourceforge.net/mad/libmad-0.15.1b.tar.gz /tmp/libmad-0.15.1b.tar.gz
echo 'bbfac3ed6bfbc2823d3775ebb931087371e142bb0e9bb1bee51a76a6e0078690  /tmp/libmad-0.15.1b.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /tmp/libtheora-1.1.1.tar.bz2)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2 /tmp/libtheora-1.1.1.tar.bz2
echo 'b6ae1ee2fa3d42ac489287d3ec34c5885730b1296f0801ae577a35193d3affbc  /tmp/libtheora-1.1.1.tar.bz2' | sha256sum -c -
mkdir -p "$(dirname /tmp/SDL2_net-2.2.0.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.2.0.tar.gz /tmp/SDL2_net-2.2.0.tar.gz
echo '4e4a891988316271974ff4e9585ed1ef729a123d22c08bd473129179dc857feb  /tmp/SDL2_net-2.2.0.tar.gz' | sha256sum -c -
git -C /build/scummvm apply --check /work/patches/scummvm/common-1-cacert-env.patch
git -C /build/scummvm apply /work/patches/scummvm/common-1-cacert-env.patch
git -C /build/scummvm apply --check /work/patches/scummvm/a30-1-display-rotation.patch
git -C /build/scummvm apply /work/patches/scummvm/a30-1-display-rotation.patch
git -C /build/scummvm apply --check /work/patches/scummvm/a30-2-mouse-x-scaling.patch
git -C /build/scummvm apply /work/patches/scummvm/a30-2-mouse-x-scaling.patch
git -C /build/scummvm apply --check /work/patches/scummvm/common-2-sigusr1-save-and-quit.patch
git -C /build/scummvm apply /work/patches/scummvm/common-2-sigusr1-save-and-quit.patch
cd /build/scummvm
set +u +o pipefail
printf '#!/bin/sh\nexport PKG_CONFIG_SYSROOT_DIR=%s\nexport PKG_CONFIG_LIBDIR=%s/usr/lib/pkgconfig:%s/usr/share/pkgconfig\nexec pkg-config "$@"\n' /opt/a30/arm-a30-linux-gnueabihf/sysroot /opt/a30/arm-a30-linux-gnueabihf/sysroot /opt/a30/arm-a30-linux-gnueabihf/sysroot > /opt/a30/bin/arm-a30-linux-gnueabihf-pkg-config
(export CC=arm-a30-linux-gnueabihf-gcc CXX=arm-a30-linux-gnueabihf-g++ AR=arm-a30-linux-gnueabihf-ar AS=arm-a30-linux-gnueabihf-as LD=arm-a30-linux-gnueabihf-ld RANLIB=arm-a30-linux-gnueabihf-ranlib STRIP=arm-a30-linux-gnueabihf-strip PKG_CONFIG=arm-a30-linux-gnueabihf-pkg-config LDFLAGS=--sysroot=/opt/a30/arm-a30-linux-gnueabihf/sysroot PKG_CONFIG_LIBDIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/pkgconfig:/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/share/pkgconfig PKG_CONFIG_SYSROOT_DIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot CFLAGS="--sysroot=/opt/a30/arm-a30-linux-gnueabihf/sysroot -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -O2 -fPIC" && export CXXFLAGS="$CFLAGS" && cd /tmp && tar xzf libmad-0.15.1b.tar.gz && cd libmad-0.15.1b && ./configure --host=arm-a30-linux-gnueabihf --build="$(dpkg-architecture -qDEB_BUILD_GNU_TYPE)" --prefix=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr --disable-static --enable-shared && find . -name Makefile -type f -exec sed -i -e 's/-fforce-mem//g' -e 's/-fforce-addr//g' -e 's/-fstrength-reduce//g' {} + && make -j"$(nproc)" && make install && cd /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib && { [ -e libmad.so ] || ln -sf "$(basename "$(ls libmad.so.* | head -n1)")" libmad.so; })
(export CC=arm-a30-linux-gnueabihf-gcc CXX=arm-a30-linux-gnueabihf-g++ AR=arm-a30-linux-gnueabihf-ar AS=arm-a30-linux-gnueabihf-as LD=arm-a30-linux-gnueabihf-ld RANLIB=arm-a30-linux-gnueabihf-ranlib STRIP=arm-a30-linux-gnueabihf-strip PKG_CONFIG=arm-a30-linux-gnueabihf-pkg-config LDFLAGS=--sysroot=/opt/a30/arm-a30-linux-gnueabihf/sysroot PKG_CONFIG_LIBDIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/pkgconfig:/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/share/pkgconfig PKG_CONFIG_SYSROOT_DIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot CFLAGS="--sysroot=/opt/a30/arm-a30-linux-gnueabihf/sysroot -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -O2" && export CXXFLAGS="$CFLAGS" && cd /tmp && tar xjf libtheora-1.1.1.tar.bz2 && cd libtheora-1.1.1 && ./configure --host=arm-a30-linux-gnueabihf --build="$(dpkg-architecture -qDEB_BUILD_GNU_TYPE)" --prefix=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr --disable-static --enable-shared --disable-examples --disable-spec --disable-encode && make -j"$(nproc)" && make install)
(export CC=arm-a30-linux-gnueabihf-gcc CXX=arm-a30-linux-gnueabihf-g++ AR=arm-a30-linux-gnueabihf-ar AS=arm-a30-linux-gnueabihf-as LD=arm-a30-linux-gnueabihf-ld RANLIB=arm-a30-linux-gnueabihf-ranlib STRIP=arm-a30-linux-gnueabihf-strip PKG_CONFIG=arm-a30-linux-gnueabihf-pkg-config LDFLAGS=--sysroot=/opt/a30/arm-a30-linux-gnueabihf/sysroot PKG_CONFIG_LIBDIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/pkgconfig:/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/share/pkgconfig PKG_CONFIG_SYSROOT_DIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot CFLAGS="--sysroot=/opt/a30/arm-a30-linux-gnueabihf/sysroot -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -O2" && export CXXFLAGS="$CFLAGS" && cd /tmp && tar xzf SDL2_net-2.2.0.tar.gz && cd SDL2_net-2.2.0 && ./configure --host=arm-a30-linux-gnueabihf --build="$(dpkg-architecture -qDEB_BUILD_GNU_TYPE)" --prefix=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr --disable-static --enable-shared --with-sdl-prefix=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr && make -j"$(nproc)" && make install)
(export CC=arm-a30-linux-gnueabihf-gcc CXX=arm-a30-linux-gnueabihf-g++ CFLAGS="--sysroot=/opt/a30/arm-a30-linux-gnueabihf/sysroot -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -O2" && mkdir -p /tmp/FluidLite/build && cd /tmp/FluidLite/build && cmake -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=arm -DCMAKE_C_COMPILER=arm-a30-linux-gnueabihf-gcc "-DCMAKE_C_FLAGS=--sysroot=/opt/a30/arm-a30-linux-gnueabihf/sysroot -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -O2" -DCMAKE_INSTALL_PREFIX=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr -DBUILD_SHARED_LIBS=ON .. && make -j"$(nproc)" && make install)
cd /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib && ln -sf libSDL2-2.0.so.0.2800.5 libSDL2.so && ln -sf libMali.so libEGL.so && ln -sf libMali.so libGLESv2.so && ln -sf libasound.so.2.0.0 libasound.so && ln -sf libfreetype.so.6.20.1 libfreetype.so
export CC="ccache arm-a30-linux-gnueabihf-gcc" CXX="ccache arm-a30-linux-gnueabihf-g++" AR=arm-a30-linux-gnueabihf-ar STRIP=arm-a30-linux-gnueabihf-strip PKG_CONFIG_PATH=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/pkgconfig PKG_CONFIG_SYSROOT_DIR=/opt/a30/arm-a30-linux-gnueabihf/sysroot CFLAGS="--sysroot=/opt/a30/arm-a30-linux-gnueabihf/sysroot -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -O2"
export CXXFLAGS="$CFLAGS" LDFLAGS="--sysroot=/opt/a30/arm-a30-linux-gnueabihf/sysroot -L/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib -static-libstdc++"
rm -f /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/libfontconfig* /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/pkgconfig/fontconfig.pc
cd /build/scummvm
./configure --host=arm-linux-gnueabihf --backend=sdl --enable-optimizations --enable-release --disable-debug --disable-eventrecorder --enable-fluidlite --with-sdl-prefix=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr | tee configure_summary.txt
make -j"$(nproc)"
rm -f base/version.o && SOURCE_DATE_EPOCH=1774999952 make -j"$(nproc)"
printf '%s\n' '#include <stdio.h>' '#include <fcntl.h>' '#include <unistd.h>' '#include <linux/input.h>' '#include <sys/ioctl.h>' '#include <string.h>' '#include <stdlib.h>' '' 'int main(int argc, char **argv) {' '    const char *dev = argc > 1 ? argv[1] : "/dev/input/event4";' '    int range = argc > 2 ? atoi(argv[2]) : 128;' '    int fd = open(dev, O_RDWR);' '    if (fd < 0) { perror("open"); return 1; }' '' '    int i;' '    for (i = 0; i < 6; i++) {' '        struct input_absinfo info;' '        if (ioctl(fd, EVIOCGABS(i), &info) == 0) {' '            printf("axis %d: val=%d min=%d max=%d fuzz=%d flat=%d\n",' '                   i, info.value, info.minimum, info.maximum, info.fuzz, info.flat);' '            if (info.minimum < -range || info.maximum > range) {' '                printf("  -> fixing range to [%d, %d]\n", -range, range);' '                info.minimum = -range;' '                info.maximum = range;' '                info.fuzz = 0;' '                info.flat = 0;' '                ioctl(fd, EVIOCSABS(i), &info);' '            }' '        }' '    }' '    close(fd);' '    return 0;' '}' > /tmp/fixjoy.c
mkdir -p /build/out/liba30 && arm-a30-linux-gnueabihf-gcc -static -o /build/out/fixjoy /tmp/fixjoy.c
cp -L /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/libtheoradec.so.1* /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/libSDL2_net-2.0.so.0* /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/libfluidlite.so* /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/libasound.so.2* /opt/a30/arm-a30-linux-gnueabihf/sysroot/usr/lib/libmad.so.0* /build/out/liba30/
mkdir -p /output/dist
install -D -m 0755 /build/scummvm/scummvm /output/dist/scummvm.a30
arm-a30-linux-gnueabihf-strip -s /output/dist/scummvm.a30
install -D -m 0755 /build/out/fixjoy /output/dist/fixjoy
arm-a30-linux-gnueabihf-strip -s /output/dist/fixjoy
mkdir -p "$(dirname /output/dist/liba30)"
cp -a /build/out/liba30 /output/dist/liba30
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if arm-a30-linux-gnueabihf-readelf -h "$file" >/dev/null 2>&1; then
    arm-a30-linux-gnueabihf-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
