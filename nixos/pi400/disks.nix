{ disks ? [ "/dev/mmcblk0" ], ... }:
let
  defaultBtrfsOpts = [ "defaults" "autodefrag" "commit=120" "compress=zstd" "nodiratime" "relatime" ];
in
{
  disko.devices = {
    disk = {
      mmcblk0 = {
        type = "disk";
        device = "/dev/disk/by-label/NIXOS_SD";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "550MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "/rootfs" = {
                    mountpoint = "/";
                    mountOptions = defaultBtrfsOpts;
                  };
                  # Subvolume name is the same as the mountpoint
                  "/home" = {
                    mountOptions = defaultBtrfsOpts;
                    mountpoint = "/home";
                  };
                  # Sub(sub)volume doesn't need a mountpoint as its parent is mounted
                  # "/home/user" = { };
                  # Parent is not mounted so the mountpoint must be set
                  "/nix" = {
                    mountOptions = [ "defaults" "autodefrag" "commit=120" "compress=zstd" "noatime" ];
                    mountpoint = "/nix";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
