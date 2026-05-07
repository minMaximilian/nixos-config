#!/usr/bin/env bash
# Seed /persist/etc/passwords/<user> from the live /etc/shadow before
# switching myOptions.impermanence.declarativeUsers on for the first time.
#
# Required because:
#   - bind-mounting /etc/shadow on a tmpfs root breaks update-users-groups.pl
#     (the activation script renames a temp file over /etc/shadow → EBUSY),
#   - so we move passwords to per-user files referenced via hashedPasswordFile,
#   - which means /etc/shadow is regenerated on every activation from the
#     declarative password files.
#
# Usage:
#   sudo ./scripts/migrate-shadow-to-passwords.sh [user...]
#
# Defaults to extracting "max" and "root" if no users are passed.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "must run as root (uses /etc/shadow and writes to /persist)" >&2
  exit 1
fi

PERSIST=/persist/etc/passwords
USERS=("${@:-max root}")

mkdir -p "$PERSIST"
chmod 0700 "$PERSIST"
chown root:root "$PERSIST"

for user in "${USERS[@]}"; do
  hash=$(awk -F: -v u="$user" '$1==u {print $2}' /etc/shadow)
  if [[ -z "$hash" ]]; then
    echo "skip $user: not in /etc/shadow" >&2
    continue
  fi
  case "$hash" in
    "" | "!" | "*" | "!!" | "x")
      echo "skip $user: password is locked or empty ($hash)" >&2
      continue
      ;;
  esac
  out="$PERSIST/$user"
  printf '%s\n' "$hash" > "$out"
  chmod 0600 "$out"
  chown root:root "$out"
  echo "wrote $out"
done

echo
echo "Now you can rebuild:"
echo "  sudo nixos-rebuild switch --flake .#whiteforest"
