{ config, desktop, lib, pkgs, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  # Only include desktop components if one is supplied.
  imports = [ ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;

  environment.systemPackages = [
    # pkgs.yadm # Terminal dot file manager
  ];

  users.users.jordan = {
    description = "Jordan Williams";
    extraGroups = [
      "audio"
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
    # todo
    # mkpasswd -m sha-512
    hashedPassword = "todo";
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      # todo
      "ssh-rsa ..."
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };
}
