## Wenn etwas schiefgeht

- **Die LED bleibt nach dem Upload rot, oder der Router hängt beim Start.**
  Der M60 hat zwei Speicherbereiche für die Firmware. Die Recovery schreibt in
  den gerade aktiven, die Freifunk-Firmware startet aber nur aus dem ersten. War der zweite
  aktiv, braucht es vorher ein Umschalt-Image ("M60-Recovery-UBI-Switch" von
  RolandoMagico auf GitHub), das genauso über die Recovery hochgeladen wird.
  Das ist ein Weg für Fortgeschrittene; frag im Zweifel deine Community. Bei
  unserem Test war es nicht nötig.

## Gut zu wissen

- **Mehrfach-Packs:** Geräte aus Mehrfach-Packs (auf dem Typenschild "M60-2")
  speichern ihre MAC-Adresse an anderer Stelle. Die RAMpe zeigt deshalb eine
  falsche Adresse, die mit `06:00:` beginnt. Gluon ohne Korrektur übernimmt
  diese falsche Adresse. Die Neanderfunk-Firmware enthält die Korrektur und
  liest beim ersten Start die Adresse vom Aufkleber. Frag deine Community, ob
  ihre Firmware das auch tut.
- **Über die normale D-Link-Oberfläche** lässt sich der M60 nicht auf
  Freifunk umstellen, nur über die Recovery.
