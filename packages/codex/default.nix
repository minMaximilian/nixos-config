{
  lib,
  stdenv,
  stdenvNoCC,
  codex,
  fetchurl,
}: let
  codexVersion = "0.153.3";
  codexPackage =
    # Remove when fixed upstream: https://github.com/NixOS/nixpkgs/issues/550421
    if stdenv.hostPlatform.system == "x86_64-linux" && lib.versionOlder codex.version codexVersion
    then
      stdenvNoCC.mkDerivation {
        pname = "codex";
        version = codexVersion;
        src = fetchurl {
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
          codex.meta
          // {
            sourceProvenance = [lib.sourceTypes.binaryNativeCode];
            platforms = ["x86_64-linux"];
          };
      }
    else codex;
in
  codexPackage
