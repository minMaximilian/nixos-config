{
  lib,
  config,
  inputs ? {},
  ...
}: let
  cfg = config.myOptions.impermanence;
  username = config.myOptions.vars.username;
  hasPreservation = inputs ? preservation;
in {
  imports = lib.optionals hasPreservation [
    inputs.preservation.nixosModules.preservation
  ];

  options.myOptions.impermanence = {
    enable = lib.mkEnableOption "impermanence persistence";
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
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = hasPreservation;
          message = "myOptions.impermanence requires inputs.preservation";
        }
        {
          assertion = cfg.tmpfsRoot -> cfg.rootUuid != "";
          message = "myOptions.impermanence.rootUuid must be set when tmpfsRoot is enabled";
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
            {
              file = "/etc/shadow";
              inInitrd = true;
              mode = "0640";
              group = "shadow";
            }
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

              # Gaming
              ".local/share/Steam"
              ".local/share/PrismLauncher"
              ".local/share/bottles"
              ".local/share/Paradox Interactive"
              ".local/share/Tabletop Simulator"
              ".local/share/SlayTheSpire2"

              # Chat
              ".config/Signal"
              ".config/vesktop"

              # User data
              "Documents"
              "Downloads"
              "Pictures"
              "Videos"
              "Music"
              "workspace"

              # Desktop state
              ".config/dconf"

              # Shell history
              ".local/share/fish"

              # Zoxide directory database
              ".local/share/zoxide"

              # WirePlumber sound device settings
              ".local/state/wireplumber"

              # Nix user profile GC roots
              ".local/state/nix"

              # Amp CLI session + credentials
              ".amp"
              ".config/amp"
              ".local/share/amp"
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
