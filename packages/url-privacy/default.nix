{
  writeShellApplication,
  python3,
}:
writeShellApplication {
  name = "url-privacy";
  runtimeInputs = [python3];
  text = ''
    exec ${python3}/bin/python3 ${../../modules/home/gui/url-privacy/url_privacy.py} "$@"
  '';
}
