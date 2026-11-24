{
  lib,
  pkgs,
  gpuPkgs,
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
  systemd.services.rtkit-daemon.enable = lib.mkForce false;
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

  # Android mounts nosuid tmpfs; allow internal user@1000.service via pam_permit
  security.pam.services.systemd-user.text = lib.mkForce ''
    account required pam_permit.so
    session required pam_limits.so
    session required pam_env.so
    session required pam_systemd.so
  '';

  # Map Android/Droidspaces supplementary GIDs for native GPU/input/network access
  users.groups = {
    droidspaces-gpu.gid = 786;
    aid_graphics.gid = 1003;
    aid_input.gid = 1004;
  };

  # Normal desktop user inside the NixOS container
  users.users.zioyre = {
    isNormalUser = true;
    uid = 1000;
    linger = true;
    initialPassword = "omarchnix";
    extraGroups = [
      "wheel"
      "video"
      "render"
      "audio"
      "input"
      "tty"
      "droidspaces-gpu"
      "aid_graphics"
      "aid_input"
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
    startWhenNeeded = false;
    ports = [ 2222 ];
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "prohibit-password";
    };
  };

  # Headless Wayland + VNC + Adreno 750 Turnip/Zink KGSL GPU stack
  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    gpuPkgs.mesa-razr-kgsl
    gpuPkgs.aquamarine-razr
    sway
    wayvnc
    sunshine
    dbus
    mesa
    vulkan-tools
    mesa-demos
    procps
    iproute2
    openssh
    git
    vim
  ];

  home-manager.users.zioyre = {
    services.hypridle.enable = lib.mkForce false;
  };
}
