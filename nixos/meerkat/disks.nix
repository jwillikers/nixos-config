{ disks ? [ "/dev/sda" ], ... }:
let
  defaultBtrfsOpts = [ "defaults" "autodefrag" "commit=120" "compress=zstd" "nodiratime" "relatime" ];
in
{
  disko.devices = {
    disk = {
      sda = {
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
                # Overwirte the existing filesystem
                extraArgs = [ "-f" ];
                format = "btrfs";
                mountpoint = "/";
                mountOptions = defaultBtrfsOpts;
              };
            }];
        };
      };
    };
  };
}
