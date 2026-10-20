---
gluon_name: linksys-ea8300-dallas
modell: Linksys EA8300
anzeige: Linksys EA8300
familie: sonderweg-linksys-ea8300
gluon_broken: false
sprache: de
level: L4
level_text: Network-Tools
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, router-antwortet-nicht, ssh-scp]
daten_stand: a459f9d4
vorlage_stand: 33a38da8
---

# Linksys EA8300: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
> Teil 1 und 2 beschreibt das OpenWrt-Wiki genau so. Dass sich die Freifunk-Firmware in Teil 3 wie OpenWrt mit „Force upgrade“ einspielen lässt, haben wir daraus abgeleitet.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Linksys%20EA8300)

> **Wichtig:** Lade **nicht** die Freifunk-Firmware direkt über die
> Linksys-Oberfläche hoch. Laut OpenWrt macht jede Firmware ab OpenWrt 23.05
> den EA8300 auf diesem Weg unbrauchbar, und die Freifunk-Firmware baut auf
> OpenWrt 24.10 auf.

Der EA8300 braucht drei Etappen:

1. Über die Linksys-Oberfläche kommt zuerst ein älteres OpenWrt (22.03.6).
2. Darin wird im Bootloader der Platz für den Kernel von 3 auf 5 MB
   vergrößert. Das ist nur einmal im Leben des Geräts nötig.
3. Danach lässt sich die Freifunk-Firmware ganz normal über die
   Weboberfläche von OpenWrt aufspielen.

Für Etappe 2 brauchst du SSH ([SSH und scp benutzen](grundlagen/ssh-scp.md)).
Rechne mit einer knappen Stunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- OpenWrt 22.03.6 für den EA8300:
  [openwrt-22.03.6-ipq40xx-generic-linksys_ea8300-squashfs-factory.bin](https://downloads.openwrt.org/releases/22.03.6/targets/ipq40xx/generic/openwrt-22.03.6-ipq40xx-generic-linksys_ea8300-squashfs-factory.bin),
  SHA256 `95593b6293cba4a1e1a5947f0d4975da4a2c5837e3666559e05852c920412fa5`.
  Genau diese Version (oder 22.03.5), keine neuere.
- die Freifunk-Firmware deiner Community für den Linksys EA8300, und zwar das
  **factory**-Image
- `ssh` ([SSH und scp benutzen](grundlagen/ssh-scp.md))

## Schritte

### Teil 1: OpenWrt 22.03.6 über die Linksys-Oberfläche

1. **Werkseinstellungen.** War der Router schon eingerichtet (etwa mit einem
   Linksys-Konto), setz ihn zurück: Reset-Taste hinten etwa 10 Sekunden
   drücken.

2. **Verbinden.** Kabel vom Rechner an eine **LAN**-Buchse, **nicht** an
   "Internet". Den Router einschalten und warten, bis die weiße
   LINKSYS-Leuchte dauerhaft leuchtet.

3. **Oberfläche öffnen.** Im Browser `http://192.168.1.1`. **Nicht** auf
   "Next" klicken, sondern auf **"Manual configuration"**. Auf der Seite
   "Internet connection is down" auf **"Login"**, Passwort `admin`.

4. **OpenWrt hochladen.** Unter **"Connectivity"**, Bereich "Manual", die
   Datei `openwrt-22.03.6-…-squashfs-factory.bin` wählen und **"Start"**.
   Die Warnung bestätigen.

5. **Warten.** Der Router schreibt OpenWrt und startet neu. Der Browser meldet
   danach, dass der Router nicht gefunden wird. Das ist hier normal: Jetzt
   läuft OpenWrt.

### Teil 2: Platz für den Kernel vergrößern

6. **Anmelden.**

   ```
   ssh root@192.168.1.1
   ```

   Ein Passwort gibt es nicht. Meldet ssh "REMOTE HOST IDENTIFICATION HAS
   CHANGED", siehe [SSH und scp benutzen](grundlagen/ssh-scp.md).

7. **Nachsehen.**

   ```
   fw_printenv
   ```

   In der Ausgabe steht `kernsize=300000`.

8. **Ändern.** Genau so, **ohne Gleichheitszeichen**:

   ```
   fw_setenv kernsize 500000
   ```

   Ein `=` an dieser Stelle macht den Bootloader unbrauchbar; dann hilft nur
   noch die serielle Konsole.

9. **Prüfen.**

   ```
   fw_printenv
   ```

   **Prüfen:** Jetzt muss dort `kernsize=500000` stehen. Sonst hier aufhören.
   Dann neu starten:

   ```
   reboot
   ```

   OpenWrt startet wie vorher.

### Teil 3: Freifunk-Firmware

10. **Weboberfläche öffnen.** `http://192.168.1.1`, anmelden mit leerem
    Passwort-Feld.

11. **Hochladen.** **System → Backup / Flash Firmware**, ganz unten
    "Flash image…", das factory-Image der Freifunk-Firmware wählen. Im
    folgenden Fenster den Haken bei **"Keep settings" entfernen** und den
    Haken bei **"Force upgrade"** setzen. Dann **Continue**.

12. **Fertig.** Einige Minuten warten, Strom nicht ziehen. Danach startet die
    Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
    Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- Nach Teil 1 meldet sich OpenWrt (ssh ohne Passwort).
- In Schritt 9 steht `kernsize=500000`.
- Nach Teil 3 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Der Router startet nicht mehr richtig.** Der EA8300 hat zwei
  Firmware-Speicher. Einschalten, 10 Sekunden warten, ausschalten,
  5 Sekunden warten; das dreimal. Dann startet er die Firmware im anderen
  Speicher.
- **Du kommst nicht an die Linksys-Seite "Connectivity".** Werkseinstellungen
  wie in Schritt 1 und noch einmal.

## Gut zu wissen

Der EA8300 wechselt bei jedem Flash zwischen seinen zwei Firmware-Speichern.
Nach Teil 1 liegt die Linksys-Firmware noch im anderen Speicher; Teil 3
überschreibt sie. Wer zur Linksys-Firmware zurück will: Laut OpenWrt kann
OpenWrt ab 22.03.3 ein Linksys-Image direkt einspielen (sysupgrade mit
"Force").

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- Folge abgeleitet; geprüft: Wiki toh:linksys:ea8300 (Schritte (Normalweg), Warnung)
- Folge abgeleitet; geprüft: Wiki toh:linksys:ea8300, korrigiert (Schritte (Normalweg), Datei)
- abgeleitet (Schritte (Normalweg))
- geprüft: Commit a9071d02 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Wiki toh:linksys:ea8300 (Weg ab Werk, Schritte (Normalweg), Adressen, Programm, Zugang, Rückweg zur Herstellerfirmware)
- geprüft: Wiki toh:linksys:ea8300; Gluon-Teil abgeleitet (Weg ab Werk)
- Geräteeintrag: OpenWrt 819e7946b0964725dab50c92797f49cf4053d955
