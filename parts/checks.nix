{
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks = {
      preservation = assert import ../tests/preservation.nix {
        config = self.nixosConfigurations.whiteforest.config;
      };
        pkgs.runCommand "preservation-inventory-check" {} "touch $out";
      password-migration =
        pkgs.runCommand "password-migration-tests" {
          nativeBuildInputs = [pkgs.bash pkgs.coreutils pkgs.gawk];
        } ''
          bash ${../tests/password-migration.sh} ${../scripts/migrate-shadow-to-passwords.sh}
          touch "$out"
        '';
      miniflux =
        pkgs.runCommand "miniflux-tests" {
          nativeBuildInputs = [pkgs.bash pkgs.coreutils pkgs.jq pkgs.python3];
        } ''
          python3 ${../tests/miniflux.py} ${pkgs.writeText "miniflux-test.opml" (import ../modules/nixos/miniflux/opml.nix {inherit (pkgs) lib;} (import ../tests/miniflux-feeds.nix))} ${../modules/nixos/miniflux/sync-feeds.sh}
          touch "$out"
        '';
      git-hooks =
        pkgs.runCommand "git-hook-tests" {
          nativeBuildInputs = [pkgs.python3 pkgs.git pkgs.bash];
        } ''
          python3 ${../tests/test_git_hook.py} ${pkgs.writeText "test-pre-commit" (import ../tests/git-hook.nix {inherit (pkgs) lib;})}
          touch "$out"
        '';
      home-module-evaluation = assert import ../tests/home-modules.nix {inherit inputs system;};
      assert import ../tests/home-modules.nix {
        inherit inputs;
        system = "aarch64-darwin";
      };
        pkgs.runCommand "home-module-evaluation" {} "touch $out";
      headless-evaluation = assert import ../tests/headless.nix {inherit inputs system;};
        pkgs.runCommand "headless-evaluation" {} "touch $out";
      editor =
        pkgs.runCommand "editor-smoke-test" {
          nativeBuildInputs = [
            self.nixosConfigurations.ravenholm.config.home-manager.users.max.nixCats.out.packages.nixcats-nvim
          ];
        } ''
          export XDG_STATE_HOME="$TMPDIR/state"
          export XDG_DATA_HOME="$TMPDIR/data"
          export XDG_CACHE_HOME="$TMPDIR/cache"
          export NVIM_LOG_FILE="$TMPDIR/nvim.log"
          cd ${../.}
          nvim --headless -u NONE -c 'luafile tests/editor-smoke.lua'
          touch "$out"
        '';
      url-privacy = pkgs.runCommand "url-privacy-tests" {nativeBuildInputs = [pkgs.python3];} ''
        export PYTHONDONTWRITEBYTECODE=1
        python3 -m unittest discover -s ${../modules/home/gui/url-privacy} -p 'test_*.py' -v
        touch "$out"
      '';
    };
  };
}
