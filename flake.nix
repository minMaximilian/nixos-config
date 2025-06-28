{
  description = "";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprlock.url = "github:hyprwm/Hyprlock";
    hyprlock.inputs.nixpkgs.follows = "nixpkgs";
    hyprcursor.url = "github:hyprwm/hyprcursor";
    hyprcursor.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    spicetify-nix.url = "github:gerg-l/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixcord.url = "github:kaylorben/nixcord";
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./hosts
        ./parts
      ];
    };
}
