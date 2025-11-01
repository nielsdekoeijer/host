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

      # typst for note-taking
      pkgs.typst

      # for hyprland
      pkgs.wofi
      pkgs.hyprshot
      pkgs.bibata-cursors
      # pkgs.ghostty

      # font for everything
      pkgs.nerd-fonts.fantasque-sans-mono

      # perf
      pkgs.linuxPackages_latest.perf
      pkgs.croc

    ];

    # set variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "nvim +Man!";
    };
  };

  # ghostty settings
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      font-family = "FantasqueSansM Nerd Font";
      background-opacity = 0.95;
      theme = "aurora";
    };
    themes = {
      aurora = {
        background = "211c2f";
        foreground = "645775";
        cursor-color = "ddd0f4";
        selection-background = "3f4060";
        selection-foreground = "e7d3fb";

        palette = [
          "0=#070510" # Black
          "1=#ff5874" # Red
          "2=#addb67" # Green
          "3=#ecc48d" # Yellow
          "4=#be9af7" # Blue
          "5=#FD9720" # Magenta
          "6=#A1EFE4" # Cyan
          "7=#645775" # White
          "8=#211c2f" # Bright Black
          "9=#ec5f67" # Bright Red
          "10=#d7ffaf" # Bright Green
          "11=#fbec9f" # Bright Yellow
          "12=#6690c4" # Bright Blue
          "13=#ffbe00" # Bright Magenta
          "14=#54CED6" # Bright Cyan
          "15=#e7d3fb" # Bright White
        ];
      };
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
    ../common/nvim/nvim.nix
    ../common/kitty/kitty.nix
    ../common/bash/bash.nix
    ../common/waybar/waybar.nix
    ../common/hyprland/hyprland.nix
  ];

}
