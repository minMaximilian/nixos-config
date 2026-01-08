{lib, ...}: {
  imports = [
    ./shared
    ./git
    ./fish
    ./neovim
    ./btop
    ./devenv
    ./golang
    ./zellij
  ];

  config.myOptions = {
    git.enable = lib.mkDefault true;
    fish.enable = lib.mkDefault true;
    neovim.enable = lib.mkDefault true;
    btop.enable = lib.mkDefault true;
    devenv.enable = lib.mkDefault true;
    golang.enable = lib.mkDefault true;
    zellij.enable = lib.mkDefault true;
  };
}
