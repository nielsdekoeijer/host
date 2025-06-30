{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    font.name = "FantasqueSansM Nerd Font";
    font.size = 10;
  };
}
