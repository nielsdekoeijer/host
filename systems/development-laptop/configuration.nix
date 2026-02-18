{ config, pkgs, user, hostName, stateVersion, lib, ... }: {
  # propegate the state version
  system.stateVersion = stateVersion;

  # propegate the host name
  networking.hostName = hostName;

  # compatability
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ stdenv.cc.cc ];
  };

  # direnv
  programs.direnv.enable = true;

  # bin bash
  services.envfs.enable = true;

  # enable flakes and nix-command, you always want this
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # always fine, could be parameterized in the future
  time.timeZone = "Europe/Amsterdam";

  # enable network manager, disable wpa_supplicant
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;

  # enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # devport
  networking.firewall.allowedTCPPorts = [ 8000 9190 ];

  # NOTE: needs dbus for network manager to work! So enable that
  services.dbus.enable = true;

  # avahi
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.addresses = true;

  # more aggressive oom killer
  services.earlyoom = {
      enable = true;
  };

  # TODO: I dont know why this is needed
  networking.useDHCP = lib.mkDefault true;

  # this is good for getting wifi + other drivers to work, requires non-free
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  # additional settings for user
  # TODO: should be in home-manager?
  users.groups.${user}.gid = 1000;
  users.users.${user} = {
    isNormalUser = true;
    initialPassword = " ";
    extraGroups = [ "wheel" "video" "input" "seat" "docker" "users" ];
    group = "${user}";
    uid = 1000;
  };

  # adb/fastboot binaries
  environment.systemPackages = [ 
      pkgs.android-tools 
      pkgs.man-pages 
      pkgs.avahi 
      (pkgs.writeShellScriptBin "show-products" ''
          ${pkgs.avahi}/bin/avahi-browse -rtp _bangolufsen._tcp | ${pkgs.gawk}/bin/awk -F"\;" '/^=/ {print $4, $8}'
      '')
  ];

  # enable man pages
  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.includeAllModules = true;                                         
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
}
