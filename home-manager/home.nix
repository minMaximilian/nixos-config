{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    zsh
  ];

  programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
    };
    home-manager.enable = true;
  };

  home.stateVersion = "24.05"; 
}
