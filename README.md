# NixOS configuration

Personal NixOS hosts with explicitly composed system and Home Manager profiles.
No directory auto-discovery: adding a file does not enable or export it.

```text
flake.nix → hosts/default.nix → hosts/<host>/configuration.nix
                              ├── profiles/nixos/{workstation,gaming}.nix
                              ├── users/max/nixos.nix → users/max/home.nix
                              └── hosts/<host>/home.nix → profiles/home/*.nix

profiles → focused modules → native NixOS / Home Manager options
packages/ → local package recipes, independent of module policy
```

Host hardware, storage, displays and services belong in `hosts/`; identity and
personal state belong in `users/max/`. Profiles choose features; modules configure
one concern. See [the architecture audit](docs/ARCHITECTURE.md) for the comparison,
compatibility contract, file inventory and rollout precautions.

## Reuse on a work MacBook

The explicit [Home Manager exports](modules/home/exports.nix) are `neovim`,
`ideavim`, `git`, `git-hooks`, `fish` and `zellij`. Each is opt-in, without
personal identity or Linux desktop configuration. Existing editor shortcuts are
shared unchanged; no Command-key substitutions are introduced.

Use selected modules in standalone Home Manager or a future nix-darwin host.
The [source-only work-flake example](docs/ARCHITECTURE.md#work-macbook-reuse)
avoids evaluating this personal flake's local RSS proxy input. Darwin module
evaluation is tested; a Mac build and physical keyboard test are still required.

## Verification

```sh
nix fmt
nix flake check --no-build --no-write-lock-file
nix flake check --no-write-lock-file
nix build .#nixosConfigurations.whiteforest.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.ravenholm.config.system.build.toplevel --dry-run
```

For an unstaged checkout, use `path:$PWD` instead of `.` so Nix includes new files.
This flake deliberately retains its local `rss-archive-proxy` input; building the
personal hosts requires that checkout.

**Before activating Whiteforest:** preserve existing qBittorrent mutable state as
described in [rollout](docs/ARCHITECTURE.md#rollout-and-rollback). No activation,
password migration or reboot is part of the architecture refactor.

[Git hook behavior and installation](docs/GIT_HOOKS.md).
