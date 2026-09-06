{
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook4,
  webkitgtk_4_1,
  libsoup_3,
  openssl,
  glib-networking,
  gst_all_1,
}:
stdenv.mkDerivation {
  pname = "deadlock-mod-manager";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/deadlock-mod-manager/deadlock-mod-manager/releases/download/v1.0.0/Deadlock.Mod.Manager_1.0.0_amd64.deb";
    hash = "sha256-CpOatJHe8LSMTaItv7Q6VvhoxG9Fdg5FMZiBML7P+Fs=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook4
  ];

  buildInputs = [
    webkitgtk_4_1
    libsoup_3
    openssl
    glib-networking
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r usr/* $out/

    runHook postInstall
  '';
}
