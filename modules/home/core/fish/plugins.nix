{pkgs}: [
  {
    name = "pure";
    inherit (pkgs.fishPlugins.pure) src;
  }
  {
    name = "fzf.fish";
    src = pkgs.fetchFromGitHub {
      owner = "PatrickF1";
      repo = "fzf.fish";
      rev = "e5d54b93cd3e096ad6c2a419df33c4f50451c900";
      hash = "sha256-5cO5Ey7z7KMF3vqQhIbYip5JR6YiS2I9VPRd6BOmeC8=";
    };
  }
]
