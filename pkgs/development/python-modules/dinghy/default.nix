{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  pythonOlder,
  aiofiles,
  aiohttp,
  backports-datetime-fromisoformat,
  click,
  click-log,
  emoji,
  glom,
  jinja2,
  pyyaml,
  freezegun,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dinghy";
  version = "1.3.3";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "nedbat";
    repo = pname;
    tag = version;
    hash = "sha256-fn8SRzhFJyyr2Wr9/cp8Sm6kbVARq2LEeKSE0HU9V74=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    aiofiles
    aiohttp
    backports-datetime-fromisoformat
    click
    click-log
    emoji
    glom
    jinja2
    pyyaml
  ];

  nativeCheckInputs = [
    freezegun
    pytestCheckHook
  ];

  pythonImportsCheck = [ "dinghy.cli" ];

  meta = with lib; {
    description = "GitHub activity digest tool";
    mainProgram = "dinghy";
    homepage = "https://github.com/nedbat/dinghy";
    changelog = "https://github.com/nedbat/dinghy/blob/${version}/CHANGELOG.rst";
    license = licenses.asl20;
    maintainers = with maintainers; [
      trundle
      veehaitch
    ];
  };
}
