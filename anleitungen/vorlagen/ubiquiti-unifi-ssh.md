{#-
Vorlage ubiquiti-unifi-ssh (UniFi-Access-Points: per SSH auf die
Ubiquiti-Firmware, Image per scp hochladen, mit einigen Befehlen auf dem
Gerät in den Flash schreiben). Entwurf Content, 15.10.2026.

Vom Skript: bilder, modell, status, erprobt_am, erprobt_mit,
erprobt_mit_aelter, zusatz.vorher, zusatz.fehler, zusatz.text, herkunft.

Werte aus dem Block "werte" des Geräts (ohne Belegmarken):

  Pflicht
    geraet_ip            Adresse des Geräts ab Werk, z. B. 192.168.1.20
    rechner_ip           feste Adresse für den Rechner, z. B. 192.168.1.2
    datei_art            "sysupgrade" oder "factory"
    ziel                 Pfad auf dem Gerät, z. B. /tmp/firmware.bin
    befehle              Liste der Befehle auf dem Gerät, GENAU wie im
                         OpenWrt-Commit, mit {{ziel}} als Dateipfad;
                         der letzte ist meist "reboot"
                         Eine Zeile, die mit "# " beginnt, ist eine Prüfung:
                         Die Vorlage teilt dort den Befehlsblock und setzt den
                         Text als "Prüfen: … Sonst hier aufhören." dazwischen.

  optional (leer = Satz entfällt bzw. allgemeiner Satz)
    dauer                erster Start, z. B. "etwa 4 Minuten" (leer = "einige Minuten")
    ssh_alt              true: alte Schlüssel-Verfahren, ssh/scp brauchen
                         -o HostKeyAlgorithms=+ssh-rsa
    rueckweg_taste       nach "Halte sie gedrückt:", z. B. "etwa 15 Sekunden, bis
                         die LED weiß, blau und aus wechselt"
-#}
{%- set w = werte -%}
{%- set b = bilder if bilder is defined else {} -%}
{%- set alt = " -o HostKeyAlgorithms=+ssh-rsa" if w.ssh_alt else "" -%}
{%- if status == "ungeprüft" %}
> **Noch nicht am Gerät erprobt.** Diese Anleitung ist aus Quellen
> zusammengestellt, aber noch niemand hat sie an einem {{ modell }} Schritt
> für Schritt nachvollzogen. Wenn du es tust: Schreib uns an
> [projekt@neanderfunk.de](mailto:projekt@neanderfunk.de), ob es geklappt hat.
{%- else %}
> **Am Gerät erprobt** am {{ erprobt_am }} mit `{{ erprobt_mit }}`.
{%- endif %}

# {{ modell }}: Freifunk-Firmware installieren

Die UniFi-Geräte von Ubiquiti haben keine Oberfläche, über die man fremde
Firmware hochladen kann. Man meldet sich stattdessen per **SSH** auf dem
Gerät an, kopiert die Freifunk-Firmware hinüber und schreibt sie mit ein paar
Befehlen selbst in den Speicher. Das ist nicht schwer, aber die Befehle
müssen genau stimmen. Wenn du noch nie mit SSH gearbeitet hast, lies vorher
[SSH und scp benutzen](grundlagen/ssh-scp.md).

## Was du brauchst

- das Gerät mit PoE-Injektor oder einem PoE-Switch
- einen Rechner mit Netzwerkanschluss und ein Netzwerkkabel
- die Freifunk-Firmware deiner Community für den {{ modell }}, und zwar das
  **{{ w.datei_art }}**-Image
- `ssh` und `scp`. Unter Linux, macOS und Windows 10/11 sind sie eingebaut
  ([SSH und scp benutzen](grundlagen/ssh-scp.md)).

Das Gerät muss im **Werkszustand** sein. Ist es in einem UniFi-Controller
angemeldet, gelten dort andere Zugangsdaten. Setz es dann vorher auf
Werkseinstellungen zurück oder entferne es im Controller.
{%- if zusatz.vorher is defined and zusatz.vorher %}

## Vorher prüfen

{{ zusatz.vorher }}
{%- endif %}

## Schritte

1. **Datei bereitlegen.** Lade das {{ w.datei_art }}-Image herunter und
   benenne es in `firmware.bin` um. Das erspart Tippfehler in den Befehlen.

2. **Feste Adresse am Rechner.** Stell deinen Rechner auf die feste Adresse
   `{{ w.rechner_ip }}` mit der Netzmaske `255.255.255.0`
   ([Feste IP-Adresse einstellen](grundlagen/feste-ip.md)).

3. **Verbinden.** Steck das Kabel vom Rechner an die Buchse **LAN** des
   PoE-Injektors (oder an den PoE-Switch, an dem das Gerät hängt) und warte,
   bis das Gerät gestartet ist. Das dauert etwa eine Minute.

4. **Firmware hinüberkopieren.** Öffne ein Terminal im Ordner mit der Datei
   und gib ein:

   ```
   scp -O{{ alt }} firmware.bin ubnt@{{ w.geraet_ip }}:{{ w.ziel }}
   ```

   Das Passwort ist `ubnt`. Beim ersten Mal fragt `scp`, ob du dem Gerät
   vertraust: mit `yes` bestätigen.

5. **Anmelden.**

   ```
   ssh{{ alt }} ubnt@{{ w.geraet_ip }}
   ```

   Passwort wieder `ubnt`. Du bist jetzt auf dem Gerät angemeldet.

6. **Firmware schreiben.** Gib diese Befehle **einzeln und genau so** ein,
   jeweils mit Enter. Am besten kopierst du sie Zeile für Zeile.

{%- set ns = namespace(block=[]) %}
{%- for z in w.befehle %}
{%- if z.startswith("# ") %}
{%- if ns.block %}

   ```
{%- for y in ns.block %}
   {{ y }}
{%- endfor %}
   ```
{%- set ns.block = [] %}
{%- endif %}

   **Prüfen:** {{ z[2:] }} Sonst hier aufhören.
{%- else %}
{%- set ns.block = ns.block + [z] %}
{%- endif %}
{%- endfor %}
{%- if ns.block %}

   ```
{%- for y in ns.block %}
   {{ y }}
{%- endfor %}
   ```
{%- endif %}

   Ein Tippfehler an dieser Stelle kann das Gerät unbrauchbar machen. Meldet
   ein Befehl einen Fehler, mach **nicht** weiter, sondern melde dich bei
   deiner Community oder bei uns.

7. **Warten.** Das Gerät startet mit der Freifunk-Firmware neu. Der erste
   Start dauert {% if w.dauer %}{{ w.dauer }}{% else %}einige Minuten{% endif %}.
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
{{ zusatz.fehler }}

## Zurück zur Ubiquiti-Firmware

UniFi-Geräte haben einen TFTP-Notfall-Modus. Strom aus, Reset-Taste drücken
und halten, Strom ein. Halte sie gedrückt:
{% if w.rueckweg_taste %}{{ w.rueckweg_taste }}{% else %}bis die LED ihr Muster
wechselt{% endif %}. Dann schickst du die Original-Firmware von Ubiquiti per
TFTP an `{{ w.geraet_ip }}`, wie unter
[TFTP-Client benutzen](grundlagen/tftp-client.md) beschrieben.

{{ zusatz.text }}

## Herkunft der Angaben

{{ herkunft }}
