{ lib, hostname, username, ... }: {
  imports = [ ]
    ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix;

  home = {
    file.".ssh/config".text = "
      Host github.com
        HostName github.com
        User git
    ";
    file."Quickemu/nixos-console.conf".text = ''
      #!/run/current-system/sw/bin/quickemu --vm
      guest_os="linux"
      disk_img="nixos-console/disk.qcow2"
      disk_size="96G"
      iso="nixos-console/nixos.iso"
    '';
    file."Quickemu/nixos-desktop.conf".text = ''
      #!/run/current-system/sw/bin/quickemu --vm
      guest_os="linux"
      disk_img="nixos-desktop/disk.qcow2"
      disk_size="96G"
      iso="nixos-desktop/nixos.iso"
    '';
  };
  programs = {
    git = {
      userEmail = "jordan@jwillikers.com";
      userName = "Jordan Williams";
      signing = {
        key = "A6AB406AF5F1DE02CEA3B6F09FB42B0E7F657D8C";
        signByDefault = true;
      };
    };
  };

  systemd.user.tmpfiles.rules = [
    "d /home/${username}/Books 0755 ${username} users - -"
    "d /home/${username}/Books/Audiobooks 0755 ${username} users - -"
    "d /home/${username}/Books/Books 0755 ${username} users - -"
    "d /home/${username}/Quickemu/nixos-console 0755 ${username} users - -"
    "d /home/${username}/Quickemu/nixos-desktop 0755 ${username} users - -"
    "d /home/${username}/Projects 0755 ${username} users - -"
  ];
}
