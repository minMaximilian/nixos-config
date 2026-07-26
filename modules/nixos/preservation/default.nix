{
  lib,
  config,
  inputs ? {},
  ...
}: let
  cfg = config.myOptions.preservation;
  username = config.myOptions.vars.username;
  hasPreservation = inputs ? preservation;
in {
  imports = lib.optionals hasPreservation [
    inputs.preservation.nixosModules.preservation
  ];

  options.myOptions.preservation = {
    enable = lib.mkEnableOption "preservation persistence";
    tmpfsRoot = lib.mkEnableOption "tmpfs as root filesystem (ephemeral root)";

    persistPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "Path to persistent storage mount point";
    };

    rootUuid = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "UUID of the partition to mount as /state when tmpfsRoot is enabled";
    };

    tmpfsSize = lib.mkOption {
      type = lib.types.str;
      default = "8G";
      description = "Size limit for the tmpfs root filesystem";
    };

    declarativeUsers = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        max = "/persist/etc/passwords/max";
        root = "/persist/etc/passwords/root";
      };
      description = ''
        Map of username → path to a file containing a single SHA-512 password
        hash on persistent storage. When non-empty, forces
        `users.mutableUsers = false` and wires each entry into
        `users.users.<name>.hashedPasswordFile`.

        This is the recommended way to handle passwords on a tmpfs root:
        bind-mounting `/etc/shadow` breaks `update-users-groups.pl`'s atomic
        rename (EBUSY), and symlinking `/etc/shadow` is silently destroyed by
        the same rename. Declarative password files survive both, because
        `/etc/shadow` is regenerated from them on every activation.

        Use `scripts/migrate-shadow-to-passwords.sh` to seed these files from
        an existing `/etc/shadow`.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = hasPreservation;
          message = "myOptions.preservation requires inputs.preservation";
        }
        {
          assertion = cfg.tmpfsRoot -> cfg.rootUuid != "";
          message = "myOptions.preservation.rootUuid must be set when tmpfsRoot is enabled";
        }
      ];

      preservation = {
        enable = true;

        preserveAt.${cfg.persistPath} = {
          commonMountOptions = ["x-gvfs-hide"];

          directories = [
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
            "/var/lib/NetworkManager"
            "/var/lib/bluetooth"
            "/var/lib/systemd/coredump"
            "/var/lib/postgresql"
            "/var/log"
            "/etc/NetworkManager/system-connections"
          ];

          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            # /etc/shadow is intentionally NOT bind-mounted here.
            # See myOptions.preservation.declarativeUsers for the password
            # persistence model used on this tmpfs root.
          ];

          users.${username} = {
            directories = [
              {
                directory = ".ssh";
                mode = "0700";
              }
              {
                directory = ".gnupg";
                mode = "0700";
              }
              {
                directory = ".local/share/keyrings";
                mode = "0700";
              }

              # Browser logins
              ".config/net.imput.helium"

              # Comics
              ".local/share/komikku"

              # Graphics editors (user prefs, palettes, recent files, plugins)
              ".config/aseprite"
              ".config/Blockbench"
              ".config/GIMP"

              # OBS Studio scenes, profiles, settings, and user-installed plugins
              ".config/obs-studio"

              # Gaming
              ".local/share/Steam"
              ".local/share/PrismLauncher"
              ".local/share/Paradox Interactive"
              ".local/share/Tabletop Simulator"
              ".local/share/SlayTheSpire2"

              # Switch emulator (firmware, prod.keys, saves, mods)
              ".config/Ryujinx"

              # Chat
              ".config/Signal"
              ".config/vesktop"
              ".config/TeamSpeak"

              # User data
              "Documents"
              "Downloads"
              "Pictures"
              "Videos"
              "Music"
              "workspace"

              # Desktop state
              ".config/dconf"

              # IntelliJ settings and user-installed plugins
              ".config/JetBrains"
              ".local/share/JetBrains"

              # Gradle wrapper distributions and dependency cache
              ".gradle"

              # JetBrains Java prefs registry: stores the accepted EULA/ToS
              # version (and license tokens). Without this the ToS prompt
              # reappears on every tmpfs-root boot. (.java/fonts is a
              # regenerable cache and is intentionally not persisted.)
              ".java/.userPrefs"

              # Noctalia GUI/runtime state. The declarative config remains
              # generated by home-manager; this only preserves app-managed
              # acknowledgements and UI state so first-run prompts do not
              # reappear on every tmpfs-root boot.
              ".local/state/noctalia"

              # Shell history
              ".local/share/fish"

              # Direnv approvals for reviewed .envrc content
              ".local/share/direnv"

              # Zoxide directory database
              ".local/share/zoxide"

              # Serialized Zellij sessions for resurrection after reboot
              ".cache/zellij"

              # WirePlumber sound device settings
              ".local/state/wireplumber"

              # TIDAL Chrome app login session and preferences
              ".config/tidal"

              # Solaar — Logitech device settings (scroll wheel resolution,
              # SmartShift, DPI, button mappings). Without this, mouse
              # settings reset to factory defaults on every reboot.
              ".config/solaar"

              # Nix user profile GC roots
              ".local/state/nix"
              # Nix trusted flake settings, including permanently accepted
              # flake-provided binary caches.
              ".local/share/nix"

              # Amp CLI session + credentials
              ".amp"
              ".config/amp"
              ".local/share/amp"

              # Claude Code settings + credentials (manually configured for GLM Coding Plan)
              ".claude"

              # opencode CLI auth + sessions
              ".config/opencode"
              ".local/share/opencode"

              # Codex CLI auth + history + config
              ".codex"

              # Pi coding agent auth + sessions
              ".pi"

              # ML model weights and dataset caches — large downloads
              # (HuggingFace hub, torch hub, torchvision pretrained
              # checkpoints) that should survive reboots.
              ".cache/huggingface"
              ".cache/torch"

              # uv wheel cache — recreating venvs is instant when this
              # survives reboots, otherwise every venv re-downloads
              # multi-GB torch+rocm wheels.
              ".cache/uv"
              ".local/share/uv"
            ];

            files = [
              # Claude Code state file: hasCompletedOnboarding, theme, OAuth session,
              # MCP user-scope config, per-project trust. Without this, claude prompts
              # for theme/trust on every boot.
              ".claude.json"
            ];
          };
        };
      };

      security.sudo.extraConfig = ''
        # rollback results in sudo lectures after each reboot
        Defaults lecture = never
      '';

      systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
    }

    (lib.mkIf (cfg.declarativeUsers != {}) {
      # Force declarative password files. /etc/shadow is regenerated from
      # these on every activation, so it can safely live on the tmpfs.
      # mkForce overrides shared/users.nix which defaults mutableUsers = true.
      users.mutableUsers = lib.mkForce false;
      users.users =
        lib.mapAttrs (_user: passwordFile: {
          hashedPasswordFile = passwordFile;
        })
        cfg.declarativeUsers;
    })

    (lib.mkIf cfg.tmpfsRoot {
      fileSystems."/" = lib.mkForce {
        device = "none";
        fsType = "tmpfs";
        options = ["defaults" "size=${cfg.tmpfsSize}" "mode=755"];
      };

      fileSystems."/state" = {
        device = "/dev/disk/by-uuid/${cfg.rootUuid}";
        fsType = "ext4";
        neededForBoot = true;
      };

      fileSystems."/nix" = {
        device = "/state/nix";
        fsType = "none";
        options = ["bind"];
        neededForBoot = true;
      };

      fileSystems.${cfg.persistPath} = {
        device = "/state/persist";
        fsType = "none";
        options = ["bind"];
        neededForBoot = true;
      };
    })
  ]);
}
