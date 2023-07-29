{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi.4
    (import ./disks.nix { })
    ../_mixins/hardware/systemd-boot.nix
    ../_mixins/services/btrbk.nix
    ../_mixins/services/net-snmp.nix
    ../_mixins/services/tailscale.nix
  ];

  swapDevices = [{
    device = "/swap";
    size = 4*1024;
  }];

  # Disable the OpenSSH server to lock-down the backup server.
  services.openssh.enable = false;

  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "nvme"
      "rtsx_pci_sdmmc"
      "sd_mod"
      "sdhci_pci"
      "uas"
      "usbhid"
      "usb_storage"
      "xhci_pci"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
  };


  environment.systemPackages = with pkgs; [];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
