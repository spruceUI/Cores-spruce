# Cores-spruce

Build bot for libretro cores targeting spruceOS handheld devices. Builds 32-bit (armhf) and 64-bit (arm64) cores using [libretro-super](https://github.com/libretro/libretro-super).

## Supported devices

| Arch | Devices |
|------|---------|
| arm64 | Trimui Brick, Smart Pro, Smart Pro S, Miyoo Flip |
| armhf | Miyoo Mini/Mini+, Miyoo A30 |

## How it works

- Two Docker images (cached on the `toolchains` release) provide cross-compilation environments
- Each core has its own GitHub Actions workflow — trigger individually or use **Build All Cores** to build everything in parallel
- Output: one zip per core containing `cores/` (armhf), `cores64/` (arm64), and a `.info` metadata file
- Built cores are uploaded to the `beta-{branch}` release
- Some workflows default `core_ref` to the commit that [cores-experimental](https://github.com/spruceUI/cores-experimental) builds and load-tests, with its flags and patches (`patches/<core>/`); a blank `core_ref` builds upstream's latest

## Usage

1. **Build Docker images** (only needed once, or after Dockerfile changes): run `Build Docker Images`
2. **Build one core**: run `Build <corename>` from Actions
3. **Build all cores**: run `Build All Cores` from Actions
4. **Build a standalone emulator or app**: run `Build <name>` (BigPEmu, Flycast standalone, GameTank standalone,
   GVU, Mupen64Plus standalone, PPSSPP, ScummVM, vtree), or `Build All Standalones`. Each build
   is a cores-experimental recipe in `scripts/standalone/`, run in that repo's image from its `toolchains` release
   (checked by sha256). `check.py` checks the libraries each build needs and compares its files with what spruce
   ships. The zip holds the files at their card paths. `azahar` and `yabasanshiro_generic` are cores built the same
   way, and are part of Build All Cores.

## What the cores-experimental recipes ship

Each recipe below rebuilds, byte for byte, what spruceOS ships
([cores-experimental](https://github.com/spruceUI/cores-experimental) checks this; spruceOS `Development` 7592638d0).
The scripts in `scripts/standalone/` were rendered from cores-experimental 9f6b4d3. Devices are spruce's
`$PLATFORM` groups (`spruce/scripts/helperFunctions.sh`):
- `DARKMOSS`: RGB30, RGB20SX, RG353M, E5 Plus, Miniloong, A10 Mini, XU Mini M, G350, V10, Pixel 2 on dArkMoss
- `OAKMOSS_A133P`: MagicX Zero 28, Zero 40, XU20; Powkiddy V90S, V20
- `TRIMUI_A133P`: Brick, Brick Pro, Smart Pro
- `ANBERNIC_RGXX`: the H700 RG devices
- `MIYOO_MINI_FAMILY`: Mini, Mini v4, Mini Plus, Mini Flip

| workflow (zip) | recipe | ships as | devices |
|---|---|---|---|
| Build azahar (`azahar_libretro.zip`) | `azahar-libretro` | `RetroArch/.retroarch/cores64/azahar_libretro.so` | 3DS default on MIYOO_FLIP, OAKMOSS_A133P, and DARKMOSS's RGB30, RGB20SX, RG353M, E5 Plus and Miniloong |
| Build yabasanshiro_generic (`yabasanshiro_generic_libretro.zip`) | `yabasanshiro-libretro` | `RetroArch/.retroarch/cores64/yabasanshiro_generic_libretro.so` | Saturn default on DARKMOSS, MIYOO_FLIP, ANBERNIC_RGXX, TRIMUI_SMART_PRO_S, TRIMUI_A133P and OAKMOSS_A133P (GKD_PIXEL2 has its own core) |
| Build flycast (`flycast_libretro.zip`, its arm64 half) | `flycast-libretro-t3` | `RetroArch/.retroarch/cores64/flycast_libretro.so` | Dreamcast, NAOMI and Atomiswave default on MIYOO_FLIP, TRIMUI_A133P, TRIMUI_SMART_PRO_S, ANBERNIC_RGXX and OAKMOSS_A133P |
| Build Flycast standalone (`flycast-standalone.zip`) | `flycast-standalone-t3-lto` | `Emu/DC/flycast`, `Emu/DC/lib64/` | Dreamcast default on DARKMOSS; an option for Dreamcast, NAOMI and Atomiswave on the other 64-bit devices (all three run Emu/DC's copy) |
| Build BigPEmu (`bigpemu.zip`) | `bigpemu` | `Emu/JAGUAR/bigpemu/` | Jaguar default on MIYOO_FLIP, TRIMUI_A133P, TRIMUI_SMART_PRO_S, GKD_PIXEL2, ANBERNIC_RGXX, DARKMOSS and OAKMOSS_A133P |
| Build GameTank standalone (`gametank-standalone.zip`) | `gametank-arm64` | `Emu/GAMETANK/gametank/GameTankEmulator` | a GameTank option on the 64-bit devices (the gametank core is the default) |
| | `gametank-a30` | `Emu/GAMETANK/gametank-a30/GameTankEmulator` | a GameTank option on MIYOO_A30 |
| Build GVU (`gvu.zip`) | `gvu-arm64` | `Emu/MEDIA/bin64/gvu` | the selected media player on MIYOO_FLIP, TRIMUI_A133P, TRIMUI_SMART_PRO_S, ANBERNIC_RGXX, DARKMOSS and OAKMOSS_A133P |
| | `gvu-a30` | `Emu/MEDIA/bin32/gvu` | the selected media player on MIYOO_A30 and MIYOO_MINI_FAMILY |
| Build Mupen64Plus standalone (`mupen64plus-standalone.zip`) | `mupen64plus-arm64-20260404` | `Emu/N64/mupen64plus/`: frontend, core, audio, input and RSP plugins | N64 default on DARKMOSS; an option on MIYOO_FLIP, TRIMUI_A133P, TRIMUI_SMART_PRO_S, GKD_PIXEL2, ANBERNIC_RGXX and OAKMOSS_A133P |
| | `mupen64plus-arm64` | `Emu/N64/mupen64plus/`: the rice and glide64mk2 plugins, `overlay_settings.json` | the same |
| | `mupen64plus-arm64-gliden64-ovl` | `Emu/N64/mupen64plus/mupen64plus-video-GLideN64.so` | the same |
| | `mupen64plus-a30` | `Emu/N64/mupen64plus-a30/` | an N64 option on MIYOO_A30 |
| Build PPSSPP (`ppsspp.zip`) | `ppsspp-h700` | `Emu/PSP/PPSSPPSDL_h700`, `Emu/PSP/assets/` | ANBERNIC_RGXX |
| | `ppsspp-a30` | `Emu/PSP/PPSSPPSDL_A30` | MIYOO_A30 |
| | `ppsspp-flip` | `Emu/PSP/PPSSPPSDL_Flip` (Vulkan on VK_KHR_display) | MIYOO_FLIP |
| | `ppsspp-darkmoss3566` | `Emu/PSP/PPSSPPSDL_dArkMoss3566` | DARKMOSS RK3566 boards: RGB30, RGB20SX, RG353M, E5 Plus, Miniloong |
| | `ppsspp-darkmoss3326` | `Emu/PSP/PPSSPPSDL_dArkMoss3326` | DARKMOSS RK3326 boards: A10 Mini, G350, V10, XU Mini M, Pixel 2 on dArkMoss |
| | `ppsspp-trimui` | `Emu/PSP/PPSSPPSDL_TrimUI` | TRIMUI_A133P, OAKMOSS_A133P |
| | `ppsspp-smartpros` | `Emu/PSP/PPSSPPSDL_SmartProS` | TRIMUI_SMART_PRO_S |
| Build ScummVM (`scummvm.zip`) | `scummvm-arm64` | `Emu/SCUMMVM/scummvm.64` (spruce packs it as `scummvm_64.7z`), `Emu/SCUMMVM/lib/` | MIYOO_FLIP, TRIMUI_A133P, TRIMUI_SMART_PRO_S, GKD_PIXEL2, ANBERNIC_RGXX, OAKMOSS_A133P, DARKMOSS |
| | `scummvm-a30` | `Emu/SCUMMVM/scummvm.a30` (`scummvm_a30.7z`), `fixjoy`, `liba30/` | MIYOO_A30 |
| | `scummvm-mini` | `Emu/SCUMMVM/scummvm.mini` (`scummvm_mini.7z`), `plugins/` (`scummvm_mini_plugins.7z`), `libmini/` | MIYOO_MINI_FAMILY |
| Build vtree (`vtree.zip`) | `vtree-arm64` | `App/FileManagement/vtree.aarch64` | every device but MIYOO_A30 and MIYOO_MINI_FAMILY |
| | `vtree-a30` | `App/FileManagement/vtree.a30`, `lib-A30/` | MIYOO_A30 |
| | `vtree-mini` | `App/FileManagement/vtree.mini` | MIYOO_MINI_FAMILY |

spruce firstboot unpacks ScummVM's `.7z` files into `Emu/SCUMMVM/`. The zips hold the unpacked files. BigPEmu's recipe
also builds 11 files that spruce no longer ships (nine third-party licence texts, `ThirdPartyBin.txt` and
`make_desktop.sh`); they are in the zip but not compared.

## TODO: cores not yet buildable

These cores are shipped by spruceOS but can't be built from libretro-super and need custom build processes:

- [ ] **mkxp-z** — hyphen in name breaks libretro-super's bash variable parsing
- [ ] **mupen64plus** — removed from libretro-super (replaced by mupen64plus_next)
- [ ] **km_flycast_xtreme** — KMFDManic/morpheuscast_xtreme fork uses bare `as` for ARM64 assembly, not cross-compile friendly
- [ ] **km_ludicrousn64_2k22_xtreme_amped** — KMFDManic fork has broken aarch64 dynarec source and missing includes
