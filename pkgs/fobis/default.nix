{ lib
, buildPythonApplication
, fetchPypi
, configparser
, future
, gfortran
}:

buildPythonApplication rec {
  pname = "fobis";
  version = "3.0.5";

  src = fetchPypi {
    pname = "FoBiS.py";
    inherit version;
    sha256 = "sha256-7yP95BmSd6vGk9U5qB4HKFccNJF02mt0dlefgkgquWw=";
  };

  propagatedBuildInputs = [ configparser future gfortran ];
}
