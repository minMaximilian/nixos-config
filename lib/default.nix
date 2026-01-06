{
  # Helper to create the specialArgs needed by this flake's modules
  # Consumers should call this with their inputs that match the required ones
  mkSpecialArgs = {
    inputs,
    self,
    pkgs-stable ? null,
    pkgs-graalvm21 ? null,
  }:
    {
      inherit inputs self;
    }
    // (
      if pkgs-stable != null
      then {inherit pkgs-stable;}
      else {}
    )
    // (
      if pkgs-graalvm21 != null
      then {inherit pkgs-graalvm21;}
      else {}
    );

  # Required flake inputs for full module compatibility
  # Consumers should have these inputs in their flake to use all modules
  requiredInputs = {
    # Core
    nixpkgs = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = "github:nix-community/home-manager";

    # Desktop (required for desktop/GUI modules)
    hyprland = "github:hyprwm/Hyprland";
    hyprlock = "github:hyprwm/Hyprlock";
    hyprcursor = "github:hyprwm/hyprcursor";
    stylix = "github:danth/stylix";

    # Applications (required for specific app modules)
    zen-browser = "github:0xc000022070/zen-browser-flake";
    firefox-addons = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    spicetify-nix = "github:gerg-l/spicetify-nix";
    nixcord = "github:FlameFlag/nixcord";
    nixCats = "github:BirdeeHub/nixCats-nvim";
  };

  # Modules grouped by their input requirements
  moduleGroups = {
    # Modules with no external input dependencies (safe to use anywhere)
    standalone = [
      "vars"
      "audio"
      "bluetooth"
      "fonts"
      "shell"
      "amdgpu"
      "logitech"
    ];

    # Modules requiring specific inputs
    withInputs = {
      desktop = ["hyprland" "hyprlock" "hyprcursor"];
      theme = ["stylix"];
      login = ["hyprland"]; # Uses hyprland for greeter
      games = []; # Check if any inputs needed
    };
  };
}
