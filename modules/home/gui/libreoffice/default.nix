{
  config,
  inputs ? {},
  lib,
  pkgs,
  ...
}: let
  libreoffice =
    if inputs ? nixpkgs-stable
    then (import inputs.nixpkgs-stable {inherit (pkgs.stdenv.hostPlatform) system;}).libreoffice
    else pkgs.libreoffice;
in {
  options.myOptions.libreoffice.enable = lib.mkEnableOption "LibreOffice office suite";

  config = lib.mkIf config.myOptions.libreoffice.enable {
    home.packages = [libreoffice];
  };
}
