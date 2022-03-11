{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.hostConfig;
in
{
  options.hostConfig = {
    enable = mkEnableOption "Enable default host configuration";

    machine = {

      hostName = mkOption {
        type = with types; uniq str;
        description = "Host name";
        example = "marcos-desktop";
      };

      timeZone = mkOption {
        type = with types; uniq str;
        description = "Host time zone";
        default = "Brazil/East";
        example = "TODO";
      };

      locale = mkOption {
        type = with types; uniq str;
        description = "Host locale";
        default = "en_US.UTF-8";
        example = "TODO";
      };

      stateVersion = mkOption {
        type = with types; uniq str;
        description = "NixOS state version";
        default = "21.05";
        example = "21.11";
      };
    };

    users = {
      available = mkOption {
        type = with types; attrs;
        description = "Set of users for the machine";
        default = {
          "marcosrdac" = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };
        };
        example = {
          "marcos" = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };
          "family" = {
            isNormalUser = true;
          };
        };
      };

      defaultUserShell = mkOption {
        type = with types; package;
        description = "Default user shell";
        default = pkgs.zsh;
        example = pkgs.bash;
      };

    };

    boot = {
      loader = {
        portable = {
          enable = mkEnableOption ''
            Cofigure NixOS for a removable drive (compatible with both MBR and EFI loaders)
            TODO describe partition setup required
          '';
          device = mkOption {
            type = with types; uniq str;
            description = ''
              Drive device ID (not to be confused with partition ID) in which to install GRUB. Can be gotten from ls TODO
            '';
            default = null;
            example = "/dev/disk/by-id/ata-KINGSTON_SA400S37960G_0123456789ABCDEF";
          };
          efiSysMountPoint = mkOption {
            description = "Mount point for EFI system";
            type = with types; uniq str;
            default = null;
            example = "/efi";
          };
        };

        efi = { };

      };

      useOSProber = mkEnableOption ''
        Whether to search for other operational systems for boot menu or not
      '';

      tmpOnTmpfs = mkOption {
        description = ''
          Whether to mount /tmp on RAM or not
        '';
        type = with types; bool;
        default = true;
        example = false;
      };
    };

    packages = {
      useDefault = mkOption {
        description = ''
          Whether to use default system packages or not
        '';
        type = with types; bool;
        default = true;
        example = false;
      };

      extra = mkOption {
        description = "Extra packages";
        type = with types; listOf package;
        default = [ ];
        example = [ inkscape ];
      };
    };

    variables = {  # TODO: add extra variables by host as // overlay
      useDefault = mkOption {
        description = ''
          Whether to use default environment variables or not
        '';
        type = with types; bool;
        default = true;
        example = false;
      };
      extra = mkOption {
        description = "Extra variables";
        type = with types; attrsOf str;
        default = { };
        example = { EDITOR = "nano"; };
      };
    };

    devices = {
      input = {
        keyboard = {
          xkbLayout = mkOption {
            description = "";
            type = with types; str;
            default = "us";
            example = "us";
          };
          xkbVariant = mkOption {
            description = "";
            type = with types; str;
            default = "intl";
            example = "intl";
          };
          xkbOptions = mkOption {
            description = "";
            type = with types; str;
            default = "caps:swapescape";
            example = "";
          };
          ttyLayout = mkOption {
            description = "";
            type = with types; str;
            default = "us";
            example = "us";
          };
        };
      };
      network = {
        interfaces = mkOption {
          description = "Network interfaces";
          type = with types; listOf str ;
          default = [ ];
          example = [ "enp2s0" "wlp3s0" ];
        };
        useDHCP = mkOption {
          description = "Whether to use DHCP or not";
          type = with types; bool;
          default = true;
          example = false;
        };
      };
    };

  };


  config = mkIf cfg.enable {

    networking.hostName = cfg.machine.hostName;
    time.timeZone = cfg.machine.timeZone;
    system.stateVersion = cfg.machine.stateVersion;

    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''experimental-features = nix-command flakes'';
    };

    boot.loader = let
        loaders = rec {
          portable = {
            grub = {
              device = cfg.boot.loader.portable.device;
              efiSupport = true;
              efiInstallAsRemovable = true;
              useOSProber = cfg.boot.useOSProber;
            };
            efi.efiSysMountPoint = cfg.boot.loader.portable.efiSysMountPoint;
          };
          efi = { };  # TODO make it grubby
          default = efi;
        };
      in (
        if (cfg.boot.loader.portable.enable)
        then loaders.portable
        else loaders.default
      );
    boot.tmpOnTmpfs = cfg.boot.tmpOnTmpfs;


    environment.systemPackages = with pkgs; let
      defaultPackages = [
        unstable.home-manager
        #home-manager # error: file 'home-manager/home-manager/home-manager.nix' was not found in the Nix search path (add it using $NIX_PATH or -I)

        lf
        vim neovim
	tmux
	alacritty

        git wget
        busybox  #=: lspci

        firefox

        keepassx2
      ];
      designPackages = [
        gimp
        inkscape
      ];
      in
        (if cfg.packages.useDefault
          then defaultPackages
          else [ ])
        ++ designPackages
        ++ cfg.packages.extra;


    services.xserver = {
      enable = true;
      autorun = true;
      exportConfiguration = true;

      displayManager.lightdm = {
        enable = true;
	#background = "";
        #extraSeatDefaults = "";
      };

      desktopManager.xfce.enable = true;

      desktopManager.session = [
        {
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
      ];

      libinput.enable = true;

      layout = cfg.devices.input.keyboard.xkbLayout;
      xkbVariant = cfg.devices.input.keyboard.xkbVariant;
      xkbOptions = cfg.devices.input.keyboard.xkbOptions;
    };


    environment.variables = let
      defaultVariables = {
        EDITOR = "nvim";
      };
      in
        (if cfg.variables.useDefault
          then defaultVariables
          else { })
        // cfg.variables.extra;

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";


    console.font = "Lat2-Terminus16";

    fonts = {
      fontDir.enable = true;
      fonts = with pkgs; [
        spleen
        #noto-fonts
        #noto-fonts-cjk
        #noto-fonts-emoji
        #liberation_ttf
        #fira-code
        #fira-code-symbols
        #mplus-outline-fonts
        #dina-font
        #proggyfonts
        #source-sans-pro
        #source-serif-pro
        #noto-fonts-emoji
        #corefonts
        #recursive
      ];

      fontconfig = {
        defaultFonts = {
          serif = [ "Recursive Sans Casual Static Medium" ];
          sansSerif = [ "Recursive Sans Linear Static Medium" ];
          monospace = [ "Recursive Mono Linear Static" ];
          emoji = [ "Noto Color Emoji" ];
        };

        localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <alias binding="weak">
              <family>monospace</family>
              <prefer>
                <family>emoji</family>
              </prefer>
            </alias>
            <alias binding="weak">
              <family>sans-serif</family>
              <prefer>
                <family>emoji</family>
              </prefer>
            </alias>
            <alias binding="weak">
              <family>serif</family>
              <prefer>
                <family>emoji</family>
              </prefer>
            </alias>
          </fontconfig>
        '';
      };
    };

    console.keyMap = cfg.devices.input.keyboard.ttyLayout;

    sound.enable = true;
    hardware.pulseaudio.enable = true;
    services.printing.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.openssh.enable = true;

    users.users = cfg.users.available;
    users.defaultUserShell = cfg.users.defaultUserShell;

    nix.allowedUsers = builtins.attrNames cfg.users.available;  # all of them

    #users.extraGroups = {
    #   vboxusers.members = [ "marcosrdac" ];
    #};

    networking = {
      networkmanager.enable = true;

      interfaces = listToAttrs ( map (
        n: { name = "${n}"; value = { useDHCP = cfg.devices.network.useDHCP; }; }
      ) cfg.devices.network.interfaces);

      proxy = {
        #default = "http://user:password@proxy:port/";
        #noProxy = "127.0.0.1,localhost,internal.domain";
      };

      firewall = {
        enable = false;
        #allowedTCPPorts = [ ... ];
        #allowedUDPPorts = [ ... ];
      };

      extraHosts = ''
        # Public
        #IP.ADDR hostname
        # VPN protected services
        #IP.ADDR hostname
      '';
    };

  };
}
