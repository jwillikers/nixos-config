{ lib, hostname, username, ... }: {
  imports = [ ]
    ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix;

  fonts.fontconfig.enable = true;
  home = {
    # file.".ssh/config".text = "
    #   Host github.com
    #     HostName github.com
    #     User git
    # ";
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Noto" ]; })
    ];
    programs = {
      carapace = {
        enable = true;
      };
      git = {
        userEmail = "jordan@jwillikers.com";
        userName = "Jordan Williams";
        signing = {
          key = "A6AB406AF5F1DE02CEA3B6F09FB42B0E7F657D8C";
          signByDefault = true;
        };
      };
      nushell = {
        enable = true;
      };
      starship = {
        enable = true;
      };
    };
  };
  systemd.user.tmpfiles.rules = [
    "d /home/${username}/Books 0755 ${username} users - -"
    "d /home/${username}/Books/Audiobooks 0755 ${username} users - -"
    "d /home/${username}/Books/Books 0755 ${username} users - -"
    "d /home/${username}/Projects 0755 ${username} users - -"
  ];
}