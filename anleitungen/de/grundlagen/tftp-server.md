---
thema: tftp-server
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# TFTP-Server einrichten

Viele Router holen sich im Notfall eine Firmware-Datei selbst von deinem
Rechner, und zwar über **TFTP**, ein sehr einfaches Übertragungsverfahren.
Dein Rechner spielt dafür den TFTP-Server: Er stellt einen Ordner bereit, aus
dem der Router eine Datei mit einem festen Namen abholt.

Was die Geräteanleitung dir sagt:

- welche **feste Adresse** dein Rechner haben muss (zum Beispiel
  `192.168.1.88`), siehe [Feste IP-Adresse einstellen](feste-ip.md)
- wie die Datei **genau heißen** muss (zum Beispiel `recovery.bin`). Der
  Router sucht nur diesen einen Namen, Groß- und Kleinschreibung zählt.

## Windows: Tftpd64

1. Tftpd64 herunterladen und installieren (oder die portable Fassung
   entpacken). Cudy und viele Hersteller nennen es auch "tftp32".
2. Die Firmware-Datei in einen eigenen Ordner legen und genau so benennen,
   wie die Geräteanleitung es sagt. Achtung: Windows blendet Dateiendungen
   gern aus. Heißt die Datei im Explorer `recovery.bin`, kann sie in
   Wirklichkeit `recovery.bin.bin` heißen. Im Explorer unter "Ansicht" die
   "Dateinamenerweiterungen" einschalten.
3. Tftpd64 starten. Bei **Current Directory** über "Browse" den Ordner
   wählen. Bei **Server interfaces** die feste Adresse aus der
   Geräteanleitung auswählen.
4. Die **Windows-Firewall** blockiert TFTP. Erlaube Tftpd64 beim ersten
   Start den Zugriff, auch für "öffentliche Netzwerke". Klappt es trotzdem
   nicht, schalte die Firewall für die Dauer der Installation ab und danach
   wieder an.
5. Tftpd64 offen lassen. Im Reiter "Log viewer" siehst du, wenn der Router
   die Datei abholt.

## Linux

Am einfachsten mit `dnsmasq`, nur als TFTP-Server und nur so lange, wie du
es brauchst. Die Datei liegt im Ordner `~/tftp`, der Anschluss heißt hier
`eth0` (Name mit `ip link` nachsehen):

```sh
mkdir -p ~/tftp
cp <Firmware-Datei> ~/tftp/recovery.bin
sudo dnsmasq --no-daemon --port=0 --enable-tftp --tftp-root="$HOME/tftp" --interface=eth0 --bind-interfaces
```

`--port=0` schaltet den DNS-Teil ab. Läuft eine Firewall (ufw, firewalld),
muss sie UDP-Port 69 durchlassen. Mit Strg+C beendest du den Server.

## macOS

macOS hat einen TFTP-Server eingebaut, der aus `/private/tftpboot` liefert:

```sh
sudo cp <Firmware-Datei> /private/tftpboot/recovery.bin
sudo chmod 644 /private/tftpboot/recovery.bin
sudo launchctl load -F /System/Library/LaunchDaemons/tftp.plist
```

Danach wieder abschalten:

```sh
sudo launchctl unload -F /System/Library/LaunchDaemons/tftp.plist
```

## Woran du erkennst, dass es klappt

Der TFTP-Server zeigt, dass eine Datei abgeholt wird (Tftpd64 im Log, dnsmasq
im Terminal mit "sent … to 192.168.…"). Kommt nichts, prüf der Reihe nach:
feste Adresse am Rechner, Kabel an der richtigen Buchse, Firewall, Dateiname.
