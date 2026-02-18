# common/configuration.nix
#
# Shared NixOS configuration for all devices.
{
  config,
  pkgs,
  user,
  hostName,
  stateVersion,
  lib,
  ...
}:
{
  system.stateVersion = stateVersion;
  networking.hostName = hostName;

  # flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # timezone
  time.timeZone = "Europe/Amsterdam";

  # networking
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
  services.dbus.enable = true;

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # firmware
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;

  # user
  users.groups.${user}.gid = 1000;
  users.users.${user} = {
    isNormalUser = true;
    initialPassword = " ";
    group = "${user}";
    uid = 1000;
    extraGroups = [
      "wheel"
      "video"
      "input"
      "seat"
      "docker"
    ];
  };

  # man pages
  environment.systemPackages = [ pkgs.man-pages ];
  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.includeAllModules = true;
  };

  # bootloader
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 42;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    kernelPackages = pkgs.linuxPackages;
    kernelModules = [
      "uinput"
      "kvm-intel"
    ];
  };

  # docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless.enable = true;

  # audio
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # touchpad
  services.libinput.enable = true;

  # display manager + hyprland
  services.displayManager.gdm.enable = true;
  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # nix-ld
  programs.nix-ld.enable = true;

  # direnv + envfs
  programs.direnv.enable = true;
  services.envfs.enable = true;

  # OOM killer
  services.earlyoom.enable = true;
}
