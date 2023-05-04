{ stdenv
, lib
, fetchurl
, mkWindowsApp
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, wine
, instanceName ? "default" # This should be alphanumeric, no spaces
}:
mkWindowsApp rec {
  inherit wine;

  pname = "rtrader-pro-${instanceName}";
  version = "17.27.0.0"; #:version:
  wineArch = "win64";

  src = fetchurl {
    url = "https://rithmic.com/rtraderpro.msi";
    sha256 = "1r21ah9fqrxnbdi0nrx7scfi4p8m4v7yi5yv6jwk02vsr38ixsaf"; #:hash:
  };

  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems copyDesktopIcons ];

  fileMap = { "$HOME/.local/share/${pname}/AppData/Rithmic" = "drive_c/users/$USER/AppData/Roaming/Rithmic"; };

  winAppInstall = ''
    $WINE msiexec /i ${src} /qn
  '';

  winAppRun = '' 
    $WINE "$WINEPREFIX/drive_c/Program Files (x86)/Rithmic/Rithmic Trader Pro/Rithmic Trader Pro.exe";
  '';

  enabledWineSymlinks = {
    desktop = false;
  };

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "R Trader Pro (${instanceName})";
      genericName = "Trading and charting software";
      categories = ["Office" "Finance"];
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = pname;
    src = ./rtrader-pro.png;
  };

  meta = with lib; {
    description = "Rithmic professional trading software";
    homepage = "https://yyy3.rithmic.com/?page_id=16";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ emmanuelrosa ];
    mainProgram = pname;
  };
}
