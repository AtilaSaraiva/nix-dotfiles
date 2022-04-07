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
        amdgpu-fan
      ];
    };

  };

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
