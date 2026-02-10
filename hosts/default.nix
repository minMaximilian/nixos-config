{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;

    sharedModules = import ../modules;

    pkgs-graalvm21 = import inputs.nixpkgs-graalvm21 {
      system = "x86_64-linux";
    };

    specialArgs = {
      inherit inputs pkgs-graalvm21 self;
    };
  in {
    whiteforest = nixosSystem {
      inherit specialArgs;
      modules = [
        sharedModules
        ./whiteforest/configuration.nix
      ];
    };

    ravenholm = nixosSystem {
      inherit specialArgs;
      modules = [
        sharedModules
        ./ravenholm/configuration.nix
      ];
    };
  };
}
