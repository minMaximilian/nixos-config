{
  pkgs,
  inputs,
  ...
}: {
  imports = [../../profiles/home/base.nix];
  _module.args.localPackages = import ../../packages {inherit pkgs inputs;};
  home.username = "max";
  home.homeDirectory = "/home/max";
  programs.git.settings.user = {
    name = "minmaximilian";
    email = "minmaximilian@noreply.codeberg.org";
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings.hermes = {
      HostName = "127.0.0.1";
      Port = 2222;
      User = "max";
    };
  };
}
