# NixOS Config — Agent Guidelines

## Before editing

This repository uses pinned nixos-unstable. Before modifying any file:

1. Read relevant current upstream documentation with web search/page tools.
   For package/input updates, check NixOS, Home Manager and affected upstream
   release notes/changelogs. Do not infer current option syntax from memory.
2. Inspect the affected files, imports and consumers with `rg` and file reads.
3. State findings, intended changes, observable success criteria and meaningful
   risks before editing. For complex decisions, obtain an independent review
   when available; do not invent unavailable tool results.
4. Delegate independent implementation work to subagents when available, with
   disjoint file ownership. Each implementation agent runs flake evaluation.
5. Use surgical edits, preserve unrelated changes, and verify the result.

Sources: [NixOS options](https://search.nixos.org/options),
[packages](https://search.nixos.org/packages),
[Home Manager](https://nix-community.github.io/home-manager/options.xhtml),
[Hyprland](https://wiki.hyprland.org/), [Stylix](https://danth.github.io/stylix/)
and the affected locked upstream repositories.

## Ownership

| Location | Responsibility |
| --- | --- |
| `flake.nix`, `parts/` | Inputs, outputs, dev shells, formatter and checks |
| `hosts/default.nix` | Small native NixOS constructor |
| `hosts/<host>/` | Hardware, storage layout, displays, host-only services and selections |
| `users/max/` | Personal identity, HM integration, user persistence and password policy |
| `profiles/nixos/` | Explicit base, workstation and gaming composition |
| `profiles/home/` | Explicit personal base, development and desktop composition |
| `modules/nixos/` | Focused system features; do not write Home Manager user settings |
| `modules/home/` | Focused Home Manager features |
| `modules/shared/theme.nix` | Only actually consumed, context-independent theme values |
| `packages/` | Package construction; not user or host policy |
| `lib/` | Small domain-specific pure helpers |
| `tests/` | Regression checks and configuration snapshot expression |

Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) before changing ownership.

There is **no auto-discovery**, global vars bridge, import-all root, public
NixOS module collection or public profile API. Import a feature explicitly from
its owning profile/host. Use native options first; group package-only selections
in profiles instead of creating one-option wrappers.

## Portable module contract

Only the six entries in `modules/home/exports.nix` are supported reusable modules:
`neovim`, `ideavim`, `git`, `git-hooks`, `fish`, `zellij`.

- Custom feature switches use `myOptions.*` and default to false.
- No personal username, home path, Git identity, SSH hosts, Linux desktop,
  `self`, or private `localPackages` dependency in these exports.
- Git hooks are independently opt-in. Fish helpers require hooks and Fish.
- Neovim requires `inputs.nixCats` when enabled. Optional nightly/ZLS/Styling
  integration must remain optional. Debug/Godot default off; the personal
  development profile enables them.
- Preserve PC-style editor bindings on Darwin. Do not substitute Command keys.
  Add OS-level keyboard policy only for a real host with explicit requirements.
- Test every export alone and combined on Linux and aarch64-darwin.
- An export addition/removal is a deliberate API change: update the manifest,
  consumer tests and documentation together.
- Personal profiles are not portable exports. Use the documented source-only
  import to avoid the personal root flake's absolute RSS input.

## State and behavior preservation

Whiteforest has a tmpfs root. Storage is in `hosts/whiteforest/storage.nix`,
the Preservation engine in `modules/nixos/preservation/`, and personal mutable
state in `users/max/persistence.nix`.

- For added applications, identify state not reproducible from Nix and persist it.
- Remove obsolete entries when removing applications or making a previously
  mutable file fully declarative.
- Do not remove a persisted parent merely because some children are generated:
  mixed directories may contain authentication, databases or other mutable state.
- Migrate existing data before activating new bind mounts; never conceal it under
  an empty persisted directory. See the qBittorrent rollout warning.
- Preserve input pins, package versions, stateVersions, filesystem UUIDs,
  credentials, service exposure and shortcuts during architecture-only work.
- Do not activate, reboot, migrate live passwords, delete state, or rotate
  credentials without authorization.

Temporary package workarounds must link the upstream issue and return the
unmodified package after their version/condition expires. Intentional permanent
customizations do not need expiry.

## Verification

```sh
nix run nixpkgs#alejandra -- .
nix flake check --no-build --no-write-lock-file
nix flake check --no-write-lock-file
nix build .#nixosConfigurations.whiteforest.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.ravenholm.config.system.build.toplevel --dry-run
git diff --check
```

Use the pinned `nix fmt` or installed Alejandra if the registry is unavailable,
and report that fallback. If new files cannot be staged, evaluate
`nix flake check "path:$PWD" --no-build --no-write-lock-file`; do not confuse
missing untracked inputs with module failures.

The flake checks cover password migration, Miniflux XML/auth handling, Git-hook
staging/failure safety, Linux/Darwin module evaluation, headless composition,
Neovim startup/keymaps and URL privacy. `--no-build` only evaluates checks:
report executed fixtures separately from successful evaluation and host builds.
Use temporary state paths for editor tests; do not write `nvim.log` in the repo.

Work on the user's requested branch. Read-only Git metadata is not a reason to
abandon editable source work; report staging/commit limitations without trying
to bypass permissions.
