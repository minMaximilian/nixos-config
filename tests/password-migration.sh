#!/usr/bin/env bash
set -euo pipefail
source "$1"

test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT
printf '%s\n' 'max:$6$max:0:0:0:0:0:0:0' 'root:$6$root:0:0:0:0:0:0:0' \
  'alice:$6$alice:0:0:0:0:0:0:0' 'locked:!$6$locked:0:0:0:0:0:0:0' > "$test_dir/shadow"

migrate_passwords "$test_dir/shadow" "$test_dir/defaults"
[[ $(< "$test_dir/defaults/max") == '$6$max' ]]
[[ $(< "$test_dir/defaults/root") == '$6$root' ]]
[[ $(stat -c %a "$test_dir/defaults") == 700 ]]
[[ $(stat -c %a "$test_dir/defaults/max") == 600 ]]
if migrate_passwords "$test_dir/shadow" "$test_dir/defaults"; then
  echo 'existing password files were not rejected' >&2
  exit 1
fi
[[ $(< "$test_dir/defaults/max") == '$6$max' ]]

migrate_passwords "$test_dir/shadow" "$test_dir/explicit" alice locked missing
[[ $(< "$test_dir/explicit/alice") == '$6$alice' ]]
[[ ! -e "$test_dir/explicit/max" && ! -e "$test_dir/explicit/locked" && ! -e "$test_dir/explicit/missing" ]]
if migrate_passwords "$test_dir/shadow" "$test_dir/invalid" ../max; then
  echo 'invalid username was not rejected' >&2
  exit 1
fi
[[ ! -e "$test_dir/invalid" ]]
ln -s "$test_dir/defaults/max" "$test_dir/explicit/max"
if migrate_passwords "$test_dir/shadow" "$test_dir/explicit" max; then
  echo 'symlink destination was not rejected' >&2
  exit 1
fi
[[ $(< "$test_dir/defaults/max") == '$6$max' ]]
echo 'Password migration checks passed.'
