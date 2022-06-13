{ stdenv, lib, fetchurl, gfortran }:

stdenv.mkDerivation rec {
  pname = "fpm";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/fortran-lang/fpm/releases/download/v${version}/fpm-${version}.F90";
    sha256 = "sha256-U7uk09Cdh11RPtQwmj3v5BT6cn283rOOT9zwlOGcAlc=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ gfortran ];

  buildPhase = ''
    gfortran ${src} -o fpm
  '';

  installPhase = ''
    install -Dm755 -t $out/bin/ fpm
  '';

  meta = with lib; {
    description = "Fortran Package Manager (fpm)";
    homepage = "fpm.fortran-lang.org";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ atila ];
  };
}
