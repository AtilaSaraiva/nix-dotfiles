# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
      ./hardware-configuration.nix
  ];

  hostConfig = {
    enable = true;

    machine = {
      hostName = "kojiro";
      stateVersion = "21.11";
      autoUpgrade = false;
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
      #kernelPackage = pkgs.linuxPackages;
      extraModulePackages = [ config.boot.kernelPackages.rtlwifi_new ];
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
        steam-run
        openmw
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
        endpoint = "lab.pedrohlc.com:51820";
        persistentKeepalive = 25;
      }
    ];
    postSetup = ''
      ip link set wg0 multicast on
    '';
  };

  nix.settings = {
    #require-sigs = false;
    substituters = [ "http://10.0.0.165:5000" "http://10.100.0.202:5000" ];
  };

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";

  specialisation.gnome.configuration = {
    system.nixos.tags = [ "gnome" ];
    programs.sway.enable = lib.mkForce false;
    services.xserver.desktopManager.cinnamon.enable = lib.mkForce false;
    services.xserver.desktopManager.gnome.enable = lib.mkForce true;
    services.xserver.displayManager.defaultSession = lib.mkForce "gnome";
    xdg.portal.wlr.enable = lib.mkForce false;
    xdg.portal.extraPortals = lib.mkForce [
      pkgs.xdg-desktop-portal-gnome
      (pkgs.xdg-desktop-portal-gtk.override {
        # Do not build portals that we already have.
        buildPortalsInGnome = false;
      })
    ];
    programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
  };

}
