⚠️ Hinweis vorab  
Antivirenprogramme können bei Skripten, die Programme automatisch herunterladen und installieren, vorsorglich Alarm schlagen (falsch-positiv). Die Nutzung geschieht auf eigenes Risiko. Der Code ist vollständig offen einsehbar, leicht überprüfbar und macht nichts Gefährliches – er automatisiert nur transparente Einzelschritte (Download, Entpacken, Einrichten). Bitte bei Nachfragen des Systems auf “Zulassen” klicken, wenn das Skript Administratorrechte anfordert und gegebenenfalls die cmd auf die Ausschluss-Liste des Antivirus setzten.

# BetterBahn Ein-Klick-Setup (Windows) 🚆💡

Eine komfortable CMD “App” für Windows 10/11, die die Open-Source-App “betterbahn” lokal vorbereitet und startklar macht – inklusive Node.js/pnpm‑Einrichtung, Download, Entpacken, Abhängigkeiten installieren, Desktop‑Verknüpfung anlegen und automatischem Browser‑Start auf http://localhost:49200.  

- 100% lokal, ohne Konto oder Telemetrie  
- Quelloffen und nachvollziehbar  
- Komfortabel für Einsteiger, praktisch für Fortgeschrittene

## Was macht die CMD? ✨
- Prüft und installiert die technische Grundlage (Node.js) via winget.  
- Installiert pnpm über den offiziellen PowerShell‑Installer (mit Binary‑Fallback).  
- Lädt das betterbahn‑ZIP von GitHub, entpackt es und kopiert die App an einen festen, benutzerfreundlichen Ort.  
- Installiert App‑Abhängigkeiten (pnpm install), aktiviert corepack und pnpm projektweit.  
- Legt eine Startdatei Start_BetterBahn.cmd im App‑Ordner an und erstellt eine Desktop‑Verknüpfung.  
- Öffnet den Standard‑Browser auf http://localhost:49200 und startet den lokalen Dev‑Server.  
- Falls nicht als Administrator gestartet: Zeigt einen 5‑Sekunden‑Countdown an und startet sich danach automatisch mit Admin‑Rechten neu (Bitte “Zulassen”).  

## Schnellstart 🚀
1) Lade die CMD (BetterBahn‑Setup.cmd) herunter und speichere sie lokal.  
2) Rechtsklick → Als Administrator ausführen.  
3) Den großen, gut lesbaren Schritt‑Hinweisen folgen – es läuft alles automatisch.  
4) Nach “FERTIG” ist auf dem Desktop eine Verknüpfung “BetterBahn” vorhanden.  
5) Für künftige Starts: Doppelklick auf “BetterBahn” (oder Start_BetterBahn.cmd im App‑Ordner).  

## Voraussetzungen 🧰
- Windows 10/11 mit Internetzugang  
- Windows App Installer (winget) empfohlen  
- PowerShell ist standardmäßig vorhanden  
- Optional: 7‑Zip oder WinRAR (für Entpack‑Fallback)  

## Wo landet die App? 📁
- App‑Ordner: %LOCALAPPDATA%\Programs\BetterBahn  
- Startdatei: %LOCALAPPDATA%\Programs\BetterBahn\Start_BetterBahn.cmd  
- Desktop‑Verknüpfung: BetterBahn.lnk  

## Was passiert unter der Haube? 🔧
- Admin‑Check: Bei fehlenden Rechten 5‑Sekunden‑Countdown → Neustart mit Admin‑Rechten.  
- winget‑Quellen aktualisieren; Node.js (OpenJS.NodeJS) installieren/prüfen.  
- pnpm installieren: PowerShell‑Einzeiler (offiziell) → Fallback Binary falls nötig.  
- betterbahn‑ZIP laden, per VBScript/Shell.Application entpacken; Fallback: 7‑Zip/WinRAR.  
- Dateien an Zielort kopieren; danach pnpm install, corepack enable, corepack prepare pnpm@latest --activate.  
- Startdatei + Desktop‑Verknüpfung erzeugen; Browser öffnen; Dev‑Server auf Port 49200 starten.  

## Sicherheit, Transparenz & Privatsphäre 🔒
- Quelloffen: Die CMD ist lesbar, ändert keine Systemeinstellungen abseits der genannten Tools.  
- Downloads erfolgen aus offiziellen Quellen (open‑source Repos/Installer).  
- Keine Telemetrie, keine Datensammlung, keine stille Registrierung.  
- Antiviren‑Hinweis: Einige Scanner schlagen bei Automationsskripten präventiv an – hier handelt es sich um harmlose Abläufe. Nutzung auf eigene Verantwortung.  

## Häufige Fragen (FAQ) ❓
- “Mein Virenschutz warnt – ist das gefährlich?”  
  Vorsorgliche Warnungen sind bei Automationsskripten normal. Der Code ist transparent, lädt nur notwendige Komponenten und richtet die App lokal ein. Bei Unsicherheit den Inhalt vor Ausführung einsehen.  
- “Brauche ich Admin‑Rechte?”  
  Ja Empfohlen, damit Installation/Setup reibungslos erfolgen. Das Skript zeigt einen 5‑Sekunden‑Timer und startet sich automatisch erhöht neu.  
- “Der Port 49200 ist belegt.”  
  In Start_BetterBahn.cmd bzw. im Setup‑Skript DEV_PORT einfach auf einen freien Port ändern (z. B. 49210).  
- “pnpm wird nicht gefunden.”  
  Nach Installation Fenster neu öffnen oder PATH‑Anpassung in der Sitzung sicherstellen. Das Skript versucht dies bereits automatisch und nutzt mehrere Suchpfade.  
- “Entpacken schlägt fehl.”  
  Optional 7‑Zip oder WinRAR installieren und erneut ausführen.  

## Tipps zur Anpassung 🧩
- Port ändern: DEV_PORT im Skript/Starter anpassen.  
- Browser‑Start deaktivieren: In Start_BetterBahn.cmd die start "" "http://localhost:PORT"‑Zeile auskommentieren.  
- Eigenen Zielordner verwenden: FINAL_DST im Setup‑Skript ändern (fortgeschritten).  

## Deinstallation 🗑️
- BetterBahn‑Ordner löschen: %LOCALAPPDATA%\Programs\BetterBahn  
- Desktop‑Verknüpfung entfernen  
- Optional: Node.js via winget deinstallieren (winget uninstall OpenJS.NodeJS)  
- Optional: pnpm‑Ordner im %LOCALAPPDATA% bereinigen  

## Beiträge willkommen 🤝
Fehler gefunden, Idee oder Verbesserung? Pull Requests und Issue‑Meldungen sind sehr willkommen – bitte mit kurzer Problembeschreibung. 

## Lizenz 📜
Dieses Projekt steht unter einer offenen Lizenz.

## Danke An ❤️
- betterbahn (Open Source Projekt) (https://github.com/l2xu/betterbahn)
- Node.js, pnpm  
- 7‑Zip, WinRAR (optionale Entpack‑Tools)  

Viel Spaß beim Ausprobieren – und gute Fahrt mit cleveren Verbindungen! 🚄✨
