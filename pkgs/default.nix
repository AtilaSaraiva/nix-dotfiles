self: super: rec {
  amdgpu-fan = super.callPackage ./amdgpu-fan { };
  stpv      = super.callPackage ./stpv { };
  microsoft-edge-stable = super.callPackage (import ./edge).stable { };
  microsoft-edge-beta = super.callPackage (import ./edge).beta { };
  microsoft-edge-dev = super.callPackage (import ./edge).dev { };
  fpm      = super.callPackage ./fpm { };
  fobis      = super.python3Packages.callPackage ./fobis { };
  waybar      = super.callPackage ./waybar { };
  monitor-dimensions-calculator      = super.callPackage ./monitor-dimensions-calculator { };
  #bcachefs-tools = super.bcachefs-tools.overrideAttrs (oldAttrs: {
    #version = "unstable-2023-03-19";
    #src = super.fetchgit {
      #url = "https://www.evilpiepirate.org/cgit/bcachefs-tools.git";
      #rev = "d22c79d2fff10dd782caf5668fd019387914a5bb";
      #sha256 = "0i2mfz4r350w3fsgx5919z283r73jsjvkbawxxnf3jg6g0gl2gad";
    #};
  #});

  #distrobox = super.distrobox.overrideAttrs (oldAttrs: {
    #version = "unstable-2022-05-25";
    #src = super.fetchFromGitHub {
      #owner = "89luca89";
      #repo = "distrobox";
      #rev = "cd49151";
      #sha256 = "sha256-Z4FK8k8bp7C293oTkWw+HRxlQKcY6bZGWu/Qx9WCQ9g=";
    #};
  #});
}
