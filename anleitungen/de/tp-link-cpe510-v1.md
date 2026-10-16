---
gluon_name: tp-link-cpe510-v1
modell: TP-Link CPE510 v1
anzeige: TP-Link CPE510 v1
familie: k0-webui
gluon_broken: false
sprache: de
level: L3
level_text: Feste Adresse am Rechner
risiko: normal
status: ungeprüft
grundlagen: [browser-not-found, feste-ip]
daten_stand: 3d3f59fa
vorlage_stand: dd72aaab
---

# TP-Link CPE510 v1: Freifunk-Firmware installieren

> **Noch nicht am Gerät erprobt.** So beschreiben die Entwickler von OpenWrt
> bzw. der Hersteller den Weg für dieses Gerät. Mit der Freifunk-Firmware hat
> ihn bei uns noch niemand nachvollzogen. Wir sind ziemlich sicher, dass es so
> klappt.
>
> Probier es aus und schreib uns, ob es geklappt hat. Und wenn es irgendwo
> hakt: Melde dich, wir helfen dir weiter. Jede Rückmeldung macht die
> Anleitung für alle nach dir besser:
>
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de?subject=Anleitung%20TP-Link%20CPE510%20v1)

Beim TP-Link CPE510 v1 geht die Installation über die normale Weboberfläche des
Herstellers: Du lädst die Freifunk-Firmware dort hoch, wo sonst ein Update
des Herstellers hinkäme. Du brauchst nur einen Browser.

## Was du brauchst

- das Gerät und Strom über den PoE-Injektor
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- den Browser **Firefox**; mit anderen Browsern lässt sich die Oberfläche
  dieses Geräts nicht öffnen (siehe Schritt 3)
- die Freifunk-Firmware deiner Community für den TP-Link CPE510 v1, und zwar das
  **factory**-Image für die Erstinstallation, nicht "sysupgrade"

Auf dem Aufkleber unter dem Gerät stehen Modell und Hardware-Version (bei
TP-Link etwa "Ver: 5.0", bei anderen "H/W Ver."). Viele Geräte gibt es in
mehreren Versionen, und jede braucht ihr eigenes Image. Vergleich den
Aufkleber genau mit "TP-Link CPE510 v1", bevor du anfängst.

## Vorher prüfen

Dieses Image passt zum CPE510 mit Hardware 1.0 und 1.1 und auch zum **CPE520 mit Hardware 1.1**. v2 und v3 brauchen eigene Images. Der v1 hat zwei Netzwerkanschlüsse, v2 und v3 nur einen. Die Hardware-Version steht auf dem Aufkleber ("Ver").

## Schritte

1. **Datei bereitlegen.** Lade das factory-Image herunter. Benenne es danach in `factory.bin` um, genau
   so. Die Oberfläche lehnt den langen Originalnamen sonst ab. Achtung:
   Windows blendet Dateiendungen gern aus; schalte sie im Explorer unter
   "Ansicht" ein, damit nicht `factory.bin.bin` daraus wird.

2. **Verbinden.** Versorg das Gerät mit Strom und steck das Kabel vom
   Rechner an die LAN-Buchse des PoE-Injektors.
   Stell deinen Rechner auf die feste Adresse `192.168.0.10` mit der
   Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

3. **Oberfläche öffnen.** Diese Oberfläche nutzt noch eine alte Verschlüsselung
   (TLS 1.0). Aktuelle Browser lehnen sie ab, und **nur Firefox** lässt sich
   so umstellen, dass er sie für die Installation doch annimmt. Mit Chrome,
   Edge oder Safari geht es nicht. Stell Firefox deshalb zuerst um:

   1. In die Adresszeile `about:config` eingeben, Enter. Die Warnung mit
      "Risiko akzeptieren und fortfahren" bestätigen.
   2. Oben im Suchfeld `security.tls.version.min` eingeben.
   3. Auf den Stift rechts klicken, den Wert `3` durch `1` ersetzen und mit
      dem Haken rechts speichern.

   **Nach der Installation zurückstellen:** genauso, Wert wieder auf `3`.
   Sonst bleibt dein Firefox auch bei anderen Seiten unnötig unsicher.

   Öffne dann in Firefox `https://192.168.0.254`.
   Der Browser warnt vor dem Zertifikat. Das ist hier normal: auf
   "Erweitert" und dann auf "Weiter" bzw. "Risiko akzeptieren" klicken.
   Melde dich an: Benutzer `admin`, Passwort `admin`.

