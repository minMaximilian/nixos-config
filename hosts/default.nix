{inputs, ...}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;

    specialArgs = {
      inherit inputs;
    };
  in {
    whiteforest = nixosSystem {
      inherit specialArgs;
      modules = [
        ./whiteforest/configuration.nix
      ];
    };

    ravenholm = nixosSystem {
      inherit specialArgs;
      modules = [
        ./ravenholm/configuration.nix
      ];
    };
  };
}
