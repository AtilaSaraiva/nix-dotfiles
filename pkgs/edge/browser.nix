{ channel, version, revision, sha256 }:

{ stdenv
, fetchurl
, lib

, binutils-unwrapped
, xz
, gnutar
, file

, gtk4
, pango

, glibc
, glib
, nss
, nspr
, atk
, at-spi2-atk
, xorg
, cups
, dbus
, expat
, libdrm
, libxkbcommon
, cairo
, gdk-pixbuf
, mesa
, alsa-lib
, at-spi2-core
, libuuid
, systemd
}:

let

  baseName = "microsoft-edge";

  shortName = if channel == "stable"
              then "msedge"
              else "msedge-" + channel;

  longName = if channel == "stable"
             then baseName
             else baseName + "-" + channel;

in

stdenv.mkDerivation rec {
  name="${baseName}-${channel}-${version}";

  src = fetchurl {
    url = "https://packages.microsoft.com/repos/edge/pool/main/m/${baseName}-${channel}/${baseName}-${channel}_${version}-${revision}_amd64.deb";
    inherit sha256;
  };

  unpackCmd = "${binutils-unwrapped}/bin/ar p $src data.tar.xz | ${xz}/bin/xz -dc | ${gnutar}/bin/tar -xf -";
  sourceRoot = ".";

  dontPatch = true;
  dontConfigure = true;
  dontPatchELF = true;

  buildPhase = let
    libPath = {
      msedge = lib.makeLibraryPath [
        glibc glib nss nspr atk at-spi2-atk xorg.libX11
        xorg.libxcb cups.lib dbus.lib expat libdrm
        xorg.libXcomposite xorg.libXdamage xorg.libXext
        xorg.libXfixes xorg.libXrandr libxkbcommon
        gtk4 pango cairo gdk-pixbuf mesa
        alsa-lib at-spi2-core xorg.libxshmfence systemd
      ];
      naclHelper = lib.makeLibraryPath [
        glib nspr atk libdrm xorg.libxcb mesa xorg.libX11
        xorg.libXext dbus.lib libxkbcommon
      ];
      libwidevinecdm = lib.makeLibraryPath [
        glib nss nspr
      ];
      libGLESv2 = lib.makeLibraryPath [
        xorg.libX11 xorg.libXext xorg.libxcb
      ];
      libsmartscreen = lib.makeLibraryPath [
        libuuid stdenv.cc.cc.lib
      ];
      libsmartscreenn = lib.makeLibraryPath [
        libuuid
      ];
      liboneauth = lib.makeLibraryPath [
        libuuid xorg.libX11
      ];
    };
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.msedge}" \
      opt/microsoft/${shortName}/msedge

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      opt/microsoft/${shortName}/msedge-sandbox

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      opt/microsoft/${shortName}/msedge_crashpad_handler

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath.naclHelper}" \
      opt/microsoft/${shortName}/nacl_helper

    patchelf \
      --set-rpath "${libPath.libwidevinecdm}" \
      opt/microsoft/${shortName}/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so

    patchelf \
      --set-rpath "${libPath.libGLESv2}" \
      opt/microsoft/${shortName}/libGLESv2.so

    patchelf \
      --set-rpath "${libPath.libsmartscreen}" \
      opt/microsoft/${shortName}/libsmartscreen.so

    patchelf \
      --set-rpath "${libPath.libsmartscreenn}" \
      opt/microsoft/${shortName}/libsmartscreenn.so

    patchelf \
      --set-rpath "${libPath.liboneauth}" \
      opt/microsoft/${shortName}/liboneauth.so
  '';

  installPhase = ''
    mkdir -p $out
    cp -R opt usr/bin usr/share $out

    ${if channel == "stable"
      then ""
      else "ln -sf $out/opt/microsoft/${shortName}/${baseName}-${channel} $out/opt/microsoft/${shortName}/${baseName}"}

    ln -sf $out/opt/microsoft/${shortName}/${longName} $out/bin/${baseName}-${channel}

    rm -rf $out/share/doc
    rm -rf $out/opt/microsoft/${shortName}/cron

    substituteInPlace $out/share/applications/${longName}.desktop \
      --replace /usr/bin/${baseName}-${channel} $out/bin/${baseName}-${channel}

    substituteInPlace $out/share/gnome-control-center/default-apps/${longName}.xml \
      --replace /opt/microsoft/${shortName} $out/opt/microsoft/${shortName}

    substituteInPlace $out/share/menu/${longName}.menu \
      --replace /opt/microsoft/${shortName} $out/opt/microsoft/${shortName}

    substituteInPlace $out/opt/microsoft/${shortName}/xdg-mime \
      --replace "''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" "''${XDG_DATA_DIRS:-/run/current-system/sw/share}" \
      --replace "xdg_system_dirs=/usr/local/share/:/usr/share/" "xdg_system_dirs=/run/current-system/sw/share/" \
      --replace /usr/bin/file ${file}/bin/file

    substituteInPlace $out/opt/microsoft/${shortName}/default-app-block \
      --replace /opt/microsoft/${shortName} $out/opt/microsoft/${shortName}

    substituteInPlace $out/opt/microsoft/${shortName}/xdg-settings \
      --replace "''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" "''${XDG_DATA_DIRS:-/run/current-system/sw/share}" \
      --replace "''${XDG_CONFIG_DIRS:-/etc/xdg}" "''${XDG_CONFIG_DIRS:-/run/current-system/sw/etc/xdg}"
  '';

  meta = with lib; {
    homepage = "https://www.microsoft.com/en-us/edge";
    description = "Microsoft's fork of Chromium web browser";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [
      { name = "Azure Zanculmarktum";
        email = "zanculmarktum@gmail.com"; }
    ];
  };
}
