{#-
Vorlage ubiquiti-edgerouter (EdgeRouter X, EdgeRouter X-SFP): Neuinstallation
aus der Ubiquiti-Firmware EdgeOS auf Gluon 2025.1, ohne Übernahme einer
alten Installation. ENTWURF Content, 15.10.2026, zur Durchsicht durch adorfer.

Weg (OpenWrt-Wiki toh:ubiquiti:edgerouter_x_er-x_ka, github darkxst/erx-migration):
EdgeOS -> OpenWrt-22.03-initramfs-factory.tar (stman) -> darkxst-Skript mit
vorher abgelegtem OpenWrt-24.10-sysupgrade (neues 6-MB-Kernel-Layout) ->
Gluon-sysupgrade über LuCI.

Die Links auf das factory.tar und die Skripte sind auf Commits festgenagelt
(stman de2ade9, darkxst d29f71a), damit sich die Dateien nicht unter der
Anleitung ändern.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    openwrt_datei        Dateiname des OpenWrt-24.10-sysupgrade für dieses Modell
    openwrt_url          Download-Adresse dieser Datei
    openwrt_sha256       SHA256 dieser Datei (aus sha256sums von OpenWrt)
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set stman = "https://raw.githubusercontent.com/stman/OpenWRT-19.07.2-factory-tar-file-for-Ubiquiti-EdgeRouter-x/de2ade9e0c5356af31e5ae0ff011fd22525e8342/Version%2022.03/openwrt-ramips-mt7621-ubnt_edgerouter-x-initramfs-factory.tar" -%}
{%- set darkxst = "https://raw.githubusercontent.com/darkxst/erx-migration/d29f71a94ec3fadd1f31bee2b39536f395ee9aa5/" -%}

# {{ modell }}: Freifunk-Firmware installieren

{% include "_status.md" %}

Diese Anleitung ist für einen {{ modell }}, auf dem noch die Firmware von
Ubiquiti läuft (EdgeOS), und der neu mit Freifunk anfangen soll.

Der Weg hat drei Etappen, weil es keine Abkürzung gibt:

1. **Aus EdgeOS heraus ein altes OpenWrt aufspielen.** EdgeOS nimmt nur
   Dateien in einem bestimmten Format an, und die gibt es nur für ältere
   OpenWrt-Versionen.
2. **Auf das neue Speicherlayout umstellen.** Die Firmware ab Gluon 2025.1
   (Linux 6.6) ist zu groß für den alten Platz im Speicher. Ein Skript teilt
   den Speicher neu ein und spielt dabei OpenWrt 24.10 auf.
3. **Die Freifunk-Firmware aufspielen**, ganz normal über die
   Weboberfläche von OpenWrt.

Du arbeitest dabei mit SSH und scp im Terminal. Wenn das neu für dich ist,
lies vorher [SSH und scp benutzen](grundlagen/ssh-scp.md). Rechne mit einer
Stunde.

## Was du brauchst

- den Router mit Netzteil, einen Rechner mit Netzwerkanschluss und ein
  Netzwerkkabel
- `ssh` und `scp` ([SSH und scp benutzen](grundlagen/ssh-scp.md))
- diese vier Dateien, alle in einem Ordner:
  1. das OpenWrt-factory-Image für EdgeOS:
     [openwrt-ramips-mt7621-ubnt_edgerouter-x-initramfs-factory.tar]({{ stman }})
     (3.010.560 Bytes), SHA256
     `8f6f370dd7a8bc3e702fba607f175ac5b892a6d8cc852faa94fa73b0f8eccb42`.
     Es stammt nicht von OpenWrt selbst, sondern von einem Nutzer, der es
     gebaut hat, weil OpenWrt für diesen Router keine solche Datei mehr
     erzeugt; das OpenWrt-Wiki verweist darauf.
  2. die beiden Umstellungs-Skripte
     [ubnt_erx_migrate.sh]({{ darkxst }}ubnt_erx_migrate.sh) und
     [ubnt_erx_stage2.sh]({{ darkxst }}ubnt_erx_stage2.sh), genau unter
     diesen Namen
  3. OpenWrt 24.10 für dein Modell:
     [{{ w.openwrt_datei }}]({{ w.openwrt_url }}), SHA256
     `{{ w.openwrt_sha256 }}`
  4. die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar
     das **sysupgrade**-Image
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Empfohlen: EdgeOS und Bootloader vorher aktualisieren

