final: prev: {
  amp = prev.writeShellScriptBin "amp" ''
    export NPM_CONFIG_YES=true
    exec ${prev.nodejs_20}/bin/npx -y @sourcegraph/amp@latest "$@"
  '';

  # G502 X Plus support - use latest libratbag/piper from master
  # https://github.com/libratbag/libratbag/issues/1780
  libratbag = prev.libratbag.overrideAttrs (old: {
    version = "0.18-unstable-2025-12-14";
    src = prev.fetchFromGitHub {
      owner = "libratbag";
      repo = "libratbag";
      rev = "c5214d26336695d1414a6b4e32697f5b5a835089";
      hash = "sha256-o1lsdJ8QwprpBVUdntjjfV6lPaqhG0rD9ySjf+LXriQ=";
    };
    # Add receiver ID c547 for G502 X Plus
    postInstall =
      (old.postInstall or "")
      + ''
        sed -i 's/DeviceMatch=usb:046d:4099;usb:046d:c095/DeviceMatch=usb:046d:4099;usb:046d:c095;usb:046d:c547/' \
          $out/share/libratbag/logitech-g502-x-plus.device
      '';
  });

  piper = prev.piper.overrideAttrs (old: {
    version = "0.8-unstable-2025-12-14";
    src = prev.fetchFromGitHub {
      owner = "libratbag";
      repo = "piper";
      rev = "48056eb1788cdfbdda67a2360c53b7157782a9b3";
      hash = "sha256-jF7qowV4Ub5MqQBlTDuf7x83RTfMQ/J5DSD74lP02pU=";
    };
  });
}
