{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.myOptions.codex;

  codexVersion = "0.153.3";
  codexPackage =
    # Remove when fixed upstream: https://github.com/NixOS/nixpkgs/issues/550421
    if pkgs.stdenv.hostPlatform.system == "x86_64-linux" && lib.versionOlder pkgs.codex.version codexVersion
    then
      pkgs.stdenvNoCC.mkDerivation {
        pname = "codex";
        version = codexVersion;
        src = pkgs.fetchurl {
          url = "https://releases.openai.com/codex/releases/${codexVersion}/codex-package-x86_64-unknown-linux-musl.tar.gz";
          hash = "sha256-R7sfs2+x29X+GvPrDbQi/7TDw42cF2LHYYqb7UbESmM=";
        };
        dontUnpack = true;
        installPhase = ''
          runHook preInstall
          mkdir -p "$out"
          tar -xzf "$src" -C "$out"
          runHook postInstall
        '';
        doInstallCheck = true;
        installCheckPhase = ''
          test "$("$out/bin/codex" --version)" = "codex-cli ${codexVersion}"
        '';
        meta =
          pkgs.codex.meta
          // {
            sourceProvenance = [lib.sourceTypes.binaryNativeCode];
            platforms = ["x86_64-linux"];
          };
      }
    else pkgs.codex;
in {
  options.myOptions.codex = {
    enable = mkEnableOption "OpenAI Codex CLI coding agent";
  };

  config = mkIf cfg.enable {
    home.packages = [
      codexPackage
    ];

    home.activation.configureCodex = lib.hm.dag.entryAfter ["writeBoundary"] ''
      config_file="$HOME/.codex/config.toml"

      run mkdir -p "$HOME/.codex"
      run touch "$config_file"
      run ${pkgs.perl}/bin/perl -0pi -e '
        s/^(?:approval_policy|sandbox_mode)\s*=.*\n//mg;
        s/\n?\[plugins\."impeccable\@personal"\]\n(?:[^\[]*\n?)//g;
        s/\n?\[plugins\."impeccable\@impeccable"\]\n(?:[^\[]*\n?)//g;
        s/\n?\[marketplaces\.impeccable\]\n(?:[^\[]*\n?)//g;
        $_ = qq{approval_policy = "never"\nsandbox_mode = "workspace-write"\n\n} . $_;
      ' "$config_file"

    '';
  };
}
