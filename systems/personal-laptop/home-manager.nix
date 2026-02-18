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

      # helpers
      pkgs.nvimpager
      pkgs.htop
      pkgs.rsync
      pkgs.jq
      pkgs.ripgrep
      pkgs.tree

      # typst for note-taking
      pkgs.typst

      # for hyprland
      pkgs.wofi
      pkgs.hyprshot
      pkgs.bibata-cursors

      # font for everything
      pkgs.nerd-fonts.fantasque-sans-mono

      # discord
      pkgs.discord

      # obsidian
      pkgs.obsidian
    ];

    # set variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "nvim +Man!";
    };
  };

  # git settings
  programs.git = {
    enable = true;
    userName = "Niels";
    userEmail = "hidden@email.com";
  };

  # firefox settings
  programs.firefox.enable = true;

  # import common
  imports = [
    ../../common/nvim/nvim.nix
    ../../common/bash/bash.nix
    ../../common/waybar/waybar.nix
    ../../common/hyprland/hyprland.nix
    ../../common/ghostty/ghostty.nix
    ../../common/wofi/wofi.nix
  ];

  wayland.windowManager.hyprland.extraConfig = pkgs.lib.mkForce ''
    monitor=eDP-2,preferred,0x0,1.6
    monitor=eDP-4,1920x1080@165.00,auto,1
    misc {
        vrr = 0
    }
  '';

}
