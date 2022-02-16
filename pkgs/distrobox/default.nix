{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  pname = "distrobox";
  version = "1.2.13";

  src = fetchurl {
    url = "https://github.com/89luca89/distrobox/archive/refs/tags/1.2.13.tar.gz";
    sha256 = "00x6rrw1z2z2w1aw2l2v773n25rd25d8fmvz45i188gjp316kyq1";
  };

  dontConfigure = true;
  dontBuild = true;

  passthru.updateScript = ./update.sh;

  installPhase = ''
    runHook preInstall
    install -D -m 0755 distrobox $out/bin/distrobox
    install -D -m 0755 distrobox-export $out/bin/distrobox-export
    install -D -m 0755 distrobox-create $out/bin/distrobox-create
    install -D -m 0755 distrobox-init $out/bin/distrobox-init
    install -D -m 0755 distrobox-list $out/bin/distrobox-list
    install -D -m 0755 distrobox-rm $out/bin/distrobox-rm
    install -D -m 0755 distrobox-enter $out/bin/distrobox-enter
    install -D -m 0755 distrobox-enter $out/bin/distrobox-enter
    install -D -m 0644 man/man1/distrobox.1 $out/share/man/man1/distrobox
    install -D -m 0644 man/man1/distrobox-export.1 $out/share/man/man1/distrobox-export
    install -D -m 0644 man/man1/distrobox-create.1 $out/share/man/man1/distrobox-create
    install -D -m 0644 man/man1/distrobox-init.1 $out/share/man/man1/distrobox-init
    install -D -m 0644 man/man1/distrobox-list.1 $out/share/man/man1/distrobox-list
    install -D -m 0644 man/man1/distrobox-rm.1 $out/share/man/man1/distrobox-rm
    install -D -m 0644 man/man1/distrobox-enter.1 $out/share/man/man1/distrobox-enter
    install -D -m 0644 man/man1/distrobox-enter.1 $out/share/man/man1/distrobox-enter
    runHook postInstall
  '';

  meta = with lib; {
    description = "Use any linux distribution inside your terminal. Enable both backward and forward compatibility with software and freedom to use whatever distribution you’re more comfortable with.";
    homepage = "https://distrobox.privatedns.org/";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ atila ];
  };
}
