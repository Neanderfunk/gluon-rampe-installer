---
gluon_name: genexis-pulse-ex400
modell: Genexis/Inteno Pulse EX400
anzeige: Genexis/Inteno Pulse EX400
familie: sonderweg-genexis-pulse-ex400
gluon_broken: false
sprache: de
level: L4
level_text: Netzwerkwerkzeuge
risiko: normal
status: ungeprüft
rampe_image: gluon-rampe-20261015-genexis-pulse-ex400-factory.bin
grundlagen: [browser-https, browser-not-found, feste-ip, router-antwortet-nicht, ssh-scp]
daten_stand: b246719e
vorlage_stand: 33a38da8
---

# Genexis/Inteno Pulse EX400: Freifunk-Firmware installieren

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
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Genexis/Inteno%20Pulse%20EX400)

Diese Anleitung ist für einen Pulse EX400 von **Genexis** oder **Inteno**
(Inteno heißt heute Genexis, die Geräte sind gleich). Der Router hat einen
eingebauten Notfall-Modus, über den du ohne Passwort eine neue Firmware
aufspielen kannst. Das geht in zwei Etappen:

1. **OpenWrt starten.** Über den Notfall-Modus spielst du eine OpenWrt-Datei
   auf. Sie startet ein kleines OpenWrt, das nur im Arbeitsspeicher läuft.
2. **Die Freifunk-Firmware aufspielen.** Aus diesem OpenWrt heraus
   installierst du die Freifunk-Firmware deiner Community mit zwei Befehlen
   im Terminal.

Die zweite Etappe läuft über SSH und scp. Wenn das neu für dich ist, lies
vorher [SSH und scp benutzen](grundlagen/ssh-scp.md). Rechne mit einer
Viertelstunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- `ssh` und `scp` ([SSH und scp benutzen](grundlagen/ssh-scp.md))
- diese zwei Dateien, beide im selben Ordner:
  1. das OpenWrt-factory-Image für den EX400:
     [openwrt-24.10.8-ramips-mt7621-genexis_pulse-ex400-factory.bin](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-genexis_pulse-ex400-factory.bin), SHA256
     `7b9debc8d1c8ed36e2632a2b20835f3d33c628e352e8eceaf555a5ffeaa8764e`
  2. die Freifunk-Firmware deiner Community für den Genexis/Inteno Pulse EX400, und zwar
     das **sysupgrade**-Image. Ein factory-Image gibt es für dieses Gerät
     nicht. Benenn die Datei in `gluon.bin` um, dann passen die Befehle
     unten ohne Änderung.

## Vorher prüfen

