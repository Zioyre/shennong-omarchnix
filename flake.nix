{
  description = "Xiaomi 14 Pro Titanium (shennong) — Omarchnix (NixOS + Hyprland) container for Droidspaces";

  inputs = {
    omarchnix.url = "github:Th0rgal/omarchnix";
    droidspaces.url = "github:ravindu644/Droidspaces-OSS";
    nixpkgs.follows = "omarchnix/nixpkgs";
    home-manager.follows = "omarchnix/home-manager";
  };

  outputs =
    {
      self,
      omarchnix,
      droidspaces,
      nixpkgs,
      ...
    }@inputs:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ omarchnix.overlays.default ];
      };
      gpuPkgs = import ./pkgs/gpu-stack.nix {
        inherit pkgs;
        inherit (nixpkgs) lib;
      };
    in
    {
      packages.${system} = {
        inherit (gpuPkgs) mesa-razr-kgsl aquamarine-razr;
        gpu-stack = pkgs.symlinkJoin {
          name = "shennong-gpu-stack";
          paths = [
            gpuPkgs.mesa-razr-kgsl
            gpuPkgs.aquamarine-razr
          ];
        };
      };

      nixosConfigurations.shennong = omarchnix.lib.mkHost {
        platform = "container";
        inherit system;
        includeSops = false;
        extraSpecialArgs = {
          inherit inputs gpuPkgs;
        };
        modules = [
          droidspaces.nixosModules.working-droidspaces-rootfs-minimal
          ./hosts/shennong.nix
        ];
      };
    };
}
