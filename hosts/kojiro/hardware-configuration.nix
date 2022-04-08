# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/98999d5f-3a5c-4ea9-9fe1-35a3df476293";
      fsType = "btrfs";
      options = [ "subvol=@root" "discard=async" "compress-force=zstd:4" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/98999d5f-3a5c-4ea9-9fe1-35a3df476293";
      fsType = "btrfs";
      options = [ "subvol=@home" "discard=async" "compress-force=zstd:4" ];
    };

  fileSystems."/mnt/storage" =
    { device = "/dev/disk/by-uuid/98999d5f-3a5c-4ea9-9fe1-35a3df476293";
      fsType = "btrfs";
      options = [ "subvol=@storage" "discard=async" "compress-force=zstd:4" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6F43-D416";
      fsType = "vfat";
    };

  swapDevices =
    [
      {
        device = "/dev/disk/by-uuid/309a350c-b0fa-44f5-be28-f6fe28ddd8b5";
        priority = 5;
      }
    ];

}
