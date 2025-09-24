BetterBahn Windows Auto-Setup 🚂🪟
Einfacher geht’s kaum: Diese kleine Windows-App (eine einzige CMD-Datei) richtet die lokale BetterBahn-Devversion automatisch ein – inklusive Installation der Grundlagen, Download der App, Entpacken, Abhaengigkeiten laden, Startdatei erzeugen und Start des lokalen Servers samt Browser-Tab zu localhost. Kein Vorwissen noetig. 🎉

Plattform: Windows 10/11

Modus: Lokal, offline nutzbar nach Setup

Fokus: Komfort-Setup fuer das Open-Source-Projekt „BetterBahn“

💡 Was macht die CMD genau?
Die CMD fuehrt alle noetigen Schritte in sicherer Reihenfolge aus und erklaert jeden Schritt gut sichtbar im Konsolenfenster:

Admin-Rechte pruefen und bei Bedarf mit 5‑Sekunden‑Countdown als Admin neu starten (Anzeige: „Neustart in 5 s …“)

Windows Paketquellen (winget) aktualisieren und absichern

Node.js installieren oder aktualisieren (OpenJS.NodeJS)

pnpm bereitstellen (PowerShell-Installer mit Binary-Fallback)

BetterBahn als ZIP aus dem offiziellen Repo herunterladen

Entpacken in einen stabilen Benutzerordner (%LOCALAPPDATA%\Programs\BetterBahn)

App-Dateien an Zielort kopieren und aufraeumen

pnpm und corepack lokalisieren, Abhaengigkeiten installieren

corepack enable sowie corepack prepare pnpm@latest --activate

Eine Startdatei Start_BetterBahn.cmd im App-Ordner erzeugen

Eine Desktop-Verknuepfung BetterBahn.lnk zu dieser Startdatei anlegen

Direkt im Hauptskript: Browser-Tab zu http://localhost:49200 oeffnen und Dev-Server starten

Hinweis: Der Port ist standardmaessig 49200 und kann spaeter angepasst werden (siehe Abschnitt „Anpassen“).

✨ Vorteile
Zero-Fussel: Kein manuelles Klicken durch Installer – einfach starten

Selbsterklaerend: Grosse Schritt-Headlines erklaeren was gerade passiert

Robust: Fallbacks beim Entpacken, bei pnpm-Setup und beim Serverstart

Komfort: Startdatei + Desktop-Verknuepfung fuer 1‑Klick‑Start in Zukunft

Offen: Reiner Klartext, keine Obfuskation, lokale Ausfuehrung

🚀 Schnellstart
CMD-Datei herunterladen und per Rechtsklick „Als Administrator ausfuehren“ starten

Den Anzeigen im Fenster folgen – alles laeuft automatisch

Nach Abschluss oeffnet sich der Browser automatisch zu localhost:49200

Fuer kuenftige Starts: Einfach auf die Desktop-Verknuepfung „BetterBahn“ klicken

Tipp: Falls das Fenster einmal zu schnell schliesst, die CMD ueber „Eingabeaufforderung als Administrator“ starten, damit alle Meldungen sichtbar bleiben.

🧩 Voraussetzungen (werden soweit moeglich automatisch erfuellt)
Windows 10 oder 11

Internetzugang (Download von Node.js, pnpm, GitHub-Archiv)

winget (App Installer) – wird geprueft und Quellen werden aktualisiert

PowerShell ist normalerweise vorhanden (fuer pnpm-Standardinstallation)

curl ist ab Windows 10 standardmaessig nutzbar (Download der ZIP-Datei)

Keine Sorge: Die CMD prueft alles und bietet Fallbacks, falls ein Standardweg nicht funktioniert.

🛠️ Anpassen
Port aendern: In der CMD „DEV_PORT=49200“ auf den Wunschport setzen

Browser-Start deaktivieren: Die „start "" "http://localhost:PORT"“-Zeile kann bei Bedarf entfernt werden

Speicherort der App: Standard ist %LOCALAPPDATA%\Programs\BetterBahn

🧪 Troubleshooting
„Bitte als Admin neu starten“ – Die CMD zeigt einen 5‑Sekunden‑Timer und startet automatisiert mit Admin-Rechten neu. Danach im Dialog „Zulassen“ klicken.

