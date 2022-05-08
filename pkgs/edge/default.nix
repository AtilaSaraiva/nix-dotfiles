{
  beta = import ./browser.nix {
    channel = "beta";
    version = "101.0.1210.39";
    revision = "1";
    sha256 = "sha256:0mjiziy13wj5r8m0lngwlx6gy3vlyr3796g8nz9dacgyyx8lb5wf";
  };
  dev = import ./browser.nix {
    channel = "dev";
    version = "102.0.1245.3";
    revision = "1";
    sha256 = "sha256:1j1j85nas24185bqxa6ipf824cvf1d8ssk284wahwzqs89d28ryv";
  };
  stable = import ./browser.nix {
    channel = "stable";
    version = "101.0.1210.39";
    revision = "1";
    sha256 = "sha256:0y57mgyhhnv3azxcpn070spm21gk8rqb8m3s8vmfyq96h9sw2p70";
  };
}
