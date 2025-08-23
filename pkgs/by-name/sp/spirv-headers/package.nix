{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation rec {
  pname = "spirv-headers";
  version = "1.4.322.0";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Headers";
    rev = "a8637796c28386c3cf3b4e8107020fbb52c46f3f";
    hash = "sha256-eOe6L957Necug+6KUQ8EwCTjpBOWHiW1rgyTvPogVEY=";
  };

  nativeBuildInputs = [cmake];

  meta = with lib; {
    description = "Machine-readable components of the Khronos SPIR-V Registry";
    homepage = "https://github.com/KhronosGroup/SPIRV-Headers";
    license = licenses.mit;
    maintainers = [maintainers.ralith];
  };
}
