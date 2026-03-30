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
      rev = "v11.0";
      hash = "sha256-H7HgYT+okuVXo2SinrSs+hxAKCn4Q4su7oMbebKd/7s=";
    };
  }
]
