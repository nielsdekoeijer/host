{
  pkgs,
  user,
  stateVersion,
  ...
}:
{
  home.packages = [
    # formatters
    pkgs.nixfmt

    # sound
    pkgs.pwvucontrol

    # helpers
    pkgs.nvimpager
    pkgs.htop
    pkgs.rsync
    pkgs.jq
    pkgs.ripgrep
    pkgs.tree
    pkgs.unzip
    pkgs.zip
    pkgs.bat
    pkgs.swww

    # typst
    pkgs.typst

    # hyprland
    pkgs.hyprshot
    pkgs.bibata-cursors

    # font
    pkgs.nerd-fonts.fantasque-sans-mono

    # gui
    pkgs.networkmanagerapplet
    pkgs.kdePackages.okular
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "nvim +Man!";
  };

  programs.firefox.enable = true;

  imports = [
    ./nvim/nvim.nix
    ./bash/bash.nix
    ./hyprland/hyprland.nix
    ./waybar/waybar.nix
    ./ghostty/ghostty.nix
    ./git/git.nix
    ./wofi/wofi.nix
  ];
}
