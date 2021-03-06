# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/f3818b1f-ad35-4331-8379-7e5987f5e4f5";
      fsType = "btrfs";
      options = [ "subvol=@nix" "discard=async" "space_cache=v2" "compress-force=zstd:4" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/f3818b1f-ad35-4331-8379-7e5987f5e4f5";
      fsType = "btrfs";
      options = [ "subvol=@home" "discard=async" "space_cache=v2" "compress-force=zstd:4" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/f3818b1f-ad35-4331-8379-7e5987f5e4f5";
      fsType = "btrfs";
      options = [ "subvol=@swap" "discard=async" "space_cache=v2" "compress-force=zstd:4" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B10A-B619";
      fsType = "vfat";
    };

  fileSystems."/home/atila/Files/Imagens" =
    { device = "/dev/disk/by-uuid/c9231e4e-4002-4a31-be7b-75c4c7b5760e";
      fsType = "btrfs";
      options = [ "subvol=files/@Imagens" "autodefrag" "compress-force=zstd:9" "space_cache=v2"];
    };

  fileSystems."/home/atila/Files/Códigos" =
    { device = "/dev/disk/by-uuid/c9231e4e-4002-4a31-be7b-75c4c7b5760e";
      fsType = "btrfs";
      options = [ "subvol=files/@Códigos"  "autodefrag" "compress-force=zstd:9" "space_cache=v2" ];
    };

  fileSystems."/home/atila/Files/Mangas" =
    { device = "/dev/disk/by-uuid/c9231e4e-4002-4a31-be7b-75c4c7b5760e";
      fsType = "btrfs";
      options = [ "subvol=files/@Mangas" "autodefrag"  "compress-force=zstd:9" "space_cache=v2" ];
    };

  fileSystems."/home/atila/Files/Músicas" =
    { device = "/dev/disk/by-uuid/c9231e4e-4002-4a31-be7b-75c4c7b5760e";
      fsType = "btrfs";
      options = [ "subvol=files/@Músicas" "autodefrag"  "compress-force=zstd:9" "space_cache=v2" ];
    };

  fileSystems."/home/atila/Files/Documentos" =
    { device = "/dev/disk/by-uuid/c9231e4e-4002-4a31-be7b-75c4c7b5760e";
      fsType = "btrfs";
      options = [ "subvol=files/@Documentos" "autodefrag" "compress-force=zstd:9" "space_cache=v2" ];
    };

  fileSystems."/home/atila/Files/Comics" =
    { device = "/dev/disk/by-uuid/c9231e4e-4002-4a31-be7b-75c4c7b5760e";
      fsType = "btrfs";
      options = [ "subvol=files/@Comics" "autodefrag"  "compress-force=zstd:9" "space_cache=v2" ];
    };

  fileSystems."/home/atila/Files/Biblioteca-Calibre" =
    { device = "/dev/disk/by-uuid/c9231e4e-4002-4a31-be7b-75c4c7b5760e";
      fsType = "btrfs";
      options = [ "subvol=files/@Biblioteca-Calibre" "autodefrag"  "compress-force=zstd:9" "space_cache=v2" ];
    };

  fileSystems."/home/atila/Games" =
    { device = "/dev/disk/by-uuid/c9231e4e-4002-4a31-be7b-75c4c7b5760e";
      fsType = "btrfs";
      options = [ "subvol=@games" "autodefrag"  "compress-force=zstd:9" "space_cache=v2" ];
    };

  fileSystems."/mnt/Games/hd1tb" =
    { device = "/dev/disk/by-uuid/c9231e4e-4002-4a31-be7b-75c4c7b5760e";
      fsType = "btrfs";
      options = [ "subvol=@games" "autodefrag"  "compress-force=zstd:9" "space_cache=v2"];
    };

  fileSystems."/home/atila/Games/nvme" =
    { device = "/dev/disk/by-uuid/f3818b1f-ad35-4331-8379-7e5987f5e4f5";
      fsType = "btrfs";
      options = [ "subvol=@games" "nofail" "discard=async" "space_cache=v2" "compress-force=zstd:4" ];
    };

  fileSystems."/mnt/Games/nvme" =
    { device = "/dev/disk/by-uuid/f3818b1f-ad35-4331-8379-7e5987f5e4f5";
      fsType = "btrfs";
      options = [ "subvol=@games" "nofail" "discard=async" "space_cache=v2" "compress-force=zstd:4" ];
    };

  fileSystems."/home/atila/Games/Prefixes" =
    { device = "/dev/disk/by-uuid/c9231e4e-4002-4a31-be7b-75c4c7b5760e";
      fsType = "btrfs";
      options = [ "subvol=@prefixes" "autodefrag" "compress-force=zstd:9" "space_cache=v2" ];
    };

  fileSystems."/home/atila/Files/Downloads" =
    { device = "/dev/disk/by-uuid/34081a37-6fb1-418a-9d88-427d1e866d6c";
      fsType = "btrfs";
      options = [ "subvol=files/@Downloads" "autodefrag" "nofail" "space_cache=v2" "compress=lzo" ];
    };

  fileSystems."/home/atila/Files/Downloads-torrents" =
    { device = "/dev/disk/by-uuid/34081a37-6fb1-418a-9d88-427d1e866d6c";
      fsType = "btrfs";
      options = [ "subvol=files/@Downloads-torrent" "autodefrag"  "nofail" "space_cache=v2" "compress=lzo" ];
    };

  fileSystems."/home/atila/Files/Anime" =
    { device = "/dev/disk/by-uuid/34081a37-6fb1-418a-9d88-427d1e866d6c";
      fsType = "btrfs";
      options = [ "subvol=files/@Anime"  "autodefrag" "nofail" "space_cache=v2" "compress=lzo" ];
    };

  fileSystems."/home/atila/Games/big" =
    { device = "/dev/disk/by-uuid/34081a37-6fb1-418a-9d88-427d1e866d6c";
      fsType = "btrfs";
      options = [ "subvol=@big"  "autodefrag" "nofail" "space_cache=v2" "compress=lzo" ];
    };

  fileSystems."/mnt/Games/big" =
    { device = "/dev/disk/by-uuid/34081a37-6fb1-418a-9d88-427d1e866d6c";
      fsType = "btrfs";
      options = [ "subvol=@big"  "autodefrag" "nofail" "space_cache=v2" "compress=lzo" ];
    };

  swapDevices =
    [ {
    	device = "/dev/disk/by-uuid/109c7ce4-4349-465c-ae89-967db832698d";
    	priority = 5;
      }
    ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
