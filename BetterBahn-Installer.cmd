@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ===== INFO - Diese App richtet BetterBahn automatisch ein =======================
REM - Keine Sorge: Es werden nur benoetigte Programme installiert und Dateien kopiert.
REM - Grossformatige Erklaerungen werden waehrend der Ausfuehrung eingeblendet.
REM - Bitte das Fenster offen lassen, bis "FERTIG" gemeldet wird.
REM ===============================================================================

echo.
echo ============================================================
echo   Willkommen bei der BetterBahn Installation
echo ============================================================
echo.

REM ========= Admin-Check =========
>nul 2>&1 "%SystemRoot%\system32\cacls.exe" "%SystemRoot%\system32\config\system"
if %errorlevel% NEQ 0 (
  echo.
  echo ============================================================
  echo   HINWEIS - ADMIN RECHTE ERFORDERLICH
  echo   Diese App startet in 5 Sekunden neu mit Admin Rechten
  echo   Bitte dann im Dialog auf "Zulassen" klicken
  echo ============================================================
  echo.

  for /l %%S in (5,-1,1) do (
    <nul set /p "=  Neustart in %%S s ..."
    timeout /t 1 /nobreak >nul
    echo.
  )

  echo Starte mit Admin-Rechten neu... Bitte im Dialog "Zulassen" auswaehlen.
  "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -Verb RunAs -FilePath '%~f0'" 2>nul
  exit /b
)

echo.
echo ============================================================
echo   STEP 1 - WINDOWS PAKETVERWALTUNG PRUEFEN
echo   Warum: winget installiert Node.js automatisch
echo   Hinweis: Falls nicht vorhanden, bitte "App Installer" installieren
echo ============================================================
echo.

