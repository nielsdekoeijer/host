{ pkgs, user, stateVersion, ... }: {
  # with home manager, we configure user only packages and dotfiles
  home = {
    # the user for our system
    username = user;

    # propegate nixos base version
    stateVersion = stateVersion;

    # packages for the user
    packages = [
      pkgs.neovim
      pkgs.nixfmt-classic
      pkgs.ripgrep
      pkgs.dwl
      pkgs.foot
      pkgs.htop
      pkgs.wmenu
      pkgs.dejavu_fonts
    ];

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
    shellAliases = { vi = "nvim"; };
    bashrcExtra = ''
      export EDITOR=nvim
      export VISUAL=nvim
      export PAGER="nvim +Man!"
      PS1="\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;31m\]$HOSTNAME\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "
    '';
  };

  # enable firefox
  programs.firefox.enable = true;

}
