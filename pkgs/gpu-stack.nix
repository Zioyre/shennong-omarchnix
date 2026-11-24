{
  lib,
  pkgs,
}:
{
  # Patched Mesa (Turnip KGSL without KHR_display abort + ZINK_KGSL_FALLBACK=1)
  # for native Qualcomm Adreno 750 GPU acceleration over /dev/kgsl-3d0.
  mesa-razr-kgsl =
    (pkgs.mesa.override {
      galliumDrivers = [
        "zink"
        "llvmpipe"
        "softpipe"
        "virgl"
      ];
      vulkanDrivers = [ "freedreno" ];
      vulkanLayers = [ ];
    }).overrideAttrs
      (old: {
        pname = "mesa-razr-kgsl";
        patches = (old.patches or [ ]) ++ [ ../patches/mesa-razr-kgsl.patch ];
        mesonFlags =
          (builtins.filter (
            f:
            !(lib.hasPrefix "-Dgallium-rusticl=" f)
            && !(lib.hasPrefix "-Dtools=" f)
            && !(lib.hasPrefix "-Dteflon=" f)
          ) (old.mesonFlags or [ ]))
          ++ [
            "-Dgallium-rusticl=false"
            "-Dtools="
            "-Dteflon=false"
          ];
        postInstall = (old.postInstall or "") + "\nmkdir -p $spirv2dxil $opencl $cross_tools\n";
        postFixup = builtins.replaceStrings [ " $opencl/lib/libRusticlOpenCL.so" ] [ "" ] (
          old.postFixup or ""
        );
      });

  # Patched Aquamarine allowing AQ_HEADLESS_DRM_NODE=/dev/dri/renderD128 so Hyprland
  # runs standalone in GPU-accelerated headless mode (zero outer sway, zero llvmpipe).
  aquamarine-razr = pkgs.aquamarine.overrideAttrs (old: {
    pname = "aquamarine-razr";
    patches = (old.patches or [ ]) ++ [ ../patches/aquamarine-headless-drm.patch ];
  });
}
