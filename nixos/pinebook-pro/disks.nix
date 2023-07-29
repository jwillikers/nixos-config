{ disks ? [ "/dev/sda" ], ... }:
let
  defaultBtrfsOpts = [ "defaults" "autodefrag" "commit=120" "compress=zstd" "nodiratime" "relatime" ];
in
{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "EFI";
              name = "ESP";
              size = "512M";
              type = "EF00" ;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                extraOpenArgs = [ "--allow-discards" ];
                # if you want to use the key for interactive login be sure there is no trailing newline
                # for example use `echo -n "password" > /tmp/secret.key`
                keyFile = "/tmp/secret.key"; # Interactive
                # settings.keyFile = "/tmp/secret.key";
                # additionalKeyFiles = ["/tmp/additionalSecret.key"];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
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
  };
}