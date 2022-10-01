{ stdenv
, lib
, fetchFromGitHub
, meson
, pkg-config
, ninja
, fmt
}:

stdenv.mkDerivation rec {
  pname = "monitor-dimensions-calculator";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "AtilaSaraiva";
    repo = pname;
    rev = version;
    sha256 = "sha256-RfjDvmnC8I3v8fjZ/MF2UhloYeCAIFHk7wj3qLaY6sM=";
  };

  nativeBuildInputs = [ meson ninja pkg-config ];
  buildInputs = [ fmt ];

  meta = with lib; {
    description = "Simple program to calculate computer monitor (and TVs) dimensions in cm";
    homepage = "https://github.com/AtilaSaraiva/monitor-dimensions-calculator";
    platforms = platforms.unix;
    maintainers = with maintainers; [ atila ];
  };
}

