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
    pkgs.lazygit

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

  programs.obsidian = {
    enable = true;
    vaults."repositories/personal/vault".enable = true;

    defaultSettings = {
      app = {
        defaultViewMode = "preview";
        livePreview = true;
        readableLineLength = true;
        showLineNumber = true;
        tabSize = 4;
      };

      corePlugins = [
        "bookmarks"
        "daily-notes"
        "templates"
        "command-palette"
        "file-explorer"
        "sync"
      ];

      communityPlugins = [
      ];

      hotkeys = {
          "command-palette:open" = [ { key = "F1"; } ];
      };
    };
  };

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
