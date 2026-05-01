let
  niels = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCOaFvac4Ra2ZW3pKwV04NDgtio/y8sVDxTVAkWnnDD niels@work-laptop-2";
in
{
    "devices/work-laptop-2/wg0.age".publicKeys = [niels];
}
