# Installationsanleitungen je Gerät

**Entwurf, Format in Abstimmung.** Hier entstehen Schritt-für-Schritt-Anleitungen
für die Erstinstallation von Gluon, eine je Gerät aus
[`data/geraete-2025.1.json`](../data/geraete-2025.1.json). Sie sind für Laien
geschrieben. Wo ein Weg Werkzeug braucht (serielle Konsole, TFTP, Terminal),
sollen sie Leute mit etwas Erfahrung so weit bringen, dass es klappt.

## Aufbau

```
anleitungen/
  vorlagen/<familie>.md          Text je Anleitungsfamilie, mit Platzhaltern
  zusatz/<gluon_name>.md         optional: was nur ein Gerät braucht
  <sprache>/<gluon_name>.md      erzeugt, nicht von Hand ändern
  <sprache>/grundlagen/<thema>.md  von Hand: feste IP, curl, serielle Konsole …
  bilder/<gluon_name>/<name>.png   Bilder nur für ein Gerät
  bilder/allgemein/<name>.png      Bilder für alle Geräte (z. B. Seiten der RAMpe)
```

`<sprache>` ist `de`, später auch `en` und `fr`; dann gibt es `vorlagen/` und
`zusatz/` je Sprache (`vorlagen/en/…`). Die Grundlagen-Seiten schreibt man von
Hand, die Geräteanleitungen verlinken sie, statt dieselben Handgriffe 351-mal
zu wiederholen.

Erzeugt werden die Geräteseiten von `scripts/anleitungen.py` (wie
`erstinstallation.py`, mit `--check`): je Gerät eine Markdown-Seite und daraus
eine eigenständige HTML-Seite (`html/<sprache>/<gluon_name>.html`, dazu die
Grundlagen und eine Übersicht). Die HTML-Seiten laden nichts von fremden
Hosts und teilen sich ein lokales CSS; die Kopfangaben stehen dort zusätzlich
als `<meta>`-Tags. Ändert sich ein Wert im JSON, entstehen
die betroffenen Seiten neu; ändert sich eine Vorlage, alle Seiten der Familie.

## Vorlagen

Jinja2 mit `StrictUndefined`: Ein fehlender Wert lässt die Erzeugung
scheitern, statt eine Lücke in den Text zu schreiben. Platzhalter sind die
Felder des Geräts, `{{ werte.recovery_ip }}` usw., dazu `{{ zusatz.fehler }}`
und `{{ zusatz.text }}` und `{{ herkunft }}`.

Ein Zusatz `zusatz/<gluon_name>.md` ist Markdown. Das Skript teilt ihn an
festen Überschriften auf:

- `## Vorher prüfen` -> `zusatz.vorher` (ohne Überschrift; die Vorlage setzt
  ihn vor die Schritte, z. B. Verwechslungen beim Modell)
- `## Wenn etwas schiefgeht` -> `zusatz.fehler` (ohne Überschrift; hängt an
  die gleichnamige Liste der Vorlage)
- alles andere -> `zusatz.text` (mit Überschriften, vor "Herkunft der Angaben")

Ohne Zusatzdatei oder ohne den Abschnitt ist der jeweilige Teil leer.
Verweise auf andere Geräteseiten schreibt man als `<gluon_name>.md`; das
Skript macht daraus in der HTML-Ausgabe `.html`.

Die vorhandenen JSON-Felder (`schritte`, `zeichen`, `dauer` …) sind
Rohmaterial: lange Sätze mit Belegmarken, für die Recherche gedacht. Die
Vorlagen setzen sie **nicht** in den Text. Sie brauchen kurze, einzelne Werte
ohne Belegmarken in einem eigenen Block `werte` je Gerät. Welche Werte eine
Familie braucht, steht oben in ihrer Vorlage.

Die Belegmarken (`[geprüft: …]`, `[abgeleitet: …]` …) aus den Feldern des
Geräts sammelt das Skript unter "Herkunft der Angaben", nach Quelle
zusammengefasst. Im Lesetext stehen keine Marken.

## Kopf jeder erzeugten Seite

