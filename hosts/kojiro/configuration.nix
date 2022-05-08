# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
  ];

  hostConfig = {
    enable = true;

    machine = {
      hostName = "kojiro";
      stateVersion = "21.11";
    };

    isBtrfs = true;
    enablePlex = false;
    isLaptop = true;

    users.available = {
      atila = {
         isNormalUser = true;
         shell = pkgs.zsh;
         extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
         uid = 1001;
         openssh.authorizedKeys.keys = [
           "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEDBtZRp53vGMrfJpuy9DZDgN1B77zB141EQG++PHD6 atilasaraiva@gmail.com"
         ];
      };
      sabrina = {
         isNormalUser = true;
         createHome = true;
         shell = pkgs.zsh;
         extraGroups = [ "networkmanager" ]; # Enable ‘sudo’ for the user.
         uid = 1002;
      };
    };

    boot = {
      useOSProber = false;
      kernelPackage = pkgs.linuxPackages;
      extraModulePackages = [ pkgs.linuxPackages.rtlwifi_new ];
      blacklistedKernelModules = [
        "rtw88_8822ce"
        "rtw88_8822c"
        "rtw88_pci"
        "rtw88_core"
      ];
      tmpOnTmpfs = false;
    };

    packages = {
      useDefaultGaming = false;
      extra = with pkgs; [
        zeroad
        minetest
        lutris
        mangohud
      ];
    };

  };

  # Wireguard Client
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.203/24" "fda4:4413:3bb1::203/64" ];
    privateKeyFile = "/home/atila/wireguard-keys/private";
    peers = [
      {
        publicKey = "kjVAAeIGsN0r3StYDQ2vnYg6MbclMrPALdm07qZtRCE=";
        allowedIPs = [
          "10.100.0.0/24"
          "fda4:4413:3bb1::/64"
          # Multicast IPs
          "224.0.0.251/32"
          "ff02::fb/128"
        ];
        endpoint = "home.pedrohlc.com:51820";
        persistentKeepalive = 25;
      }
    ];
    postSetup = ''
      ip link set wg0 multicast on
    '';
  };

  nix.binaryCaches = [ "nix-cache.atila.com" ];
  #nix.requireSignedBinaryCaches = false;
  nix.binaryCachePublicKeys = [ "nix-cache.atila.com:ZDPBr5CfpBck7aCWYvUIQ8KrVfqy/ym7QiCGRMFqGnY=" ];

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
