---
gluon_name: gl.inet-gl-xe300
modell: GL.iNet GL-XE300
anzeige: GL.iNet GL-XE300
familie: glinet
gluon_broken: false
sprache: de
stufe: fortgeschritten
status: ungeprüft
rampe_image: gluon-rampe-20261015-gl.inet-gl-xe300-factory.img
grundlagen: [browser-https, feste-ip]
daten_stand: a638c45
vorlage_stand: 393f161
---

# GL.iNet GL-XE300: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20GL.iNet%20GL-XE300)

GL.iNet-Router haben einen eingebauten Notfall-Modus: Hält man beim
Einschalten die Reset-Taste, startet statt der Firmware eine schlichte
Webseite zum Hochladen. Über die kommt die Freifunk-Firmware auf den Router.
Du brauchst nur einen Browser und eine feste Adresse am Rechner.

## Was du brauchst

- den Router mit Netzteil
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- OpenWrt für den GL.iNet GL-XE300:
  [openwrt-24.10.8-ath79-nand-glinet_gl-xe300-squashfs-factory.img](https://downloads.openwrt.org/releases/24.10.8/targets/ath79/nand/openwrt-24.10.8-ath79-nand-glinet_gl-xe300-squashfs-factory.img). Die Freifunk-Firmware
  gibt es nicht in der Form, die der Notfall-Modus annimmt; deshalb kommt
  erst OpenWrt drauf und darüber die Freifunk-Firmware.
- die Freifunk-Firmware deiner Community für den GL.iNet GL-XE300, und zwar das
  **sysupgrade**-Image

## Schritte

1. **Datei bereitlegen.** Lade OpenWrt und das Freifunk-sysupgrade-Image herunter.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf `192.168.1.2`,
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)). Schalte ein VPN
   am Rechner aus (auch Tailscale oder ZeroTier), das stört sonst.

3. **Kabel stecken.** Steck das Kabel vom Rechner an eine LAN-Buchse.
   Alle anderen Buchsen bleiben frei. Der Router hat noch keinen Strom.

4. **Notfall-Modus starten.** Drück die Reset-Taste und die Power-Taste gleichzeitig und halte beide, bis die LAN-LED 5-mal geblinkt hat. Dann beide loslassen. Bleibt die WLAN-LED an, ist der Notfall-Modus erreicht.

5. **Hochladen.** Öffne im Browser `http://192.168.1.1`. Es erscheint die
   schlichte Notfall-Seite. Wähl die OpenWrt-Datei aus und
   starte das Hochladen ("Update firmware").

6. **Warten.** Der Router schreibt die Firmware, das dauert etwa
   3 Minuten.
   **Strom nicht ziehen.**

7. **Freifunk-Firmware über OpenWrt.** Nach dem Neustart läuft OpenWrt.
   Öffne `http://192.168.1.1`, melde dich an (Passwort-Feld leer), geh zu
   **System → Backup / Flash Firmware**, "Flash image…", wähl das
   Freifunk-sysupgrade-Image, **entfern den Haken bei "Keep settings"** und
   klick **Continue**. Wieder einige Minuten warten.

8. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- In Schritt 4 zeigen die LEDs, dass der Notfall-Modus erreicht ist, und
  unter `http://192.168.1.1` kommt die Notfall-Seite.
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **Unter `http://192.168.1.1` kommt nichts.** Prüf die feste Adresse
  (Schritt 2), schalte VPN-Programme aus und versuch Schritt 4 noch einmal,
  diesmal genau auf die LEDs achtend. Hilft ein anderer Browser oder ein
  privates Fenster, lag es am Zwischenspeicher des Browsers.

## Anderer Weg: mit der Gluon-RAMpe (ungetestet)

Statt erst OpenWrt und dann die Freifunk-Firmware aufzuspielen, geht es auch
mit der **Gluon-RAMpe**: einer kleinen Firmware, die nur eins kann, nämlich
die Freifunk-Firmware deiner Community annehmen. Das spart die
OpenWrt-Etappe. Für den GL.iNet GL-XE300 ist dieser Weg **noch von niemandem
ausprobiert**; die RAMpe selbst läuft auf anderen Geräten.

1. Lade die RAMpe für den GL.iNet GL-XE300 herunter:
   [gluon-rampe-20261015-gl.inet-gl-xe300-factory.img](https://download.ffnef.de/other/Gluon-Installer-RAMpe/gluon-rampe-20261015-gl.inet-gl-xe300-factory.img).
2. Lade in Schritt 5 im Notfall-Modus statt der OpenWrt-Datei die RAMpe hoch.
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

## Zurück zur GL.iNet-Firmware

Die Firmware von GL.iNet herunterladen und auf demselben Weg über den
Notfall-Modus aufspielen.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Weg ab Werk, Schritte (Normalweg), Datei, Werkzeug/Spezial, Gluon-RAMpe passt)
- geprüft (Weg ab Werk, Quelle (OpenWrt-Commit))
- geprüft: Commit (Schritte (Normalweg), Sichtbare Zeichen, Datei)
- geprüft: Commit af8a059 (Schritte (Normalweg), Taste und Zeitpunkt, Rückweg zur Herstellerfirmware)
- geprüft: Commit af8a059, GL-Doku (Schritte (Normalweg), Sichtbare Zeichen)
- geprüft: GL.iNet-Doku debrick (docs.gl-inet.com/router/en/4/faq/debrick, Stand 12.08.2026) (Schritte (Normalweg), Anschluss, Adressen, Programm, Dauer)
- geprüft: OpenWrt 24.10.8 ath79/nand, Datei in sha256sums gelistet und per HEAD erreichbar, 15.10.2026 (Weg ab Werk)
- Geräteeintrag: af8a059bb41dd7afee49ce9a5d52e9a8e010bbd8 [geprüft]
