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
      hostName = "betinha";
      stateVersion = "22.05";
      autoUpgrade = false;
    };

    isBtrfs = false;
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
    };

    boot = {
      useOSProber = false;
      #kernelPackage = pkgs.linuxPackages;
      tmpOnTmpfs = false;
    };

    packages = {
      useDefaultGaming = false;
      extra = with pkgs; [
        zeroad
      ];
    };

  };
}
