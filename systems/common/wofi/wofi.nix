{ pkgs, ... }: {
  # Enable wofi
  programs.wofi.enable = true;

  # Basic wofi settings
  # You might need to adjust the font size
  programs.wofi.settings = {
    font = "FantasqueSansM Nerd Font 12";
    allow_markup = true;
    width = "30%";
    height = "40%";
    show = "drun"; # Show applications by default
    normal_window = true; # Run in a normal window (can be better for some WMs)
  };

  # CSS styling to match your 'aurora' theme
  programs.wofi.style = ''
    * {
      font-family: "FantasqueSansM Nerd Font";
      font-size: 14px;
    }

    window {
      background-color: #211c2f; /* aurora background */
      border: 1px solid #e7d3fb; /* CHANGED: aurora foreground (white) border */
      border-radius: 0px; /* CHANGED: No rounding */
    }

    #input {
      background-color: #211c2f; /* aurora selection-background */
      color: #e7d3fb; /* aurora foreground */
      border: 1px solid #e7d3fb; /* CHANGED: aurora foreground (white) border */
      border-radius: 0px; /* CHANGED: No rounding */
      padding: 8px;
      margin: 10px;
    }

    #input:focus {
      border-color: #ddd0f4; /* aurora cursor-color */
    }

    #inner-box {
      margin: 5px;
    }

    #scroll {
      margin: 0px 5px;
    }

    #entry {
      padding: 8px;
      border-radius: 0px; /* CHANGED: No rounding */
    }

    #text {
      color: #e7d3fb; /* aurora foreground */
    }

    #entry:selected {
      background-color: #3f4060; /* aurora selection-background */
    }

    #entry:selected #text {
      color: #e7d3fb; /* aurora cursor-color */
    }
  '';
}


