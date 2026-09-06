{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.git-hooks;
  formattersCfg = config.myOptions.formatters;

  preCommitScript = import ./pre-commit.nix {
    inherit lib;
    inherit (formattersCfg) systemFormatters verbose;
  };

  # Build the template tree out-of-store, then symlink via xdg.configFile.
  hookTemplate = pkgs.runCommand "git-hook-templates" {} ''
    mkdir -p $out/hooks
    cat > $out/hooks/pre-commit <<'__EOF__'
    ${preCommitScript}
    __EOF__
    chmod +x $out/hooks/pre-commit
  '';
in {
  imports = [./formatters.nix ./fish.nix];
  options.myOptions.git-hooks = {
    enable = mkEnableOption "Global git hooks";
  };

  config = mkIf cfg.enable {
    # Place the templates under ~/.config/git/templates/. `git init` (and
    # implicit init via `git clone`) copies everything from
    # `init.templateDir` into the new repo's `.git/`.
    xdg.configFile."git/templates".source = hookTemplate;

    # Tell git to use the template dir for new repos.
    programs.git.settings.init.templateDir = "${config.xdg.configHome}/git/templates";

    # Default formatter config: a global ~/.editorconfig honored by prettier,
    # shfmt, taplo, and most editors. Repo-local .editorconfig with
    # `root = true` overrides this entirely; otherwise the closer file wins
    # per-key.
    home.file.".editorconfig".source = ./files/editorconfig;

    # Formatter packages. Optional ones are included so the hook can use them
    # whenever a matching file is staged.
    home.packages = with pkgs; [
      alejandra
      go
      black
      rustfmt
      shfmt
      yamlfmt
      taplo
      stylua
      prettier
    ];
  };
}
