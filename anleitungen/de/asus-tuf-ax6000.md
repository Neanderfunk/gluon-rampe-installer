---
gluon_name: asus-tuf-ax6000
modell: ASUS TUF-AX6000
anzeige: ASUS TUF-AX6000
familie: asus-tuf-herbetom
gluon_broken: false
sprache: de
level: L4
level_text: Netzwerkwerkzeuge
risiko: normal
status: ungeprüft
grundlagen: [ssh-scp]
daten_stand: 03ee77d
vorlage_stand: 0a1a0e7
---

# ASUS TUF-AX6000: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
> Freifunk Darmstadt beschreibt denselben Weg für ihre Freifunk-Firmware.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20ASUS%20TUF-AX6000)

Die ASUS-Firmware nimmt keine fremde Firmware über ihre Weboberfläche an.
Der Weg führt über SSH, also die Anmeldung im Terminal, und hat drei
Etappen:

1. **Ein kleines OpenWrt in den Speicher schreiben.** Du meldest dich per
   SSH an der ASUS-Firmware an. Der Router holt sich eine OpenWrt-Datei von
   deinem Rechner und schreibt sie anstelle der ASUS-Firmware in den
   Speicher.
2. **OpenWrt starten.** Nach einem Neustart läuft dieses kleine OpenWrt.
3. **Die Freifunk-Firmware aufspielen.** Aus OpenWrt heraus installierst du
   die Freifunk-Firmware deiner Community.

Du brauchst dafür SSH und scp ([SSH und scp benutzen](grundlagen/ssh-scp.md))
und Python 3 auf deinem Rechner. Rechne mit einer Dreiviertelstunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- `ssh` und `scp` ([SSH und scp benutzen](grundlagen/ssh-scp.md))
- **Python 3**. Unter Linux und macOS ist es meist schon da, unter Windows
  bekommst du es bei <https://www.python.org/downloads/>.
