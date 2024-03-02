{
  description = "JWillikers NixOS and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # You can access packages and modules from different nixpkgs revs at the same time.
    # See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # FlakeHub
    # antsy-alien-attack-pico.url = "https://flakehub.com/f/wimpysworld/antsy-alien-attack-pico/*.tar.gz";
    # antsy-alien-attack-pico.inputs.nixpkgs.follows = "nixpkgs";

    # crafts-flake.url = "https://flakehub.com/f/jnsgruk/crafts-flake/=0.4.3.tar.gz";
    # crafts-flake.inputs.nixpkgs.follows = "nixpkgs";

    # fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
    # fh.inputs.nixpkgs.follows = "nixpkgs";

    # Configuration file repositories
    openssh-config = {
      type = "github";
      owner = "jwillikers";
      repo = "openssh-config";
      flake = false;
    };

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix";
    pi-stereo = {
      url = "git+file:///home/jordan/Projects/pi-stereo";
      flake = false;
    };
  };
  outputs =
    { self
    , nix-formatter-pack
    , nixpkgs
    , nixos-hardware
    , openssh-config
    , raspberry-pi-nix
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "23.11";
      libx = import ./lib { inherit inputs outputs stateVersion; };
    in
    {
      # home-manager switch -b backup --flake $HOME/Zero/nix-config
      # nix build .#homeConfigurations."jordan@pinebook-pro".activationPackage
      homeConfigurations = {
        # .iso images
        "jordan@iso-console" = libx.mkHome { hostname = "iso-console"; username = "nixos"; };
        "jordan@iso-desktop" = libx.mkHome { hostname = "iso-desktop"; username = "nixos"; desktop = "pantheon"; };
        # Workstations
        "jordan@pinebook-pro" = libx.mkHome { hostname = "pinebook-pro"; username = "jordan"; platform = "aarch64-linux"; desktop = "sway"; };
        # Servers
        "jordan@cm4-io-01" = libx.mkHome { hostname = "cm4-io-01"; username = "jordan"; platform = "aarch64-linux"; };
        "jordan@cm4-io-02" = libx.mkHome { hostname = "cm4-io-02"; username = "jordan"; platform = "aarch64-linux"; };
        "jordan@pi400" = libx.mkHome { hostname = "cm4-io-02"; username = "jordan"; platform = "aarch64-linux"; };
        "jordan@stereo" = libx.mkHome { hostname = "stereo"; username = "jordan"; platform = "aarch64-linux"; };
                # Steam Deck
        "deck@steamdeck" = libx.mkHome { hostname = "steamdeck"; username = "deck"; };
      };
      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        iso-console = libx.mkHost { hostname = "iso-console"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"; };
        iso-desktop = libx.mkHost { hostname = "iso-desktop"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        iso-gpd-edp = libx.mkHost { hostname = "iso-gpd-edp"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        iso-gpd-dsi = libx.mkHost { hostname = "iso-gpd-dsi"; username = "nixos"; installer = nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"; desktop = "pantheon"; };
        pi400-sd-image = libx.mkHost { hostname = "pi400-sd-image"; username = "jordan"; installer = nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel.nix"; };
        star64-sd-image = libx.mkHost { hostname = "star64-sd-image"; username = "jordan"; }; # installer = nixos-hardware + "/pine64/star64/sd-image.nix"; };
        # SD Images
        # Workstations
        #  - sudo nixos-rebuild boot --flake $HOME/Zero/nix-config
        #  - sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
        #  - nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel
        pinebook-pro = libx.mkHost { hostname = "pinebook-pro"; username = "jordan"; desktop = "sway"; };
        stereo = libx.mkHost { hostname = "stereo"; username = "jordan"; installer = raspberry-pi-nix + "/sd-image/default.nix" };
        # Servers
        cm4-io-01 = libx.mkHost { hostname = "cm4-io-01"; username = "jordan"; };
        cm4-io-02 = libx.mkHost { hostname = "cm4-io-02"; username = "jordan"; };
        pi400 = libx.mkHost { hostname = "pi400"; username = "jordan"; };
      };

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      # nix fmt
      formatter = libx.forAllSystems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = false;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        }
      );

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };

      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = libx.forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs { inherit pkgs; }
      );
    };
}
