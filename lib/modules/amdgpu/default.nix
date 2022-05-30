{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.amdgpu-fan;
  format = pkgs.formats.yaml { };
in
{
  options.services.amdgpu-fan = {
    enable = mkEnableOption "Fan controller for AMD graphics cards running the amdgpu driver on Linux";
    settings = mkOption {
      type = format.type;
      default = { };
      defaultText = literalExpression "{ }";
      example = literalExpression ''
        {
          speed_matrix = [
            [0 0]
            [40 40]
            [60 60]
            [70 70]
            [80 90]
          ];
          temp_drop = 8;
        };
      '';
      description = ''
        Configuration written to
        <filename>/etc/amdgpu-fan.yml</filename>. See
        <link xlink:href="<link-to-more-info>"/> for more options.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.etc."amdgpu-fan.yml" = mkIf (cfg.settings != { }) {
      source = format.generate "amdgpu-fan.yml" cfg.settings;
    };

    environment.systemPackages = [ pkgs.amdgpu-fan ];

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
