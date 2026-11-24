{
  lib,
  pkgs,
  ...
}:
{
  networking.hostName = "shennong";

  omarchnix = {
    enable = true;
    profile = "container";
    hardening.enable = false;
    containers.enable = false;
    secrets.enable = false;
    desktop = {
      enable = true;
      user = "zioyre";
      autostartTty.enable = false;
    };
  };

  # Ensure container-safe defaults don't collide with Droidspaces' rootfs module
  boot.isContainer = lib.mkForce true;

  # Disable bare-metal daemons that cannot/should not manage host hardware from inside an Android container
  security.auditd.enable = lib.mkForce false;
  systemd.oomd.enable = lib.mkForce false;
  services.timesyncd.enable = lib.mkForce false;
  services.chrony.enable = lib.mkForce false;
  services.ntp.enable = lib.mkForce false;
  services.thermald.enable = lib.mkForce false;
  services.fwupd.enable = lib.mkForce false;
  services.smartd.enable = lib.mkForce false;
  services.irqbalance.enable = lib.mkForce false;
  services.udisks2.enable = lib.mkForce false;
  services.upower.enable = lib.mkForce false;
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Normal desktop user inside the NixOS container
  users.users.zioyre = {
    isNormalUser = true;
    uid = 1000;
    initialPassword = "omarchnix";
    extraGroups = [
      "wheel"
      "video"
      "render"
      "audio"
      "input"
      "tty"
      "aid_inet"
      "aid_net_raw"
      "aid_net_admin"
    ];
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = false;

  # SSH on port 2222 so it never collides with Android
  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "prohibit-password";
    };
  };

  # Headless Wayland + VNC + GPU diagnostics expected by sidesystem-ctl
  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    sway
    wayvnc
    dbus
    mesa
    vulkan-tools
    procps
    iproute2
    openssh
    git
    vim
  ];
}
