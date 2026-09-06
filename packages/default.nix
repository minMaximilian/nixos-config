{
  pkgs,
  inputs ? {},
}: let
  # ponytail: explicit selections keep package provenance visible without an overlay.
  stable =
    if inputs ? nixpkgs-stable
    then import inputs.nixpkgs-stable {inherit (pkgs.stdenv.hostPlatform) system;}
    else pkgs;
in {
  codex = pkgs.callPackage ./codex {};
  helium = pkgs.callPackage ./helium {};
  krita = pkgs.callPackage ./krita {};
  vesktop = pkgs.vesktop.overrideAttrs (import ./vesktop {inherit (pkgs) lib xdg-utils;});
  url-privacy = pkgs.callPackage ./url-privacy {};
  deadlock-mod-manager = pkgs.callPackage ./deadlock-mod-manager {};

  inherit (stable) jujutsu libreoffice;
  graalvm21 =
    if inputs ? nixpkgs-graalvm21 && pkgs.stdenv.hostPlatform.system == "x86_64-linux"
    then (import inputs.nixpkgs-graalvm21 {localSystem = "x86_64-linux";}).graalvm-ce
    else null;
}
