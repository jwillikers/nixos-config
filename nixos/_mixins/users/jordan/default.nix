  { config, desktop, hostname, inputs, lib, pkgs, platform, username, ... }:
let
  isWorkstation = if (desktop != null) then true else false;
  # https://nixos.wiki/wiki/OBS_Studio
  isStreamstation = if (hostname == "phasma" || hostname == "vader") && (isWorkstation) then true else false;
in
{

  environment.systemPackages = (with pkgs; [
    bitwarden-cli
  ] ++ lib.optionals (isWorkstation) [
    bitwarden
    zoom-us
  ]) ++ (with pkgs.unstable; lib.optionals (isWorkstation) [
    chromium
    firefox
    microsoft-edge
  ])

  programs = {
    chromium = lib.mkIf (isWorkstation) {
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # BitWarden
        "fnaicdffflnofjppbagibeoednhnbjhg" # Floccus Bookmark Sync
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # UBlock Origin
        "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      ];
    };
  #   dconf.profiles.user.databases = [{
  #     settings = with lib.gvariant; lib.mkIf (isWorkstation) {
  #       "io/elementary/terminal/settings" = {
  #         unsafe-paste-alert = false;
  #       };

  #       "net/launchpad/plank/docks/dock1" = {
  #         dock-items = [ "brave-browser.dockitem" "authy.dockitem" "Wavebox.dockitem" "org.telegram.desktop.dockitem" "discord.dockitem" "nheko.dockitem" "code.dockitem" "GitKraken.dockitem" "com.obsproject.Studio.dockitem" ];
  #       };

  #       "org/gnome/desktop/input-sources" = {
  #         xkb-options = [ "grp:alt_shift_toggle" "caps:none" ];
  #       };

  #       "org/gnome/desktop/wm/preferences" = {
  #         num-workspaces = mkInt32 8;
  #         workspace-names = [ "Web" "Work" "Chat" "Code" "Virt" "Cast" "Fun" "Stuff" ];
  #       };

  #       "org/gnome/shell" = {
  #         disabled-extensions = mkEmptyArray type.string;
  #         favorite-apps = [ "brave-browser.desktop" "authy.desktop" "Wavebox.desktop" "org.telegram.desktop.desktop" "discord.desktop" "nheko.desktop" "code.desktop" "GitKraken.desktop" "com.obsproject.Studio.desktop" ];
  #       };

  #       "org/gnome/shell/extensions/auto-move-windows" = {
  #         application-list = [ "brave-browser.desktop:1" "Wavebox.desktop:2" "discord.desktop:2" "org.telegram.desktop.desktop:3" "nheko.desktop:3" "code.desktop:4" "GitKraken.desktop:4" "com.obsproject.Studio.desktop:6" ];
  #       };

  #       "org/gnome/shell/extensions/tiling-assistant" = {
  #         show-layout-panel-indicator = true;
  #       };

  #       "org/mate/desktop/peripherals/keyboard/kbd" = {
  #         options = [ "terminate\tterminate:ctrl_alt_bksp" "caps\tcaps:none" ];
  #       };

  #       "org/mate/marco/general" = {
  #         num-workspaces = mkInt32 8;
  #       };

  #       "org/mate/marco/workspace-names" = {
  #         name-1 = " Web ";
  #         name-2 = " Work ";
  #         name-3 = " Chat ";
  #         name-4 = " Code ";
  #         name-5 = " Virt ";
  #         name-6 = " Cast ";
  #         name-7 = " Fun ";
  #         name-8 = " Stuff ";
  #       };
  #     };
  #   }];
  # };

  users.users.jordan = {
    description = "Jordan Williams";
    extraGroups = [
      "audio"
      "dialout"
      "input"
      "networkmanager"
      "users"
      "video"
      "wheel"
    ]
    ++ ifExists [
      "docker"
      "podman"
    ];
    # mkpasswd -m sha-512
    hashedPassword = "$6$iH4ONfriJCTcmTr7$MqNHxbzCYAji6nrNRtoz.D2Njot1DaflNgZl.Byx0qz5QZWFDVkDi9p7lU6uvnJ2Adc4HQRbyum1SJV/p219t1";
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOCXKobdFsqttj7q7kuyIInjKkUsqPM+qo+imjODbqDiVAy6iU6HbKez9S0+qbW7zGbMITX/hgm+k+gyDwHLUrPna9ObJvO/uhgUqtUv1tjGf+Ch1BZ015eNRerSQdWNJKwYr+JjVQRiqMkUyhCUiuoWe+f5u58+LzXQaR1r5JmOyDORaYdbg0aq3zqwZ92dAjjPgTob3xbj3jYwWw39rcnORPdN3g1wkWSSE7xSGQb95KuaHj8Xy60KFXPAMiFaDP6OTXPy/706TLrJsZSpbPKhyoKAH7/7u54QNLxVVlfvdi7CvOoTVr4fpneWGfPMP1XB0b8hS7zjPaVtQJ/4vlvMsyi52w5FhJ5kT+MTXO7vezWkIsq8F3NmHOmJoHcrby+nfIqBmy21FjjHF/kSjM9+Cf1uguUZe0laSgYNwx+x1+Mu1rlgaghDasd6Y78P6iOi76mc5o7V+lN75B6GDo+GouB2uBavKrFuRmPxPUR33mK4jz3Wm/JBmSNX4Ib+c= jordan@pinebook-pro.jwillikers.io"
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };
}
