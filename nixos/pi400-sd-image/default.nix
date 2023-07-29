{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    # inputs.nixpkgs.nixos.modules.installer.sd-card.sd-image-raspberrypi
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
    # (import ./disks.nix { })
    ../_mixins/hardware/systemd-boot.nix
    ../_mixins/services/openssh.nix
    ../_mixins/services/tailscale.nix
  ];

  swapDevices = [{
    device = "/swap";
    size = 4*1024;
  }];

  boot = {
    initrd.availableKernelModules = [
      "usbhid" 
      "usb_storage"
      "xhci_pci"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
  };


  environment.systemPackages = with pkgs; [
    foot
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
