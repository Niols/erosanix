{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, makeDesktopItem
, makeDesktopIcon
, copyDesktopItems
, copyDesktopIcons
, unzip
, imagemagick }:
mkWindowsApp rec {
  inherit wine;

  pname = "sierrachart";
  version = "2347";

  src = fetchurl {
    url = "https://www.sierrachart.com/downloads/ZipFiles/SierraChart${version}.zip";
    sha256 = "1nzhnhl55p9qhrz8baig28k90rhnb2dgn27nchm2cf9388lk7cb2";
  };

  dontUnpack = true;
  wineArch = "win64";
  enableInstallNotification = false;
  nativeBuildInputs = [ unzip copyDesktopItems copyDesktopIcons ];

  winAppInstall = ''
    d="$WINEPREFIX/drive_c/SierraChart"
    mkdir -p "$d"
    unzip ${src} -d "$d"
    rm -fR "$d/NPP"
  '';

  winAppRun = ''
   data_dir="$HOME/.local/share/sierrachart"
   sc_dir="$WINEPREFIX/drive_c/SierraChart" 
   files_to_persist=( "Data" "Sierra4.config" "Accounts4.config" "KeyboardShortcuts4.config" "TradeActivityLogs" "TradePositions.data" "AccountBalance.data" "TradeOrdersList.data" "SymbolSettings" "DefaultStudySettings" "AlertSounds")

   if [ ! -d "$data_dir" ]
   then
     mkdir -p "$data_dir"
     mkdir -p "$data_dir/Graphics"
   fi

   echo "Persisting data files..."
   for file in "''${files_to_persist[@]}"
   do
     mv -nv "$sc_dir/$file" "$data_dir/" 

     if [ -e "$data_dir/$file" ]
     then
       rm -fRv "$sc_dir/$file"
       ln -sv "$data_dir/$file" "$sc_dir/"
     fi
   done

   mv -nv "$sc_dir/Graphics/Buttons" "$data_dir/Graphics/"
   ln -sv "$data_dir/Graphics/Buttons" "$sc_dir/Graphics/"

   # Run Sierra Chart
   wine "$WINEPREFIX/drive_c/SierraChart/SierraChart.exe" "$ARGS"
    wineserver -w

   echo "Persisting any new data files..."
   for file in "''${files_to_persist[@]}"
   do
     if [ -h "$sc_dir/$file" ]
     then
       rm -fR "$sc_dir/$file"
     fi

     mv -nv "$sc_dir/$file" "$data_dir/"
   done
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/sierrachart

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Sierra Chart";
      genericName = "Trading and charting software";
      categories = "Network;Finance;";
    })
  ];

  desktopIcon = makeDesktopIcon {
    name = "sierrachart";

    src = fetchurl {
      url = "https://www.sierrachart.com/favicon/favicon-192x192.png";
      sha256 = "06wdklj01i0h6c6b09288k3qzvpq1zvjk7fsjc26an20yp2lf21f";
    };
  };

  meta = with lib; {
    description = "A professional desktop Trading and Charting platform for the financial markets, supporting connectivity to various exchanges and backend trading platform services.";
    homepage = "https://www.sierrachart.com";
    license = licenses.unfree;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}

