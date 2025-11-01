{ pkgs, ... }: {

  # programs.bat.enable = true;
  #
  # programs.ghostty = {
  #   enable = true;
  #   enableZshIntegration = true;
  #
  #   settings = {
  #     auto-update = "off";
  #     background-opacity = 0.8;
  #     confirm-close-surface = false;
  #     font-family = "FiraCode Nerd Font Mono";
  #     font-size = 12;
  #     theme = "Teerb";
  #   };
  # };
  #
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    font.name = "FantasqueSansM Nerd Font";
    font.size = 12;
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      window_padding_width = 2;
      window_padding_height = 1;
      background_opacity = "0.9";
      hide_window_decorations = true;
    };
  };
}

