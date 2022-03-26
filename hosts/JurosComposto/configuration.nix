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
    };

    packages = {
      extra = with pkgs; [
        # Gaming
        zeroad
        minetest
        protonup
        lutris
        yuzu-ea
        unstable.rpcs3
        pcsx2
        wine64Packages.stagingFull
        airshipper
        steam-run
        protontricks
        multimc
        unstable.cataclysm-dda
        ryujinx
        endgame-singularity
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

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
