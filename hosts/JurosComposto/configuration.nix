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
         openssh.authorizedKeys.keys = [
           "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEDBtZRp53vGMrfJpuy9DZDgN1B77zB141EQG++PHD6 atilasaraiva@gmail.com"
           "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAgKaUqBBJjthB/Pmxh878RXs3Vh9mpIKUZ/U0nZ67S4K492VB3IzhyiSo3pL4RUVorNPTOEjsNAh7OCM9eNrmkaVs49OUr43JV4pCD2CqfYEpbtDN6s1E5fswfpvmi3d2aF7kpHP0OOKisw2nOe9Vp3VdHMPdmU4cXtrbYyBruWMPbZ29M6tIKqmEzZjLnDdAplSLzfAy+vAlpUxLE1xhEXN91cRF98xMmMCTOfyHgzRkdX0Jl2FGWMoGP/1NB5zPgHMh+7rJNXEWYnxd01mQiXlAjBLMUGH46lB2CNOhAtpEyDTazRhAw7VY5+Ge5rjrO0ht6AczroWG9KpNEZ5jJ671Rpzk4kghqHa2EChtH2x6kY0s6hM4QWiGE58Bry9z0APsoR64t1tIXdbsG54NhAbTstb4RHUpuOi8Y00qWCX4XzvRNIMcFj/fUSieTExjyosXcC4gLlN2KJOBJOXHpAjzyogEJ3T4AUfTOSNQ/o24wRzMsx4dz4YZFzhq1wrD/FGuzule08cvrSRcBrlEaslHdlWu9hf99zZUAGZ8ncZNmYwn0conJNRJp55qOSNiJ8q4yn0WNhy6sBnkfzNf+yOcPoCWRRakBwlt3Z4iC7vPWPzXcoHFMxoXnwIq0jbMYT1c2N/2GYWukB92+7S3De/DILVoFZwcC6cpwpWB5Q== root@JurosComposto"
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
      kernelPackage = pkgs.linuxPackages_zen;
      extraModulePackages = [ pkgs.linuxPackages_zen.rtl88xxau-aircrack ];
      tmpOnTmpfs = true;
    };

    packages = {
      useDefaultGaming = true;
      extra = with pkgs; [
        unigine-heaven
      ];
    };

    snapperExtraDir = {
      home = {
          subvolume = "/home";
          extraConfig = ''
            ALLOW_USERS="atila"
            TIMELINE_CREATE=yes
            TIMELINE_CLEANUP=yes
          '';
      };
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
    lxd.enable = true;
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

  nix.sshServe = {
    enable = true;
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEDBtZRp53vGMrfJpuy9DZDgN1B77zB141EQG++PHD6 atilasaraiva@gmail.com"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAgKaUqBBJjthB/Pmxh878RXs3Vh9mpIKUZ/U0nZ67S4K492VB3IzhyiSo3pL4RUVorNPTOEjsNAh7OCM9eNrmkaVs49OUr43JV4pCD2CqfYEpbtDN6s1E5fswfpvmi3d2aF7kpHP0OOKisw2nOe9Vp3VdHMPdmU4cXtrbYyBruWMPbZ29M6tIKqmEzZjLnDdAplSLzfAy+vAlpUxLE1xhEXN91cRF98xMmMCTOfyHgzRkdX0Jl2FGWMoGP/1NB5zPgHMh+7rJNXEWYnxd01mQiXlAjBLMUGH46lB2CNOhAtpEyDTazRhAw7VY5+Ge5rjrO0ht6AczroWG9KpNEZ5jJ671Rpzk4kghqHa2EChtH2x6kY0s6hM4QWiGE58Bry9z0APsoR64t1tIXdbsG54NhAbTstb4RHUpuOi8Y00qWCX4XzvRNIMcFj/fUSieTExjyosXcC4gLlN2KJOBJOXHpAjzyogEJ3T4AUfTOSNQ/o24wRzMsx4dz4YZFzhq1wrD/FGuzule08cvrSRcBrlEaslHdlWu9hf99zZUAGZ8ncZNmYwn0conJNRJp55qOSNiJ8q4yn0WNhy6sBnkfzNf+yOcPoCWRRakBwlt3Z4iC7vPWPzXcoHFMxoXnwIq0jbMYT1c2N/2GYWukB92+7S3De/DILVoFZwcC6cpwpWB5Q== root@JurosComposto"
    ];
  };

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
