{ pkgs, user, stateVersion, ... }: {
  # with home manager, we configure user only packages and dotfiles
  home = {
    # set home dir
    homeDirectory = "/home/${user}/";

    # the user for our system
    username = user;

    # propegate nixos base version
    stateVersion = stateVersion;

    # packages for the user
    packages = [
      # formatters
      pkgs.nixfmt-classic

      # helpers
      pkgs.nvimpager
      pkgs.htop
      pkgs.rsync
      pkgs.jq
      pkgs.ripgrep
      pkgs.tree

      # typst for note-taking
      pkgs.typst
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

  # import common
  imports = [
    ../common/nvim/nvim.nix
    ../common/bash/bash.nix
  ];

}