4. **Firmware-Update aufrufen.** Such den Menüpunkt für das Firmware-Update. Er heißt je nach
   Hersteller etwa "Firmware Upgrade", "Firmware-Update" oder "Firmware
   aktualisieren" und liegt oft unter "System", "System Tools" oder
   "Verwaltung".

5. **Hochladen.** Wähl das factory-Image aus, starte das Update und
   bestätige die Rückfragen.

6. **Warten.** Das Gerät schreibt die Firmware und startet neu. Das dauert
   einige Minuten.
   **Nicht ausschalten, Strom nicht ziehen und die Seite nicht neu laden.**
   Manche Geräte löschen zuerst den ganzen Speicher; ein Abbruch in dieser
   Zeit kann sie unbrauchbar machen.

7. **Fertig.** Danach startet die Freifunk-Firmware deiner Community: je nach
   Community zuerst mit einer Einrichtungsseite unter `http://192.168.1.1`
   oder gleich im Betrieb.
   Kommt dort "Not Found", siehe [Der Browser zeigt
   "Not Found"](grundlagen/browser-not-found.md). Stell den Rechner vorher wieder auf "automatisch".
   Wie es weitergeht, beschreibt deine Community.

## Woran du erkennst, dass es geklappt hat

- Das Gerät startet nach einigen Minuten von selbst neu.
- Die Herstelleroberfläche ist weg. Stattdessen meldet sich die
  Freifunk-Firmware, oft zuerst mit der Einrichtungsseite unter
  `http://192.168.1.1`.

## Wenn etwas schiefgeht

- **Die Oberfläche lehnt die Datei ab.** Häufige Gründe: Das Image ist für
  eine andere Hardware-Version oder Region (Aufkleber prüfen), es ist das sysupgrade- statt des factory-Images, der Dateiname
  ist zu lang (kurz umbenennen, z. B. in `factory.bin`), oder die
  Herstellerfirmware ist zu neu und sperrt fremde Firmware (siehe "Vorher
  prüfen", falls vorhanden).
- **Nach dem Neustart ist unter `http://192.168.1.1` nichts.** Stell den
  Rechner auf "automatisch" und zieh das Kabel kurz ab und wieder an. Je nach
  Community startet die Firmware auch gleich im Betrieb ohne
  Einrichtungsseite.

## Notfall

Die TFTP-Notfallfunktion dieser Geräte nimmt nur Firmware von TP-Link an, nicht die Freifunk-Firmware.

## Herkunft der Angaben

Die Angaben stammen aus diesen Quellen (in Klammern, wofür):

- abgeleitet (Schritte (Normalweg))
- geprüft (Weg ab Werk, Schritte (Normalweg), Programm, Quelle (OpenWrt-Commit))
- geprüft: OpenWrt-Commit (Rückweg zur Herstellerfirmware)
- geprüft: OpenWrt-Commit; dass nur Originalfirmware genommen wird: Neanderfunk-Labortest laut Feld weg (Notweg, Rückweg zur Herstellerfirmware)
- geprüft: cpe510, Wiki toh:tp-link:cpe210 (Schritte (Normalweg), Adressen, Programm, Zugang)
- geprüft: cpe510, Wiki toh:tp-link:cpe510 (Schritte (Normalweg), Datei)
- geprüft: tplink-safeloader CPE510 (Schritte (Normalweg), Typenschild/Verwechslung)
- Geräteeintrag: 0104eed1e5ca93a1c912e2d9b70e800b8d3099ad [geprüft]
