{
  description = "Max's Nix Files";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    globalModules = [
      {
        system.configurationRevision = self.rev or self.dirtyRev or null;
      }
      ./modules/nixos/default.nix
      ./modules/home-manager/default.nix
    ];
    inherit (self) outputs;
  in {
    formatter = {
      x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;
      aarch64-linux = inputs.nixpkgs.legacyPackages.aarch64-linux.alejandra;
      x86_64-darwin = inputs.nixpkgs.legacyPackages.x86_64-darwin.alejandra;
      aarch64-darwin = inputs.nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    };

    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        system = "x86_64-linux";
        modules = globalModules ++ [./hosts/laptop/configuration.nix];
      };
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        system = "x86_64-linux";
        modules = globalModules ++ [./hosts/desktop/configuration.nix];
      };
      wsl = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        system = "x86_64-linux";
        modules = globalModules ++ [./hosts/wsl/configuration.nix];
      };
    };
  };
}
