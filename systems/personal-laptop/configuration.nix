{ config, pkgs, user, hostName, stateVersion, lib, ... }: {
  # propegate the state version
  system.stateVersion = stateVersion;

  # propegate the host name
  networking.hostName = hostName;

  # enable flakes and nix-command, you always want this
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # always fine, could be parameterized in the future
  time.timeZone = "Europe/Amsterdam";

  # enable network manager, disable wpa_supplicant
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  # enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # NOTE: needs dbus for network manager to work! So enable that
  services.dbus.enable = true;

  # TODO: I dont know why this is needed
  networking.useDHCP = lib.mkDefault true;

  # this is good for getting wifi + other drivers to work, requires non-free
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  # additional settings for user
  # TODO: should be in home-manager?
  users.users.${user} = {
    isNormalUser = true;
    initialPassword = " ";
    extraGroups = [ "wheel" "video" "input" "seat" "docker" ];
  };

  # configure the bootloader
  # TODO: I just copy pasted this, I dont know what any of it means yet
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

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "uinput" "kvm-intel" ];
  };

  # docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless.enable = true;

  # enable pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # enable touchpad support
  services.libinput.enable = true;

  # configure graphics
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.open = true;

  # configure displaymanager
  services.displayManager.gdm.enable = true;
  programs.hyprland = { enable = true; };
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # dunno

  # nix ld
  programs.nix-ld.enable = true;
}
