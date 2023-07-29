{ disks ? [ "/dev/mmcblk0" ], ... }:
let
  defaultBtrfsOpts = [ "defaults" "autodefrag" "commit=120" "compress=zstd" "nodiratime" "relatime" ];
in
{
  disko.devices = {
    disk = {
      mmcblk0 = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "table";
          format = "gpt";
          partitions = [{
            name = "ESP";
            start = "0%";
            end = "550MiB";
            bootable = true;
            flags = [ "esp" ];
            fs-type = "fat32";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "root";
            start = "550MiB";
            end = "100%";
            content = {
              type = "filesystem";
              # Overwrite the existing filesystem
              extraArgs = [ "-f" ];
              format = "btrfs";
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
          }];
        };
      };
    };
  };
}
