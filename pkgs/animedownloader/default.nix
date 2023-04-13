{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "animedownloader";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "AtilaSaraiva";
    repo = pname;
    rev = version;
    sha256 = "sha256-WEtbgu/dW5JK0/imLfdg1aYvjJXXebhfCRgTgszvMNo=";
  };

  propagatedBuildInputs = with python3Packages; [
    requests
    beautifulsoup4
  ];

  meta = with lib; {
    description = "A command-line tool to search for anime torrents on Anime Tosho and download them using qBittorrent";
    homepage = "https://github.com/AtilaSaraiva/animedownloader";
    license = licenses.wtfpl;
    maintainers = with maintainers; [ atila ]; # Replace with your maintainer name
  };
}
