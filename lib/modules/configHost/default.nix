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
        default = "America/Bahia";
        example = "TODO";
      };

      locale = mkOption {
        type = with types; uniq str;
        description = "Host locale";
        default = "pt_BR.UTF-8";
        example = "TODO";
      };

      stateVersion = mkOption {
        type = with types; uniq str;
        description = "NixOS state version";
        default = "21.05";
        example = "21.11";
      };

      autoUpgrade = mkOption {
        description = "Automatically upgrade de system?";
        type = with types; bool;
        default = true;
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
      };

      kernelPackage = mkOption {
        description = "The linux kernel package";
        default = pkgs.linuxPackages_zen;
      };

      extraModulePackages = mkOption {
        description = "Kernel module packages";
        type = types.listOf types.package;
        default = [ ];
      };

      blacklistedKernelModules = mkOption {
        description = "What modules to blacklist";
        type = types.listOf types.str;
        default = [ ];
        example = [
          "rtw88_8822ce"
          "rtw88_8822c"
          "rtw88_pci"
          "rtw88_core"
        ];
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

    isLaptop = mkOption {
      description = "Enable laptop optimizations?";
      type = with types; bool;
      default = false;
      example = true;
    };

    enablePlex = mkOption {
      description = "Do you want to enable plex?";
      type = types.bool;
      default = !cfg.isLaptop;
      example = true;
    };

    enableJellyfin = mkOption {
      description = "Do you want to enable jellyfin?";
      type = types.bool;
      default = false;
      example = true;
    };

    snapperExtraDir = mkOption {
      description = ''
        Additional directories to tell snapper to take snapshots of. Home is set by default, any
        dir set with this option will only be added to the list
      '';
      type = with types; attrs;
      default = { };
      example = {
        home = {
          subvolume = "/home";
          extraConfig = ''
            ALLOW_USERS="atila"
            TIMELINE_CREATE=yes
            TIMELINE_CLEANUP=yes
          '';
        };
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
      useDefaultGaming = mkOption {
        description = ''
          Whether to use default gaming packages or not
        '';
        type = with types; bool;
        default = false;
        example = true;
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
    };
  };


  config = mkIf cfg.enable {

    nixpkgs.overlays = [ (import ../../../pkgs) ];
    nixpkgs.config.allowUnfree = true;

    networking.hostName = cfg.machine.hostName;
    time.timeZone = cfg.machine.timeZone;
    system.stateVersion = cfg.machine.stateVersion;

    boot.tmpOnTmpfs = cfg.boot.tmpOnTmpfs;
    boot.cleanTmpDir = !cfg.boot.tmpOnTmpfs;
    boot.tmpOnTmpfsSize = "180%";
    boot.loader.systemd-boot.enable = cfg.boot.loader.systemdBoot.enable;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = cfg.boot.loader.systemdBoot.timeout;
    boot.loader.systemd-boot.memtest86.enable = true;
    boot.kernel.sysctl = {
      "abi.vsyscall32" = 0;
      "vm.swappiness"  = 7;
      "kernel.sysrq"   = 1;
      };
    boot.supportedFilesystems = [ "btrfs" "xfs" "ntfs" ];
    boot.kernelParams = [ "quiet" "udev.log_level=3" ];
    # Silent boot
    boot.initrd.verbose = false;
    boot.consoleLogLevel = 0;
    #boot.kernelPackages = cfg.boot.kernelPackage;
    boot.extraModulePackages = cfg.boot.extraModulePackages;
    boot.blacklistedKernelModules = cfg.boot.blacklistedKernelModules;

    services.flatpak.enable = true;
    services.upower.enable = true;

    services.plex = {
      enable = cfg.enablePlex;
      user = "atila";
    };

    services.jellyfin = {
      enable = cfg.enableJellyfin;
      user = "atila";
      openFirewall = true;
    };

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
        smartmontools
        iotop
        easyeffects
        virt-manager
        xfsprogs
        libxfs
        duf
        radeontop
        unstable.btdu
        nix-prefetch-scripts
        qjackctl
        nox
        unstable.distrobox
        cage
        binutils
        nixpkgs-fmt
        nix-index
        nix-update
        nixpkgs-review
        direnv
        niv
        file
        cheat
        imv
        rssguard
        unstable.nix-du
        graphviz
        any-nix-shell

        # research
        jabref
        texlive.combined.scheme-full
        fpm
        mendeley
        julia-bin
        fobis

        # lf
        lf
        trash-cli
        fasd
        chafa
        archivemount
        fzf
        xdragon
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
        p7zip

        # Browsers
        firefox-wayland
        qutebrowser
        google-chrome
        brave

        # Database
        sqlite
        dbeaver

        # File Browsers
        vifm-full


        # Python
        (let
           my-python-packages = python-packages: with python-packages; [
               pynvim
               devito
               matplotlib
               numpy
            #other python packages you want
           ];
           python-with-my-packages = python3.withPackages my-python-packages;
        in
           python-with-my-packages)

        # Apps
        calibre
        onlyoffice-bin
        tdesktop
        dropbox
        megasync
        keepassxc
        bitwarden
        unstable.kotatogram-desktop
        zathura
        font-manager
        gnome.gucharmap
        mpv
        buku
        unstable.oil-buku
        libsForQt5.okular
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
        unstable.droidmote
        cached-nix-shell
        gimp-with-plugins
        obsidian
        master.irpf
        bottles
        microsoft-edge-beta
        elementary-planner
        ventoy-bin
        usbimager
        jellyfin-mpv-shim
      ];

      defaultGaming = [
        # Gaming
        zeroad
        minetest
        lutris
        openssl
        opusfile
        unstable.yuzu-ea
        unstable.rpcs3
        pcsx2
        wine64Packages.stagingFull
        airshipper
        steam-run
        protontricks
        unstable.cataclysm-dda
        endgame-singularity
        mangohud
        openmw
        unstable.gamescope
      ];
      in
        (if cfg.packages.useDefault
          then defaultPackages
          else [ ])
        ++ (if cfg.packages.useDefaultGaming
          then defaultGaming
          else [ ])
        ++ cfg.packages.extra;


    services.xserver = {
      enable = true;

      displayManager = {
        gdm = {
          enable = true;
          autoSuspend = false;
          autoLogin = {
            delay = 2;
          };
        };


        defaultSession = "sway";
        autoLogin = {
          enable = true;
          user = "atila";
        };
      };

      desktopManager.cinnamon.enable = true;

      libinput.enable = true;

      layout = cfg.devices.input.keyboard.xkbLayout;
      xkbVariant = cfg.devices.input.keyboard.xkbVariant;
      xkbOptions = cfg.devices.input.keyboard.xkbOptions;
    };

    programs.gamemode.enable = true;
    programs.file-roller.enable = true;
    programs.autojump.enable = true;

    security.sudo.extraConfig = ''
      Defaults passwd_timeout=0
    '';

    programs.zsh = {
      enable = true;
      shellAliases = {
        rebuild-os = "sudo nixos-rebuild switch";
        upgrade-os = ''
          cd /etc/nixos
          nix flake update
          sudo nixos-rebuild boot
          git add flake.lock
          git commit -m "updated inputs"
          git push
          echo "Please reboot"
        '';
        edit-os = "nvim /etc/nixos/configuration.nix";
        gc-os = "nix-collect-garbage -d";
        verifyStore = "nix store verify --all --no-trust";
        repairStore = ''
          nix-store --verify --check-contents --repair
        '';
      };
      shellInit = ''
          source /home/atila/.config/shell/shenv
      '';
      promptInit = ''
        any-nix-shell zsh --info-right | source /dev/stdin
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

    i18n.defaultLocale = cfg.machine.locale;

    services.auto-cpufreq.enable = cfg.isLaptop;

    services.lorri.enable = true;
    services.locate = {
      enable = true;
      localuser = "atila";
      pruneBindMounts = false;
    };

    services.snapper.configs =
      let default = {
      };
      in
        default // cfg.snapperExtraDir;

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
      ];
    };

    zramSwap = {
      enable = true;
      priority = 32000;
      algorithm = "lz4";
      memoryPercent = 90;
    };
    nix = {
      autoOptimiseStore = true;
      gc = {
        automatic = true;
        persistent = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';
      package = pkgs.nixUnstable;
      trustedUsers = [ "@wheel" ];
      nixPath = [ "nixpkgs=/run/current-system/nixpkgs" ];
    };
    #nix.buildMachines = [
      #{
        #hostName = "192.168.0.19";
        #system = "x86_64-linux";
        #supportedFeatures = [ "big-parallel" "kvm" ];
        #sshUser = "atila";
        #maxJobs = 20;
        #speedFactor = 2;
        #sshKey = "/home/atila/.ssh/id_private";
      #}
      #{
        #hostName = "192.168.0.229";
        #system = "x86_64-linux";
        #supportedFeatures = [ "big-parallel" "kvm" ];
        #sshUser = "atila";
        #maxJobs = 3;
        #speedFactor = 1;
        #sshKey = "/home/atila/.ssh/id_private";
      #}
    #];
    system.extraSystemBuilderCmds = ''
      ln -s ${pkgs.path} $out/nixpkgs
    '';

    nix.distributedBuilds = true;

    system.autoUpgrade = {
      enable = cfg.machine.autoUpgrade;
      flake = "github:AtilaSaraiva/nix-dotfiles";
      dates = "13:00";
    };

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true; # so that gtk works properly
      extraPackages = with pkgs; let
        defaultPackages = [
        swaylock
        xwayland
        swayidle
        swaytools
        wf-recorder
        wl-clipboard
        sway-contrib.grimshot
        mako # notification daemon
        kitty # Alacritty is the default terminal in the config
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
        gnome.adwaita-icon-theme
        wdisplays
      ];
      laptopPackages = [
        brightnessctl
        acpi
      ];
      in
      (if cfg.isLaptop then laptopPackages else [ ])
      ++ defaultPackages;
      extraSessionCommands = ''
        #export SDL_VIDEODRIVER=wayland
        #export QT_QPA_PLATFORM=wayland
        #export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
      '';
    };
    xdg.portal = {
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

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
        hostKeys = [
          {
            bits = 4096;
            path = "/etc/ssh/ssh_host_rsa_key";
            type = "rsa";
          }
        ];
    };

    users.users = cfg.users.available;

    services.logind.lidSwitch = "suspend-then-hibernate";

    services.earlyoom = {
      enable = true;
      enableNotifications = true;
    };

    networking = {
      networkmanager = {
        enable = true;
        wifi.powersave = false;
      };

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
        #wireplumber.enable = true;
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

    hardware.opengl.extraPackages = with pkgs; [ # TODO: create an option for amdgpus
        rocm-opencl-icd
        amdvlk
        vaapiVdpau
        libvdpau-va-gl
        libva
    ];
    hardware.steam-hardware.enable = true;

    # Rule to increase polling rate of dualshock 4 to reduce input lag
    services.udev.extraRules = ''
      ACTION=="bind", SUBSYSTEM=="hid", DRIVER=="sony", KERNEL=="*054C:09CC*", ATTR{bt_poll_interval}="1"
    '';

    hardware.opengl.extraPackages32 = [
      pkgs.driversi686Linux.amdvlk
      pkgs.driversi686Linux.mesa
    ];

    services.btrfs.autoScrub = {
      enable = cfg.isBtrfs;
      interval = "monthly";
    };

    services.fcron = {
      enable = true;
      systab = ''
        0 12 * * 1 nix-store --verify --check-contents --repair
      '';
    };

    programs.dconf.enable = true;

    hardware.opengl.enable = true;
    hardware.opengl.driSupport32Bit = true;
    #services.undervolt.gpuOffset = 50;
    programs.corectrl.enable = true;
    programs.corectrl.gpuOverclock.enable = true;

    programs.msmtp.setSendmail = true;
    services.smartd.enable = true;
    #services.smartd.notifications.test = true;
    services.postfix.setSendmail = true;
    #services.smartd.notifications.mail.enable = true;
    services.postfix.enable = true;
    services.smartd.notifications.mail.recipient = "atilasaraiva@gmail.com";
  };
}
