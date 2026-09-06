# Explicit source-only entrypoint: this does not evaluate flake.nix.
{
  neovim = ./core/neovim;
  git = ./core/git;
  git-hooks = ./core/git-hooks;
  fish = ./core/fish;
  zellij = ./core/zellij;
  ideavim = ./core/ideavim;
}
