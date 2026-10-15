---
gluon_name: netgear-wndr3700-v5
modell: NETGEAR WNDR3700 v5 (Gluon: broken, "untested")
familie: netgear-nmrp
sprache: de
stufe: mit Werkzeug
status: ungeprüft
rampe_image: gluon-rampe-20261015-netgear-wndr3700-v5-factory.img
grundlagen: [browser-https, nmrpflash]
daten_stand: lokal
vorlage_stand: ce95dd8
---

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20NETGEAR%20WNDR3700%20v5%20%28Gluon%3A%20broken%2C%20%22untested%22%29)

# NETGEAR WNDR3700 v5 (Gluon: broken, "untested"): Freifunk-Firmware installieren

Viele Netgear-Geräte fragen direkt nach dem Einschalten im Netzwerk, ob
jemand eine Firmware für sie hat. Das Programm **nmrpflash** auf deinem
Rechner antwortet darauf und schickt die Freifunk-Firmware. Das geht auch
dann, wenn die Netgear-Oberfläche fremde Firmware nicht annimmt.

## Was du brauchst

- das Gerät mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- das Programm nmrpflash ([nmrpflash benutzen](grundlagen/nmrpflash.md))
- OpenWrt für den NETGEAR WNDR3700 v5 (Gluon: broken, "untested"):
  [openwrt-24.10.8-ramips-mt7621-netgear_wndr3700-v5-squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ramips/mt7621/openwrt-24.10.8-ramips-mt7621-netgear_wndr3700-v5-squashfs-factory.img). Die Freifunk-Firmware
  gibt es für dieses Gerät nicht in der Form, die nmrpflash schickt; deshalb
  kommt erst OpenWrt drauf und darüber die Freifunk-Firmware.
- die Freifunk-Firmware deiner Community für den NETGEAR WNDR3700 v5 (Gluon: broken, "untested"), und zwar das
  **sysupgrade**-Image

## Vorher prüfen

Nur der WNDR3700 **v5**. WNDR3700 v1 bis v4 sind ganz andere Geräte mit
eigenen Images. Prüf den Aufkleber auf "v5".

Die Freifunk-Firmware für den WNDR3700 v5 gilt bei Gluon als ungetestet.

## Schritte

1. **nmrpflash bereitlegen.** Lade nmrpflash herunter und richte es ein, wie
   unter [nmrpflash benutzen](grundlagen/nmrpflash.md) beschrieben. Leg die OpenWrt-Datei
   in denselben Ordner und benenne es in `firmware.img` um.

2. **Verbinden.** Das Gerät ist **aus**. Steck das Kabel vom Rechner an die LAN-Buchse (bei
   Netgear oft blau; bei mehreren die mit "1"). Schalte die
   Firewall am Rechner für die Dauer aus.

3. **Anschluss finden.** Im Terminal (als Administrator bzw. mit `sudo`):

   ```
   nmrpflash -L
   ```

   Merk dir den Namen des Anschlusses, an dem das Kabel steckt, zum Beispiel
   `eth0` oder `net1`.

4. **nmrpflash starten.** Mit diesem Namen statt `eth0`:

   ```
   nmrpflash -i eth0 -f firmware.img
   ```

5. **Gerät einschalten,** sobald `Waiting for Ethernet connection` erscheint.

6. **Warten.** nmrpflash meldet `Uploading … OK` und dann `Waiting for remote
   to respond.` Jetzt schreibt das Gerät, das dauert meist wenige Minuten,
   manchmal 15 Minuten und mehr. **Strom nicht ziehen,** bis
   `Reboot your device now.` erscheint.

7. **Neu starten.** Schalte das Gerät aus und wieder ein.

8. **Freifunk-Firmware über OpenWrt.** Stell den Rechner auf
   "automatisch", öffne `http://192.168.1.1` und melde dich an
   (Passwort-Feld leer). Unter **System → Backup / Flash Firmware**,
   "Flash image…", das Freifunk-sysupgrade-Image wählen, **den Haken bei
   "Keep settings" entfernen** und **Continue**. Einige Minuten warten.

9. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- nmrpflash endet mit `Reboot your device now.`
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **"No response after 60 seconds."** Reihenfolge einhalten: erst nmrpflash
  starten, dann das Gerät einschalten. Manche Netgear-Geräte brauchen beim
  Einschalten zusätzlich die gedrückte Reset-Taste. Eine andere LAN-Buchse
  probieren.
- **"Timeout while waiting for ACK(0)/OACK."** Meist die Firewall am Rechner.
- Weitere Meldungen erklärt [nmrpflash benutzen](grundlagen/nmrpflash.md).

## Anderer Weg: mit der Gluon-RAMpe (ungetestet)

Statt erst OpenWrt und dann die Freifunk-Firmware aufzuspielen, geht es auch
mit der **Gluon-RAMpe**: einer kleinen Firmware, die nur eins kann, nämlich
die Freifunk-Firmware deiner Community annehmen. Das spart die
OpenWrt-Etappe. Für den NETGEAR WNDR3700 v5 (Gluon: broken, "untested") ist dieser Weg **noch von niemandem
ausprobiert**; die RAMpe selbst läuft auf anderen Geräten.

1. Lade die RAMpe für den NETGEAR WNDR3700 v5 (Gluon: broken, "untested") herunter:
   [gluon-rampe-20261015-netgear-wndr3700-v5-factory.img](https://download.ffnef.de/other/Gluon-Installer-RAMpe/gluon-rampe-20261015-netgear-wndr3700-v5-factory.img).
2. Benenne die RAMpe in firmware.img um und schick sie in Schritt 4 mit nmrpflash statt der OpenWrt-Datei.
3. Nach dem Neustart öffne `http://192.168.1.1`. Es erscheint die Seite
   "Firmware aktualisieren" der RAMpe. Startet der Router zwischendurch neu,
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

- abgeleitet (Gluon-RAMpe passt)
- abgeleitet: Commit cb049e7 nennt MT7621S für v5 (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit 2fdd02c 'factory image ... can be flashed using nmrpflash' (Datei)
- geprüft: OpenWrt 24.10.8 ramips/mt7621, factory.img in sha256sums gelistet und per HEAD erreichbar, 15.10.2026 (Weg ab Werk)
- geprüft: nmrpflash-README (Schritte (Normalweg), Taste und Zeitpunkt, Sichtbare Zeichen, Anschluss, Adressen, Programm, Dauer)
- Geräteeintrag: cb049e71cdc08e17f664403a0ef970c480ae5c4a + 2fdd02cc7c3516c2cce2ace2c7b539e0821ecbe8 (factory-Image)