- Steht auf dem Gerät **DNA** (finnischer Anbieter, "DNA Valokuitu Plus
  EX400", mit einer LED "Update" statt "WPS")? Dann passt diese Anleitung
  nicht: Für diese Variante gibt es eine eigene OpenWrt-Datei, aber keine
  Freifunk-Firmware.

## Schritte

### Teil 1: OpenWrt über den Notfall-Modus starten

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.1.10`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Nur
   `192.168.1.1` darf es nicht sein, die nimmt der Router.

2. **Notfall-Modus starten.** Zieh den Stecker des Netzteils. Halt die
   **Reset**-Taste gedrückt und steck das Netzteil wieder ein. Halt die
   Taste weiter, bis die **Status-LED orange** und die **WPS-LED grün**
   leuchtet. Dann loslassen. **Danach die Reset-Taste nicht noch einmal
   drücken:** Im Notfall-Modus schaltet ein Druck zwischen den beiden
   Systemen auf dem Router um.

3. **Kabel an LAN.** Steck das Kabel vom Rechner in die **LAN**-Buchse des
   Routers (nicht in WAN).

4. **Notfall-Seite öffnen.** Öffne im Browser `http://192.168.1.1`. Es
   erscheint eine schlichte Seite mit einem Feld zum Hochladen einer
   Firmware. Je nach Version des Bootloaders sieht sie etwas anders aus.

5. **OpenWrt hochladen.** Wähl `openwrt-24.10.8-ramips-mt7621-genexis_pulse-ex400-factory.bin` aus und lad sie hoch.
   Warte, bis eine Bestätigungsseite erscheint.

6. **Warten.** Der Router startet jetzt OpenWrt, das dauert meist etwa zwei
   Minuten. Strom nicht ziehen.

### Teil 2: Freifunk-Firmware aufspielen

7. **Prüfen, ob OpenWrt läuft.** Öffne ein Terminal im Ordner mit den
   Dateien und melde dich an:

   ```
   ssh root@192.168.1.1
   ```

   Ein Passwort gibt es nicht. **Prüfen:** Es erscheint ein Begrüßungstext
   mit "OpenWrt". Kommt "Connection refused" oder nichts, noch eine Minute
   warten und es erneut versuchen. Meldet `ssh` "REMOTE HOST IDENTIFICATION
   HAS CHANGED", siehe [SSH und scp benutzen](grundlagen/ssh-scp.md). Mit
   `exit` wieder abmelden.

8. **Freifunk-Firmware kopieren und installieren.** Im Terminal auf deinem
   Rechner, eine Zeile nach der anderen:

   ```
   scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
   ssh root@192.168.1.1 "sysupgrade -n /tmp/gluon.bin"
   ```

   Danach bricht die Verbindung ab, oft mit einer Meldung wie dieser:

   ```
   Command failed: ubus call system sysupgrade { ... } (Connection failed)
   ```

   Die ist harmlos: Der Router hat die Verbindung beendet, weil er jetzt
   die Firmware schreibt.

9. **Fertig.** Einige Minuten warten, Strom nicht ziehen. Stell den Rechner
   wieder auf "automatisch". Danach startet die Freifunk-Firmware deiner
   Community: je nach Community zuerst mit einer Einrichtungsseite unter
   `http://192.168.1.1` oder gleich im Betrieb.
   Antwortet dort nichts, siehe [Die Router-Seite antwortet
   nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
   [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md).

## Woran du erkennst, dass es geklappt hat

- In Schritt 2 leuchten Status-LED orange und WPS-LED grün.
- In Schritt 5 erscheint die Bestätigungsseite.
- In Schritt 7 meldet sich OpenWrt.
- Nach Schritt 9 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Die LEDs werden nicht orange und grün.** Netzteil ziehen und Schritt 2
  wiederholen. Die Reset-Taste muss schon gedrückt sein, bevor der Strom
  kommt.
- **Die Notfall-Seite erscheint nicht.** Prüf die feste Adresse am Rechner
  und ob das Kabel in der LAN-Buchse steckt. Manche Browser machen aus
  `http` von selbst `https`, siehe
  [Browser macht https daraus](grundlagen/browser-https.md).
- **OpenWrt meldet sich auch nach fünf Minuten nicht.** Der Notfall-Modus
  steckt im Bootloader und bleibt immer erhalten. Fang einfach wieder bei
  Schritt 2 an.
- **`scp` meldet einen Fehler.** Prüf, ob das `-O` dabei ist und ob
  `gluon.bin` wirklich im Ordner liegt, in dem das Terminal gerade ist.

## Zurück zur Herstellerfirmware

Das geht nur, wenn du eine Datei der Herstellerfirmware hast. Spiel über den
Notfall-Modus (Schritte 1 bis 7) wieder OpenWrt auf, melde dich an und gib
ein:

```
ubirmvol /dev/ubi0 -n 2
ubirmvol /dev/ubi0 -n 3
ubirmvol /dev/ubi0 -n 4
ubimkvol /dev/ubi0 -N rootfs_0 -S 990
ubimkvol /dev/ubi0 -N rootfs_1 -S 990
```

Danach Netzteil ziehen, den Notfall-Modus wie in Schritt 2 starten und dort
die Herstellerfirmware hochladen. So beschreiben es die Entwickler von
OpenWrt; ausprobiert haben wir es nicht.

## Anderer Weg: mit der Gluon-RAMpe (ungetestet)

Statt erst OpenWrt und dann die Freifunk-Firmware aufzuspielen, geht es auch
mit der **Gluon-RAMpe**: einer kleinen Firmware, die nur eins kann, nämlich
die Freifunk-Firmware deiner Community annehmen. Das spart die
OpenWrt-Etappe. Für den Genexis/Inteno Pulse EX400 ist dieser Weg **noch von niemandem
ausprobiert**; die RAMpe selbst läuft auf anderen Geräten.

1. Lade die RAMpe für den Genexis/Inteno Pulse EX400 herunter:
   [gluon-rampe-20261015-genexis-pulse-ex400-factory.bin](https://download.ffnef.de/other/Gluon-Installer-RAMpe/gluon-rampe-20261015-genexis-pulse-ex400-factory.bin).
2. Lade in Schritt 5 statt der OpenWrt-Datei die RAMpe hoch.
3. Nach dem Neustart öffne `http://192.168.1.1/cgi-bin/config`. Es erscheint
   die Seite "Firmware aktualisieren" der RAMpe. Kommt "Not Found", hat sich
   der Browser eine Seite von früher gemerkt: Tipp die Adresse vollständig
   ein, mit `/cgi-bin/config` am Ende. Hilft das nicht, siehe [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Kommt gar nichts, siehe [Die Router-Seite antwortet nicht](grundlagen/router-antwortet-nicht.md). Startet der Router zwischendurch neu,
   einfach die Seite wieder aufrufen.

   ![Die Seite der RAMpe: "Firmware aktualisieren" mit Feld für die Datei und Knopf "Datei hochladen"](../bilder/allgemein/rampe-seite.png)
4. Wähl das **sysupgrade**-Image deiner Community und klick "Datei
   hochladen". Die RAMpe zeigt die Prüfsumme (SHA256); vergleich sie mit der
   Angabe deiner Community und klick "Fortfahren".
5. Nach wenigen Minuten startet die Freifunk-Firmware.

Zeigt der Browser beim Aufruf eine Warnung vor dem Zertifikat, siehe
[Browser macht https daraus](grundlagen/browser-https.md).

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- Wiki-Zusammenfassung: Darmstadt-Wiki (Schritte (Normalweg), Sichtbare Zeichen, Anschluss, Adressen, Programm, Dauer)
- Wiki-Zusammenfassung: Darmstadt-Wiki; 'nicht Strom ziehen' abgeleitet (Schritte (Normalweg))
- Wiki-Zusammenfassung: Freifunk-Darmstadt-Wiki Genexis-EX400 (Taste und Zeitpunkt)
- Wiki-Zusammenfassung: Freifunk-Darmstadt-Wiki Genexis-EX400; geprüft: Commit (Schritte (Normalweg))
- abgeleitet (Dauer)
- abgeleitet aus mk (Gluon-RAMpe passt)
- geprüft (Weg ab Werk, Schritte (Normalweg), Datei, Notweg)
- geprüft: Commit (Typenschild/Verwechslung, Notweg, Rückweg zur Herstellerfirmware)
- geprüft: Commit dd0c283 (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Commit; Wiki-Zusammenfassung: Darmstadt-Wiki (Sichtbare Zeichen)
- geprüft: github herbetom/multiflash install-ex400.sh @4afd1dba, nutzt Gluon von Freifunk Darmstadt (Programm)
- geprüft; Wiki-Zusammenfassung: Darmstadt-Wiki (Schritte (Normalweg))
- Geräteeintrag: dd0c2839a81bb3c5067be99b02ec5c0adff93ac6
