# Evaluate against a checkout and already locked inputs, without activating it.
{
  root,
  inputs,
}: let
  f = (import (root + "/flake.nix")).outputs (inputs // {self = f // {outPath = root;};});
  lib = inputs.nixpkgs.lib;
  package = p: {
    name = lib.getName p;
    version = lib.getVersion p;
    drv = p.drvPath;
    out = toString p;
  };
  snapshot = host: let
    c = host.config;
    h = c.home-manager.users.max;
  in {
    systemPackages = map package c.environment.systemPackages;
    homePackages = map package h.home.packages;
    systemVersion = c.system.stateVersion;
    homeVersion = h.home.stateVersion;
    homeFiles =
      lib.mapAttrs (_: v: {
        inherit (v) enable target text;
        source =
          if v.source == null
          then null
          else toString v.source;
      })
      h.home.file;
    homeServices = h.systemd.user.services;
    homeSession = h.home.sessionVariables;
    systemUnits = lib.mapAttrs (_: v: {inherit (v) enable text;}) c.systemd.units;
    users =
      lib.mapAttrs (_: u: {
        inherit (u) uid group extraGroups home isNormalUser hashedPasswordFile;
        keys = u.openssh.authorizedKeys.keys;
      })
      c.users.users;
    fileSystems = lib.mapAttrs (_: v: {inherit (v) device fsType options neededForBoot;}) c.fileSystems;
    preservation = c.preservation.preserveAt or {};
    tmpfiles = c.systemd.tmpfiles.rules;
    firewall = {inherit (c.networking.firewall) enable allowedTCPPorts allowedUDPPorts;};
    hyprland = h.wayland.windowManager.hyprland.settings;
    git = h.programs.git.settings;
    zellij = h.programs.zellij.settings;
  };
in
  lib.mapAttrs (_: snapshot) f.nixosConfigurations
