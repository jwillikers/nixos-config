{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs, platform, stateVersion, username, ... }:
let
  notVM = if (hostname == "minimech" || hostname == "scrubber" || builtins.substring 0 5 hostname == "lima-") then false else true;
  # Create some variable to control what doesn't get installed/enabled
  isInstall = if (builtins.substring 0 4 hostname != "iso-") then true else false;
  isWorkstation = if (desktop != null) then true else false;
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-snapd.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    (modulesPath + "/installer/scan/not-detected.nix")
    ./${hostname}
    ./_mixins/scripts
    ./_mixins/users
  ] ++ lib.optional (isWorkstation) ./_mixins/desktop;

  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelModules = [ "vhost_vsock" ];
    kernelParams = [
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      # Keep zram swap (lz4) latency in check
      "vm.page-cluster" = 1;
    };
    # Only enable the systemd-boot on installs, not live media (.ISO images)
    loader = lib.mkIf (isInstall) {
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.consoleMode = "max";
      systemd-boot.enable = true;
      systemd-boot.memtest86.enable = true;
      timeout = 10;
    };
  };

  console = {
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    keyMap = "us";
    packages = with pkgs; [ tamzen ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
  services.xserver.layout = "us";
  time.timeZone = "US/Central";

  # Only install the docs I use
  documentation.enable = true;
  documentation.nixos.enable = false;
  documentation.man.enable = true;
  documentation.info.enable = false;
  documentation.doc.enable = false;

  environment = {
    # Eject nano and perl from the system
    defaultPackages = with pkgs; lib.mkForce [
      coreutils-full
      micro
      util-linux
    ];

    systemPackages = with pkgs; [
      age
      git
      ssh-to-age
      sops
      just
      nushell
      tmux
    ] ++ lib.optionals (isInstall) [
      inputs.crafts-flake.packages.${platform}.snapcraft
      inputs.fh.packages.${platform}.default
      clinfo
      unstable.distrobox
      flyctl
      fuse-overlayfs
      libva-utils
      nvme-cli
      #https://nixos.wiki/wiki/Podman
      podman-compose
      podman-tui
      podman
      smartmontools
    ] ++ lib.optionals (isInstall && isWorkstation && notVM) [
      pods
      quickemu
    ] ++ lib.optionals (isInstall && hasNvidia) [
      nvtop
      vdpauinfo
    ]  ++ lib.optionals (isInstall && !hasNvidia) [
      nvtop-amd
    ];

    variables = {
      EDITOR = "vim";
      SYSTEMD_EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  hardware = {
    # https://nixos.wiki/wiki/Bluetooth
    bluetooth = {
      enable = true;
      package = pkgs.bluez;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };

  # Use passed hostname to configure basic networking
  networking = {
    extraHosts = ''
      10.1.0.41 cm4-io-01
      10.1.0.23 pinebook-pro 
      10.1.0.40 rockpro64
      10.1.0.45 meerkat
      10.1.0.42 quartz64
      10.1.0.43 rock64
      10.1.0.44 zero-2w-01
      10.1.0.52 zero-2w-02
      10.1.0.51 cm4-io-02
    '';
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]
      trustedInterfaces = lib.mkIf (isInstall) [ "lxdbr0" ];
    };
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    domain = "jwillikers.io";
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      # Add overlays exported from other flakes:
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    optimise.automatic = true;
    package = pkgs.unstable.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];

      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;

      warn-dirty = false;
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "${platform}";

  programs = {
    command-not-found.enable = false;
    dconf.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_cursor_default block blink
        set fish_cursor_insert line blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual block
        set -U fish_color_autosuggestion brblack
        set -U fish_color_cancel -r
        set -U fish_color_command green
        set -U fish_color_comment brblack
        set -U fish_color_cwd brgreen
        set -U fish_color_cwd_root brred
        set -U fish_color_end brmagenta
        set -U fish_color_error red
        set -U fish_color_escape brcyan
        set -U fish_color_history_current --bold
        set -U fish_color_host normal
        set -U fish_color_match --background=brblue
        set -U fish_color_normal normal
        set -U fish_color_operator cyan
        set -U fish_color_param blue
        set -U fish_color_quote yellow
        set -U fish_color_redirection magenta
        set -U fish_color_search_match bryellow '--background=brblack'
        set -U fish_color_selection white --bold '--background=brblack'
        set -U fish_color_status red
        set -U fish_color_user brwhite
        set -U fish_color_valid_path --underline
        set -U fish_pager_color_completion normal
        set -U fish_pager_color_description yellow
        set -U fish_pager_color_prefix white --bold --underline
        set -U fish_pager_color_progress brwhite '--background=cyan'
      '';
      shellAbbrs = {
        captive-portal = "${pkgs.xdg-utils}/bin/xdg-open http://$(${pkgs.iproute2}/bin/ip --oneline route get 1.1.1.1 | ${pkgs.gawk}/bin/awk '{print $3}'";
        nix-gc = "sudo ${pkgs.unstable.nix}/bin/nix-collect-garbage --delete-older-than 10d && ${pkgs.unstable.nix}/bin/nix-collect-garbage --delete-older-than 10d";
        update-lock = "pushd $HOME/Zero/nix-config && ${pkgs.unstable.nix}/bin/nix flake update && popd";
      };
      shellAliases = {
        nano = "micro";
      };
    };
    nano.enable = lib.mkDefault false;
    nix-index-database.comma.enable = isInstall;
    nix-ld.enable = isInstall;
    ssh.startAgent = true;
  };

  services = {
    avahi = {
      enable = true;
      nssmdns = true;
      # Only open the avahi firewall ports on servers
      openFirewall = isWorkstation;
      publish = {
        addresses = true;
      	enable = true;
      	workstation = isWorkstation;
      };
    };
    fwupd.enable = isInstall;
    hardware.bolt.enable = true;
    kmscon = lib.mkIf (isInstall) {
      enable = true;
      hwRender = true;
      fonts = [{
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      }];
      extraConfig = ''
        font-size=14
        xkb-layout=gb
      '';
    };
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = lib.mkDefault "no";
      };
    };
    smartd.enable = isInstall;
    snap.enable = isInstall;
    sshguard = {
      enable = true;
      whitelist = [
        "192.168.2.0/24"
        "192.168.192.0/24"
        "62.31.16.154"
        "80.209.186.67"
      ];
    };
  };

  sops = lib.mkIf (isInstall) {
    age = {
      keyFile = "/home/${username}/.config/sops/age/keys.txt";
      generateKey = false;
    };
    defaultSopsFile = ../secrets/secrets.yaml;
    # sops-nix options: https://dl.thalheim.io/
    secrets.test-key = {};
  };

  # Enable Multi-Gen LRU:
  # - https://docs.kernel.org/next/admin-guide/mm/multigen_lru.html
  # - Inspired by: https://github.com/hakavlad/mg-lru-helper
  systemd.services."mglru" = {
    enable = true;
    wantedBy = ["basic.target"];
    script = ''
      ${pkgs.coreutils-full}/bin/echo 1000 > /sys/kernel/mm/lru_gen/min_ttl_ms
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    unitConfig = {
      ConditionPathExists = "/sys/kernel/mm/lru_gen/enabled";
      Description = "Configure Enable Multi-Gen LRU";
    };
  };

  # Disable hiberate and hybrid-sleep when using zram.
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  # Enable zram
  # - https://github.com/ecdye/zram-config/blob/main/README.md#performance
  # - https://www.reddit.com/r/Fedora/comments/mzun99/new_zram_tuning_benchmarks/
  # - https://linuxreviews.org/Zram
  zramSwap = {
    algorithm = "lz4";
    enable = true;
  };

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
  ];

  system = {
    activationScripts.diff = lib.mkIf (isInstall) {
      supportsDryActivation = true;
      text = ''
        if [ -e /run/current-system/boot.json ] && ! ${pkgs.gnugrep}/bin/grep -q "LABEL=nixos-minimal" /run/current-system/boot.json; then
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.unstable.nix}/bin diff /run/current-system "$systemConfig"
        fi
      '';
    };
    nixos.label = lib.mkIf (isInstall) "-";
    stateVersion = stateVersion;
  };

  virtualisation = lib.mkIf (isInstall) {
    lxd = {
      enable = true;
    };
    podman = {
      defaultNetwork.settings = {
        dns_enabled = true;
      };
      dockerCompat = true;
      dockerSocket.enable = true;
      enable = true;
      enableNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
    };
  };
}