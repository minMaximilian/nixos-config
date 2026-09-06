{lib, ...}: {
  # /etc/shadow is regenerated on activation, not bind-mounted.
  users.mutableUsers = lib.mkForce false;
  users.users.max.hashedPasswordFile = "/persist/etc/passwords/max";
  users.users.root.hashedPasswordFile = "/persist/etc/passwords/root";
}
