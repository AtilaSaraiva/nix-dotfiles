{ stdenv, lib, fetchurl, jq, peco, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "oil-buku";
  version = "0.3.2";

  src = fetchurl {
    url = "https://github.com/AndreiUlmeyda/oil/archive/refs/tags/${version}.tar.gz";
    sha256 = "1nwas1v0z2sjfab8ada9k9pf4jw4jn79rzmmn4n69xlfzzf4npq6";
  };

  passthru.updateScript = [ ./update.sh ];

  postUnpack = ''
    sed -i 's/$LIBDIR/$LOCALLIB/g' oil-${version}/src/oil
  '';

  buildInputs = [ jq peco ];
  nativeBuildInputs = [ makeWrapper ];
  dontPatchShebangs = true;

  buildPhase = ''
    runHook preBuild;
    runHook postBuild;
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib
    cp src/oil $out/bin/
    cp src/json-to-line.jq $out/lib/
    cp src/format-columns.awk $out/lib/

    wrapProgram $out/bin/oil \
        --prefix PATH : ${lib.makeBinPath [ jq peco ]} \
        --prefix LOCALLIB : "$out/lib"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Search-as-you-type cli frontend for the buku bookmarks manager using peco.";
    homepage = "https://github.com/AndreiUlmeyda/oil";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ atila ];
  };
}
