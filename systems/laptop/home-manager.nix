{ pkgs, user, stateVersion, ... }: {
  # with home manager, we configure user only packages and dotfiles
  home = {
    # the user for our system
    username = user;

    # propegate nixos base version
    stateVersion = stateVersion;

    # packages for the user
    packages = [ pkgs.neovim pkgs.nixfmt ];

  };

  # git settings
  programs.git = {
    enable = true;
    userName = "Niels";
    userEmail = "hidden@email.com";
  };

}