REM ========= Winget Check =========
where winget >nul 2>&1
if errorlevel 1 (
  echo Fehler: winget ist nicht verfuegbar. Bitte Windows App Installer installieren/aktualisieren.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo   STEP 2 - QUELLEN AKTUALISIEREN
echo   Warum: Sicherstellen, dass die richtigen winget Quellen aktiv sind
echo   Aktion: Quellen updaten und Community-Quelle ggf. hinzufuegen
echo ============================================================
echo.

REM ========= Quellen-Absicherung =========
echo Aktualisiere winget-Quellen...
winget source update || (echo Fehler: source update. & pause & exit /b 1)
winget source list | findstr /I "^winget " >nul || (
  echo Fuege Community-Quelle hinzu...
  winget source add -n winget -a https://cdn.winget.microsoft.com/cache || (echo Fehler: Quelle 'winget'. & pause & exit /b 1)
)
winget show --id OpenJS.NodeJS --source winget -e >nul 2>&1 || (
  echo Fehler: Paket-ID OpenJS.NodeJS nicht in Quelle 'winget' gefunden.
  pause & exit /b 1
)

echo.
echo ============================================================
echo   STEP 3 - STORE QUELLE TEMPORAER ENTFERNEN
echo   Warum: Verhindert Verwechslungen bei der Paketwahl
echo   Aktion: msstore kurz entfernen - spaeter wiederherstellen
echo ============================================================
echo.

REM ========= Store-Quelle temporaer entfernen =========
set "MSSTORE_REMOVED="
for /f "tokens=1" %%S in ('winget source list ^| findstr /I "^msstore " 2^>nul') do (
  echo Entferne Microsoft-Store-Quelle temporaer...
  winget source remove msstore >nul 2>&1
  set "MSSTORE_REMOVED=1"
)

echo.
echo ============================================================
echo   STEP 4 - NODE.JS INSTALLIEREN ODER AKTUALISIEREN
echo   Warum: Technische Grundlage fuer die App
echo   Aktion: Installation via winget
echo ============================================================
echo.

REM ========= Node.js installieren =========
echo Installiere/Aktualisiere Node.js via winget...
winget install OpenJS.NodeJS -e -h 0 --accept-package-agreements --accept-source-agreements 2>nul
set "INSTALL_RC=%errorlevel%"

echo.
echo ============================================================
echo   STEP 5 - STORE QUELLE WIEDERHERSTELLEN
echo   Warum: Urspruengliche winget Quellenlage wieder aktivieren
echo ============================================================
echo.

REM ========= Store-Quelle wiederherstellen =========
if defined MSSTORE_REMOVED (
  echo Fuege Microsoft-Store-Quelle wieder hinzu...
  winget source add -n msstore >nul 2>&1
)

echo.
echo ============================================================
echo   STEP 6 - NODE STATUS PRUEFEN
echo   Warum: Falls Installation nicht 0 meldet, pruefen ob Node vorhanden ist
echo ============================================================
echo.

REM ========= Exitcode tolerant =========
if not "%INSTALL_RC%"=="0" (
  winget list --source winget | findstr /I /R "^OpenJS\.NodeJS " >nul 2>&1
  if %errorlevel% NEQ 0 (
    echo Fehler: Node.js konnte nicht installiert werden und ist nicht vorhanden. Abbruch.
    pause
    exit /b 1
  ) else (
    echo Hinweis: Node.js ist bereits installiert/aktuell. Fahre fort...
  )
)

echo.
echo ============================================================
echo   STEP 7 - PNPM INSTALLIEREN
echo   Warum: Laedt die App-Bausteine und startet Skripte
echo   Aktion: Standardweg per PowerShell, bei Bedarf Fallback Binary
echo ============================================================
echo.

REM ========= pnpm Installation (PowerShell-Pipe, Binary-Fallback) =========
echo Installiere pnpm...
set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "%PS_EXE%" (
  "%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest https://get.pnpm.io/install.ps1 -UseBasicParsing | Invoke-Expression"
  if errorlevel 1 (
    echo Warnung: pnpm-Install ueber PowerShell fehlgeschlagen. Versuche Binary-Fallback...
    set "TMP_EXE=%TEMP%\pnpm-setup.exe"
    if "%TEMP%"=="" set "TEMP=%USERPROFILE%\AppData\Local\Temp"
    curl -L -o "%TMP_EXE%" "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-win-x64.exe"
    if exist "%TMP_EXE%" (
      "%TMP_EXE%" setup
      del "%TMP_EXE%" >nul 2>&1
    ) else (
      echo Fehler: Konnte pnpm Binary nicht laden. Ueberspringe pnpm.
    )
  )
) else (
  echo Hinweis: PowerShell nicht gefunden. Versuche pnpm-Binary-Fallback...
  set "TMP_EXE=%TEMP%\pnpm-setup.exe"
  if "%TEMP%"=="" set "TEMP=%USERPROFILE%\AppData\Local\Temp"
  curl -L -o "%TMP_EXE%" "https://github.com/pnpm/pnpm/releases/latest/download/pnpm-win-x64.exe"
  if exist "%TMP_EXE%" (
    "%TMP_EXE%" setup
    del "%TMP_EXE%" >nul 2>&1
  ) else (
    echo Fehler: Konnte pnpm Binary nicht laden. Ueberspringe pnpm.
  )
)

echo.
echo ============================================================
echo   STEP 8 - APP HERUNTERLADEN
echo   Warum: BetterBahn ZIP aus dem offiziellen GitHub holen
echo   Ziel: %USERPROFILE%\Downloads\betterbahn-main.zip
echo ============================================================
echo.

REM ========= BetterBahn ZIP: Download =========
set "GH_ZIP_URL=https://github.com/l2xu/betterbahn/archive/refs/heads/main.zip"
set "GH_ZIP_ALT=https://codeload.github.com/l2xu/betterbahn/zip/refs/heads/main"
set "DL_DIR=%USERPROFILE%\Downloads"
set "DL_FILE=%DL_DIR%\betterbahn-main.zip"
if not exist "%DL_DIR%" mkdir "%DL_DIR%" >nul 2>&1
echo Lade BetterBahn ZIP nach: "%DL_FILE%"
call :download "%GH_ZIP_URL%" "%DL_FILE%"
if not exist "%DL_FILE%" call :download "%GH_ZIP_ALT%" "%DL_FILE%"
if not exist "%DL_FILE%" (
  echo Fehler: Download der ZIP fehlgeschlagen. Bitte Netzwerk/Proxy/SSL-Inspection pruefen.
  pause
  exit /b 1
)
echo ZIP gespeichert: "%DL_FILE%"

echo.
echo ============================================================
echo   STEP 9 - APP ENTPACKEN
echo   Warum: Archiv entpacken und Dateien vorbereiten
echo   Zielordner: %LOCALAPPDATA%\Programs\BetterBahn
echo ============================================================
echo.

REM ========= BetterBahn ZIP: Entpacken nach %LOCALAPPDATA%\Programs\BetterBahn =========
set "APPROOT=%LOCALAPPDATA%\Programs\BetterBahn"
set "EXTRACTTMP=%APPROOT%_unzip_tmp"
set "FINAL_DST=%APPROOT%"
echo Zielordner vorbereiten: "%FINAL_DST%"
mkdir "%APPROOT%" 2>nul
rmdir /s /q "%EXTRACTTMP%" 2>nul
mkdir "%EXTRACTTMP%" 2>nul

echo Entpacke ZIP per VBScript/Shell.Application nach "%EXTRACTTMP%"...
call :unzip_vbs "%DL_FILE%" "%EXTRACTTMP%"
if errorlevel 1 (
  echo Hinweis: VBScript-Entpacken fehlgeschlagen. Versuche 7-Zip/WinRAR...
  call :unzip_7z_winrar "%DL_FILE%" "%EXTRACTTMP%"
  if errorlevel 1 (
    echo Fehler: Entpacken fehlgeschlagen. Installiere ggf. 7-Zip/WinRAR und starte erneut.
    echo 7-Zip: https://www.7-zip.org/download.html
    echo WinRAR: https://www.rarlab.com/download.htm
    pause
    exit /b 1
  )
)

echo.
echo ============================================================
echo   STEP 10 - STARTORDNER FINDEN
echo   Warum: Den Ordner mit package.json finden - das ist der Startpunkt
echo ============================================================
echo.

REM Projektordner im entpackten Archiv finden
set "FOUND_SRC="
if exist "%EXTRACTTMP%\betterbahn-main\package.json" set "FOUND_SRC=%EXTRACTTMP%\betterbahn-main"
if not defined FOUND_SRC (
  for /d %%D in ("%EXTRACTTMP%*") do (
    if not defined FOUND_SRC if exist "%%~fD\package.json" set "FOUND_SRC=%%~fD"
  )
)
if not defined FOUND_SRC (
  echo Fehler: Konnte Projektordner ^(package.json^) im Archiv nicht finden.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo   STEP 11 - DATEIEN AN DEN ENDGUELTIGEN ORT KOPIEREN
echo   Ziel: %LOCALAPPDATA%\Programs\BetterBahn
echo ============================================================
echo.

echo Kopiere alle Dateien direkt nach "%FINAL_DST%"...
robocopy "%FOUND_SRC%" "%FINAL_DST%" /E
set "RC=%ERRORLEVEL%"
if %RC% GEQ 8 (
  echo Fehler: Robocopy meldete Fehlercode %RC%.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo   STEP 12 - AUFRAEUMEN
echo   Warum: ZIP und Zwischenordner entfernen - Ordnung schaffen
echo ============================================================
echo.

echo Aufraeumen...
del "%DL_FILE%" >nul 2>&1
rmdir /s /q "%EXTRACTTMP%" 2>nul

echo.
echo ============================================================
echo   STEP 13 - IN DEN APP ORDNER WECHSELN
echo   Ziel: %LOCALAPPDATA%\Programs\BetterBahn
echo ============================================================
echo.

echo Wechsle in Projektordner: "%FINAL_DST%"
pushd "%FINAL_DST%"

echo.
echo ============================================================
echo   STEP 14 - PNPM UND COREPACK FINDEN
echo   Warum: Werkzeuge fuer Installation und Start ermitteln
echo ============================================================
echo.

REM ========= pnpm lokalisieren =========
set "PNPM_CMD="
if exist "%LOCALAPPDATA%\pnpm\pnpm.exe" set "PNPM_CMD=%LOCALAPPDATA%\pnpm\pnpm.exe"
if not defined PNPM_CMD (
  where pnpm >nul 2>&1 && for /f "delims=" %%P in ('where pnpm') do if not defined PNPM_CMD set "PNPM_CMD=%%~fP"
)
if not defined PNPM_CMD if exist "%APPDATA%\npm\pnpm.cmd" set "PNPM_CMD=%APPDATA%\npm\pnpm.cmd"

REM ========= corepack lokalisieren und PATH ergaenzen =========
set "COREPACK_CMD="
set "NODE_BIN=%ProgramFiles%\nodejs"
if exist "%NODE_BIN%\node.exe" set "PATH=%NODE_BIN%;%LOCALAPPDATA%\pnpm;%PATH%"
if exist "%NODE_BIN%\corepack.cmd" set "COREPACK_CMD=%NODE_BIN%\corepack.cmd"
if not defined COREPACK_CMD (
  where corepack >nul 2>&1 && for /f "delims=" %%C in ('where corepack') do if not defined COREPACK_CMD set "COREPACK_CMD=%%~fC"
)

echo Gefundene pnpm: "%PNPM_CMD%"
echo Gefundene corepack: "%COREPACK_CMD%"

echo.
echo ============================================================
echo   STEP 15 - BAUSTEINE INSTALLIEREN UND COREPACK AKTIVIEREN
echo   Warum: App-Abhaengigkeiten holen und pnpm sauber aktivieren
echo ============================================================
echo.

REM ========= Befehle in gewuenschter Reihenfolge =========
if defined PNPM_CMD (
  echo Fuehre aus: pnpm install
  call "%PNPM_CMD%" install
) else (
  echo Warnung: pnpm nicht gefunden. Ueberspringe "pnpm install".
)

if defined COREPACK_CMD (
  echo Fuehre aus: corepack enable
  call "%COREPACK_CMD%" enable
  set "CP_RC=%ERRORLEVEL%"
  if not "%CP_RC%"=="0" (
    echo Hinweis: corepack enable schlug fehl. Versuche mit benutzerbezogenem Install-Ordner...
    set "COREPACK_HOME=%APPDATA%\corepack"
    mkdir "%COREPACK_HOME%" 2>nul
    call "%COREPACK_CMD%" enable --install-directory "%COREPACK_HOME%"
    if exist "%COREPACK_HOME%\pnpm.cmd" set "PATH=%COREPACK_HOME%;%PATH%"
  )
  set "COREPACK_ENABLE_DOWNLOAD_PROMPT=0"
  echo Fuehre aus: corepack prepare pnpm@latest --activate
  echo Y| call "%COREPACK_CMD%" prepare pnpm@latest --activate
) else (
  echo Hinweis: corepack nicht gefunden. Ueberspringe corepack-Schritte.
)

echo.
echo ============================================================
echo   STEP 16 - STARTDATEI UND DESKTOP VERKNUEPFUNG ERZEUGEN
echo   Warum: Kuenzukuenftiger 1-Klick Start ueber Desktop
echo   Startdatei: Start_BetterBahn.cmd
echo   Verknuepfung: BetterBahn.lnk auf Desktop
echo ============================================================
echo.

REM ========= Launcher-Datei erstellen + Desktop-Verknuepfung =========
set "DEV_PORT=49200"
set "DEV_URL=http://localhost:%DEV_PORT%/"
set "LAUNCHER=%FINAL_DST%\Start_BetterBahn.cmd"

echo Erstelle Startdatei: "%LAUNCHER%"
> "%LAUNCHER%" echo @echo off
>>"%LAUNCHER%" echo setlocal EnableExtensions EnableDelayedExpansion
>>"%LAUNCHER%" echo set "NODE_BIN=%%ProgramFiles%%\nodejs"
>>"%LAUNCHER%" echo if exist "%%NODE_BIN%%\node.exe" set "PATH=%%NODE_BIN%%;%%LOCALAPPDATA%%\pnpm;%%APPDATA%%\npm;%%PATH%%"
>>"%LAUNCHER%" echo set "DEV_PORT=%DEV_PORT%"
>>"%LAUNCHER%" echo set "DEV_URL=http://localhost:%%DEV_PORT%%/"
>>"%LAUNCHER%" echo echo Oeffne %%DEV_URL%% im Standardbrowser ...
>>"%LAUNCHER%" echo start "" "%%DEV_URL%%"
>>"%LAUNCHER%" echo set "PNPM_EXE="
>>"%LAUNCHER%" echo if exist "%%LOCALAPPDATA%%\pnpm\pnpm.exe" set "PNPM_EXE=%%LOCALAPPDATA%%\pnpm\pnpm.exe"
>>"%LAUNCHER%" echo if not defined PNPM_EXE if exist "%%APPDATA%%\npm\pnpm.cmd" set "PNPM_EXE=%%APPDATA%%\npm\pnpm.cmd"
>>"%LAUNCHER%" echo if not defined PNPM_EXE ^( where pnpm ^>nul 2^>^&1 ^&^& for /f "delims=" %%%%P in ^('where pnpm'^) do if not defined PNPM_EXE set "PNPM_EXE=%%%%~fP" ^)
>>"%LAUNCHER%" echo if defined PNPM_EXE ^(
>>"%LAUNCHER%" echo   call "%%PNPM_EXE%%" run dev -p %%DEV_PORT%%
>>"%LAUNCHER%" echo   if "%%ERRORLEVEL%%"=="0" goto :done
>>"%LAUNCHER%" echo   set "PORT=%%DEV_PORT%%"
>>"%LAUNCHER%" echo   call "%%PNPM_EXE%%" run dev
>>"%LAUNCHER%" echo   if "%%ERRORLEVEL%%"=="0" goto :done
>>"%LAUNCHER%" echo   call "%%PNPM_EXE%%" run dev -- --port %%DEV_PORT%%
>>"%LAUNCHER%" echo ^) else ^(
>>"%LAUNCHER%" echo   if exist "server.js" ^( node server.js ^) else if exist "index.js" ^( node index.js ^) else ^( node . ^)
>>"%LAUNCHER%" echo ^)
>>"%LAUNCHER%" echo :done
>>"%LAUNCHER%" echo exit /b 0

echo Erstelle Desktop-Verknuepfung...
set "PS_EXE_SYS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "%PS_EXE_SYS%" (
  "%PS_EXE_SYS%" -NoProfile -Command "$s=New-Object -ComObject WScript.Shell;$d=[Environment]::GetFolderPath('Desktop');$lnk=Join-Path $d 'BetterBahn.lnk';$c=$s.CreateShortcut($lnk);$c.TargetPath='%LAUNCHER%';$c.WorkingDirectory='%FINAL_DST%';$c.IconLocation='cmd.exe,0';$c.Save()" 2>nul
)

echo.
echo ============================================================
echo   STEP 17 - LOKALE SEITE OEFFNEN UND SERVER STARTEN
echo   Warum: Browser sofort oeffnen - Server direkt dahinter starten
echo   URL: http://localhost:49200/
echo ============================================================
echo.

REM ========= Dev-Server auf stabilem Port starten (URL zuerst oeffnen) =========
echo Starte Dev-Server auf Port %DEV_PORT% ...
echo Oeffne %DEV_URL% im Standardbrowser ...
start "" "%DEV_URL%"

if defined PNPM_CMD (
  REM Next-Style Flag zuerst (kein "--" vor -p)
  call "%PNPM_CMD%" run dev -p %DEV_PORT%
  if "!ERRORLEVEL!"=="0" goto :DEV_DONE

  REM Fallback: PORT-Umgebungsvariable
  set "PORT=%DEV_PORT%"
  call "%PNPM_CMD%" run dev
  if "!ERRORLEVEL!"=="0" goto :DEV_DONE

  REM Fallback: Vite-Style --port
  call "%PNPM_CMD%" run dev -- --port %DEV_PORT%
  if "!ERRORLEVEL!"=="0" goto :DEV_DONE

  echo Fehler: Dev-Server konnte nicht gestartet werden.
) else (
  echo Warnung: pnpm nicht gefunden; Dev-Server kann nicht gestartet werden.
)

:DEV_DONE
echo.
echo ============================================================
echo   FERTIG - DIE APP LAEUFT
echo   Hinweis: Ueber "Start_BetterBahn.cmd" oder Desktop-Verknuepfung
echo   kann die App spaeter mit 1 Klick gestartet werden.
echo ============================================================
echo.

popd
exit /b 0

REM =================== Funktionen ===================

:download
REM Lade eine Datei stabil mit curl (und Fallbacks, falls noetig).
setlocal
set "URL=%~1"
set "OUT=%~2"
where curl >nul 2>&1
if %ERRORLEVEL%==0 (
  curl -L --fail --retry 3 --retry-delay 2 --ssl-no-revoke -o "%OUT%" "%URL%"
  if not errorlevel 1 (endlocal & exit /b 0)
  curl -L --fail --retry 3 --retry-delay 2 --insecure -o "%OUT%" "%URL%"
  if not errorlevel 1 (endlocal & exit /b 0)
)
where bitsadmin >nul 2>&1
if %ERRORLEVEL%==0 (
  bitsadmin /transfer "bbzip" /priority normal "%URL%" "%OUT%"
  if exist "%OUT%" (endlocal & exit /b 0)
)
where wget >nul 2>&1
if %ERRORLEVEL%==0 (
  wget --tries=3 --no-check-certificate -O "%OUT%" "%URL%"
  if exist "%OUT%" (endlocal & exit /b 0)
)
endlocal & exit /b 1

:unzip_vbs
REM Entpacken via VBScript + Shell.Application.CopyHere (Windows-Bordmittel, ohne PowerShell).
setlocal
set "ZIP=%~1"
set "DST=%~2"
if "%TEMP%"=="" set "TEMP=%USERPROFILE%\AppData\Local\Temp"
set "VBS=%TEMP%\bb_unzip.vbs"
> "%VBS%" echo Dim fso, sh, zip, dest, srcItems
>>"%VBS%" echo Set fso = CreateObject("Scripting.FileSystemObject")
>>"%VBS%" echo Set sh  = CreateObject("Shell.Application")
>>"%VBS%" echo If Not fso.FolderExists("%DST%") Then fso.CreateFolder("%DST%")
>>"%VBS%" echo Set zip = sh.NameSpace("%ZIP%")
>>"%VBS%" echo If zip Is Nothing Then WScript.Quit 10
>>"%VBS%" echo Set dest = sh.NameSpace("%DST%")
>>"%VBS%" echo If dest Is Nothing Then WScript.Quit 11
>>"%VBS%" echo Set srcItems = zip.Items
>>"%VBS%" echo If srcItems Is Nothing Then WScript.Quit 12
>>"%VBS%" echo dest.CopyHere srcItems, 16
>>"%VBS%" echo WScript.Sleep 200
>>"%VBS%" echo WScript.Quit 0
cscript //nologo "%VBS%"
set "RC=%ERRORLEVEL%"
del "%VBS%" >nul 2>&1
endlocal & exit /b %RC%

:unzip_7z_winrar
REM Fallback: Entpacken mit 7-Zip oder WinRAR, falls installiert.
setlocal
set "ZIP=%~1"
set "DST=%~2"
set "SEVENZIP="
for %%P in ("7z.exe" "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe") do if not defined SEVENZIP if exist "%%~fP" set "SEVENZIP=%%~fP"
if defined SEVENZIP (
  start "" /wait "%SEVENZIP%" x -y -o"%DST%" "%ZIP%"
  if %ERRORLEVEL%==0 (endlocal & exit /b 0)
)
set "WINRAR="
for %%P in ("WinRAR.exe" "rar.exe" "%ProgramFiles%\WinRAR\WinRAR.exe" "%ProgramFiles(x86)%\WinRAR\WinRAR.exe" "%ProgramFiles%\WinRAR\rar.exe" "%ProgramFiles(x86)%\WinRAR\rar.exe") do if not defined WINRAR if exist "%%~fP" set "WINRAR=%%~fP"
if defined WINRAR (
  start "" /wait "%WINRAR%" x -y "%ZIP%" "%DST%\"
  if %ERRORLEVEL%==0 (endlocal & exit /b 0)
)
endlocal & exit /b 1
