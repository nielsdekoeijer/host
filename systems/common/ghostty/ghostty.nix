{ pkgs, ... }: {
  # ghostty settings
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      font-family = "FantasqueSansM Nerd Font";
      background-opacity = 0.95;
      theme = "aurora";
    };
    themes = {
      aurora = {
        background = "211c2f";
        foreground = "e7d3fb";
        cursor-color = "ddd0f4";
        selection-background = "3f4060";
        selection-foreground = "e7d3fb";
        working-directory = "home";
        confirm-close-surface = "false";

        palette = [
          "0=#070510" # Black
          "1=#ff5874" # Red
          "2=#addb67" # Green
          "3=#ecc48d" # Yellow
          "4=#be9af7" # Blue
          "5=#FD9720" # Magenta
          "6=#A1EFE4" # Cyan
          "7=#645775" # White
          "8=#211c2f" # Bright Black
          "9=#ec5f67" # Bright Red
          "10=#d7ffaf" # Bright Green
          "11=#fbec9f" # Bright Yellow
          "12=#6690c4" # Bright Blue
          "13=#ffbe00" # Bright Magenta
          "14=#54CED6" # Bright Cyan
          "15=#e7d3fb" # Bright White
        ];
      };
    };
  };
}
