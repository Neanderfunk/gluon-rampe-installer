{#-
Vorlage asus-tuf-herbetom (ASUS TUF-AX4200, TUF-AX6000): Per SSH in die
ASUS-Firmware, einen von OpenWrt-Leuten gebauten "factory-initramfs" vom
eigenen Rechner per wget holen und mit mtd-erase/mtd-write in die Partition
"linux" schreiben; nach dem Neustart läuft OpenWrt im Arbeitsspeicher, daraus
das Gluon-sysupgrade.

Weg: github herbetom/openwrt-asus-filogic-factory, Release filogic-v2
(10.12.2023); Freifunk-Darmstadt-Wiki "ASUS TUF-AX4200" (blocktrron
filogic-v1, Adressen 192.168.50.1/192.168.1.1, "Enable ssh (LAN Only)",
Beispielzeile für /etc/hosts). mtd-erase/mtd-write wörtlich aus der Quelle.
Abweichung: Die Zeile für /etc/hosts entsteht per echo aus $SSH_CLIENT statt
mit vi (abgeleitet; dropbear setzt SSH_CLIENT), mit Prüfung und Rückfall auf
die Hand-Eingabe.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text,
zusatz.achtung, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    factory_datei        Dateiname des factory-initramfs für dieses Modell
    factory_url          Download-Adresse dieser Datei

  optional
    factory_hinweis      ganzer Satz zur Herkunft der Datei
    sicherheit, sicherheit_hinweis   siehe _status.md
    rampe_url, rampe_datei
                         RAMpe (…-asus-tuf-ax4200/ax6000-initramfs-kernel.bin),
                         gleiches FIT-Format wie herbetom (Buildsystem
                         15.11.2026, beide Images zerlegt). Gesetzt: Sie wird
                         statt des herbetom-Image geschrieben, die
                         Freifunk-Firmware kommt über die RAMpe-Seite; herbetom
                         steht unter "Anderer Weg" (adorfer 15.11.2026:
                         "bitte alles auf RAMpe umstellen")
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set rampe = w.get("rampe_url") -%}
{%- set dn = "rampe.bin" if rampe else "openwrt.bin" -%}
{%- set wr = "rampe-webroot" if rampe else "openwrt-webroot" -%}
{%- set zw = "die RAMpe" if rampe else "OpenWrt" -%}
{%- import "_rampe_schritte.md" as rs with context -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Die ASUS-Firmware nimmt keine fremde Firmware über ihre Weboberfläche an.
Der Weg führt über SSH, also die Anmeldung im Terminal, und hat drei
Etappen:

{% if rampe -%}
1. **Die RAMpe in den Speicher schreiben.** Du meldest dich per SSH an der
   ASUS-Firmware an. Der Router holt sich die **Gluon-RAMpe** von deinem
   Rechner und schreibt sie anstelle der ASUS-Firmware in den Speicher. Die
   RAMpe ist eine kleine Firmware, die nur eins kann: die Freifunk-Firmware
   deiner Community annehmen.
2. **Die RAMpe starten.** Nach einem Neustart läuft sie.
3. **Die Freifunk-Firmware aufspielen.** Auf der Seite der RAMpe lädst du
   sie im Browser hoch.

Du brauchst dafür SSH ([SSH und scp benutzen](grundlagen/ssh-scp.md))
und Python 3 auf deinem Rechner.
{%- else -%}
1. **Ein kleines OpenWrt in den Speicher schreiben.** Du meldest dich per
   SSH an der ASUS-Firmware an. Der Router holt sich eine OpenWrt-Datei von
   deinem Rechner und schreibt sie anstelle der ASUS-Firmware in den
   Speicher.
2. **OpenWrt starten.** Nach einem Neustart läuft dieses kleine OpenWrt.
3. **Die Freifunk-Firmware aufspielen.** Aus OpenWrt heraus installierst du
   die Freifunk-Firmware deiner Community.

Du brauchst dafür SSH und scp ([SSH und scp benutzen](grundlagen/ssh-scp.md))
und Python 3 auf deinem Rechner.
{%- endif %} Rechne mit einer Dreiviertelstunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- `ssh`{% if not rampe %} und `scp`{% endif %} ([SSH und scp benutzen](grundlagen/ssh-scp.md))
- **Python 3**. Unter Linux und macOS ist es meist schon da, unter Windows
  bekommst du es bei <https://www.python.org/downloads/>.
- diese zwei Dateien:
{%- if rampe %}
  1. die RAMpe für den {{ modell }}:
     [{{ w.get("rampe_datei") or "RAMpe-Datei" }}]({{ w.rampe_url }}).
  2. die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar
     das **sysupgrade**-Image.
{%- else %}
  1. das OpenWrt-"factory-initramfs" für den {{ modell }}:
     [{{ w.factory_datei }}]({{ w.factory_url }}).
     {%- if w.get("factory_hinweis") %} {{ w.get("factory_hinweis") }}{% endif %}
  2. die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar
     das **sysupgrade**-Image. Benenn es in `gluon.bin` um, dann passen die
     Befehle unten ohne Änderung.
{%- endif %}
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

### {% if rampe %}Die RAMpe{% else %}OpenWrt{% endif %} in den Speicher schreiben

1. **Webserver auf dem Rechner starten.** Leg einen Ordner `{{ wr }}`
   an, kopier die {% if rampe %}RAMpe-Datei{% else %}OpenWrt-Datei{% endif %} hinein und benenn sie dort in `{{ dn }}`
   um. Öffne ein Terminal in dem Ordner, **in dem** `{{ wr }}` liegt,
   und starte:

   ```
   python3 -m http.server -d {{ wr }} 8080
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

6. **{% if rampe %}Die RAMpe{% else %}OpenWrt{% endif %} holen.** Auf dem Router:

   ```
   wget -O /tmp/{{ dn }} http://openwrtimage.lan:8080/{{ dn }}
   ```

   **Prüfen:** `wget` meldet keinen Fehler, und im Terminal mit dem
   Webserver erscheint eine Zeile mit `GET /{{ dn }}` und `200`. Sonst
   hier aufhören und Schritt 1 und 5 prüfen.

7. **Schreiben.** Jetzt wird die ASUS-Firmware überschrieben.

   > **Ab dem ersten Befehl, bis `mtd-write` fertig ist, auf keinen Fall den
   > Strom ziehen.** In dieser Zeit ist die ASUS-Firmware schon gelöscht und
   > {% if rampe %}die RAMpe{% else %}OpenWrt{% endif %} noch nicht vollständig geschrieben. Dann hilft nur noch die
   > serielle Konsole.

   Gib die beiden Befehle nacheinander ein, genau so:

   ```
   mtd-erase -d linux
   mtd-write -i /tmp/{{ dn }} -d linux
   ```

   Beide Befehle zeigen keinen Fortschritt. Warte, bis die Eingabe wieder
   erscheint.

### {% if rampe %}Die RAMpe{% else %}OpenWrt{% endif %} starten

8. **Neu starten.** Zieh den Stecker des Netzteils, warte ein paar Sekunden
   und steck ihn wieder ein. Nach etwa einer Minute läuft {{ zw }} unter
   `192.168.1.1`. Damit dein Rechner eine passende Adresse bekommt, zieh das
   Netzwerkkabel am Rechner kurz ab und steck es wieder ein.

### Freifunk-Firmware aufspielen
{%- if rampe %}

{{ rs.seite(9) }}

11. **Fertig.** Einige Minuten warten, Strom nicht ziehen. Danach startet
    die Freifunk-Firmware deiner Community: je nach Community zuerst mit
    einer Einrichtungsseite unter `http://192.168.1.1` oder gleich im
    Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Den Webserver aus Schritt 1 kannst du mit Strg+C beenden.
{%- else %}

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
    Betrieb.
    Antwortet dort nichts, siehe [Die Router-Seite antwortet
    nicht](grundlagen/router-antwortet-nicht.md); kommt "Not Found", siehe
    [Der Browser zeigt "Not Found"](grundlagen/browser-not-found.md). Den Webserver aus Schritt 1 kannst du mit Strg+C beenden.
{%- endif %}

## Woran du erkennst, dass es geklappt hat

- In Schritt 5 steht eine Adresse vor `openwrtimage.lan`.
- In Schritt 6 zeigt der Webserver `GET /{{ dn }}` mit `200`.
{%- if rampe %}
- Nach Schritt 8 zeigt `http://192.168.1.1` die RAMpe-Seite "Firmware
  aktualisieren".
- Nach Schritt 11 meldet sich die Freifunk-Firmware.
{%- else %}
- Nach Schritt 8 antwortet OpenWrt unter `192.168.1.1`.
- Nach Schritt 10 meldet sich die Freifunk-Firmware.
{%- endif %}

## Wenn etwas schiefgeht

- **`ssh` kommt in Schritt 4 nicht durch.** Prüf in der ASUS-Oberfläche, ob
  SSH an ist, "LAN only" und Port 22. Den Benutzernamen hast du im
  Assistenten selbst vergeben.
- **`wget` meldet einen Fehler.** Läuft der Webserver noch? Lässt die
  Firewall deines Rechners Port 8080 durch? Stimmt die Adresse in
  `/etc/hosts` (Schritt 5)? Liegt `{{ dn }}` wirklich im Ordner
  `{{ wr }}`?
- **Nach Schritt 8 antwortet nichts unter `192.168.1.1`.** Warte noch etwas
  und steck das Netzwerkkabel am Rechner neu ein. Kommt auch nach fünf
  Minuten nichts, schreib uns. Weiter geht es dann nur über die serielle
  Konsole im Router.
- **Meldet `ssh` "REMOTE HOST IDENTIFICATION HAS CHANGED"**, siehe
  [SSH und scp benutzen](grundlagen/ssh-scp.md).
{%- if zusatz.fehler is defined and zusatz.fehler %}
{{ zusatz.fehler }}
{%- endif %}

{%- if rampe %}

## Anderer Weg: über OpenWrt

Statt der RAMpe lässt sich in Schritt 1 bis 7 auch das OpenWrt-"factory-initramfs"
schreiben: [{{ w.factory_datei }}]({{ w.factory_url }}).
{%- if w.get("factory_hinweis") %} {{ w.get("factory_hinweis") }}{% endif %}
Benenn es im Webserver-Ordner in `rampe.bin` um, dann passen die Befehle
oben. Nach dem Neustart läuft OpenWrt unter `192.168.1.1`; die
Freifunk-Firmware kommt dann per scp und ssh
([SSH und scp benutzen](grundlagen/ssh-scp.md)): das sysupgrade-Image in
`gluon.bin` umbenennen und

```
scp -O gluon.bin root@192.168.1.1:/tmp/gluon.bin
ssh root@192.168.1.1 "sysupgrade -n /tmp/gluon.bin"
```

Ein Passwort gibt es nicht. Nach dem zweiten Befehl bricht die Verbindung
ab, das ist harmlos.
{%- endif %}

## Zurück zur ASUS-Firmware

Laut OpenWrt-Wiki hilft dafür das ASUS-Werkzeug "Firmware Restoration" mit
dem Rettungsmodus des Routers. Ausprobiert haben wir es nicht.

{{ zusatz.text }}

