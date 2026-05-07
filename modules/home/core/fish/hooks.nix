{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.myOptions.fish;
in {
  config = lib.mkIf cfg.enable {
    programs.fish.functions = {
      git-init-hooks = ''
        if ! git rev-parse --git-dir > /dev/null 2>&1
          echo "Not in a git repository" >&2
          return 1
        end

        set -l git_dir (git rev-parse --git-dir)
        set -l template_dir (git config --get init.templateDir)

        if test -z "$template_dir"
          set template_dir "$HOME/.config/git/templates"
        end

        if not test -d "$template_dir/hooks"
          echo "No hooks found in template directory: $template_dir/hooks/" >&2
          return 1
        end

        mkdir -p "$git_dir/hooks"
        cp -rfL "$template_dir/hooks/." "$git_dir/hooks/"
        chmod +x "$git_dir/hooks/"*
        echo "Git hooks installed from $template_dir/hooks/ into $git_dir/hooks/"
      '';

      git-disable-hooks = ''
        if ! git rev-parse --git-dir > /dev/null 2>&1
          echo "Not in a git repository" >&2
          return 1
        end

        set -l git_dir (git rev-parse --git-dir)

        if test -f "$git_dir/hooks/pre-commit"
          mv "$git_dir/hooks/pre-commit" "$git_dir/hooks/pre-commit.disabled"
          echo "Pre-commit hook disabled"
        else
          echo "No pre-commit hook found" >&2
        end
      '';

      git-enable-hooks = ''
        if ! git rev-parse --git-dir > /dev/null 2>&1
          echo "Not in a git repository" >&2
          return 1
        end

        set -l git_dir (git rev-parse --git-dir)

        if test -f "$git_dir/hooks/pre-commit.disabled"
          mv "$git_dir/hooks/pre-commit.disabled" "$git_dir/hooks/pre-commit"
          echo "Pre-commit hook enabled"
        else
          echo "No disabled pre-commit hook found. Run git-init-hooks to install." >&2
        end
      '';
    };

    # Add abbreviations
    programs.fish.shellAbbrs = {
      gih = "git-init-hooks";
      gdh = "git-disable-hooks";
      geh = "git-enable-hooks";
    };
  };
}
