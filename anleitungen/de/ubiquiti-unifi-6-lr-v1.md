---
gluon_name: ubiquiti-unifi-6-lr-v1
modell: Ubiquiti UniFi 6 LR v1
anzeige: Ubiquiti UniFi 6 LR v1
familie: ubiquiti-unifi-ssh
gluon_broken: false
sprache: de
level: L4
level_text: Netzwerkwerkzeuge
risiko: normal
status: ungeprüft
grundlagen: [feste-ip, schreibschutz, ssh-scp, tftp-client]
daten_stand: bf1e9ed3
vorlage_stand: 393f1614
---

# Ubiquiti UniFi 6 LR v1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** Wichtige Schritte haben wir von
> ähnlichen Geräten oder aus dem OpenWrt-Wiki übernommen. Es sollte so klappen,
> aber sei aufmerksam und hör auf, wenn etwas anders aussieht als hier
> beschrieben.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20Ubiquiti%20UniFi%206%20LR%20v1)

Die UniFi-Geräte von Ubiquiti haben keine Oberfläche, über die man fremde
Firmware hochladen kann. Man meldet sich stattdessen per **SSH** auf dem
Gerät an, kopiert die Freifunk-Firmware hinüber und schreibt sie mit ein paar
Befehlen selbst in den Speicher. Das ist nicht schwer, aber die Befehle
müssen genau stimmen. Wenn du noch nie mit SSH gearbeitet hast, lies vorher
[SSH und scp benutzen](grundlagen/ssh-scp.md).

## Was du brauchst

- das Gerät mit PoE-Injektor oder einem PoE-Switch
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den Ubiquiti UniFi 6 LR v1, und zwar das
  **sysupgrade**-Image
- `ssh` und `scp`. Unter Linux, macOS und Windows 10/11 sind sie eingebaut
  ([SSH und scp benutzen](grundlagen/ssh-scp.md)).

Das Gerät muss im **Werkszustand** sein. Ist es in einem UniFi-Controller
angemeldet, gelten dort andere Zugangsdaten. Setz es dann vorher auf
Werkseinstellungen zurück oder entferne es im Controller.

## Vorher prüfen

Den U6 LR gibt es in drei Versionen, die sich außen wenig unterscheiden.
Jede braucht ihr eigenes Image; mit dem falschen hat das Gerät danach
vermutlich kein Netzwerk.

- **v1:** LED-Leiste, die in Farben leuchten kann
- **v2:** statt der Leiste nur zwei einfache LEDs (weiß und blau)
- **v3:** wie v2, aber mit anderem Netzwerkchip; laut OpenWrt ab
  Produktionswoche 34/2022

Die frühe "U6 LR-EA" ist keine dieser Versionen.

**Schreibschutz ab Herstellerfirmware 6.2:** Läuft auf dem Gerät
Ubiquiti-Firmware 6.2 oder neuer, gib laut OpenWrt nach dem Anmelden
(Schritt 5) zuerst diesen Befehl ein, bevor du mit Schritt 6 weitermachst:

```
echo 5edfacbf > /proc/ubnthal/.uf
```

Weißt du die Version nicht, gib ihn trotzdem ein. Meldet er "No such file or
directory", ist die Firmware älter und du machst einfach mit Schritt 6
weiter. Ohne diesen Befehl laufen die Schreibbefehle bei neuerer Firmware
scheinbar fehlerfrei durch, schreiben aber nichts. Mehr dazu unter
[Schreibschutz im Flash](grundlagen/schreibschutz.md).

Ältere Ubiquiti-Firmware antwortet laut OpenWrt eventuell unter
`192.168.1.34` statt `192.168.1.20`.

## Schritte

1. **Datei bereitlegen.** Lade das sysupgrade-Image herunter und
   benenne es in `firmware.bin` um. Das erspart Tippfehler in den Befehlen.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf die feste Adresse
   `192.168.1.2` mit der Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

3. **Verbinden.** Steck das Kabel vom Rechner an die Buchse **LAN** des
   PoE-Injektors (oder an den PoE-Switch, an dem das Gerät hängt) und warte,
   bis das Gerät gestartet ist. Das dauert etwa eine Minute.

4. **Firmware hinüberkopieren.** Öffne ein Terminal im Ordner mit der Datei
   und gib ein:

   ```
   scp -O -o HostKeyAlgorithms=+ssh-rsa firmware.bin ubnt@192.168.1.20:/tmp/openwrt.bin
   ```

   Das Passwort ist `ubnt`. Beim ersten Mal fragt `scp`, ob du dem Gerät
   vertraust: mit `yes` bestätigen.

5. **Anmelden.**

   ```
   ssh -o HostKeyAlgorithms=+ssh-rsa ubnt@192.168.1.20
   ```

   Passwort wieder `ubnt`. Du bist jetzt auf dem Gerät angemeldet.

