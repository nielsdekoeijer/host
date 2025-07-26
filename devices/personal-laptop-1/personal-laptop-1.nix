{ nixpkgs, home-manager, disko, system }:

# note that we symlink but must still respect the relative path 
(import ../../systems/development-laptop/system.nix) {
  inherit nixpkgs home-manager disko system;
  user = "niels";
  hostName = "nixos-laptop";
  stateVersion = "25.11";
  diskoConfiguration = { ... }: {
    disko.devices = {
      disk = {
        vdb = {
          device = "/dev/nvme0n1";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "100M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}