OpenWrt empfiehlt, vor allem anderen die neueste EdgeOS-Version 2.x und das
Bootloader-Update von Ubiquiti einzuspielen. Der neue Bootloader hat einen
Notfall-Modus, der über die Reset-Taste erreichbar ist; ohne ihn bleibt im
Notfall nur die serielle Konsole. Wie es geht, beschreibt Ubiquiti:
[EdgeOS herunterladen](https://www.ui.com/download/software/er-x),
[Bootloader aktualisieren](https://help.ui.com/hc/en-us/articles/360009932554-EdgeRouter-How-to-Update-the-Bootloader).

## Schritte

### Teil 1: OpenWrt aus EdgeOS heraus aufspielen

1. **Feste Adresse am Rechner.** Stell deinen Rechner auf
   `192.168.1.10`, Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

2. **Kabel an eth0.** Steck das Kabel vom Rechner in die Buchse **eth0**
   des Routers und schalte ihn ein. Warte, bis er gestartet ist (etwa eine
   Minute).

3. **factory-Image einspielen.** Öffne ein Terminal im Ordner mit den
   Dateien:

   ```
   scp -O openwrt-ramips-mt7621-ubnt_edgerouter-x-initramfs-factory.tar ubnt@192.168.1.1:/tmp/
   ssh ubnt@192.168.1.1
   ```

   Das Passwort ist jeweils `ubnt` (sofern es niemand geändert hat). Auf dem
   Router dann:

   ```
   add system image /tmp/openwrt-ramips-mt7621-ubnt_edgerouter-x-initramfs-factory.tar
   reboot
   ```

   Die Meldung `line 509: [: too many arguments` dabei ist harmlos; am Ende
   muss `Upgrade completed` stehen. `reboot` fragt eventuell nach: mit `y`
   bestätigen.

   Statt mit `scp` und `ssh` geht das auch in der Weboberfläche von EdgeOS
   (`https://192.168.1.1`): unten links auf **System**, dann bei "Upgrade
   System Image" die Datei hochladen.

4. **Kabel an eth1.** Nach dem Neustart läuft OpenWrt, und das antwortet
   **nicht mehr an eth0, sondern an eth1**. Steck das Kabel um und warte etwa
   eine Minute. Dann:

   ```
   ssh root@192.168.1.1
   ```

   Ein Passwort gibt es nicht. Meldet `ssh` "REMOTE HOST IDENTIFICATION HAS
   CHANGED", ist das hier richtig so, siehe
   [SSH und scp benutzen](grundlagen/ssh-scp.md). Mit `exit` wieder
   abmelden.

### Teil 2: Auf das neue Speicherlayout umstellen

5. **Dateien hinüberkopieren.** Im Terminal auf deinem Rechner:

   ```
   scp -O ubnt_erx_migrate.sh ubnt_erx_stage2.sh root@192.168.1.1:/tmp/
   scp -O {{ w.openwrt_datei }} root@192.168.1.1:/tmp/sysupgrade.img
   ```

   Die OpenWrt-Datei heißt auf dem Router `sysupgrade.img`. Unter diesem
   Namen findet das Skript sie und lädt nichts aus dem Internet nach.

6. **Umstellen.** Melde dich an und starte das Skript:

   ```
   ssh root@192.168.1.1
   cd /tmp
   chmod +x ubnt_erx_migrate.sh
   ./ubnt_erx_migrate.sh
   ```

   Es meldet `Found local /tmp/sysupgrade.img... Skipping download step.` und
   fragt `Do you want to proceed with the migration? (y/n)`: `y` eintippen,
   Enter. Danach bricht die Verbindung ab. Der Router schreibt Kernel und
   System neu und startet neu. **Einige Minuten warten, Strom nicht
   ziehen.**

7. **Prüfen.** Melde dich wieder an (`ssh root@192.168.1.1`, kein Passwort)
   und gib ein:

   ```
   cat /proc/mtd
   ```

   **Prüfen:** In der Ausgabe muss eine Zeile `mtd3: 00600000 00020000
   "kernel"` stehen, und es darf kein `kernel1` und `kernel2` mehr geben.
   Dann ist das neue Layout drin. Sonst hier aufhören und melden.

### Teil 3: Freifunk-Firmware aufspielen

8. **Weboberfläche öffnen.** Öffne im Browser `http://192.168.1.1`. Es
   erscheint die Anmeldung von OpenWrt. Das Passwort-Feld bleibt leer.

9. **Freifunk-Firmware hochladen.** Geh zu **System → Backup / Flash
   Firmware**, ganz unten "Flash image…", und wähl das sysupgrade-Image
   deiner Community aus. Im folgenden Fenster den Haken bei **"Keep
   settings"** (Einstellungen beibehalten) **entfernen**, dann
   **Continue**.

10. **Fertig.** Der Router schreibt die Freifunk-Firmware und startet neu,
    einige Minuten, Strom nicht ziehen. Stell den Rechner wieder auf
    "automatisch". Danach startet die Freifunk-Firmware deiner Community: je
    nach Community zuerst mit einer Einrichtungsseite unter
    `http://192.168.1.1` oder gleich im Betrieb.

## Woran du erkennst, dass es geklappt hat

- In Schritt 3 endet EdgeOS mit `Upgrade completed`.
- In Schritt 4 meldet sich OpenWrt an **eth1**.
- In Schritt 7 zeigt `cat /proc/mtd` eine Partition `kernel` mit `00600000`.
- Nach Schritt 10 meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **In Schritt 4 antwortet nichts.** Das Kabel steckt noch an eth0. OpenWrt
  ist an **eth1** erreichbar.
- **`scp` meldet einen Fehler.** Das `-O` fehlt, oder der Router hat kein
  `scp`. Dann geht es auch so, zum Beispiel für die OpenWrt-Datei:
  `ssh root@192.168.1.1 "cat > /tmp/sysupgrade.img" < {{ w.openwrt_datei }}`
  (in der Eingabeaufforderung "cmd", nicht in der PowerShell).
- **Das Skript meldet "Incompatible board".** Dann läuft auf dem Router
  nicht das OpenWrt aus Teil 1. Zurück zu Schritt 3.
- **Das Skript meldet "Invalid image file".** Die Datei `/tmp/sysupgrade.img`
  ist nicht vollständig angekommen. Schritt 5 wiederholen.
- **EdgeOS lehnt das factory-Image ab** ("invalid firmware"). Das OpenWrt-Wiki
  nennt dafür einen Umweg über ältere EdgeOS-Versionen:
  <https://openwrt.org/toh/ubiquiti/edgerouter_x_er-x_ka>.
- **Der Router startet nach Schritt 6 nicht wieder.** Nicht wild
  ausprobieren. Mit aktualisiertem Bootloader (siehe oben) gibt es den
  Notfall-Modus über die Reset-Taste, sonst nur die serielle Konsole
  (57600 Baud). Frag deine Community oder uns.
{{ zusatz.fehler }}

## Zurück zur Ubiquiti-Firmware

Ubiquiti beschreibt, wie EdgeOS wieder aufgespielt wird:
<https://help.ui.com/hc/en-us/articles/360019289113>.

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
