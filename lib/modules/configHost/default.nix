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
        default = "America/Edmonton";
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
        default = false;
      };
    };

    isBtrfs = mkEnableOption ''
      Does the system contain a btrfs partition?
    '';

    isBcachefs = mkEnableOption ''
      Does the system contain a bcachefs partition?
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
        default = pkgs.linuxPackages_latest;
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

    enableAdguard = mkOption {
      description = "Do you want to enable adguard?";
      type = types.bool;
      default = false;
      example = true;
    };

    serveNixStore = mkOption {
      description = "Do you want to enable nix-serve?";
      type = types.bool;
      default = false;
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
          SUBVOLUME = "/home";
          ALLOW_USERS = [ "atila" ];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
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
    #nixpkgs.config.permittedInsecurePackages = [
      #"openjdk-18+36"
    #];
    #nixpkgs.config.permittedInsecurePackages = [
      #"qtwebkit-5.212.0-alpha4"
    #];

    networking.hostName = cfg.machine.hostName;
    time.timeZone = cfg.machine.timeZone;
    system.stateVersion = cfg.machine.stateVersion;

    boot.tmp.useTmpfs = cfg.boot.tmpOnTmpfs;
    boot.tmp.cleanOnBoot = !cfg.boot.tmpOnTmpfs;
    boot.tmp.tmpfsSize = "400%";
    boot.loader.systemd-boot.enable = cfg.boot.loader.systemdBoot.enable;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = cfg.boot.loader.systemdBoot.timeout;
    boot.loader.systemd-boot.memtest86.enable = true;
    boot.loader.grub.useOSProber = true;
    boot.kernel.sysctl = {
      "abi.vsyscall32" = 0;
      "vm.swappiness"  = 7;
      "kernel.sysrq"   = 1;
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      };
    boot.enableContainers = false;
    boot.supportedFilesystems = [ "btrfs" "xfs" "ntfs" ] ++ (if cfg.isBcachefs then ["bcachefs"] else []);
    boot.kernelParams = [ "quiet" "udev.log_level=3" "preempt=voluntary" "intel_iommu=on" "iommu=pt" ];
    # Silent boot
    boot.initrd.verbose = false;
    boot.consoleLogLevel = 0;
    boot.kernelPackages = if cfg.isBcachefs then lib.mkForce pkgs.linuxPackages_testing_bcachefs else cfg.boot.kernelPackage;
    #boot.kernelPackages = if cfg.isBcachefs then lib.mkForce (
      #let
        #linux_bcachefs_pkg = {fetchgit, buildLinux, ...} @ args:
          #buildLinux (args // rec {
            #version = "6.2.0";
            #modDirVersion = version;

            #src = fetchgit {
              #url = "https://evilpiepirate.org/git/bcachefs.git";
              #rev = "993b957fb7c91f6658b0a838a7ef70be7097209a";
              #sha256 = "0c0igjjwi20nhj85fnvr8cd62sfh6r39pxci0zya3gq44zxfblr5";
            #};

            #kernelPatches = [];

            #extraConfig = ''
              #CRYPTO_CRC32C_INTEL y
              #BCACHEFS_FS y
              #BCACHEFS_POSIX_ACL y
            #'';

            #extraMeta.branch = "6.1";
          #} // (args.argsOverride or {}));
        #linux_bcachefs = pkgs.callPackage linux_bcachefs_pkg{};
      #in
        #pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_bcachefs))
    #else cfg.boot.kernelPackage;

    boot.extraModulePackages = cfg.boot.extraModulePackages;
    boot.blacklistedKernelModules = cfg.boot.blacklistedKernelModules;

    services.flatpak.enable = true;
    services.upower.enable = true;

    services.plex = {
      enable = cfg.enablePlex;
      user = "atila";
    };

    services.adguardhome = {
      enable = cfg.enableAdguard;
    };

    services.jellyfin = {
      enable = cfg.enableJellyfin;
      user = "atila";
      openFirewall = true;
      package = pkgs.jellyfin;
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
          exec ${pkgs.nixVersions.nix_2_14}/bin/nix --experimental-features "nix-command flakes" "$@"
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
        #mate.pluma
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
        btdu
        nix-prefetch-scripts
        #qjackctl
        nox
        distrobox
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
        #rssguard
        nix-du
        graphviz
        any-nix-shell
        gh
        openconnect
        animedownloader
        conda
        glxinfo
        entr

        # research
        #jabref
        texlive.combined.scheme-full
        fpm
        #mendeley
        julia
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
        #wkhtmltopdf
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
        ungoogled-chromium
        #brave

        # Database
        #sqlite
        #dbeaver

        # File Browsers
        vifm-full

        bcachefs-tools


        # Python
        (let
           my-python-packages = python-packages: with python-packages; [
               pynvim
               matplotlib
               numpy
               notebook
            #other python packages you want
           ];
           python-with-my-packages = python3.withPackages my-python-packages;
        in
           python-with-my-packages)

        # nodejs
        nodejs

        # Apps
        mumble
        spotify
        zotero
        termpdfpy
        calibre
        onlyoffice-bin
        tdesktop
        dropbox
        #megasync
        keepassxc
        bitwarden
        #kotatogram-desktop
        zathura
        font-manager
        gnome.gucharmap
        mpv
        buku
        oil-buku
        libsForQt5.okular
        qbittorrent
        xournalpp
        obs-studio
        inkscape
        blanket
        libreoffice-fresh
        element-desktop
        youtube-dl
        #sayonara
        #homebank
        droidmote
        #cached-nix-shell
        gimp-with-plugins
        pinta
        obsidian
        #master.irpf
        bottles
        #microsoft-edge-beta
        #ventoy-bin
        #usbimager
        #jellyfin-mpv-shim
        jellyfin-media-player
        keybase-gui
        keybase
        scrcpy
        kopia
        monitor-dimensions-calculator
        transmission-qt
      ];

      defaultGaming = [
        # Gaming
        zeroad
        minetest
        lutris
        openssl
        opusfile
        #yuzu-ea
        rpcs3
        pcsx2
        wine64Packages.stagingFull
        airshipper
        steam-run
        protontricks
        #unstable.cataclysm-dda
        #endgame-singularity
        mangohud
        openmw
        gamescope
        dwarf-fortress-packages.dwarf-fortress-full
        #(pkgs.dwarf-fortress-packages.dwarf-fortress-full.override {
          #dfVersion = "0.44.11";
          #theme = "cla";
          #enableIntro = false;
          #enableFPS = true;
        #})
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

      videoDrivers = [ "amdgpu" ];

      displayManager = {
        gdm = {
          enable = true;
          autoSuspend = false;
          autoLogin = {
            delay = 5;
          };
        };

        defaultSession = "sway";
        autoLogin = {
          enable = true;
          user = "atila";
        };
      };

      #desktopManager.cinnamon.enable = true;

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
        gc-os = "nix-collect-garbage -d";
        verifyStore = "nix store verify --all --no-trust";
        repairStore = ''
          nix-store --verify --check-contents --repair
        '';
        uofa = ''
          sudo openconnect --protocol=anyconnect --servercert=pin-sha256:oIOESyet47e1GwMKncQkFuJ8JyungURZ57IPuM0cDH8= --server=vpn.ualberta.ca --user=saraivaq
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

    services.thinkfan = {
      enable = cfg.isLaptop;
      levels = [
        [ 0 0 55 ]
        [ 1 48 60 ]
        [ 2 50 61 ]
        [ 3 52 63 ]
        [ 6 56 65 ]
        [ 7 60 85 ]
        [
          "level auto"
          80
          32767
        ]
      ];
    };

    services.tailscale.enable = true;

    services.webdav = {
      enable = true;
      user = "atila";
      settings = {
        address = "0.0.0.0";
        port = 31460;
        scope = "/home/atila/Files/zotero/";
        modify = true;
        auth = true;
        users = [
          {
            username = "atila";
            password = "qwerty";
          }
        ];
      };
    };

    programs.mosh.enable = true;

    qt.platformTheme = "qt5ct";

    services.lorri.enable = true;
    services.locate = {
      enable = true;
      localuser = "atila";
      pruneBindMounts = false;
      interval = "hourly";
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
      settings = {
        trusted-users = [ "@wheel" ];
        auto-optimise-store = true;
        trusted-public-keys = [
          "key-name:36fe2VUzGDWhD3851hppXbCgQqlMtKSL7XPGNYnzAZk="
        ];
      };
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
          swaylock-effects
          xwayland
          swayidle
          swaytools
          wf-recorder
          wl-clipboard
          sway-contrib.grimshot
          mako # notification daemon
          kitty # Alacritty is the default terminal in the config
          waybar
          autotiling
          wlsunset
          cinnamon.nemo
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

    services.printing = {
      enable = true;
      startWhenNeeded = false;
      browsing = false;
      drivers = [ ];
    };
    services.avahi.enable = true;
    services.avahi.nssmdns = true;
    # for a WiFi printer
    services.avahi.openFirewall = true;
    hardware.printers = {
      ensurePrinters = [
        {
          name = "BrotherDCPL2550DW";
          location = "Home";
          deviceUri = "ipp://10.0.0.132:631/ipp";
          model = "everywhere";
          ppdOptions = {
            PageSize = "Letter";
            Duplex = "DuplexNoTumble";
            PrintQuality="4";
            PwgRasterDocumentType="SGray_8";
          };
        }
      ];
      ensureDefaultPrinter = "BrotherDCPL2550DW";
    };

    xdg.mime.defaultApplications = {
      "application/pdf" = "zathura";
      "image/png" = "feh";
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    programs.ssh = {
      setXAuthLocation = true;
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
        settings = {
          X11Forwarding = true;
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
    };

    users.users = cfg.users.available;

    services.logind.lidSwitch = "suspend";

    services.earlyoom = {
      enable = true;
      enableNotifications = true;
    };

    services.udisks2.enable = true;

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
    };
    hardware.pulseaudio.enable = false;

    security.rtkit.enable = true;

    services.murmur = {
      enable = true;
      openFirewall = true;
    };

    environment.etc = let
      json = pkgs.formats.json {};
    in {
      "pipewire/pipewire-pulse.d/92-low-latency.conf".source = json.generate "92-low-latency.conf" {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "32/48000";
              pulse.default.req = "32/48000";
              pulse.max.req = "32/48000";
              pulse.min.quantum = "32/48000";
              pulse.max.quantum = "32/48000";
            };
          }
        ];
        stream.properties = {
          node.latency = "32/48000";
          resample.quality = 1;
        };
      };
      "pipewire/pipewire.d/92-low-latency.conf".source = json.generate "92-low-latency.conf" {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 32;
          default.clock.min-quantum = 32;
          default.clock.max-quantum = 32;
        };
      };
    };

    hardware.sane = {
      enable = true;
      brscan5 = {
        enable = true;
        netDevices = {
          brother = {
            ip = "10.0.0.132";
            model = "DCP-L2550DW";
          };
        };
      };
      extraBackends = [ pkgs.sane-airscan ];
    };

    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
      };
    };

    programs.singularity = {
      enable = true;
      enableSuid = true;
      enableFakeroot = true;
    };

    hardware.opengl.extraPackages = with pkgs; [ # TODO: create an option for amdgpus
        rocm-opencl-icd
        amdvlk
        vaapiVdpau
        libvdpau-va-gl
        libva
    ];
    programs.steam.enable = cfg.packages.useDefaultGaming;
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

    services.tor = {
      enable = true;
      client.enable = true;
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
    services.keybase.enable = true;
    services.kbfs = {
      enable = true;
      mountPoint = "%h/Files/keybase";
      extraFlags = [
        "-label kbfs"
        "-mount-type normal"
      ];
    };

    programs.adb.enable = true;

    services.nix-serve = {
      enable = cfg.serveNixStore;
      secretKeyFile = "/home/atila/.ssh/cache-priv-key.pem";
    };

    services.mullvad-vpn.enable = true;

    programs.noisetorch.enable = true;
  };
}
