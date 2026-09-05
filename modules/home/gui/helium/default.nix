{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myOptions.helium;
  heliumPkg = pkgs.appimageTools.wrapType2 rec {
    pname = "helium";
    version = "0.15.1.1";

    src = pkgs.fetchurl {
      url = "https://github.com/imputnet/helium-linux/releases/download/${version}/${pname}-${version}-x86_64.AppImage";
      hash = "sha256-qz3w+nnvBgkpHT3E34dv4DvFuYlyzTAyg9tPYJFWs3o=";
    };

    extraInstallCommands = let
      contents = pkgs.appimageTools.extract {inherit pname version src;};
    in ''
      install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications
      cp -r ${contents}/usr/share/icons $out/share
    '';
  };

  clearUrlsSource = pkgs.fetchzip {
    url = "https://github.com/ClearURLs/Addon/releases/download/1.27.3/ClearURLs.zip";
    hash = "sha256-cv9xCix68R4PU48bgMB32EJkLWF5NZ4dsqMBfGAi0ko=";
    stripRoot = false;
  };

  clearUrls = pkgs.runCommand "clearurls-1.27.3-configured" {} ''
    cp -R ${clearUrlsSource} "$out"
    chmod -R u+w "$out"
    substituteInPlace "$out/clearurls.js" \
      --replace-fail \
      "let rules = data.providers[prvKeys[p]].getOrDefault('rules', []);" \
      "let rules = data.providers[prvKeys[p]].getOrDefault('rules', []); if (prvKeys[p] === 'instagram') rules.push('igsi');"
  '';

  libRedirectSource = pkgs.fetchzip {
    url = "https://github.com/libredirect/browser_extension/releases/download/v3.3.0/libredirect-3.3.0.zip";
    hash = "sha256-iB6rwkFqToXoYGiEbkXb22Wnxq9UuXOT4TlI9a/Zvl8=";
    stripRoot = false;
  };

  libRedirect = pkgs.runCommand "libredirect-3.3.0-configured" {nativeBuildInputs = [pkgs.jq];} ''
      cp -R ${libRedirectSource} "$out"
      chmod -R u+w "$out"

      ${pkgs.jq}/bin/jq '
        del(
          .services.youtube,
          .services.reddit,
          .services.tiktok,
          .services.instagram,
          .services.imgur,
          .services.medium,
          .services.quora,
          .services.pinterest,
          .services.imdb,
          .services.twitch,
          .services.search,
          .services.translate,
          .services.maps,
          .services.stackOverflow,
          .services.wikipedia,
          .services.bluesky
        ) |
        .services.twitter.options.enabled = true |
        .services.fandom.options.enabled = true
      ' "$out/config.json" > "$out/config.json.tmp"
      mv "$out/config.json.tmp" "$out/config.json"

      ${pkgs.jq}/bin/jq '.version = "3.3.0.4"' "$out/manifest.json" > "$out/manifest.json.tmp"
      mv "$out/manifest.json.tmp" "$out/manifest.json"

      substituteInPlace "$out/assets/javascripts/services.js" \
        --replace-fail 'nitter: ["https://nitter.privacydev.net"]' 'nitter: ["https://twitterviewer.net"]' \
        --replace-fail \
        '    browser.storage.local.clear(() => browser.storage.local.set({ options }, () => resolve()))' \
        '    options.fandom.enabled = true
      options.nitter = ["https://twitterviewer.net"]
      browser.storage.local.clear(() => browser.storage.local.set({ options }, () => resolve()))'

      substituteInPlace "$out/assets/javascripts/utils.js" \
        --replace-fail \
        '  return new Promise(resolve => browser.storage.local.get("options", r => resolve(r.options)))' \
        '  return new Promise(resolve => browser.storage.local.get("options", r => {
      if (r.options) r.options.nitter = ["https://twitterviewer.net"]
      resolve(r.options)
    }))'
  '';

  heliumWithExtensions = pkgs.writeShellScriptBin "helium" ''
    exec ${heliumPkg}/bin/helium \
      --load-extension=${clearUrls},${libRedirect} \
      "$@"
  '';

  urlPrivacy = config.myOptions.urlPrivacy.package;
  openPrivateUrl = pkgs.writeShellScript "open-private-url" ''
    if [ "$#" -eq 0 ]; then
      exec ${heliumWithExtensions}/bin/helium
    fi

    exec ${urlPrivacy}/bin/url-privacy open \
      --browser ${heliumWithExtensions}/bin/helium \
      "$1"
  '';
in {
  options.myOptions.helium = {
    enable = lib.mkEnableOption "Helium browser" // {default = config.myOptions.vars.withGui;};
  };

  config = lib.mkIf cfg.enable {
    home.packages = [heliumWithExtensions];

    xdg.desktopEntries.helium = {
      name = "Browser";
      genericName = "Web Browser";
      exec = "${openPrivateUrl} %u";
      icon = "helium";
      terminal = false;
      categories = ["Network" "WebBrowser"];
      mimeType = ["text/html" "x-scheme-handler/http" "x-scheme-handler/https"];
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "helium.desktop";
        "x-scheme-handler/http" = "helium.desktop";
        "x-scheme-handler/https" = "helium.desktop";
        "x-scheme-handler/about" = "helium.desktop";
        "x-scheme-handler/unknown" = "helium.desktop";
      };
    };
  };
}
