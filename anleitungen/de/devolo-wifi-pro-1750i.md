---
gluon_name: devolo-wifi-pro-1750i
modell: devolo WiFi pro 1750i
anzeige: devolo WiFi pro 1750i
familie: devolo-ssh
gluon_broken: false
sprache: de
stufe: mit scripts/Netzwerktools
status: ungeprüft
grundlagen: [ssh-scp]
daten_stand: 440a725
vorlage_stand: 99ea201
---

# devolo WiFi pro 1750i: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20devolo%20WiFi%20pro%201750i)

Auf den Access Points von devolo läuft eine Firmware, die selbst auf OpenWrt
aufbaut. Deshalb geht der Wechsel recht einfach: Du setzt bei der
Ersteinrichtung ein Passwort, meldest dich per SSH an und installierst die
Freifunk-Firmware mit einem Befehl. Wenn SSH neu für dich ist, lies vorher
[SSH und scp benutzen](grundlagen/ssh-scp.md). Rechne mit einer halben
Stunde.

## Was du brauchst

- den Access Point und einen PoE-Injektor oder PoE-Switch
- deinen Router zu Hause (er verteilt per DHCP Adressen), einen Rechner und
  zwei Netzwerkkabel
- `ssh` und `scp` ([SSH und scp benutzen](grundlagen/ssh-scp.md))
- die Freifunk-Firmware deiner Community für den devolo WiFi pro 1750i, und zwar das
  **sysupgrade**-Image (ein factory-Image gibt es für dieses Gerät nicht).
  Benenn es in `gluon.bin` um, dann passen die Befehle unten ohne Änderung.

## Schritte

1. **Anschließen.** Verbinde die Netzwerkbuchse mit PoE des Access Points über den
   PoE-Injektor mit deinem Router zu Hause. Dein Rechner hängt am selben
   Router. Warte nach dem Einschalten drei Minuten.

2. **Adresse herausfinden.** Schau in der Geräteliste deines Routers nach,
   welche Adresse der Access Point bekommen hat (meist steht "devolo" im
   Namen), zum Beispiel `192.168.178.57`. Unten steht sie als `<adresse>`.

3. **Ersteinrichtung und root-Passwort.** Öffne `http://<adresse>` im
   Browser. Die Ersteinrichtung fragt nach einem Passwort für den Benutzer
   **root**. Setz eines und merk es dir. Ohne dieses Passwort geht es nicht
   weiter.

4. **Freifunk-Firmware installieren.** Im Terminal auf deinem Rechner, im
   Ordner mit `gluon.bin`, mit der Adresse aus Schritt 2:

   ```
   scp -O gluon.bin root@<adresse>:/tmp/gluon.bin
   ssh root@<adresse> "sysupgrade -n -F /tmp/gluon.bin"
   ```

   Beide Male fragt das Gerät nach dem Passwort aus Schritt 3. Das `-F` ist
   hier nötig: Die devolo-Firmware hält die Freifunk-Firmware sonst für
   unpassend. Danach bricht die Verbindung ab, oft mit einer Meldung wie
   `Command failed: … (Connection failed)`. Das ist harmlos.

5. **Warten.** Der Access Point schreibt die Freifunk-Firmware und startet
   neu, einige Minuten. **Strom nicht ziehen.** Danach leuchtet die blaue
   LED.

6. **Fertig.** Je nach Community startet die Freifunk-Firmware zuerst mit
   einer Einrichtungsseite. Die erreichst du nicht über deinen Router zu
   Hause: Trenn den Access Point vom Router, verbinde den Rechner direkt
   mit dem PoE-Injektor und öffne `http://192.168.1.1`.

## Woran du erkennst, dass es geklappt hat

- In Schritt 3 erscheint die Ersteinrichtung von devolo.
- In Schritt 4 nimmt das Gerät das Passwort an.
- Nach Schritt 5 leuchtet die blaue LED, und die Freifunk-Firmware meldet
  sich.

## Wenn etwas schiefgeht

- **Der Access Point taucht in der Geräteliste nicht auf.** Warte noch etwas,
  prüf PoE-Injektor und Kabel. Wurde das Gerät schon einmal anders
  eingerichtet, setz es auf Werkseinstellungen zurück (Reset-Taste, wie in
  der Anleitung von devolo beschrieben).
- **`ssh` lehnt das Passwort ab.** Das Passwort aus Schritt 3 gilt für den
  Benutzer `root`. Ist das Gerät nicht im Werkszustand, kennt nur der
  Vorbesitzer das Passwort; dann zuerst auf Werkseinstellungen zurücksetzen.
- **`sysupgrade` meldet, das Image passe nicht.** Prüf, ob das `-F` im Befehl
  steht und ob du die Datei für genau dein Modell genommen hast.
- **Die rote LED leuchtet länger.** Das Gerät schreibt noch oder ist im
  Notfall-Modus. Warte zehn Minuten; tut sich dann nichts, schreib uns.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Adressen)
- abgeleitet: Wiki toh/devolo/wifi_pro_1750e, Tabelle der Netzwerk-Grundeinstellung (Adressen)
- geprüft (Weg ab Werk, Schritte (Normalweg), Quelle (OpenWrt-Commit))
- geprüft: Commits 'Make sure you set a password for the root user as prompted on first setup' (Bedingung an die Herstellerfirmware)
- geprüft: Commits, Weg über die laufende Stock-Firmware (Taste und Zeitpunkt)
- geprüft: Commits; Adresse abgeleitet: Wiki toh/devolo/wifi_pro_1750e (Schritte (Normalweg), Anschluss, Programm, Zugang, Datei)
- geprüft: DTS qca9558_devolo_*.dts, led-running/led-upgrade (Schritte (Normalweg), Sichtbare Zeichen)
- Geräteeintrag: 8d68be8057d6c689025cc236d20b96b77a6ccf30 [geprüft]
