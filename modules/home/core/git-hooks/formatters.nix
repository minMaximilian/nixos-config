{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.myOptions.formatters = {
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

    verbose = mkOption {
      type = types.bool;
      default = false;
      description = "Enable verbose output from formatters";
    };
  };
}
