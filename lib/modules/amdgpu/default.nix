{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.amdgpu-fan;
in {
  options.services.amdgpu-fan = {
    enable = mkEnableOption "Fan controller for AMD graphics cards running the amdgpu driver on Linux";
  };

  config = mkIf cfg.enable {
    environment = {
      etc."amdgpu-fan.yml".text = ''
        # /etc/amdgpu-fan.yml
        # eg:

        speed_matrix:  # -[temp(*C), speed(0-100%)]
        - [0, 0]
        - [40, 40]
        - [60, 60]
        - [70, 70]
        - [80, 90]

        # optional
        # cards:  # can be any card returned from
        #         # ls /sys/class/drm | grep "^card[[:digit:]]$"
        # - card0

        # optional
        temp_drop: 8  # how much temperature should drop before fan speed is decreased
      '';

      systemPackages = [ pkgs.amdgpu-fan ];
    };
    systemd.services.amdgpu-fan = {
      description = "A fan manager daemon for amd gpus";
      wantedBy = [ "sysinit.target" ];
      after = [ "syslog.target" "sysinit.target" ];
      restartTriggers = [ config.environment.etc."amdgpu-fan.yml".source ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.amdgpu-fan}/bin/amdgpu-fan";
        Restart = "always";
      };
    };
  };
}
