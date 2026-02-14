{ ... }:
{
  disko.devices = {
    disk = {
      nvme = {
        device = "/dev/disk/by-id/nvme-Netac_NVMe_SSD_2TB_RN202412242T674429";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
      vault = {
        device = "/dev/disk/by-id/ata-WDC_WD10EZEX-00WN4A0_WD-WCC6Y1CY3ZS8";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            vault = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/vault";
                mountOptions = [
                  "defaults"
                  "nofail"
                  "compress=zstd"
                ];
              };
            };
          };
        };
      };
    };
  };
}
