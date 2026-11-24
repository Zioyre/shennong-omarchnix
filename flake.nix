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
      ...
    }@inputs:
    {
      nixosConfigurations.shennong = omarchnix.lib.mkHost {
        platform = "container";
        system = "aarch64-linux";
        includeSops = false;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [
          droidspaces.nixosModules.working-droidspaces-rootfs-minimal
          ./hosts/shennong.nix
        ];
      };
    };
}
