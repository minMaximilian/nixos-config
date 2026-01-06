{
  description = "";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-graalvm21.url = "github:NixOS/nixpkgs/336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3";
    nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprlock.url = "github:hyprwm/Hyprlock";
    hyprlock.inputs.nixpkgs.follows = "nixpkgs";
    hyprcursor.url = "github:hyprwm/hyprcursor";
    hyprcursor.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";

    spicetify-nix.url = "github:gerg-l/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
    };

    nixcord = {
      url = "github:FlameFlag/nixcord";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./hosts
        ./parts
      ];

      flake = {
        overlays.default = import ./overlays/default.nix;

        nixosModules = {
          default = ./modules/nixos;
          vars = ./modules/shared/vars.nix;
          shared = ./modules/nixos/shared;
          amdgpu = ./modules/nixos/amdgpu;
          audio = ./modules/nixos/audio;
          bluetooth = ./modules/nixos/bluetooth;
          desktop = ./modules/nixos/desktop;
          fonts = ./modules/nixos/fonts;
          games = ./modules/nixos/games;
          login = ./modules/nixos/login;
          logitech = ./modules/nixos/logitech;
          shell = ./modules/nixos/shell;
          theme = ./modules/nixos/theme;
        };

        homeModules = {
          default = ./modules/home;
          core = ./modules/home/core;
          gui = ./modules/home/gui;
          vars = ./modules/shared/vars.nix;

          # Individual core modules for selective import
          btop = ./modules/home/core/btop;
          devenv = ./modules/home/core/devenv;
          fish = ./modules/home/core/fish;
          git = ./modules/home/core/git;
          golang = ./modules/home/core/golang;
          neovim = ./modules/home/core/neovim;
        };

        lib = import ./lib;
      };
    };
}
