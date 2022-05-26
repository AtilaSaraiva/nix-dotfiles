self: super: rec {
  amdgpu-fan = super.callPackage ./amdgpu-fan { };
  stpv      = super.callPackage ./stpv { };
  microsoft-edge-stable = super.callPackage (import ./edge).stable { };
  microsoft-edge-beta = super.callPackage (import ./edge).beta { };
  microsoft-edge-dev = super.callPackage (import ./edge).dev { };
  distrobox = super.distrobox.overrideAttrs (oldAttrs: {
    version = "unstable-2022-05-25";
    src = super.fetchFromGitHub {
      owner = "89luca89";
      repo = "distrobox";
      rev = "cd49151";
      sha256 = "sha256-Z4FK8k8bp7C293oTkWw+HRxlQKcY6bZGWu/Qx9WCQ9g=";
    };
  });
}
