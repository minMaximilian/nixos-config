{
  imports = [
    ../../modules/nixos/games/steam.nix
    ../../modules/nixos/games/prism-launcher.nix
  ];
  myOptions.steam.enable = true;
  myOptions.prismLauncher.enable = true;
}
