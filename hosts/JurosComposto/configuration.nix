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
  };

  services.plex = {
    enable = true;
    user = "atila";
  };

  services.snapper.configs = {
    home = {
      subvolume = "/home";
      extraConfig = ''
        ALLOW_USERS="atila"
        TIMELINE_CREATE=yes
        TIMELINE_CLEANUP=yes
      '';
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

  nixpkgs.overlays = [ (import ../../pkgs) ];

  services.undervolt.gpuOffset = 50;

  system.autoUpgrade.enable = true;
}
