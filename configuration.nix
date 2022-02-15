# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstableTarball =
      fetchTarball
        https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
  nixpkgs.config.allowUnfree = true;
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #import ./modules/module-list.nix
    ];

  services.plex = {
    enable = true;
    user = "atila";
  };

  services.flatpak.enable = true;

  services.upower.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    };

  systemd.services = {
    create-swapfile = {
      serviceConfig.Type = "oneshot";
      wantedBy = [ "swap-swapfile.swap" ];
      script = ''
        ${pkgs.coreutils}/bin/truncate -s 0 /swap/swapfile
        ${pkgs.e2fsprogs}/bin/chattr +C /swap/swapfile
        ${pkgs.btrfs-progs}/bin/btrfs property set /swap/swapfile compression none
      '';
    };
  };


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;
  boot.kernel.sysctl = {
    "abi.vsyscall32" = 0;
    "vm.swappiness"  = 60;
    "kernel.sysrq"   = 1;
    };
  boot.supportedFilesystems = [ "btrfs" "xfs" "ntfs" ];
  boot.tmpOnTmpfs = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  #boot.extraModulePackages = [ pkgs.linuxPackages.rtl88xxau-aircrack ];
  boot.extraModulePackages = [ pkgs.linuxPackages_zen.rtl88xxau-aircrack ];
  #boot.loader.grub.useOSProber = true;

  security.pam.loginLimits = [
    { domain = "*"; item = "memlock"; type = "hard"; value = "unlimited"; }
    { domain = "*"; item = "memlock"; type = "soft"; value = "unlimited"; }
  ];

  networking.hostName = "JurosComposto"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Bahia";

  # Select internationalisation properties.
   i18n.defaultLocale = "pt_BR.UTF-8";
   console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };


  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.defaultSession = "sway";
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "atila";


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


  # Configure keymap in X11
  services.xserver.layout = "br";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.atila = {
     isNormalUser = true;
     shell = pkgs.zsh;
     extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" ]; # Enable ‘sudo’ for the user.
     uid = 1001;
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    waydroid = {
        enable = true;
    };
    libvirtd = {
        enable = true;
    };
  };

  programs.dconf.enable = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.opengl.extraPackages = with pkgs; [
      rocm-opencl-icd
      intel-compute-runtime
      amdvlk
      vaapiVdpau
      libvdpau-va-gl
      libva
  ];

  # To enable Vulkan support for 32-bit applications, also add:
  hardware.opengl.extraPackages32 = [
    pkgs.driversi686Linux.amdvlk
  ];

  # Force radv
  environment.variables.AMD_VULKAN_ICD = "RADV";

  fonts.fonts = with pkgs; [
     font-awesome
     cantarell-fonts
     roboto-mono
     fantasque-sans-mono
     material-icons
  ];

  hardware.steam-hardware.enable = true;
  system.copySystemConfiguration = true;

  nixpkgs.config = {
    packageOverrides = pkgs: with pkgs; {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  nixpkgs.overlays = [ (import ./pkgs) ];

  #nixpkgs.overlays = [
    #(
      #self: super:
      #{
        #rpcs3 = super.rpcs3.overrideAttrs (old: {
          #src = super.fetchFromGitHub {
            #owner = "RPCS3";
            #repo = "rpcs3";
            #rev = "fd0e7a4efa73a8c4afa10b974da75917337e0cb5";
            #fetchSubmodules = true;
            ##sha256 = "19padq5llvj2rk2g33im879gy15lk7xhjhvigjx0x8cqwlf1p3bb";
            #hash = "sha256-4i8u54HstfkBaHLgtr+4H2WyoiEO/TfpP863Jmzx3P4=";
          #};
        #});
      #}
    #)
  #];

  environment.systemPackages = with pkgs; [
     # Editor
     neovim

     # System tools
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

     # Image viewers
     feh

     # Compression
     unstable.ouch
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
     vifm


     # Python
     (let
        my-python-packages = python-packages: with python-packages; [
            pynvim
         #other python packages you want
        ];
        python-with-my-packages = python3.withPackages my-python-packages;
     in
        python-with-my-packages)
     micromamba

     # Apps
     wpsoffice
     tdesktop
     slack
     dropbox
     keepassxc
     zathura
     font-manager
     gnome.gucharmap
     mpv
     buku
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

     # Gaming
     zeroad
     protonup
     unstable.heroic
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
   ];


  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  environment.variables.EDITOR = "nvim";
  programs.gamemode.enable = true;
  programs.file-roller.enable = true;

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


  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };

  services.undervolt.gpuOffset = 50;
  services.locate = {
    enable = true;
    locate = pkgs.plocate;
    localuser = "atila";
    pruneBindMounts = false;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
      enable = true;
      ports = [
        22
        35901
      ];
  };

  networking.firewall.enable = false;

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
  system.autoUpgrade.enable = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
