{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.default

    # Truly modular (I guess...)
    ../../modules/system/audio/default.nix
    ../../modules/system/dm/default.nix
    ../../modules/system/networking/default.nix
    ../../modules/system/wm/default.nix
    ../../modules/system/graphics/default.nix
    ../../modules/system/services/default.nix
    ../../modules/system/programs/default.nix

    # Not truly modular
    # On purpose (I'm lazy mate)
    ../../modules/system/securities/pam.nix
    ../../modules/system/themes/fonts.nix
  ];

  boot = {
    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = ["ntfs"];
    kernelParams = ["amdgpu.gpu_recovery=1"];
    kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
  };

  # Prevent RAM exhaustion freeze via compressed in-RAM swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Prevent accidental shutdown from keyboard power button & false lid suspend on AC
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };

  # Fix for AMD Radeon 680M (Yellow Carp) DMCUB firmware regression in linux-firmware 20260910
  # causing PSP LOAD_IP_FW failure (0xFFFF0008), DMUB crashes, and broken brightness control.
  hardware.firmware = [
    (pkgs.runCommand "yellow-carp-dmcub-fix" {} ''
      mkdir -p $out/lib/firmware/amdgpu
      cp ${pkgs.fetchurl {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/amdgpu/yellow_carp_dmcub.bin?id=a9f025fe99e7159c03879ff951e1a2a72686d884";
        hash = "sha256-S8uR1YunJ2hIRbAqnN0y83y1qfcb1Lk9TmeAlEZc2kc=";
      }} $out/lib/firmware/amdgpu/yellow_carp_dmcub.bin
    '')
  ];

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    input = {
      General = {
        ClassicBondedOnly = false;
      };
    };
  };

  # Enable uinput for controller mapping and virtual devices (Steam Input, Proton)
  hardware.uinput.enable = true;
  services.blueman.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # WirePlumber: autoswitch audio output to Bluetooth TWS/headphones when connected
  services.pipewire.wireplumber.extraConfig = {
    "10-bluez-priority" = {
      "monitor.bluez.rules" = [
        {
          matches = [
            {
              "node.name" = "~bluez_output.*";
            }
          ];
          actions = {
            update-props = {
              "priority.session" = 50000;
              "priority.driver" = 50000;
            };
          };
        }
      ];
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    extraHosts = ''
      127.0.0.1 daily-cloudcode-pa.googleapis.com
      127.0.0.1 cloudcode-pa.googleapis.com
    '';
  };

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "id_ID.UTF-8";
      LC_IDENTIFICATION = "id_ID.UTF-8";
      LC_MEASUREMENT = "id_ID.UTF-8";
      LC_MONETARY = "id_ID.UTF-8";
      LC_NAME = "id_ID.UTF-8";
      LC_NUMERIC = "id_ID.UTF-8";
      LC_PAPER = "id_ID.UTF-8";
      LC_TELEPHONE = "id_ID.UTF-8";
      LC_TIME = "id_ID.UTF-8";
    };
  };

  # RTKit
  security.rtkit.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fadlan = {
    isNormalUser = true;
    description = "Fadlan";
    extraGroups = ["networkmanager" "wheel" "podman" "kvm" "dialout" "video" "input"];
    shell = pkgs.nushell;
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "fadlan" = {
        imports = [./home.nix];
        home.sessionPath = [
          "$HOME/.local/bin"
          "$HOME/.cache/.bun/bin"
          "$HOME/.npm-global/bin"
          "$HOME/.bun/bin"
          "$HOME/.cargo/bin"
          "$HOME/.sdkman/candidates/java/current/bin"
          "$HOME/.sdkman/candidates/gradle/current/bin"
          "$HOME/.sdkman/candidates/maven/current/bin"
          "$HOME/.sdkman/candidates/kotlin/current/bin"
          "$HOME/Android/Sdk/platform-tools"
        ];
        wayland.windowManager.hyprland.extraConfig = ''
          hl.config({
            cursor = {
              no_hardware_cursors = 0,
            }
          })
          do
            local p = (os.getenv("HOME") or "/home/fadlan") .. "/.config/hypr/monitors.lua"
            local f = io.open(p, "r")
            if f then
              f:close()
              pcall(dofile, p)
            end
          end
        '';
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    extraOptions = ''
      trusted-users = root fadlan
    '';
    daemonIOSchedClass = "idle";
    daemonCPUSchedPolicy = "idle";
    settings = {
      experimental-features = ["nix-command" "flakes"];
      cores = 4;
      max-jobs = 2;
    };
  };

  # Paket
  environment.systemPackages = with pkgs; [
    zathura
    mako
    blender
    antigravity-fhs # biar gampang
    android-studio
    scrcpy
    spotify
    codex
    pavucontrol
    dbeaver-bin
    vscode

    # Keyring and stuff
    gnome-keyring
    gcr_4

    # Productivity, I guess
    libreoffice
    obsidian
    obsidian-export

    # Image things
    feh

    # Browser
    vivaldi
    brave

    # Video thing
    vlc

    # CLI/TUI
    wl-clipboard # Clipboard for Wayland
    zoxide # Better <cd>
    cbonsai # Bonsai tree
    yazi # File manager
    lm_sensors
    bunbun # VERY CUTE!
    peaclock # Clock
    cava # Audio Visualizer
    inputs.curd.packages."${stdenv.hostPlatform.system}".default # Watch anime
    inputs.hermes-agent.packages."${stdenv.hostPlatform.system}".default # Hermes AI Agent
    nurl # Generate nix fetcher url
    nix-tree # Interactively browse dependency graphs of Nix derivations
    nix-output-monitor
    fd
    lsof
    brightnessctl

    python3

    vscode-langservers-extracted

    gcc
    gnumake

    # Rust toolchain
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer

    nodejs_22
    bun

    php
    phpPackages.composer

    podman-compose
    distrobox

    # Uh, gaming utilities
    mangohud
    protonup-ng

    # Filesystem utilities
    ntfs3g

    # Archive utilities (required for SDKMAN)
    zip
    unzip

    # SDKMAN CLI wrapper for all shells (including Nushell)
    (pkgs.writeShellScriptBin "sdk" ''
      export SDKMAN_DIR="''${SDKMAN_DIR:-$HOME/.sdkman}"
      if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
        sdk "$@"
      else
        echo "SDKMAN tidak ditemukan di $SDKMAN_DIR."
        echo "Jalankan instalasi terlebih dahulu:"
        echo "  curl -s \"https://get.sdkman.io\" | bash"
      fi
    '')
  ];

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      NPM_CONFIG_PREFIX = "\${HOME}/.npm-global";
      NODE_EXTRA_CA_CERTS = "\${HOME}/.9router/mitm/rootCA.crt";
    };
  };

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIDOTCCAiGgAwIBAgIBATANBgkqhkiG9w0BAQsFADA+MR0wGwYDVQQDExQ5Um91
      dGVyIE1JVE0gUm9vdCBDQTEQMA4GA1UEChMHOVJvdXRlcjELMAkGA1UEBhMCVVMw
      HhcNMjYxMDEyMDMwODU2WhcNMzYxMDEyMDMwODU2WjA+MR0wGwYDVQQDExQ5Um91
      dGVyIE1JVE0gUm9vdCBDQTEQMA4GA1UEChMHOVJvdXRlcjELMAkGA1UEBhMCVVMw
      ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDZerFffWv+5eZROfzryqse
      7eWw7dwgPm9THxfJUWdvMUrJZqnAG/tSVTZMfwZIYqyvcFkZ4ZptIhHIpPzbmuJq
      0ECbtkoTTk2kd0yVb85mBwfaVXEOo3PGsXr+0D32ZQ5XtFYcthWVjrpVajSGK2Tz
      Sv9nzgRX2yFDsIg05twjG9tdDq9BVLnCq63hd1VHhmMFk6lXXx51BqNWe6iyN3Gn
      ri/HYQFEdUpgC3vrz0zNnf67MBIOrOZ1Qp1kDZ6LBSwIcsbqDAsSBiLR5BN/5FUa
      gI1QyxEOAk1u5dMawtDa9RdjvSSpuWqRPvAjUYwV/Sb2rR3DZK6PZsnoM/+0r/45
      AgMBAAGjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1Ud
      DgQWBBT8iDRiidnnrJo8ugUKpeVOoy1bATANBgkqhkiG9w0BAQsFAAOCAQEAi1ah
      HUHlQlY+q5u6riGwLgeAf5L57svU85iNrwNpGlQTfRL3w5xbnbBh5kYKaOWom7MN
      8RONhoDmR5rwIxLUPMCn3F55WHmRHzhg5n9/Xm2+HTjCgUGHc7VWmq5ktdS6oA2b
      VdcWOtAZR5McFlXBCjamWCBcfqdqx6b+qbfNueXI1e1NppNyWNpwY2XZvSgGjd17
      WVGDfYh1klLtB0YcosK3F+8sfgZBiEJKUD0/RyyJqSqwIG6T7XRquoGaR+UWMq/K
      lilGqGriNJJp2itTM9vBTvFDJ8BeMftvSdvzIbtKdWyVsoamRGJJEHAraUMcfRXV
      9stnBirm0kvg9sPJbg==
      -----END CERTIFICATE-----
    ''
  ];

  # Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Polkit
  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("wheel") &&
          (action.id === "org.freedesktop.udisks2.filesystem-mount-system" ||
           action.id === "org.freedesktop.udisks2.filesystem-mount")
        ) {
          return polkit.Result.YES;
        }
      });
    '';
  };

  # Auto-mount secondary NVMe storage
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-label/storage";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "x-gvfs-show"
      "x-gvfs-name=Storage"
    ];
  };

  netSetup.protonvpn.enable = false;
  svcs = {
    tailscale.enable = true;
    asusd.enable = false;
    actual.enable = false;
  };
  progs.obs = {
    enable = true;
    cudaSupport = false;
    virtualCamera = true;
  };
  graphics = {
    opengl.enable = true;
    cpu = "amd";
    nvidia = {
      vaapiEnable = false;
      stable.enable = false;
    };
  };

  systemd.services.nix-daemon.serviceConfig = {
    Nice = lib.mkForce 15;
    CPUWeight = 5;
    CPUQuota = "70%";
    IOWeight = 5;
    MemoryHigh = "3072M";
    MemoryMax = "4096M";
  };

  services.upower.enable = true;

  # Power Management / Balanced Performance & Battery Optimization (TLP)
  # - Saat colok charger (AC): Performa maksimal (100%), boost aktif, EPP balance_performance
  # - Saat baterai (BAT): Hemat daya dengan boost nonaktif, EPP balance_power, max perf 75%
  services.tlp = {
    enable = true;
    settings = {
      # Governor untuk driver amd-pstate-epp
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Energy Performance Preference (EPP)
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # Batas performa CPU
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 75;

      # Turbo Boost (Aktif saat colok charger, nonaktif saat baterai untuk irit suhu/daya)
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
    };
  };

  # Support running unpatched dynamic binaries (e.g., npm prebuilt packages, SDKMAN JDKs)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      fontconfig
      freetype
      cups
      libx11
      libxext
      libxi
      libxrender
      libxtst
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
