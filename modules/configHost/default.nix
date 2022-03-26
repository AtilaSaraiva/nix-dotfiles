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
        example = "atila-desktop";
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

    isBtrfs = mkEnableOption ''
      Does the system contain a btrfs partition?
    '';

    users = {
      available = mkOption {
        type = with types; attrs;
        description = "Set of users for the machine";
        default = {
          "atila" = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };
        };
        example = {
          "atila" = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };
          "sabrina" = {
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

        systemdBoot = {
          enable = mkOption {
            description = "Systemd boot";
            type = with types; bool;
            default = true;
          };
          timeout = mkOption {
            description = "Wait time for boot menu selection";
            type = with types; nullOr int;
            default = 3;
          };
        };
        extraModulePackages = mkOption {
          description = "Kernel module packages";
          type = types.listOf types.package;
          default = [ ];
        };
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
            default = "br";
            example = "us";
          };
          xkbVariant = mkOption {
            description = "";
            type = with types; str;
            default = "";
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
            default = "br-abnt2";
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

    boot.tmpOnTmpfs = cfg.boot.tmpOnTmpfs;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = cfg.boot.systemdBoot.timeout;
    boot.kernel.sysctl = {
      "abi.vsyscall32" = 0;
      "vm.swappiness"  = 60;
      "kernel.sysrq"   = 1;
      };
    boot.supportedFilesystems = [ "btrfs" "xfs" "ntfs" ];
    boot.kernelParams = [ "quiet" "udev.log_level=3" ];
    # Silent boot
    boot.initrd.verbose = false;
    boot.consoleLogLevel = 0;
    boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.extraModulePackages = cfg.boot.extraModulePackages;

    services.flatpak.enable = true;
    services.upower.enable = true;

    security.pam.loginLimits = [
      { domain = "*"; item = "memlock"; type = "hard"; value = "unlimited"; }
      { domain = "*"; item = "memlock"; type = "soft"; value = "unlimited"; }
    ];

    environment.systemPackages = with pkgs; let
      defaultPackages = [
        # Editor
        neovim

        # System tools
        (pkgs.writeShellScriptBin "nixf" ''
          exec ${pkgs.nixFlakes}/bin/nix --experimental-features "nix-command flakes" "$@"
        '')
        wget
        vulkan-tools
        clinfo
        killall
        nmap
        htop
        pavucontrol
        sshfs
        exa
        rofi
        git
        thefuck
        udiskie
        oguri
        tmux
        compsize
        xorg.xhost
        rpi-imager
        ncdu
        ripgrep
        mate.pluma
        rmlint
        podman-compose
        pacman
        smartmontools
        iotop
        easyeffects
        virt-manager
        xfsprogs
        libxfs
        duf
        radeontop
        btdu
        nix-prefetch-scripts
        qjackctl
        nox
        distrobox
        cage
        binutils
        nixpkgs-fmt
        nix-index
        direnv
        niv

        # lf
        trash-cli
        fasd
        chafa
        archivemount
        fzf
        dragon-drop
        poppler_utils
        ffmpegthumbnailer
        wkhtmltopdf
        imagemagick

        # Image viewers
        feh

        # Compression
        ouch
        unzip
        zpaq

        # Browsers
        firefox-wayland
        qutebrowser
        google-chrome

        # Database
        sqlite
        dbeaver

        # File Browsers
        vifm-full


        # Python
        (let
           my-python-packages = python-packages: with python-packages; [
               pynvim
            #other python packages you want
           ];
           python-with-my-packages = python3.withPackages my-python-packages;
        in
           python-with-my-packages)

        # Apps
        onlyoffice-bin
        tdesktop
        dropbox
        megasync
        keepassxc
        bitwarden
        kotatogram-desktop
        zathura
        font-manager
        gnome.gucharmap
        mpv
        buku
        unstable.oil-buku
        libsForQt5.okular
        jabref
        texlive.combined.scheme-full
        qbittorrent
        xournalpp
        obs-studio
        inkscape
        blanket
        libreoffice-fresh
        element-desktop
        youtube-dl
        sayonara
        homebank
        droidmote
        gimp-with-plugins
      ];
      in
        (if cfg.packages.useDefault
          then defaultPackages
          else [ ])
        ++ cfg.packages.extra;


    services.xserver = {
      enable = true;

      displayManager.gdm.enable = true;

      desktopManager.cinnamon.enable = true;

      libinput.enable = true;

      layout = cfg.devices.input.keyboard.xkbLayout;
      xkbVariant = cfg.devices.input.keyboard.xkbVariant;
      xkbOptions = cfg.devices.input.keyboard.xkbOptions;
    };

    programs.gamemode.enable = true;
    programs.file-roller.enable = true;
    programs.singularity.enable = true;
    programs.autojump.enable = true;

    programs.zsh = {
      enable = true;
      shellAliases = {
        rebuild-os = "sudo nixos-rebuild switch";
        upgrade-os = ''
          sudo nixos-rebuild --upgrade
          echo "Please reboot"
        '';
        edit-os = "nvim /etc/nixos/configuration.nix";
        gc-os = "nix-collect-garbage -d";
      };
      shellInit = ''
          source /home/atila/.config/shell/shenv
      '';
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

    i18n.defaultLocale = "pt_BR.UTF-8";

    services.lorri.enable = true;
    services.locate = {
      enable = true;
      locate = pkgs.plocate;
      localuser = "atila";
      pruneBindMounts = false;
    };

    console = {
      font = "Lat2-Terminus16";
      keyMap = cfg.devices.input.keyboard.ttyLayout;
    };

    fonts = {
      fonts = with pkgs; [
       font-awesome
       cantarell-fonts
       roboto-mono
       fantasque-sans-mono
       material-icons
       nerdfonts
      ];
    };

    zramSwap = {
      enable = true;
      priority = 32000;
      algorithm = "zstd";
      memoryPercent = 90;
    };
    nix.autoOptimiseStore = true;
    nix.gc = {
        automatic = true;
        persistent = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
    };

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true; # so that gtk works properly
      extraPackages = with pkgs; [
        swaylock
        xwayland
        swayidle
        swaytools
        wf-recorder
        wl-clipboard
        sway-contrib.grimshot
        mako # notification daemon
        alacritty # Alacritty is the default terminal in the config
        wofi # Dmenu is the default in the config but i recommend wofi since its wayland native
        autotiling
        waybar
        wlsunset
        xfce.thunar
        jq
        playerctl
        wev
        sirula
        lxappearance
        adapta-gtk-theme
        gnome3.adwaita-icon-theme
      ];
      extraSessionCommands = ''
        #export SDL_VIDEODRIVER=wayland
        #export QT_QPA_PLATFORM=wayland
        #export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
      '';
    };
    xdg.portal.wlr.enable = true;

    services.printing.enable = true;

    xdg.mime.defaultApplications = {
      "application/pdf" = "zathura";
      "image/png" = "feh";
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.openssh = {
        enable = true;
        ports = [
          22
          35901
        ];
    };

    users.users = cfg.users.available;
    users.defaultUserShell = cfg.users.defaultUserShell;

    #users.extraGroups = {
    #   vboxusers.members = [ "marcosrdac" ];
    #};

    networking = {
      networkmanager.enable = true;

      firewall = {
        enable = false;
        #allowedTCPPorts = [ ... ];
        #allowedUDPPorts = [ ... ];
      };
    };

    # Enable sound.
    sound.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
    };
    hardware.pulseaudio.enable = false;

    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
      };
    };

    hardware.opengl.extraPackages = with pkgs; [
        rocm-opencl-icd
        intel-compute-runtime
        amdvlk
        vaapiVdpau
        libvdpau-va-gl
        libva
    ];
    hardware.steam-hardware.enable = true;

    hardware.opengl.extraPackages32 = [
      pkgs.driversi686Linux.amdvlk
    ];
    services.btrfs.autoScrub = {
      enable = cfg.isBtrfs;
      interval = "monthly";
    };

    programs.dconf.enable = true;

    hardware.opengl.enable = true;
    hardware.opengl.driSupport32Bit = true;
  };
}
