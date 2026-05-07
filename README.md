# Niels Nix Stuff
Repository containing my custom nixos installation. I have one particular setup that I enjoy and want to run on all
possible computers. To do this, I factor common functionality in the `common` directory. This effectively is a library
that is then used by `hosts` to implement specific hosts. My `switch.sh` script then installs a given host
given a configuration.

## TODOs:
* I have the foundations of an ISO build there, but I am not quite happy with how it ends up working. What I really 
    want is the following:
    - Install ISO, should install a "basic" setup. I want my `host` repository contained within, preferably up to date.
        I suppose I could use a github action to create the ISO with the latest. The "basic" setup should preferably
        have my whole setup (describing the `common` configuration).
    - Given my partitioning of `common` and `hosts`, on install I want to have a script ONLY in the ISO that basically
        1) pulls the latest update of the repo, I should clone with https so that SSH setup is not required
        2) generates a new `host` with a given hostname.
        3) instructs the user to make changes to said `host` until they are happy.
        4) when the user is ready, `./switch.sh --install` something or other should install the repository
            - do all the partitioning
            - move the repository to `$HOME/repositories/personal/host` which is my prefered place for it
            - change the repository to ssh from https somehow
            - perhaps run `./switch.sh` after everything is in place in case it matters 
            - suggest the user to push their changes upstream
    - Currently, I don't think its like this. It should be a goal on my next reinstall to do this!
* I want to understand my setup more. I semi-vibed it meaning there are holes in my understanding.

## Install (from ISO), currently janky

Build and burn the ISO:
```bash
./build-iso.sh
./burn-iso.sh /dev/sdX
```

Boot the USB. You'll auto-login as root and see a prompt. Then:

```bash
nmcli host wifi rescan
nmcli host wifi connect "SSID" --ask
install-nixos
```

After it finishes:
```bash
# set your password
nixos-enter --root /mnt -c "passwd niels"
# reboot
reboot
```

## Adding a new host
1. Create `hosts/<name>/` with `configuration.nix`, `home-manager.nix`, and `disko.nix`
2. `disko.nix` can just be `import ../../common/disko/standard-nvme.nix` or a custom layout
3. `configuration.nix` imports `../../common/configuration.nix` + any hardware modules
4. `home-manager.nix` imports `../../common/home-manager.nix` + any extra packages
5. Add the host to `flake.nix`
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
