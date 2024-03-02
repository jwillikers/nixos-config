{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.raspberry-pi-nix
    # (import ./disks.nix { })
    # ../_mixins/hardware/systemd-boot.nix
    ../_mixins/services/openssh.nix
    ../_mixins/services/pipewire.nix
    ../_mixins/services/tailscale.nix
  ];

  nixpkgs.overlays = [
    (_: super: {
      rpi-kernels = super.rpi-kernels.latest.kernel.override { 
        argsOverride = {
          structuredExtraConfig = with super.lib.kernel; {
            PREEMPT_RT = yes;
            SND_HDA_GENERIC = yes;
            SND_HDA_INTEL = yes;
            SND_HDA_PREALLOC_SIZE = 2048;
            VIRTUALIZATION = no;
          };
        };
      };
    })
    (_: super: {
      pipewire = super.pipewire.override { 
        libcameraSupport = false;
      };
    })
  ];

  environment.etc = {
    "pipewire".source = pi-stereo + "/etc/pipewire";
    "wireplumber".source = pi-stereo + "/etc/wireplumber";
  };

  swapDevices = [{
    device = "/swap";
    size = 4*1024;
  }];

  environment.systemPackages = with pkgs; [];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
