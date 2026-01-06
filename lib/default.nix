{
  # Helper to create the specialArgs needed by this flake's modules
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

  # Module metadata - documents required inputs for each module
  # Used by consumers to know what inputs they need
  moduleInputs = {
    # Home modules
    fish = [];
    git = [];
    btop = [];
    devenv = [];
    golang = [];
    neovim = ["nixCats"];

    # NixOS modules
    vars = [];
    audio = [];
    bluetooth = [];
    fonts = [];
    shell = [];
    amdgpu = [];
    logitech = [];
    desktop = ["hyprland" "hyprlock" "hyprcursor"];
    theme = ["stylix"];
    login = ["hyprland"];
    games = [];
  };

  # Standalone modules (no input dependencies) - safe for any consumer
  standalone = {
    home = ["fish" "git" "btop" "devenv" "golang"];
    nixos = ["vars" "audio" "bluetooth" "fonts" "shell" "amdgpu" "logitech" "games"];
  };
}
