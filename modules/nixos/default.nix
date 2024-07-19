{ config, lib, ... }:

{
  imports = [
    ./environments/gnome.nix
    ./environments/hyprland.nix
    ./environments/plasma.nix
  ];
}
