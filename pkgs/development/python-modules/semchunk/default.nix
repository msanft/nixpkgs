{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  mpire,
  tqdm,
}:

buildPythonPackage rec {
  pname = "semchunk";
  version = "3.1.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JF/7/sj/IJ6gwtTIQ1BCb6jUYKJaRgzB7Y7rNrtjKVw=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    mpire
    tqdm
  ];

  pythonImportsCheck = [
    "semchunk"
  ];

  meta = {
    description = "A fast, lightweight and easy-to-use Python library for splitting text into semantically meaningful chunks";
    homepage = "https://pypi.org/project/semchunk/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ booxter ];
  };
}
