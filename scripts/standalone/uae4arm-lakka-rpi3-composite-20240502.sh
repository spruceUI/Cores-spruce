#!/usr/bin/env bash
# uae4arm-lakka-rpi3-composite-20240502: cores-experimental standalone recipe uae4arm-lakka-rpi3-composite-20240502 (c40801e), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-lakka-focal:v1 (archive cores-standalone-lakka-focal-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1714681962
export LC_ALL=C.UTF-8
umask 022
export CROSS=aarch64-libreelec-linux-gnueabi SOURCE=/home/docker/Lakka BUILD_DIR=/tmp/standalone-build DIST=/output/dist
git clone --filter=blob:none --no-checkout https://github.com/ToKe79/Lakka-LibreELEC.git /home/docker/Lakka
git -C /home/docker/Lakka checkout -q faf53a9754f4184a69a51c7e31ec042b555a5056
test "$(git -C /home/docker/Lakka rev-parse 'HEAD^{tree}')" = 0326ab1ddac94273ace16aa44bdda41de28c911c
git -C /home/docker/Lakka rev-parse HEAD > /output/source-commit.txt
mkdir -p "$(dirname /home/docker/Lakka/sources/gmp/gmp-6.2.1.tar.xz)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.xz /home/docker/Lakka/sources/gmp/gmp-6.2.1.tar.xz
echo 'fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2  /home/docker/Lakka/sources/gmp/gmp-6.2.1.tar.xz' | sha256sum -c -
mkdir -p "$(dirname /home/docker/Lakka/sources/alsa-lib/alsa-lib-1.2.4.tar.bz2)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://www.alsa-project.org/files/pub/lib/alsa-lib-1.2.4.tar.bz2 /home/docker/Lakka/sources/alsa-lib/alsa-lib-1.2.4.tar.bz2
echo 'f7554be1a56cdff468b58fc1c29b95b64864c590038dd309c7a978c7116908f7  /home/docker/Lakka/sources/alsa-lib/alsa-lib-1.2.4.tar.bz2' | sha256sum -c -
cd /home/docker/Lakka
set +u
for f in gmp/gmp-6.2.1.tar.xz:fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2 alsa-lib/alsa-lib-1.2.4.tar.bz2:f7554be1a56cdff468b58fc1c29b95b64864c590038dd309c7a978c7116908f7; do echo "original" > /home/docker/Lakka/sources/${f%%:*}.url && echo "${f#*:}" > /home/docker/Lakka/sources/${f%%:*}.sha256; done
{ git clone -q --bare https://git.savannah.gnu.org/git/config.git /tmp/config.git || git clone -q --bare https://github.com/gnu-mirror-unofficial/config.git /tmp/config.git; } && test "$(git -C /tmp/config.git rev-parse 'c8ddc8472f8efcadafc1ef53ca1d863415fddd5f^{tree}')" = ee86c1ed9b947daa7323495324474abd78bd0ee3
mkdir -p /home/docker/Lakka/sources/configtools && git -C /tmp/config.git archive --format=tar --prefix=config-c8ddc8472f8efcadafc1ef53ca1d863415fddd5f/ c8ddc8472f8efcadafc1ef53ca1d863415fddd5f | gzip -n > /home/docker/Lakka/sources/configtools/configtools-c8ddc8472f8efcadafc1ef53ca1d863415fddd5f.tar.gz
echo regenerated > /home/docker/Lakka/sources/configtools/configtools-c8ddc8472f8efcadafc1ef53ca1d863415fddd5f.tar.gz.url && echo 6389d62e4e55554c764c2c0deb5b42767f34d7f274728c28355fedbaa337165b > /home/docker/Lakka/sources/configtools/configtools-c8ddc8472f8efcadafc1ef53ca1d863415fddd5f.tar.gz.sha256
chown -R docker:docker /home/docker/Lakka
sudo -u docker -H env LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 PROJECT=RPi DEVICE=RPi3-Composite ARCH=aarch64 bash -c 'cd /home/docker/Lakka && scripts/build uae4arm'
B=$(ls -d /home/docker/Lakka/build.Lakka-RPi3-Composite.aarch64* | head -1) && echo "build dir: $B"
f=$(find "$B"/install_pkg -path '*uae4arm*' -name uae4arm_libretro.so | head -1) && test -n "$f" && mkdir -p /tmp/out && cp "$f" /tmp/out/uae4arm_libretro.so
export PATH="$B/toolchain/bin:$PATH" && command -v aarch64-libreelec-linux-gnueabi-readelf
mkdir -p /output/dist
install -D -m 0644 /tmp/out/uae4arm_libretro.so /output/dist/cores64/uae4arm_libretro.so
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if aarch64-libreelec-linux-gnueabi-readelf -h "$file" >/dev/null 2>&1; then
    aarch64-libreelec-linux-gnueabi-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
