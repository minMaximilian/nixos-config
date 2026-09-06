{
  lib,
  xdg-utils,
}: old: {
  postFixup =
    (old.postFixup or "")
    + ''
      wrapProgram $out/bin/vesktop \
        --set-default NIXOS_OZONE_WL 1 \
        --set-default ELECTRON_OZONE_PLATFORM_HINT auto \
        --add-flags "--disable-features=WebRtcAllowInputVolumeAdjustment" \
        --prefix PATH : ${lib.makeBinPath [xdg-utils]}
    '';
}
