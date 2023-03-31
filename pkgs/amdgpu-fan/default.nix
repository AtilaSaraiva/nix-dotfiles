{ lib, python3Packages, fetchFromGitHub}:

python3Packages.buildPythonApplication rec {
  pname = "amdgpu-fan";
  version = "unstable-2022-01-15";

  postPatch = ''
    substituteInPlace setup.py --replace "PROJECTVERSION" "0.0.6"
  '';

  src = fetchFromGitHub {
    owner = "chestm007";
    repo  = pname;
    rev = "b0cb2d0da866c58329ce2edf146be1c41d3f6d8d";
    sha256 = "0p8lnvcfvdqg13217abh9qcnpsvi6szq5jm10gr8x4b50lwp167d";
  };

  propagatedBuildInputs = with python3Packages; [ pyyaml numpy ];

  meta = with lib; {
    description = "Fan controller for AMD graphics cards running the amdgpu driver on Linux";
    homepage = "https://github.com/chestm007/amdgpu-fan";
    license = licenses.gpl2;
    maintainers = with maintainers; [ atila ];
  };
}

