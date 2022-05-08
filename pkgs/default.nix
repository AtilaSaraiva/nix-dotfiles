self: super: rec {
  amdgpu-fan = super.callPackage ./amdgpu-fan { };
  stpv      = super.callPackage ./stpv { };
  microsoft-edge-stable = super.callPackage (import ./edge).stable { };
  microsoft-edge-beta = super.callPackage (import ./edge).beta { };
  microsoft-edge-dev = super.callPackage (import ./edge).dev { };
}
