{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, pandoc
, jq
, diff-so-fancy
, poppler_utils
, ffmpegthumbnailer
}:

stdenvNoCC.mkDerivation rec {
  pname = "stpv";
  version = "18ab12c";

  src = fetchFromGitHub {
    owner = "Naheel-Azawy";
    repo = pname;
    rev = version;
    sha256 = "1gq139bcrv5drgqzjdf9wmpgpa3w8f1bdg1ikxb65g4n7lm48ig3";
  };

  postPatch = ''
    substituteInPlace Makefile --replace \
    "/usr/local" "$out/"
  '';

  nativeBuildInputs = [ makeWrapper ];
  postInstallation = ''
    wrapProgram $out/bin/stpv* \
    --prefix PATH : ${lib.makeBinPath [
      pandoc
      jq
      diff-so-fancy
      poppler_utils
      ffmpegthumbnailer
    ]}
  '';
}
