{ pkgs, user, stateVersion, ... }: {
  # with home manager, we configure user only packages and dotfiles
  home = {
    # the user for our system
    username = user;

    # propegate nixos base version
    stateVersion = stateVersion;

    # packages for the user
    packages = [ pkgs.neovim pkgs.nixfmt-classic pkgs.ripgrep pkgs.kitty pkgs.hyprland pkgs.wofi ];

  };

  # git settings
  programs.git = {
    enable = true;
    userName = "Niels";
    userEmail = "hidden@email.com";
  };

  # bash settings
  programs.bash = {
    enable = true;
    shellAliases = {
    vi = "nvim";
    };
  };

  # enable firefox
  programs.firefox.enable = true;

  # configure hyprland
  # wayland.windowManager.hyprland = {
  #  enable = true;
  #  # extraConfig = ''
  #  # 	$menu = wofi --show drun
  #  # '';
  #  };
}
