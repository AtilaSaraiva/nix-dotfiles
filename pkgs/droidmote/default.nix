{ lib, stdenv, fetchurl }:

let
  srcs = {
    x86_64-linux = fetchurl{
      url    = "https://videomap.it/script/dms-ubuntu-x64";
      sha256 = "1x7pp6k27lr206a8j2pn0wf4wjb0zi28s0g1g3rb08jmr8fh1jnh";
    };
    i686-linux = fetchurl{
      url    = "https://videomap.it/script/dms-ubuntu-x32";
      sha256 = "1d62d7jz50wzk5rqqm3xab66jdzi9i1j6mwxf7r7nsgm6j5zz8r4";
    };
    aarch64-linux = fetchurl{
      url    = "https://videomap.it/script/dms-ubuntu-arm64";
      sha256 = "1l1x7iqbxn6zsh3d37yb5x15qsxlwy3cz8g2g8vnzkgaafw9vva0";
    };

    armv7l-linux = fetchurl{
      url    = "https://videomap.it/script/dms-ubuntu-arm";
      sha256 = "1i7q9mylzvbsfydv4xf83nyqkh0nh01612jrqm93q1w6d0k2zvcd";
    };
  };
in
stdenv.mkDerivation rec {
  pname = "droidmote";
  version = "3.0.6";

  src = srcs.${stdenv.hostPlatform.system} or (throw "Unsurpported system: ${stdenv.hostPlatform.system}");

  phases = [ "installPhase" ];

  setSourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -m755 -D ${src} $out/bin/droidmote
    runHook postInstall
  '';

  postInstall = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/droidmote
  '';

  meta = with lib; {
    description = "Control your computer from your couch";
    homepage = "https://www.videomap.it/";
    license = licenses.unfree;
    maintainers = with maintainers; [ atila ];
    platforms = lib.attrNames srcs;
  };
}
