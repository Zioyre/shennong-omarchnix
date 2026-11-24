# shennong-omarchnix

Declarative **Omarchnix (NixOS + Hyprland)** workstation running natively inside a **Droidspaces** Linux container on a rooted **Xiaomi 14 Pro Titanium (`shennong`, Snapdragon 8 Gen 3, GKI `6.1.138-android14-11`)** alongside HyperOS + Magisk.

Built on:
- [Th0rgal/omarchnix](https://github.com/Th0rgal/omarchnix) (`platform = "container"`, `aarch64-linux`)
- [ravindu644/Droidspaces-OSS](https://github.com/ravindu644/Droidspaces-OSS) (native Linux namespace container runtime + NixOS rootfs module)
- [Th0rgal/sidesystem](https://github.com/Th0rgal/sidesystem) (`sidesystem-ctl` + `bt-hid-bridge`)

## GitHub Actions Workflows

1. **`Build GKI 6.1.138-android14-11 Kernel (Droidspaces + NixOS)`**
   - Compiles exact stock commit `0c3d559bcd85` (`refs/tags/android14-6.1-2025-06_r15`) with Droidspaces' SYSVIPC kABI padding patch (`slot 6_7_8` default) and Droidspaces + NixOS defconfig flags (`CONFIG_PID_NS`, `CONFIG_IPC_NS`, `CONFIG_SYSVIPC`, `CONFIG_POSIX_MQUEUE`, `CONFIG_DEVTMPFS`, `CONFIG_USER_NS`, `CONFIG_TMPFS_XATTR`, `CONFIG_TMPFS_POSIX_ACL`).
   - Preserves **Magisk** (which lives in `init_boot` on Android 14 GKI 6.1 devices).
   - Produces `AnyKernel3.zip`, `boot*.img`, and raw `Image`.

2. **`Build Omarchnix ARM64 NixOS Rootfs & SideSystem Tools`**
   - Runs natively on `ubuntu-24.04-arm`.
   - Builds `.#nixosConfigurations.shennong.config.system.build.tarball` (`shennong-omarchnix-rootfs.tar.xz`).
   - Compiles static ARM64 `bt-hid-bridge` and packages the `shennong`-adapted `sidesystem-ctl`.

## Quick Setup Steps on Xiaomi 14 Pro Titanium

### 1. Back up your stock `boot` image first
In Termux (`su`):
```sh
SLOT=$(getprop ro.boot.slot_suffix)
dd if=/dev/block/by-name/boot${SLOT} of=/sdcard/stock_boot${SLOT}.img
```
Copy `/sdcard/stock_boot*.img` off the phone to your PC so you can always restore via `fastboot flash boot stock_boot.img`.

### 2. Flash the Droidspaces GKI `6.1.138-android14-11` kernel
Download the `AnyKernel3.zip` from the kernel workflow run and flash it with Horizon Kernel Flasher / Franco Kernel Manager / EX Kernel Manager / TWRP (or flash `boot.img` via `fastboot flash boot ...` — matching your stock boot compression). Reboot and verify:
```sh
zcat /proc/config.gz | grep -E 'CONFIG_(PID_NS|IPC_NS|SYSVIPC|POSIX_MQUEUE|TMPFS_XATTR)='
```
All five should print `=y`, and Magisk should remain active.

### 3. Install Droidspaces & import the NixOS rootfs
1. Install the latest [Droidspaces APK](https://github.com/ravindu644/Droidspaces-OSS/releases/latest), grant Magisk root, and run **Settings → Requirements → Check Requirements**.
2. Copy `shennong-omarchnix-rootfs.tar.xz` to `/sdcard/Download/`.
3. In Droidspaces: **Containers → + → Install from file** → select `shennong-omarchnix-rootfs.tar.xz`, name it `shennong`, enable Hardware Access (for GPU), and start it.

### 4. Start Hyprland over VNC / USB-C DisplayPort
Default user inside the container: `zioyre` (initial password `omarchnix`, SSH on port `2222`).

Install `sidesystem-ctl` and `bt-hid-bridge` into `/data/local/nixos/bin/` on Android, then:
```sh
su -c "/data/local/nixos/bin/sidesystem-ctl desktop start 1080p 1"
```
Connect with **AVNC** to `127.0.0.1:5900` (on the phone screen or fullscreen on an external USB-C DP Alt Mode monitor). Switch to Adreno 750 Turnip/Zink hardware rendering with `sidesystem-ctl gpu hw`.
