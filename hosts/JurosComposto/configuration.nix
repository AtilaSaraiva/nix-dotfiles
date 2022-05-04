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
      hostName = "JurosComposto";
      stateVersion = "21.05";
    };

    isBtrfs = true;
    enablePlex = true;

    users.available = {
      atila = {
         isNormalUser = true;
         shell = pkgs.zsh;
         extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" ]; # Enable ‘sudo’ for the user.
         uid = 1001;
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
      kernelPackage = pkgs.linuxPackages_zen;
      extraModulePackages = [ pkgs.linuxPackages_zen.rtl88xxau-aircrack ];
      tmpOnTmpfs = true;
    };

    packages = {
      useDefaultGaming = true;
      extra = with pkgs; [
      ];
    };

    snapperExtraDir = {
      documentos = {
        subvolume = "/home/atila/Files/Documentos/";
        extraConfig = ''
          ALLOW_USERS="atila"
          TIMELINE_CREATE=yes
          TIMELINE_CLEANUP=yes
        '';
      };
      imagens = {
        subvolume = "/home/atila/Files/Imagens/";
        extraConfig = ''
          ALLOW_USERS="atila"
          TIMELINE_CREATE=yes
          TIMELINE_CLEANUP=yes
        '';
      };
      codes = {
        subvolume = "/home/atila/Files/Códigos/";
        extraConfig = ''
          ALLOW_USERS="atila"
          TIMELINE_CREATE=yes
          TIMELINE_CLEANUP=yes
        '';
      };
    };
  };

  virtualisation = {
    waydroid = {
        enable = true;
    };
    libvirtd = {
        enable = true;
    };
  };

  # Wireguard Client
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.202/24" "fda4:4413:3bb1::202/64" ];
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

  services.amdgpu-fan.enable = true;

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
