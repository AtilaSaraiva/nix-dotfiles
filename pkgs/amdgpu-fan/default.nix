{ lib, python3Packages, fetchFromGitHub}:

python3Packages.buildPythonApplication rec {
  pname = "amdgpu-fan";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "zzkW35";
    repo  = pname;
    rev = version;
    sha256 = "sha256-oWrRnEY+B16dJE9cZT8q71zzxHeuTTxRkuv14nD14AE=";
  };

  propagatedBuildInputs = with python3Packages; [ pyyaml numpy ];
}
