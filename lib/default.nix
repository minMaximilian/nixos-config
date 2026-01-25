{
  moduleInputs = {
    fish = [];
    git = [];
    btop = [];
    devenv = [];
    golang = [];
    neovim = ["nixCats"];

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

  standalone = {
    home = ["fish" "git" "btop" "devenv" "golang"];
    nixos = ["vars" "audio" "bluetooth" "fonts" "shell" "amdgpu" "logitech" "games"];
  };
}
