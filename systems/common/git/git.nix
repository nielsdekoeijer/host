{ pkgs, ... }: {
  # git settings
  programs.git = {
    enable = true;
    settings.user.name = "Niels de Koeijer";
    settings.user.email = "NEMK@bang-olufsen.com";
  };
}