- diese zwei Dateien:
  1. das OpenWrt-"factory-initramfs" für den ASUS TUF-AX6000:
     [openwrt-mediatek-filogic-asus_tuf-ax6000-initramfs-kernel.bin](https://github.com/herbetom/openwrt-asus-filogic-factory/releases/download/filogic-v2/openwrt-mediatek-filogic-asus_tuf-ax6000-initramfs-kernel.bin). Die Datei hat ein Freifunk-Entwickler für genau diesen Zweck gebaut (Dezember 2023); eine offizielle Datei von OpenWrt dafür gibt es nicht.
  2. die Freifunk-Firmware deiner Community für den ASUS TUF-AX6000, und zwar
     das **sysupgrade**-Image. Benenn es in `gluon.bin` um, dann passen die
     Befehle unten ohne Änderung.

## Schritte

### OpenWrt in den Speicher schreiben

1. **Webserver auf dem Rechner starten.** Leg einen Ordner `openwrt-webroot`
   an, kopier die OpenWrt-Datei hinein und benenn sie dort in `openwrt.bin`
   um. Öffne ein Terminal in dem Ordner, **in dem** `openwrt-webroot` liegt,
   und starte:

   ```
   python3 -m http.server -d openwrt-webroot 8080
   ```

   Unter Windows heißt der Befehl `py` statt `python3`. Erlaube der
   Windows-Firewall beim ersten Start den Zugriff. Lass das Terminal offen,
   bis Schritt 6 vorbei ist.

2. **Router einrichten.** Steck das Kabel vom Rechner in eine LAN-Buchse des
   Routers und schalte ihn ein. Der Rechner bleibt auf "automatisch" (DHCP).
   Öffne `http://192.168.50.1` und geh den Einrichtungsassistenten der
   ASUS-Firmware durch. Merk dir den Benutzernamen und das Passwort, das du
   dort vergibst.

3. **SSH einschalten.** In der ASUS-Oberfläche unter **Administration →
   System → Service** SSH einschalten, und zwar **"LAN only"**, mit
   Anmeldung per Passwort, Port **22**. Speichern.

4. **Anmelden.** In einem zweiten Terminal auf deinem Rechner (statt `admin`
   den Benutzernamen aus Schritt 2):

   ```
   ssh admin@192.168.50.1
   ```

5. **Dem Router deinen Rechner bekannt machen.** Gib auf dem Router ein:

   ```
   echo "${SSH_CLIENT%% *} openwrtimage.lan" >> /etc/hosts
   tail -1 /etc/hosts
   ```

   **Prüfen:** Die letzte Zeile lautet etwa `192.168.50.123 openwrtimage.lan`,
   also eine Adresse und dahinter `openwrtimage.lan`. Steht vorn keine
   Adresse, such die Adresse deines Rechners heraus (Windows: `ipconfig`,
   Linux: `ip addr`, macOS: `ipconfig getifaddr en0`) und trag sie von Hand
   ein, zum Beispiel:

   ```
   echo "192.168.50.123 openwrtimage.lan" >> /etc/hosts
   ```

6. **OpenWrt holen.** Auf dem Router:

   ```
   wget -O /tmp/openwrt.bin http://openwrtimage.lan:8080/openwrt.bin
   ```

   **Prüfen:** `wget` meldet keinen Fehler, und im Terminal mit dem
   Webserver erscheint eine Zeile mit `GET /openwrt.bin` und `200`. Sonst
   hier aufhören und Schritt 1 und 5 prüfen.

7. **Schreiben.** Jetzt wird die ASUS-Firmware überschrieben.

   > **Ab dem ersten Befehl, bis `mtd-write` fertig ist, auf keinen Fall den
   > Strom ziehen.** In dieser Zeit ist die ASUS-Firmware schon gelöscht und
   > OpenWrt noch nicht vollständig geschrieben. Dann hilft nur noch die
   > serielle Konsole.

   Gib die beiden Befehle nacheinander ein, genau so:

   ```
   mtd-erase -d linux
   mtd-write -i /tmp/openwrt.bin -d linux
   ```

   Beide Befehle zeigen keinen Fortschritt. Warte, bis die Eingabe wieder
   erscheint.

### OpenWrt starten

8. **Neu starten.** Zieh den Stecker des Netzteils, warte ein paar Sekunden
   und steck ihn wieder ein. Nach etwa einer Minute läuft OpenWrt unter
   `192.168.1.1`. Damit dein Rechner eine passende Adresse bekommt, zieh das
   Netzwerkkabel am Rechner kurz ab und steck es wieder ein.

### Freifunk-Firmware aufspielen

9. **Freifunk-Firmware kopieren und installieren.** Im Terminal auf deinem
   Rechner, im Ordner mit `gluon.bin`:

   ```
   scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
   ssh root@192.168.1.1 "sysupgrade -n /tmp/gluon.bin"
   ```

   Ein Passwort gibt es nicht. Nach dem zweiten Befehl bricht die Verbindung
   ab, oft mit einer Meldung wie `Command failed: … (Connection failed)`.
   Das ist harmlos.

10. **Fertig.** Einige Minuten warten, Strom nicht ziehen. Danach startet
    die Freifunk-Firmware deiner Community: je nach Community zuerst mit
    einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im
    Betrieb. Den Webserver aus Schritt 1 kannst du mit Strg+C beenden.

## Woran du erkennst, dass es geklappt hat

- In Schritt 5 steht eine Adresse vor `openwrtimage.lan`.
- In Schritt 6 zeigt der Webserver `GET /openwrt.bin` mit `200`.
- Nach Schritt 8 antwortet OpenWrt unter `192.168.1.1`.
- Nach Schritt 10 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **`ssh` kommt in Schritt 4 nicht durch.** Prüf in der ASUS-Oberfläche, ob
  SSH an ist, "LAN only" und Port 22. Den Benutzernamen hast du im
  Assistenten selbst vergeben.
- **`wget` meldet einen Fehler.** Läuft der Webserver noch? Lässt die
  Firewall deines Rechners Port 8080 durch? Stimmt die Adresse in
  `/etc/hosts` (Schritt 5)? Liegt `openwrt.bin` wirklich im Ordner
  `openwrt-webroot`?
- **Nach Schritt 8 antwortet nichts unter `192.168.1.1`.** Warte noch etwas
  und steck das Netzwerkkabel am Rechner neu ein. Kommt auch nach fünf
  Minuten nichts, schreib uns. Weiter geht es dann nur über die serielle
  Konsole im Router.
- **Meldet `ssh` "REMOTE HOST IDENTIFICATION HAS CHANGED"**, siehe
  [SSH und scp benutzen](grundlagen/ssh-scp.md).

## Zurück zur ASUS-Firmware

Laut OpenWrt-Wiki hilft dafür das ASUS-Werkzeug "Firmware Restoration" mit
dem Rettungsmodus des Routers. Ausprobiert haben wir es nicht.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Sichtbare Zeichen, Datei, Gluon-RAMpe passt)
- abgeleitet: Commit 237b1c2 zum TUF-AX4200Q (Anschluss, Adressen)
- abgeleitet: Herstellerfirmware ab Werk, SSH nur LAN (Anschluss)
- abgeleitet: OpenWrt-Standard (Zugang)
- abgeleitet: Release-Text herbetom filogic-v2 nennt keine (Taste und Zeitpunkt)
- abgeleitet: Release-Text herbetom filogic-v2, Commits (Warnung)
- abgeleitet: Wiki toh/asus/tuf-ax6000 (Typenschild/Verwechslung, Notweg, Rückweg zur Herstellerfirmware)
- abgeleitet: dasselbe Wiki, Debricking (Rückweg zur Herstellerfirmware)
- abgeleitet: dropbear setzt SSH_CLIENT (Schritte (Normalweg))
- geprüft (Weg ab Werk, Datei, Gehäuse öffnen)
- geprüft: Commit d522cce (Notweg)
- geprüft: Commit d522cce; Ersetzen abgeleitet (Notweg)
- geprüft: Commits e7c399b, d522cce (Warnung)
- geprüft: DTS am Pin, led-boot/running = led_system (Sichtbare Zeichen)
- geprüft: Freifunk-Darmstadt-Wiki TUF-AX4200, Rohtext (Schritte (Normalweg), Adressen, Zugang, Datei)
- geprüft: Release-Text (Weg ab Werk)
- geprüft: Release-Text herbetom filogic-v2 (Schritte (Normalweg), Sichtbare Zeichen, Adressen, Programm, Zugang, Datei)
- Geräteeintrag: OpenWrt d522ccecb28f941aadcaf7a50cd6daa861f468a7
