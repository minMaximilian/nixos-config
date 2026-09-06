{
  inputs,
  system,
}: let
  overlay = import ../overlays;
  openldap = version: {
    inherit version;
    overrideAttrs = f: {inherit version;} // f {};
  };
  host = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {inherit inputs;};
    modules = [
      ../profiles/nixos/base.nix
      ../users/max/nixos.nix
      {
        system.stateVersion = "24.11";
        home-manager.users.max.home.stateVersion = "24.11";
        fileSystems."/" = {
          device = "none";
          fsType = "tmpfs";
        };
      }
    ];
  };
in
  assert !(overlay {} {openldap = openldap "2.6.13";}).openldap.doCheck;
  assert (overlay {} {openldap = openldap "2.6.14";}).openldap.version == "2.6.14";
  assert !((overlay {} {openldap = openldap "2.6.14";}).openldap ? doCheck);
  assert !host.config.programs.hyprland.enable;
  assert !host.config.services.greetd.enable;
  assert !(host.config.home-manager.users.max.myOptions.hyprland.enable or false);
    builtins.deepSeq host.config.system.build.toplevel.drvPath true
