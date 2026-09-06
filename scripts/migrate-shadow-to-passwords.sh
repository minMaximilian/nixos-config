#!/usr/bin/env bash
# Seed per-user hashedPasswordFile inputs before enabling users/max/passwords.nix.
# /etc/shadow itself must remain replaceable during NixOS activation.
# Usage: sudo ./scripts/migrate-shadow-to-passwords.sh [user...]
set -euo pipefail

migrate_passwords() (
  local shadow_file=$1 password_dir=$2 user hash out temporary=""
  shift 2
  local users=("$@")
  if [[ ${#users[@]} -eq 0 ]]; then
    users=(max root)
  fi

  # Preflight every destination before writing any password files.
  for user in "${users[@]}"; do
    if [[ ! $user =~ ^[a-zA-Z_][a-zA-Z0-9_.-]*[$]?$ ]]; then
      echo "invalid username: $user" >&2
      return 1
    fi
    if [[ -e "$password_dir/$user" || -L "$password_dir/$user" ]]; then
      echo "refusing to overwrite $password_dir/$user" >&2
      return 1
    fi
  done

  umask 077
  mkdir -p -- "$password_dir" || return
  chmod 0700 -- "$password_dir" || return
  if [[ $EUID -eq 0 ]]; then
    chown root:root -- "$password_dir" || return
  fi
  trap 'if [[ -n "$temporary" ]]; then rm -f -- "$temporary"; fi' EXIT

  for user in "${users[@]}"; do
    hash=$(awk -F: -v u="$user" '$1 == u {print $2}' "$shadow_file") || return
    case "$hash" in
      "" | '!'* | '*'* | x)
        echo "skip $user: password missing, locked or empty" >&2
        continue
        ;;
    esac
    if [[ $hash == *$'\n'* ]]; then
      echo "duplicate shadow entries for $user" >&2
      return 1
    fi
    out="$password_dir/$user"
    temporary=$(mktemp "$password_dir/.${user}.XXXXXX") || return
    printf '%s\n' "$hash" > "$temporary" || return
    if [[ $EUID -eq 0 ]]; then
      chown root:root -- "$temporary" || return
    fi
    # Hard-link publication is atomic and refuses even a concurrently created target.
    ln -T -- "$temporary" "$out" || return
    rm -f -- "$temporary" || return
    temporary=""
    echo "wrote $out"
  done
)

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  if [[ $EUID -ne 0 ]]; then
    echo "must run as root (uses /etc/shadow and writes to /persist)" >&2
    exit 1
  fi
  migrate_passwords /etc/shadow /persist/etc/passwords "$@"
  echo "Password files prepared; review them before rebuilding whiteforest."
fi
