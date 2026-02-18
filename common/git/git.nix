{ pkgs, ... }:
{
  programs.git = {
    enable = true;

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
