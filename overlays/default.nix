final: prev: {
  amp = prev.writeShellScriptBin "amp" ''
    export NPM_CONFIG_YES=true
    exec ${prev.nodejs_24}/bin/npx -y @sourcegraph/amp@latest "$@"
  '';

  # Skip flaky syncrepl tests in openldap 2.6.13.
  # Multiple test{017,019}-syncreplication-* tests fail intermittently due to
  # timing assumptions ("Waiting N seconds for syncrepl..."). Disable the
  # whole check phase rather than chasing individual flaky tests.
  # https://github.com/NixOS/nixpkgs/issues/514113
  openldap = prev.openldap.overrideAttrs (_old: {
    doCheck = false;
  });
}
