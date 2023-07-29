{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    # (import ./disks.nix { })
    # ../_mixins/hardware/systemd-boot.nix
    ../_mixins/services/openssh.nix
    ../_mixins/services/tailscale.nix
  ];

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix
  # Makes `availableOn` fail for zfs, see <nixos/modules/profiles/base.nix>.
  # This is a workaround since we cannot remove the `"zfs"` string from `supportedFilesystems`.
  # The proper fix would be to make `supportedFilesystems` an attrset with true/false which we
  # could then `lib.mkForce false`
  nixpkgs.overlays = [(final: super: {
    zfs = super.zfs.overrideAttrs(_: {
      meta.platforms = [];
    });
  })];

  swapDevices = [{
    device = "/swap";
    size = 4*1024;
  }];

  boot = {
    initrd.availableKernelModules = [
      "usbhid" 
      # "usb_storage"
      "xhci_pci"
    ];
    # pkgs.linuxKernel.kernels.linux_rpi4
    # kernelPackages = pkgs.linuxPackages_rpi4;
    # kernelPackages = pkgs.latest_kernel_with_zfs_support;
    # kernelPackages = pkgs.linuxPackages_latest;
  };


  environment.systemPackages = with pkgs; [
    foot
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
