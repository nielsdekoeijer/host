{ pkgs, user, stateVersion, ... }: {
  # with home manager, we configure user only packages and dotfiles
  home = {
    # the user for our system
    username = user;

    # propegate nixos base version
    stateVersion = stateVersion;

    # packages for the user
    packages = [
      # formatters
      pkgs.nixfmt-classic

      # sound
      pkgs.pwvucontrol
      pkgs.audacity
      pkgs.qpwgraph

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
      pkgs.kdePackages.okular
      pkgs.swww

      # office
      pkgs.libreoffice
      pkgs.wf-recorder

      # guis
      pkgs.networkmanagerapplet

      # typst for note-taking
      pkgs.typst

      # for hyprland
      pkgs.hyprshot
      pkgs.bibata-cursors

      # font for everything
      pkgs.nerd-fonts.fantasque-sans-mono

      # ai
      pkgs.gemini-cli

      # perf
      pkgs.perf
      pkgs.croc

    ];

    # set variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "nvim +Man!";
    };
  };

  # firefox settings
  programs.firefox.enable = true;

  # import common
  imports = [
    ../../common/nvim/nvim.nix
    ../../common/bash/bash.nix
    ../../common/hyprland/hyprland.nix
    ../../common/waybar/waybar.nix
    ../../common/ghostty/ghostty.nix
    ../../common/git/git.nix
    ../../common/wofi/wofi.nix
  ];

}
