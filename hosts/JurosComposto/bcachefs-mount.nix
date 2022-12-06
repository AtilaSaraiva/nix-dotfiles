{ config, pkgs, ... }:
{
  systemd.mounts = [{
    type = "bcachefs";
    #mountConfig = {
      #Options = "noatime";
    #};
    what = "/dev/disk/by-partuuid/2c6b4c12-b72d-2044-a014-cc888f442691:/dev/disk/by-partuuid/0810471b-1adf-4346-9ff9-67ddf371ae2f";
    where = "/mnt/array";
  }];

  systemd.automounts = [{
    wantedBy = [ "multi-user.target" ];
    automountConfig = {
      TimeoutIdleSec = "600";
    };
    where = "/mnt/array";
  }];

}
