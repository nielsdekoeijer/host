{ pkgs, user, hostName, stateVersion, lib, ... }: {
  imports = [ ./disko.nix ];

  # propegate the state version
  system.stateVersion = stateVersion;

  networking.hostName = hostName;
  networking.wireless.enable = true;
  networking.useDHCP = lib.mkDefault true;

  services.dbus.enable = true;
  hardware.enableAllFirmware = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Amsterdam";

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

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

}
