{ config, desktop, lib, pkgs, ... }: {
  imports = [ ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;

  #https://nixos.wiki/wiki/Podman
  environment.systemPackages = with pkgs; [
    aardvark-dns
    buildah
    conmon
    distrobox
    fuse-overlayfs
    netavark
    skopeo
  ];

  virtualisation = {
    podman = {
      defaultNetwork.settings = {
        dns_enabled = true;
      };
      dockerCompat = false;
      enable = true;
    };
  };
}
