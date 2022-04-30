self: super: rec {
  droidmote = super.callPackage ./droidmote { };
  amdgpu-fan = super.callPackage ./amdgpu-fan { };
  stpv      = super.callPackage ./stpv { };
}
