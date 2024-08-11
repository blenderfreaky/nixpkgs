{ lib
, stdenvNoCC
, fetchzip
, fetchurl
, autoPatchelfHook
, makeWrapper
, libva
, alsa-lib
, libgcc
, libunwind
, libvdpau
, vulkan-loader
, pipewire
, SDL2
, wayland
, libxkbcommon
, libGL
, zenity
, xdg-utils
, nix-update-script
}:
stdenvNoCC.mkDerivation rec {
  pname = "alvr";
  version = "20.9.1";

  src =
    fetchzip
      {
        url = "https://github.com/alvr-org/ALVR/releases/download/v${version}/alvr_streamer_linux.tar.gz";
        hash = "sha256-S8GeUskAqxzPqKC5XDiRDezV++vestlHLAzK001wkXQ=";
      };

  desktop = fetchurl
    {
      url = "https://github.com/alvr-org/ALVR/raw/${version}/alvr/xtask/resources/alvr.desktop";
      hash = "sha256-DjU/RjJJOALzQNSQwaPgAgPsQgnqX5FDWBcd/PDCetU=";
    };

  icon = fetchurl
    {
      url = "https://github.com/alvr-org/ALVR/blob/${version}/resources/alvr.png?raw=true";
      hash = "sha256-SnUtyS/eDne09SRzd+Kj5Ux/XENJcIHShptkMAyfi98=";
    };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libva
    alsa-lib
    libgcc.lib
    libunwind
    libvdpau
    vulkan-loader
    pipewire
    SDL2
    wayland

    # Unsure if needed
    libxkbcommon
    libGL

    zenity
    xdg-utils
  ];

  sourceRoot = "source";

  installPhase = ''
    runHook preInstall

    install -Dm755 ${desktop} $out/share/applications/alvr.desktop
    install -Dm644 ${icon} $out/share/icons/hicolor/256x256/apps/alvr.png

    # Install SteamVR driver
    ls
    mkdir -p $out/{libexec,lib/alvr,share}
    cp -r ./bin/. $out/bin
    cp -r ./lib64/. $out/lib
    cp -r ./libexec/. $out/libexec
    cp -r ./share/. $out/share
    ln -s $out/lib $out/lib64

    runHook postInstall
  '';
  postInstall = ''
    wrapProgram "$out/bin/alvr_dashboard" \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath buildInputs}" \
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Stream VR games from your PC to your headset via Wi-Fi";
    homepage = "https://github.com/alvr-org/ALVR/";
    changelog = "https://github.com/alvr-org/ALVR/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "alvr_dashboard";
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
  };
}
