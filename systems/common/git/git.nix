{ pkgs, ... }: {
  # git settings
  programs.git = {
    enable = true;
    settings.user.name = "Niels de Koeijer";
    settings.user.email = "hidden@email.com";
  };
}