„pnpm nicht gefunden“ – Die CMD installiert pnpm via PowerShell-Installer; falls das scheitert, wird ein Binary-Fallback genutzt. Danach die CMD ggf. neu oeffnen.

Entpacken scheitert – Die CMD nutzt Windows-Bordmittel (Shell.Application) und, wenn noetig, 7‑Zip/WinRAR als Fallback. Bei sehr langen Pfaden hilft ein kuerzerer Zielpfad oder genug freier Speicherplatz.

Dev-Server startet nicht – Es gibt drei Startversuche:

pnpm run dev -p PORT

pnpm run dev mit PORT als Umgebungsvariable

pnpm run dev -- --port PORT
Pruefe Logs im Terminal, installiere fehlende Abhaengigkeiten oder pruefe, ob der Port bereits belegt ist.

🧰 Was installiert/ruft die CMD ab?
Node.js (OpenJS.NodeJS) per winget

pnpm via PowerShell-Installer (get.pnpm.io) oder Binary-Fallback

BetterBahn-Quellarchiv (ZIP) vom offiziellen Repo

Danach werden App-Abhaengigkeiten per pnpm installiert und corepack fuer pnpm aktiviert

Die Ziele sind ueblich und nachvollziehbar; keine ungewoehnlichen Endpunkte. Alles ist im Klartext in der CMD einsehbar.

🔒 Sicherheit, Antivirus und Vertrauen
Hinweis: Manche Antivirus-Programme oder SmartScreen koennen bei Skripten, die Software automatisch herunterladen und installieren, vorsorglich anschlagen. Das ist technisch verstaendlich – insbesondere bei CMD/PowerShell/Download-Kombinationen.

Nutzung auf eigene Gefahr: Die CMD ist fuer den persoenlichen Gebrauch gedacht. Bitte pruefe den Inhalt bei Bedarf – der Code ist oeffentlich, unveraendert einsehbar und kann von jedem ueberprueft werden.

Keine Datenabgriffe: Es werden keine privaten Daten erfasst oder versendet – die CMD arbeitet lokal und nutzt nachvollziehbare Downloads (Node.js, pnpm, GitHub-Archiv).

Tipp: Wenn ein AV anschlaegt, kann temporaeres Zulassen noetig sein. Alternativ die CMD in einer Testumgebung ausfuehren.

⚖️ Rechtliches und fair use
BetterBahn ist ein Open-Source-Projekt; dieses Setup-Skript richtet lediglich die lokale Entwicklungsinstanz ein und nimmt selbst keine Buchungen vor.

Bitte stets die Nutzungsbedingungen der jeweiligen Anbieter beachten.

Ticket-Splitting kann in manchen Konstellationen besondere Bedingungen haben (z.B. Umstiegspflichten, Verspaetungsregeln). Bitte eigenverantwortlich pruefen.

Keine Gewaehr: Es gibt keine Garantie auf Funktion, Vollstaendigkeit oder Korrektheit. Nutzung auf eigenes Risiko.

🧭 Warum lokal?
Lokal bedeutet: maximale Transparenz, volle Kontrolle, keine versteckten Server.

Ideal, um Funktionen auszuprobieren, ohne etwas am System dauerhaft zu veraendern.

Einfache Deinstallation: Den Zielordner loeschen und die Desktop-Verknuepfung entfernen.

🤝 Mitmachen
Vorschlaege? Verbesserungen? Pull Requests willkommen.

Bug gefunden? Bitte mit moeglichst genauer Fehlerbeschreibung, Windows-Version und Konsole-Ausgabe melden.

📄 Lizenz
Freie Nutzung fuer private, nicht-kommerzielle Zwecke.

Fuer weitergehende Nutzung und Einbettung bitte vorher Pruefung der jeweiligen Projekt-Lizenz von BetterBahn und Abhaengigkeiten.

🙏 Dank
BetterBahn Community

Node.js, pnpm, winget

Alle, die Open-Source moeglich machen

Viel Freude mit dem bequemen Setup – und allzeit gute Fahrt! 🚆💙
