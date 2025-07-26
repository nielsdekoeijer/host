# Niels Nix Stuff

## Good commands:
After booting into the iso:
```bash
# get into root mode
sudo -i

# use disko to partition our disk!
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
        --mode destroy,format,mount $DISKO_PATH_HERE

# move to /mnt/etc/nixos/
mv . /mnt/etc/nixos

# install
nixos-install --flake $FLAKE_PATH_HERE

# change passwd
nixos-enter --root /mnt/ -c "passwd niels"
```

## Sources:
* https://github.com/dustinlyons/nixos-config/tree/main/templates/starter

## Issues:
* I maintain about 3 systems, a personal laptop, a work laptop and a shell config. Selecting which
    one I want to install is not easy with this setup, I'm always just randomly changing the 
    files. Works well but is akward. 
* I need to be able to overload the hyprctl for multi monitor
* Waybar for multi monitor
