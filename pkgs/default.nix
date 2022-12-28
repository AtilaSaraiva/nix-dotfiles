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
  bcachefs-tools = super.bcachefs-tools.overrideAttrs (oldAttrs: {
    version = "unstable-2022-12-21";
    src = super.fetchgit {
      url = "https://www.evilpiepirate.org/cgit/bcachefs-tools.git";
      rev = "0417560649434fc985896c84527fbdadbb06aa42";
      sha256 = "0whq2xwq9dyn55fkwbgxxjphfixm4q9rrdrsdmnw68l52hwchkc9";
    };
  });
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
