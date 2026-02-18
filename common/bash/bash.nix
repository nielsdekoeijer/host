{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      EDITOR="nvim"
      VISUAL="nvim"
      PAGER="nvimpager";
      MANPAGER="nvimpager -c 'set ft=man'";
      PS1="\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;31m\]$HOSTNAME\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "
    '';
  };
}
