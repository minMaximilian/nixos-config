_final: prev: {
  # Skip flaky syncrepl tests in openldap 2.6.13.
  # Multiple test{017,019}-syncreplication-* tests fail intermittently due to
  # timing assumptions ("Waiting N seconds for syncrepl..."). Disable the
  # whole check phase rather than chasing individual flaky tests.
  # https://github.com/NixOS/nixpkgs/issues/514113
  openldap =
    if prev.openldap.version == "2.6.13"
    then prev.openldap.overrideAttrs (_old: {doCheck = false;})
    else prev.openldap;
}
