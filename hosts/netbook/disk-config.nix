{ lib, ... }:

{
  disko.devices.disk = {
    main = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          biosBoot = {
            type = "EF02";
            size = "1M"; # for MBR grub
          };
          root = {
            end = "-16G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          swap = {
            size = "100%";
            content = {
              type = "swap";
              discardPolicy = "both";
            };
          };
        };
      };
    };
  };
}