```yaml
---
gluon_name: d-link-aquila-pro-ai-m60-a1
modell: D-Link AQUILA PRO AI M60 A1
familie: dlink-recovery-web
sprache: de
level: L4                  # L0 | L0.1 | L1 … L8, siehe "Level und Risiko"
level_text: Network-Tools      # Kurzform zum Level
risiko: normal             # normal | bootloader
status: erprobt            # ungeprüft | erprobt
erprobt_am: 2026-10-13     # nur bei status: erprobt
erprobt_mit: gluon-rampe-20261010   # was am Gerät lief
rampe_image: gluon-rampe-*-d-link-aquila-pro-ai-m60-a1-recovery.bin
grundlagen: [feste-ip, curl]
daten_stand: <Commit von data/geraete-2025.1.json>
vorlage_stand: <Commit der Vorlage>
---
```

Feste Abschnitte, in dieser Reihenfolge: Hinweis zum Status, Was du brauchst,
Schritte, Woran du erkennst, dass es geklappt hat, Wenn etwas schiefgeht,
Herkunft der Angaben.

## Status

Der Statusblock oben auf jeder Seite kommt für alle Vorlagen aus
`vorlagen/_status.md` (per `{% include %}`; Dateien mit `_` am Anfang sind
keine Familien). Er sagt sichtbar, ob und womit die Anleitung am Gerät
erprobt ist und, wenn nicht, wie sicher wir uns sind (Wert `sicherheit`:
`praxis`, `quelle`, `abgeleitet` oder `unsicher`, dazu optional `sicherheit_hinweis`;
`praxis` heißt: bei uns an Geräten dieses Typs schon gemacht, aber Datum und Image
sind nicht festgehalten, deshalb kein `status: erprobt`).
Darunter steht immer die Bitte um Rückmeldung mit einem Mail-Link an
projekt@neanderfunk.de (adorfer 15.10.2026).


- `ungeprüft`: Oben steht sichtbar **"Noch nicht am Gerät erprobt"**. Das gilt
  auch für die Grundlagen-Seiten, bis jemand sie gegengelesen oder benutzt hat.
- `erprobt`: nur, wenn `hw_test` einen erfolgreichen Durchgang mit genau
  diesem Weg nennt. Oben steht dann Datum und welches Image lief. Ist das
  aktuelle Image neuer als das erprobte, sagt die Seite das.

## Level und Risiko

Seit 15.10.2026 (adorfer) hat jede Seite ein **Level** (L0 bis L8) statt
der vier Stufen und dazu ein **Risiko**. Die Einteilung macht das Skript aus
den Merkmalen je Gerät (`scripts/level.py`, dort die genauen Definitionen).
Für Lesende gelten diese Bezeichnungen (Seitenkopf und Übersicht):

| Level | kurz | für die Übersicht |
|---|---|---|
| L0 | Einfach hochladen | Die Freifunk-Firmware wird über die Weboberfläche des Geräts hochgeladen; es gibt nur eine passende Datei. |
| L0.1 | Hochladen, richtige Datei wählen | Wie L0, aber es gibt zwei Dateien (Erstinstallation und Upgrade), und man muss die richtige nehmen. |
| L1 | Zwei Schritte im Browser | Erst eine Zwischenfirmware oder eine ältere Herstellerfirmware, dann die Freifunk-Firmware; alles im Browser. |
| L2 | Taste beim Einschalten | Notfall-Modus per Taste, dann Hochladen im Browser; der Rechner bekommt seine Adresse von selbst. |
| L3 | Feste Adresse am Rechner | Wie L2 oder ein anderer Weg im Browser, aber die Netzwerkeinstellung des Rechners muss von Hand umgestellt werden. |
| L4 | Network-Tools | TFTP-Server, SSH, curl oder ein Image auf einen Datenträger schreiben; Programme, die es für jedes System gibt. |
| L5 | Besondere Programme | Skripte oder Programme außerhalb des Üblichen, oder Dateien vorher selbst zusammenbauen. |
| L6 | Serielles Kabel | Ein Konsolenkabel am Gerät, ohne es zu öffnen. |
| L7 | Gehäuse öffnen | Für die serielle Konsole muss das Gerät aufgeschraubt werden. |
| L8 | Löten und Programmer | Klemmen am Speicherchip, Lötarbeiten oder ein Flash-Programmer. |

