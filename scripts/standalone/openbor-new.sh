#!/usr/bin/env bash
# openbor-new: cores-experimental standalone recipe openbor-new (c40801e), as `cores.py standalone script` renders it,
# with patches at /work/patches/. Runs in cores-standalone-armhf:v1 (archive cores-standalone-armhf-v1.tar.gz).
set -euo pipefail
trap 'chown -R "$OUTPUT_UID:$OUTPUT_GID" /output' EXIT
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS ASMFLAGS ASFLAGS MAKE MAKEFLAGS GNUMAKEFLAGS MAKEFILES MAKEOVERRIDES MFLAGS GIT_VERSION EMULATOR_BUILD HAS_GPU IS_X86 USE_BLARGG_APU ARCH ARCH_AARCH64 ARCH_ARM ARCH_X86 ARCH_X86_64 HAVE_SSA LIBRETRO_EMBED_FFMPEG OPENGL CMAKE_TOOLCHAIN_FILE SOURCE_DATE_EPOCH CMAKE_GENERATOR CMAKE_GENERATOR_PLATFORM CMAKE_GENERATOR_TOOLSET CMAKE_BUILD_PARALLEL_LEVEL GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_CONFIG_SYSTEM GIT_CONFIG_GLOBAL GIT_CONFIG_NOSYSTEM GIT_CONFIG
export SOURCE_DATE_EPOCH=1718971200
export LC_ALL=C.UTF-8
umask 022
export CROSS=arm-a30-linux-gnueabihf SOURCE=/src BUILD_DIR=/tmp/standalone-build DIST=/output/dist
git clone --filter=blob:none --no-checkout https://github.com/DCurrent/OpenBOR.git /src
git -C /src checkout -q b00efbc7752cb55709dfc9fdfdfc7cfe78ddfb90
test "$(git -C /src rev-parse 'HEAD^{tree}')" = 49fa213af1b9fb69dd98253496ed1f7c4f99dcc4
git -C /src rev-parse HEAD > /output/source-commit.txt
mkdir -p "$(dirname /tmp/src_openbor-v1.2.zip)"
PATH=/usr/bin:$PATH python3 -c 'import shutil, sys, urllib.request; request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "cores-experimental"}); shutil.copyfileobj(urllib.request.urlopen(request), open(sys.argv[2], "wb"))' https://github.com/steward-fu/website/releases/download/miyoo-a30/src_openbor-v1.2.zip /tmp/src_openbor-v1.2.zip
echo 'f98bc7ae29387c2201748f12652d283d0fb3bcfdfab7ef08912140df35675f31  /tmp/src_openbor-v1.2.zip' | sha256sum -c -
cd /src
set +u +o pipefail
python3 -c 'import sys, zipfile; z = zipfile.ZipFile(sys.argv[1]); [open(n, "wb").write(z.read("src_openbor_new/" + n)) for n in ("engine/Makefile", "engine/sdl/control.c", "engine/sdl/menu.c", "engine/sdl/video.c", "engine/version.h")]' /tmp/src_openbor-v1.2.zip
test "$(git status --porcelain | sort | tr '\n' ' ')" = ' M engine/Makefile  M engine/sdl/control.c  M engine/sdl/menu.c  M engine/sdl/video.c '
grep -q '^ifdef BUILD_A30' engine/Makefile && grep -q 'VERSION_COMMIT "b00efbc"' engine/version.h
test "$(readlink /opt/a30/bin/arm-linux-gcc)" = toolchain-wrapper && test -x /opt/a30/bin/arm-linux-gcc.br_real
cd engine
make -j"$(nproc)" BUILD_A30=1
mkdir -p /output/dist
install -D -m 0755 /src/engine/OpenBOR /output/dist/OpenBOR_new
(cd /output/dist && find . -type f | LC_ALL=C sort | while read -r file; do
  if arm-a30-linux-gnueabihf-readelf -h "$file" >/dev/null 2>&1; then
    arm-a30-linux-gnueabihf-readelf -d "$file" | awk -v file="${file#./}" '/\((NEEDED|SONAME)\)/ { match($0, /\[.*\]/); kind = ($2 ~ /NEEDED/) ? "needed" : "soname"; print file "\t" kind "\t" substr($0, RSTART + 1, RLENGTH - 2) }'
  fi
done) > /output/elf.tsv
