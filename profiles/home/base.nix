{
  imports = [
    ../../modules/home/core/git
    ../../modules/home/core/git-hooks
    ../../modules/home/core/fish
    ../../modules/home/core/neovim
    ../../modules/home/core/btop
    ../../modules/home/core/zellij
    ../../modules/home/core/jj
  ];
  myOptions = {
    git.enable = true;
    git-hooks.enable = true;
    fish.enable = true;
    neovim.enable = true;
    btop.enable = true;
    zellij.enable = true;
    jj.enable = true;
  };
}
