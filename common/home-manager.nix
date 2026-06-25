{
  pkgs,
  user,
  stateVersion,
  ...
}:
let
  # Build the pdf++ plugin manually using exact release assets
  obsidian-pdf-plus = pkgs.stdenv.mkDerivation rec {
    pname = "obsidian-pdf-plus";
    version = "0.40.31";

    # Skip unpacking since we are downloading raw files, not an archive
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out

      cp ${
        pkgs.fetchurl {
          url = "https://github.com/RyotaUshio/obsidian-pdf-plus/releases/download/${version}/main.js";
          sha256 = "3fd395ca015ff812df8a48e75da0ec7a7ab5a6f59406d375470898b1f72aac93";
        }
      } $out/main.js

      cp ${
        pkgs.fetchurl {
          url = "https://github.com/RyotaUshio/obsidian-pdf-plus/releases/download/${version}/manifest.json";
          sha256 = "dca50165b74316cdb2b76c92084374997be7949d216b31efcecc2b82ff4a086c";
        }
      } $out/manifest.json

      cp ${
        pkgs.fetchurl {
          url = "https://github.com/RyotaUshio/obsidian-pdf-plus/releases/download/${version}/styles.css";
          sha256 = "4d944d6ea7aa581fdcd8367c9d8ab09f37c5a8c594e336547795f79f2ede4066";
        }
      } $out/styles.css
    '';
  };
in
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
    vaults."default".enable = true;
    vaults."default".target = "repositories/personal/vault";

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
        obsidian-pdf-plus
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
