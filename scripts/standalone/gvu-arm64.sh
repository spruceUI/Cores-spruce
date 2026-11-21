#!/usr/bin/env bash
# gvu-arm64: cores-experimental standalone recipe gvu-arm64 (9f6b4d3), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-gvu-arm64:v2 (archive cores-standalone-gvu-arm64-v2.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1793410942
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-linux-gnu SOURCE=/src BUILD_DIR=/tmp/standalone-build DIST=/output/dist
export PREFIX=/opt/brick
export PKG_CONFIG_PATH=/opt/brick/lib/pkgconfig
export PKG_CONFIG_LIBDIR=/opt/brick/lib/pkgconfig
git clone --filter=blob:none --no-checkout https://github.com/Sundownersport/GVU.git /src
git -C /src checkout -q da3e0337ae65b6a12883f36fe7d222de0f4653a8
test "$(git -C /src rev-parse 'HEAD^{tree}')" = e2571481f81b0e94e1a9a987b65088950a25d1d5
git -C /src rev-parse HEAD > /output/source-commit.txt
mkdir -p "$(dirname /build/SDL2-2.26.5.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://libsdl.org/release/SDL2-2.26.5.tar.gz /build/SDL2-2.26.5.tar.gz
echo 'ad8fea3da1be64c83c45b1d363a6b4ba8fd60f5bde3b23ec73855709ec5eabf7  /build/SDL2-2.26.5.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /build/libjpeg-turbo-2.1.5.1.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/2.1.5.1/libjpeg-turbo-2.1.5.1.tar.gz /build/libjpeg-turbo-2.1.5.1.tar.gz
echo '2fdc3feb6e9deb17adec9bafa3321419aa19f8f4e5dea7bf8486844ca22207bf  /build/libjpeg-turbo-2.1.5.1.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /build/libpng-1.6.39.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://download.sourceforge.net/libpng/libpng-1.6.39.tar.gz /build/libpng-1.6.39.tar.gz
echo 'af4fb7f260f839919e5958e5ab01a275d4fe436d45442a36ee62f73e5beb75ba  /build/libpng-1.6.39.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /build/freetype-2.13.0.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://download.savannah.gnu.org/releases/freetype/freetype-2.13.0.tar.gz /build/freetype-2.13.0.tar.gz
echo 'a7aca0e532a276ea8d85bd31149f0a74c33d19c8d287116ef8f5f8357b4f1f80  /build/freetype-2.13.0.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /build/SDL2_image-2.6.3.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://libsdl.org/projects/SDL_image/release/SDL2_image-2.6.3.tar.gz /build/SDL2_image-2.6.3.tar.gz
echo '931c9be5bf1d7c8fae9b7dc157828b7eee874e23c7f24b44ba7eff6b4836312c  /build/SDL2_image-2.6.3.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /build/SDL2_ttf-2.20.2.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.20.2.tar.gz /build/SDL2_ttf-2.20.2.tar.gz
echo '9dc71ed93487521b107a2c4a9ca6bf43fb62f6bddd5c26b055e6b91418a22053  /build/SDL2_ttf-2.20.2.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /build/ffmpeg-5.1.6.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://ffmpeg.org/releases/ffmpeg-5.1.6.tar.gz /build/ffmpeg-5.1.6.tar.gz
echo '2a963f9f627dc55cac7ce4d2bb2e063ce52c8ab57185d2b592a631c36be56fda  /build/ffmpeg-5.1.6.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /build/openssl-1.1.1w.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz /build/openssl-1.1.1w.tar.gz
echo 'cf3098950cb4d853ad95c0841f1f9c6d3dc102dccfcacd521d93925208b76ac8  /build/openssl-1.1.1w.tar.gz' | sha256sum -c -
mkdir -p "$(dirname /build/curl-8.7.1.tar.gz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://curl.se/download/curl-8.7.1.tar.gz /build/curl-8.7.1.tar.gz
echo 'f91249c87f68ea00cf27c44fdfa5a78423e41e71b7d408e5901a9896d905c495  /build/curl-8.7.1.tar.gz' | sha256sum -c -
cd /src
set +u +o pipefail
mkdir -p /opt/brick
tar xf /build/SDL2-2.26.5.tar.gz -C /
mkdir -p /SDL2-2.26.5/bld
cd /SDL2-2.26.5/bld && ../configure --host=$CROSS --build=x86_64-pc-linux-gnu --prefix=/opt/brick --enable-static --disable-shared --disable-video-opengl --disable-video-opengles --disable-video-x11 --disable-video-wayland --disable-video-kmsdrm --disable-video-directfb --disable-pulseaudio --disable-nas --disable-esd --disable-jack --disable-pipewire --disable-dbus --enable-alsa --disable-hidapi --disable-ime CC=$CROSS-gcc CFLAGS="-march=armv8-a -O2"
cd /SDL2-2.26.5/bld && make -j"$(nproc)" install
tar xf /build/libjpeg-turbo-2.1.5.1.tar.gz -C /
cmake -S /libjpeg-turbo-2.1.5.1 -B /ljt-bld -DCMAKE_C_COMPILER=$CROSS-gcc -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 -DCMAKE_C_FLAGS="-march=armv8-a -O2" -DCMAKE_INSTALL_PREFIX=/opt/brick -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DWITH_TURBOJPEG=OFF
cmake --build /ljt-bld -j"$(nproc)" && cmake --install /ljt-bld
tar xf /build/libpng-1.6.39.tar.gz -C /
mkdir -p /libpng-1.6.39/bld
cd /libpng-1.6.39/bld && ../configure --host=$CROSS --build=x86_64-pc-linux-gnu --prefix=/opt/brick --enable-static --disable-shared CC=$CROSS-gcc CFLAGS="-march=armv8-a -O2"
cd /libpng-1.6.39/bld && make -j"$(nproc)" install
tar xf /build/freetype-2.13.0.tar.gz -C /
mkdir -p /freetype-2.13.0/bld
cd /freetype-2.13.0/bld && ../configure --host=$CROSS --build=x86_64-pc-linux-gnu --prefix=/opt/brick --enable-static --disable-shared --without-harfbuzz CC=$CROSS-gcc CFLAGS="-march=armv8-a -O2"
cd /freetype-2.13.0/bld && make -j"$(nproc)" install
tar xf /build/SDL2_image-2.6.3.tar.gz -C /
mkdir -p /SDL2_image-2.6.3/bld
cd /SDL2_image-2.6.3/bld && ../configure --host=$CROSS --build=x86_64-pc-linux-gnu --prefix=/opt/brick --enable-static --disable-shared --disable-jpg-shared --enable-jpg --disable-png-shared --enable-png --disable-webp --disable-avif --disable-jxl --disable-tif CC=$CROSS-gcc CFLAGS="-march=armv8-a -O2 -I/opt/brick/include" LDFLAGS="-L/opt/brick/lib" SDL2_CFLAGS="$(pkg-config --cflags sdl2)" SDL2_LIBS="$(pkg-config --libs sdl2)"
cd /SDL2_image-2.6.3/bld && make -j"$(nproc)" install
tar xf /build/SDL2_ttf-2.20.2.tar.gz -C /
mkdir -p /SDL2_ttf-2.20.2/bld
cd /SDL2_ttf-2.20.2/bld && ../configure --host=$CROSS --build=x86_64-pc-linux-gnu --prefix=/opt/brick --enable-static --disable-shared CC=$CROSS-gcc CXX=$CROSS-g++ CFLAGS="-march=armv8-a -O2 -I/opt/brick/include" CXXFLAGS="-march=armv8-a -O2 -I/opt/brick/include" LDFLAGS="-L/opt/brick/lib" SDL2_CFLAGS="$(pkg-config --cflags sdl2)" SDL2_LIBS="$(pkg-config --libs sdl2)" FT2_CFLAGS="$(pkg-config --cflags freetype2)" FT2_LIBS="$(pkg-config --libs freetype2)"
cd /SDL2_ttf-2.20.2/bld && make -j"$(nproc)" install
tar xf /build/ffmpeg-5.1.6.tar.gz -C /
cd /ffmpeg-5.1.6 && ./configure --arch=aarch64 --target-os=linux --cross-prefix=$CROSS- --enable-cross-compile --cpu=cortex-a55 --enable-runtime-cpudetect --prefix=/opt/brick --enable-static --disable-shared --disable-programs --disable-doc --disable-everything --enable-decoder=h264 --enable-decoder=hevc --enable-decoder=vp8 --enable-decoder=vp9 --enable-decoder=av1 --enable-decoder=mpeg4 --enable-decoder=mpeg2video --enable-decoder=mjpeg --enable-decoder=aac --enable-decoder=mp3float --enable-decoder=mp3 --enable-decoder=vorbis --enable-decoder=flac --enable-decoder=opus --enable-decoder=ac3 --enable-decoder=eac3 --enable-decoder=dca --enable-decoder=truehd --enable-decoder=pcm_s16le --enable-decoder=pcm_s24le --enable-decoder=pcm_f32le --enable-decoder=pcm_s16be --enable-decoder=subrip --enable-decoder=ass --enable-decoder=ssa --enable-decoder=webvtt --enable-demuxer=mov --enable-demuxer=matroska --enable-demuxer=mp4 --enable-demuxer=avi --enable-demuxer=flv --enable-demuxer=ogg --enable-demuxer=mp3 --enable-demuxer=wav --enable-demuxer=flac --enable-demuxer=aac --enable-demuxer=mpegts --enable-demuxer=mpegvideo --enable-demuxer=srt --enable-demuxer=webvtt --enable-demuxer=hls --enable-demuxer=pcm_s16le --enable-parser=h264 --enable-parser=hevc --enable-parser=vp8 --enable-parser=vp9 --enable-parser=av1 --enable-parser=mpeg4video --enable-parser=aac --enable-parser=mpegaudio --enable-parser=vorbis --enable-parser=flac --enable-parser=opus --enable-parser=ac3 --enable-protocol=file --enable-swscale --enable-swresample --enable-avformat --enable-avcodec --enable-avutil --extra-cflags="-march=armv8-a -O2" --extra-ldflags="-march=armv8-a -O2"
cd /ffmpeg-5.1.6 && make -j"$(nproc)" install
tar xf /build/openssl-1.1.1w.tar.gz -C /
cd /openssl-1.1.1w && ./Configure linux-aarch64 --cross-compile-prefix=$CROSS- --prefix=/opt/brick --openssldir=/opt/brick/ssl no-shared no-tests -march=armv8-a -O2
cd /openssl-1.1.1w && make -j"$(nproc)" && make install_sw
tar xf /build/curl-8.7.1.tar.gz -C /
mkdir -p /curl-8.7.1/bld
cd /curl-8.7.1/bld && ../configure --host=$CROSS --build=x86_64-pc-linux-gnu --prefix=/opt/brick --enable-static --disable-shared --with-openssl=/opt/brick --with-ca-bundle=/mnt/SDCARD/spruce/etc/ca-certificates.crt --without-gnutls --disable-ftp --disable-ldap --disable-ldaps --disable-rtsp --disable-dict --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-gopher --disable-mqtt --disable-manual --disable-docs --without-libidn2 --without-libpsl CC=$CROSS-gcc CFLAGS="-march=armv8-a -O2" CPPFLAGS="-I/opt/brick/include" LDFLAGS="-L/opt/brick/lib"
cd /curl-8.7.1/bld && make -j"$(nproc)" install
cd "$SOURCE"
make trimui-brick-build
mkdir -p /output/dist
install -D -m 0755 /src/gvu64 /output/dist/gvu64
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-linux-gnu-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-linux-gnu-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
