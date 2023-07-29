{ desktop, pkgs, lib, ... }: {
  imports = [
    ../../desktop/chromium.nix
    #../../desktop/firefox.nix
    #../../desktop/evolution.nix
    ../../desktop/google-chrome.nix
    ../../desktop/microsoft-edge.nix
  ] ++ lib.optional (builtins.pathExists (../.. + "/desktop/${desktop}-apps.nix")) ../../desktop/${desktop}-apps.nix;

  environment.systemPackages = with pkgs; [
    libreoffice

    # Fast moving apps use the unstable branch
    # unstable.discord
    # unstable.tdesktop
    # unstable.vscode-fhs
  ];

  programs = {
    chromium = {
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # BitWarden
        "fnaicdffflnofjppbagibeoednhnbjhg" # Floccus Bookmark Sync
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # UBlock Origin
        "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      ];
    };
  };
}