6. **Firmware schreiben.** Gib diese Befehle **einzeln und genau so** ein,
   jeweils mit Enter. Am besten kopierst du sie Zeile für Zeile.

   ```
   dmesg | grep mtk_sgmii_init
   ```

   **Prüfen:** Weiter nur, wenn in der Ausgabe kein RTL8211 steht (mit RTL8211 ist es ein v3, dann gilt die Anleitung für den [UniFi 6 LR v3](ubiquiti-unifi-6-lr-v3.md)). Sonst hier aufhören.

   ```
   cat /proc/mtd
   ```

   **Prüfen:** Weiter nur, wenn in der Ausgabe bs bei mtd6, kernel0 bei mtd8 und kernel1 bei mtd9 steht. Sonst hier aufhören.

   ```
   dd if=/dev/zero bs=1 count=1 of=/dev/mtdblock6
   dd if=/tmp/openwrt.bin of=/dev/mtdblock8
   dd if=/tmp/openwrt.bin of=/dev/mtdblock9
   reboot
   ```

   Ein Tippfehler an dieser Stelle kann das Gerät unbrauchbar machen. Meldet
   ein Befehl einen Fehler, mach **nicht** weiter, sondern melde dich bei
   deiner Community oder bei uns.

7. **Warten.** Das Gerät startet mit der Freifunk-Firmware neu. Der erste
   Start dauert etwa 4 Minuten.
   **Strom nicht ziehen.**

8. **Fertig.** Stell den Rechner wieder auf "automatisch". Danach startet die
   Freifunk-Firmware deiner Community: je nach Community zuerst mit einer
   Einrichtungsseite unter `http://192.168.1.1` oder gleich im Betrieb. Wie
   es weitergeht, beschreibt deine Community.

## Woran du erkennst, dass es geklappt hat

- `scp` kopiert die Datei ohne Fehlermeldung.
- Keiner der Befehle in Schritt 6 meldet einen Fehler.
- Nach dem Neustart meldet sich die Freifunk-Firmware.

## Wenn etwas schiefgeht

- **`ssh` oder `scp` meldet "Connection refused" oder "Permission denied".**
  Das Gerät ist nicht im Werkszustand, oder es ist noch nicht fertig
  gestartet. Zurücksetzen und noch einmal.
- **`scp` meldet einen Fehler wie "subsystem request failed".** Das `-O` fehlt
  im Befehl.
- **"no matching host key type found".** Dein SSH ist neuer als das Gerät.
  Häng an `ssh` und `scp` noch `-o HostKeyAlgorithms=+ssh-rsa` an, siehe
  [SSH und scp benutzen](grundlagen/ssh-scp.md).
- **"REMOTE HOST IDENTIFICATION HAS CHANGED".** Du hast schon einmal ein
  anderes Gerät unter derselben Adresse benutzt. Siehe
  [SSH und scp benutzen](grundlagen/ssh-scp.md).

## Zurück zur Ubiquiti-Firmware

UniFi-Geräte haben einen TFTP-Notfall-Modus. Strom aus, Reset-Taste drücken
und halten, Strom ein. Halte sie gedrückt:
bis die LED weiß, blau und aus wechselt. Dann schickst du die Original-Firmware von Ubiquiti per
TFTP an `192.168.1.20`, wie unter
[TFTP-Client benutzen](grundlagen/tftp-client.md) beschrieben.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet: Commit a0f4ead (Warnung)
- abgeleitet: Commits nennen 'factory defaults' (Schritte (Normalweg), Bedingung an die Herstellerfirmware)
- abgeleitet: Wiki (Typenschild/Verwechslung, Dauer)
- abgeleitet: Wiki toh/ubiquiti/unifi_6_lr (Schritte (Normalweg), Sichtbare Zeichen, Adressen, Programm, Bedingung an die Herstellerfirmware, Rückweg zur Herstellerfirmware)
- geprüft: 634c13c1 (Weg ab Werk, Schritte (Normalweg))
- geprüft: Commit bf94e0a (Schritte (Normalweg), Programm)
- geprüft: Commit fb4d7a9 (Typenschild/Verwechslung)
- geprüft: Commits (Datei)
- geprüft: Commits 15a0247, 31d86a1, a0f4ead (Schritte (Normalweg), Typenschild/Verwechslung)
- geprüft: Commits, z. B. 4c8446b 'On factory defaults, user and password is ubnt at 192.168.1.20/24' (Schritte (Normalweg), Taste und Zeitpunkt)
- geprüft: Commits; IP-Beispiel .10 abgeleitet: Wiki toh/ubiquiti/unifiac (Schritte (Normalweg), Anschluss, Adressen, Programm, Zugang)
- geprüft: Wiki toh:ubiquiti:unifi_6_lr, Rohtext 15.10.2026 (Typenschild/Verwechslung)
- Geräteeintrag: OpenWrt 634c13c186646aff2badb51a43b248825d0fe5a0 (v1-Profil: 15a02471bb854245f8f94398c1e1d9ce29c2c341)
