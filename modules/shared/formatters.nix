{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.myOptions.formatters = {
    enable = lib.mkEnableOption "Global formatters system";

    # Each pattern maps to a list of formatter invocations.
    # Each invocation is a list: [ "command" "arg1" "arg2" ... ].
    # The hook appends the staged file path as the final argument.
    # Order matters: the first invocation whose command resolves is used.
    systemFormatters = mkOption {
      type = types.attrsOf (types.listOf (types.listOf types.str));
      default = {
        # Nix
        ".*\\.nix$" = [["alejandra" "--quiet"]];

        # Go
        ".*\\.go$" = [["gofmt" "-w"]];

        # Python
        ".*\\.py$" = [["black" "--quiet"]];

        # Rust
        ".*\\.rs$" = [["rustfmt"]];

        # Shell
        ".*\\.(sh|bash)$" = [["shfmt" "-w"]];

        # YAML — prefer prettier (honors .editorconfig/.prettierrc), fall back to yamlfmt
        ".*\\.(yaml|yml)$" = [
          ["prettier" "--write" "--ignore-unknown"]
          ["yamlfmt"]
        ];

        # TOML
        ".*\\.toml$" = [["taplo" "format"]];

        # Lua
        ".*\\.lua$" = [["stylua"]];

        # JS / TS / JSON / Markdown / CSS / HTML / Vue / Svelte / GraphQL
        ".*\\.(js|jsx|mjs|cjs|ts|tsx|mts|cts)$" = [["prettier" "--write" "--ignore-unknown"]];
        ".*\\.(json|jsonc|json5)$" = [["prettier" "--write" "--ignore-unknown"]];
        ".*\\.(md|mdx|markdown)$" = [["prettier" "--write" "--ignore-unknown"]];
        ".*\\.(css|scss|sass|less)$" = [["prettier" "--write" "--ignore-unknown"]];
        ".*\\.(html|htm|vue|svelte)$" = [["prettier" "--write" "--ignore-unknown"]];
        ".*\\.(graphql|gql)$" = [["prettier" "--write" "--ignore-unknown"]];
      };
      description = ''
        Map of regex pattern (matched against staged filename) to an ordered list
        of formatter invocations. Each invocation is `[command ...staticArgs]`;
        the hook appends the file path as the final argument.
      '';
    };

    projectConfigFiles = mkOption {
      type = types.listOf types.str;
      default = [
        ".pre-commit-config.yaml"
        ".pre-commit-config.yml"
        "pre-commit.config.yaml"
        "pre-commit.config.yml"
        "treefmt.toml"
        "treefmt.nix"
        ".editorconfig"
        # JS / Node ecosystem markers — when present, system formatters will
        # pick up local rc files automatically and prefer node_modules/.bin.
        "package.json"
        ".prettierrc"
        ".prettierrc.json"
        ".prettierrc.yaml"
        ".prettierrc.yml"
        ".prettierrc.js"
        ".prettierrc.cjs"
        ".prettierrc.toml"
        "prettier.config.js"
        "prettier.config.cjs"
        "prettier.config.mjs"
      ];
      description = "Config files that indicate project-specific formatting rules";
    };

    templateDir = mkOption {
      type = types.str;
      default = "\${config.xdg.configHome}/git/templates";
      description = "Directory for global git templates";
    };

    formatInPlace = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to format files in-place (true) or fail when formatting is needed (false). Currently only in-place mode is supported.";
    };

    verbose = mkOption {
      type = types.bool;
      default = false;
      description = "Enable verbose output from formatters";
    };
  };
}
