# Niels Nix Stuff

## Install (from ISO)

Build and burn the ISO:
```bash
./build-iso.sh
./burn-iso.sh /dev/sdX
```

Boot the USB. You'll auto-login as root and see a prompt. Then:

```bash
nmcli device wifi rescan
nmcli device wifi connect "SSID" --ask
install-nixos
```

After it finishes:
```bash
# set your password
nixos-enter --root /mnt -c "passwd niels"
# reboot
reboot
```

## Adding a new device
1. Create `devices/<name>/` with `configuration.nix`, `home-manager.nix`, and `disko.nix`
2. `disko.nix` can just be `import ../../common/disko/standard-nvme.nix` or a custom layout
3. `configuration.nix` imports `../../common/configuration.nix` + any hardware modules
4. `home-manager.nix` imports `../../common/home-manager.nix` + any extra packages
5. Add the device to `flake.nix`
6. Build ISO, boot, run `install-nixos`

## Good commands
```bash
# rebuild current host
./switch.sh

# format all nix files
./format.sh

# build installer ISO
./build-iso.sh

# burn ISO to USB
./burn-iso.sh /dev/sdX
```

## Sources
* https://github.com/dustinlyons/nixos-config/tree/main/templates/starter