**Risiko**, Text für die Übersicht:

> **Risiko „normal“:** Der Bootloader des Geräts bleibt unangetastet.
> Solange das so ist, ist der Weg zurück eigentlich immer offen, notfalls
> über den Notfall-Modus per TFTP oder über die serielle Konsole.
> **Risiko „Bootloader“:** Hier wird der Bootloader selbst ersetzt oder
> verändert. Geht dabei etwas schief, gibt es ohne Flash-Programmer meist
> kein Zurück.

Auf Seiten mit `risiko: bootloader` zeigt `vorlagen/_status.md` unter dem
Statusblock einen Warnkasten (Variable `risiko` vom Skript).

## Regeln für den Text

- Aus Sicht der Lesenden, "du", nummerierte Schritte.
- Sichtbare Merkmale nennen: LED-Farbe und -Takt, Seitentitel, wie lange eine
  Taste gedrückt bleibt.
- Schritte, die einen Schreibschutz im Flash aufheben, ausdrücklich benennen
  und erklären, und wo möglich den Erfolg sichtbar prüfen lassen. Sie fehlen
  sonst still: Alles läuft scheinbar fehlerfrei, aber nichts wird geschrieben
  (adorfer 15.10.2026, siehe `de/grundlagen/schreibschutz.md`).
- Nichts erfinden: Was im JSON fehlt, steht nicht im Text. Fehlt etwas für
  einen Schritt, kommt die Frage an das Buildsystem, nicht eine Annahme.
- Keine internen Pfade oder Hostnamen; interne Quellen heißen
  "Neanderfunk-Notiz".

## Einbindung in den Firmware-Selector

Abgestimmt mit Supernode-Betrieb (15.10.2026): Der Selector **verlinkt** die
Seiten, er bettet nichts ein. Er hat je Gerät genau einen Knopf "Anleitung",
der eine URL in einem neuen Tab öffnet. Daraus folgt:

- Jede Seite ist eine ganze, eigenständige HTML-Seite. Sie lädt nichts von
  fremden Hosts, keine Schriften, keine Bibliotheken. Die Bilder liegen auf
  demselben Host unter `bilder/<gluon_name>/…`.
- Die Seiten liegen dauerhaft unter **HTTPS**. Der Knopf steht in einer
  Firmware-Oberfläche, die Leute noch Jahre später benutzen.
- Das Skript erzeugt zusätzlich eine Index-Datei `html/index.json` mit
  absoluten URLs. Der Selector schlägt über Hersteller, Modell und Revision
  nach und ordnet über `gluon_name` zu:

  ```json
  [
    {"gluon_name": "d-link-aquila-pro-ai-m60-a1",
     "url": "https://<Host>/<Pfad>/html/de/d-link-aquila-pro-ai-m60-a1.html",
     "status": "erprobt", "level": "L4", "risiko": "normal", "sprache": "de"}
  ]
  ```

- Der Selector verlinkt alle Seiten, auch ungeprüfte (adorfer 15.10.2026):
  Validieren lässt sich nur über Rückmeldungen aus dem Feld, und wie sicher
  eine Seite ist, sagt sie selbst oben im Statusblock.
- Innerhalb der Seiten bleiben die Verweise relativ (Grundlagen, Bilder).

## Bilder

Die Vorlage fragt Bilder über feste Namen ab (`recovery-seite`,
`rampe-seite`, `rampe-pruefsumme`, `rampe-flash-laeuft`, `curl-ausgabe` …).
Das Skript sucht zuerst `bilder/<gluon_name>/<name>.png`, dann
`bilder/allgemein/<name>.png`, und gibt der Vorlage `bilder` als
Name -> Pfad relativ zur erzeugten Seite. Fehlt ein Bild, entfällt es im
Text. Für die HTML-Ausgabe kopiert das Skript `bilder/` nach `html/bilder/`.
Screenshots ohne persönliche Angaben (Profilbilder, Namen, Pfade mit
Benutzernamen) ablegen.
