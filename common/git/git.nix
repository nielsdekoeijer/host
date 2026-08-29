{ config, pkgs, ... }:
let
  nvim = "${config.programs.neovim.finalPackage}/bin/nvim";
in
{
  programs.git = {
    enable = true;

    userName = "Niels de Koeijer";

    extraConfig = {
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
      difftool.prompt = false;
      mergetool.prompt = false;
      mergetool.keepBackup = false;

      difftool."nvimdiff".cmd = ''${nvim} -d "$LOCAL" "$REMOTE"'';
      mergetool."nvimdiff".cmd = ''${nvim} -d "$LOCAL" "$BASE" "$REMOTE" "$MERGED" -c 'wincmd J' '';
    };

    includes = [
      {
        condition = "gitdir:~/repositories/work/";
        contents = {
          user = {
            name = "Niels de Koeijer";
            email = "NEMK@bang-olufsen.dk";
          };
          core = {
            sshCommand = "ssh -i ~/.ssh/work";
          };
        };
      }
      {
        condition = "gitdir:~/repositories/personal/";
        contents = {
          user = {
            name = "Niels de Koeijer";
            email = "nielsdekoeijer@gmail.com";
          };
          core = {
            sshCommand = "ssh -i ~/.ssh/private";
          };
        };
      }
      {
        condition = "gitdir:~/nixos/";
        contents = {
          user = {
            name = "Niels de Koeijer";
            email = "nielsdekoeijer@gmail.com";
          };
          core = {
            sshCommand = "ssh -i ~/.ssh/private";
          };
        };
      }
    ];
  };
}
