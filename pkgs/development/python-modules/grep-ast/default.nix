{
  buildPythonPackage,
  fetchPypi,
  lib,

  pathspec,
  pytestCheckHook,
  setuptools,
  tree-sitter-languages,
}:

buildPythonPackage rec {
  pname = "grep-ast";
  version = "0.6.1";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "grep_ast";
    hash = "sha256-uQRYCpkUl6/UE1xRohfQAbJwhjI7x1KWc6HdQAPuJNA=";
  };

  build-system = [ setuptools ];

  dependencies = [
    pathspec
    tree-sitter-languages
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "grep_ast" ];

  meta = {
    homepage = "https://github.com/paul-gauthier/grep-ast";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ greg ];
    description = "Python implementation of the ast-grep tool";
    mainProgram = "grep-ast";
  };
}
