{
  description = "NixOS configuration flake";

  inputs = {
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-graalvm21.url = "github:NixOS/nixpkgs/336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3";
    nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    nix-jetbrains-plugins.url = "github:nix-community/nix-jetbrains-plugins";

    nixcord.url = "github:FlameFlag/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";

    noctalia.url = "github:noctalia-dev/noctalia";

    omp.url = "github:can1357/oh-my-pi";

    impeccable = {
      url = "github:pbakaus/impeccable";
      flake = false;
    };

    rss-archive-proxy.url = "path:/home/max/workspace/repos/rss-archive-proxy";
    rss-archive-proxy.inputs.nixpkgs.follows = "nixpkgs";

    preservation.url = "github:nix-community/preservation";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";

    zls-overlay.url = "github:zigtools/zls";
    zls-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./hosts
        ./parts
      ];

      flake = {
        overlays.default = final: prev: (import ./overlays/default.nix final prev);

        nixosModules = import ./modules/nixos/exports.nix;
        homeModules = import ./modules/home/exports.nix;
      };
    };
}
