{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;

    sharedModules = import ../modules;

    pkgs-stable = import inputs.nixpkgs-stable {
      system = "x86_64-linux";
    };

    specialArgs = {
      inherit inputs pkgs-stable self;
    };
  in {
    whiteforest = nixosSystem {
      inherit specialArgs;
      modules = [
        sharedModules
        inputs.home-manager.nixosModules.home-manager
        ./whiteforest/configuration.nix
      ];
    };

    ravenholm = nixosSystem {
      inherit specialArgs;
      modules = [
        sharedModules
        inputs.home-manager.nixosModules.home-manager
        ./ravenholm/configuration.nix
      ];
    };
  };
}
