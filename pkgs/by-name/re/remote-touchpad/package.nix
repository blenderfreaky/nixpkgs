{
  buildGoModule,
  fetchFromGitHub,
  lib,
  libXi,
  libXrandr,
  libXt,
  libXtst,
}:

buildGoModule rec {
  pname = "remote-touchpad";
  version = "1.4.8";

  src = fetchFromGitHub {
    owner = "unrud";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-C/qaLEYvIbl0XINsumAFLnsQgy+EDjoX446BJnuE6eQ=";
  };

  buildInputs = [
    libXi
    libXrandr
    libXt
    libXtst
  ];
  tags = [ "portal,x11" ];

  vendorHash = "sha256-bt5KUgNDgWX7CVHvX5c0uYqoxGRDbGbae52+mpnBEZU=";

  meta = with lib; {
    description = "Control mouse and keyboard from the web browser of a smartphone";
    mainProgram = "remote-touchpad";
    homepage = "https://github.com/unrud/remote-touchpad";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ schnusch ];
    platforms = platforms.linux;
  };
}
