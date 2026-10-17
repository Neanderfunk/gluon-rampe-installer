{#-
Vorlage sonderweg-genexis-pulse-ex400 (Genexis/Inteno Pulse EX400): Recovery
des Bootloaders nimmt das OpenWrt-factory.bin (ein initramfs), daraus per
scp/ssh das Gluon-sysupgrade. Gluon baut für das Gerät kein factory.

Weg: OpenWrt-Commit dd0c283 (Recovery: Reset beim Einschalten, Webserver
192.168.1.1, Reset im Recovery-Modus wechselt rootfs_0/rootfs_1; Rückweg),
Freifunk-Darmstadt-Wiki "Genexis EX400" (LEDs Status orange + WPS grün,
Bestätigungsseite, etwa 2 min, sysupgrade -n per ssh, harmlose Meldung
"Command failed ... (Connection failed)"), github herbetom/multiflash
install-ex400.sh (Formular mit Feld "fileID", ssh wiederholen, bis OpenWrt
antwortet).

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    openwrt_datei        Dateiname des OpenWrt-factory.bin für den EX400
    openwrt_url          Download-Adresse dieser Datei
    openwrt_sha256       SHA256 dieser Datei (aus sha256sums von OpenWrt)

  optional
    sicherheit, sicherheit_hinweis   siehe _status.md
    rampe_url, rampe_datei, rampe_weg   siehe _rampe.md

Bilder (optional, bilder/<gerät>/): recovery-seite, bestaetigung.
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

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
     [{{ w.openwrt_datei }}]({{ w.openwrt_url }}), SHA256
     `{{ w.openwrt_sha256 }}`
  2. die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar
     das **sysupgrade**-Image. Ein factory-Image gibt es für dieses Gerät
     nicht. Benenn die Datei in `gluon.bin` um, dann passen die Befehle
     unten ohne Änderung.

## Vorher prüfen

- Steht auf dem Gerät **DNA** (finnischer Anbieter, "DNA Valokuitu Plus
  EX400", mit einer LED "Update" statt "WPS")? Dann passt diese Anleitung
  nicht: Für diese Variante gibt es eine eigene OpenWrt-Datei, aber keine
  Freifunk-Firmware.
{%- if zusatz.vorher is defined and zusatz.vorher %}
{{ zusatz.vorher }}
{%- endif %}

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
   {%- if b.get("recovery-seite") %}

   ![Die Notfall-Seite des EX400 mit dem Feld zum Hochladen]({{ b["recovery-seite"] }})
   {%- endif %}

5. **OpenWrt hochladen.** Wähl `{{ w.openwrt_datei }}` aus und lad sie hoch.
   Warte, bis eine Bestätigungsseite erscheint.
   {%- if b.get("bestaetigung") %}

   ![Die Bestätigungsseite nach dem Hochladen]({{ b["bestaetigung"] }})
   {%- endif %}

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
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}

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
{% include "_rampe.md" %}

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
