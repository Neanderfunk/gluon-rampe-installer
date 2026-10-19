#!/usr/bin/env python3
#
# level.py - Level L0 ... L8 eines Geräts aus seinen Level-Merkmalen.
#
# Einteilung adorfer 15.10.2026, aus Sicht der Person, die installiert:
#   L0    Upload über die vorhandene Firmware, direkt das sysupgrade (nur ein Image)
#   L0.1  Upload über die vorhandene Firmware, ein factory-Image (zwei Images,
#         Verwechslung möglich)
#   L1    mit Zwischenfirmware (auch Downgrade), alles im Browser, ohne
#         Änderung am Netzwerk des Rechners
#   L2    Taste beim Booten, Weboberfläche, DHCP vorhanden
#   L3    wie L2, aber ohne DHCP: Netzwerk am Rechner umstellen; ebenso jeder
#         Browser-Weg, der eine feste IP verlangt (Entscheidung adorfer 15.10.2026)
#   L4    TFTP-Server, Webserver, curl, ssh/scp, Werkzeuge von der Stange; dazu
#         ein Image auf einen Datenträger schreiben (Entscheidung adorfer 15.10.2026)
#   L5    Python-Skripte oder andere Programme außerhalb des Üblichen,
#         Images mit dd zusammenbauen (z. B. EVA-Skripte der FRITZ!Boxen)
#   L6    serielles Kabel nötig, ohne das Gerät zu öffnen
#   L7    Gerät öffnen, um seriell anzuschließen
#   L8    Schlimmeres: SPI-Klemmen, Widerstände auflöten, Flash-Programmer
#
# Merkmale (Feld "level_merkmale" je Gerät, feste Werte):
#   werkzeug          browser | taste-web | netztools | datentraeger | programm |
#                     seriell | offen
#   image             sysupgrade | factory | offen | -      (nur bei browser)
#   zwischenfirmware  ja | nein
#   dhcp              ja | nein | offen | -                  (browser, taste-web)
#   gehaeuse_oeffnen  ja | nein | offen | -                  (nur bei seriell)
#   l8                ja | nein
# Daneben das Feld "risiko": normal (Bootloader bleibt, Rückweg offen) |
# bootloader (Bootloader oder ein Teil davon wird ersetzt, ohne Programmer
# meist kein Zurück) | offen.
#
# SPDX-License-Identifier: BSD-3-Clause

LEVELS = ["L0", "L0.1", "L1", "L2", "L3", "L4", "L5", "L6", "L7", "L8"]

# Wortlaut für Lesende: Content, anleitungen/README.md "Level und Risiko"
KURZ = {
    "L0": "Einfach hochladen",
    "L0.1": "Hochladen, richtige Datei wählen",
    "L1": "Zwei Schritte im Browser",
    "L2": "Taste beim Einschalten",
    "L3": "Feste Adresse am Rechner",
    "L4": "Network-Tools",
    "L5": "Besondere Programme",
    "L6": "Serielles Kabel",
    "L7": "Gehäuse öffnen",
    "L8": "Löten und Programmer",
}
LANG = {
    "L0": "Die Freifunk-Firmware wird über die Weboberfläche des Geräts hochgeladen; es gibt nur eine passende Datei.",
    "L0.1": "Wie L0, aber es gibt zwei Dateien (Erstinstallation und Upgrade), und man muss die richtige nehmen.",
    "L1": "Erst eine Zwischenfirmware oder eine ältere Herstellerfirmware, dann die Freifunk-Firmware; alles im Browser.",
    "L2": "Notfall-Modus per Taste, dann Hochladen im Browser; der Rechner bekommt seine Adresse von selbst.",
    "L3": "Wie L2 oder ein anderer Weg im Browser, aber die Netzwerkeinstellung des Rechners muss von Hand umgestellt werden.",
    "L4": "TFTP-Server, SSH, curl oder ein Image auf einen Datenträger schreiben; Programme, die es für jedes System gibt.",
    "L5": "Skripte oder Programme außerhalb des Üblichen, oder Dateien vorher selbst zusammenbauen.",
    "L6": "Ein Konsolenkabel am Gerät, ohne es zu öffnen.",
    "L7": "Für die serielle Konsole muss das Gerät aufgeschraubt werden.",
    "L8": "Klemmen am Speicherchip, Lötarbeiten oder ein Flash-Programmer.",
}
RISIKO_TEXT = (
    "> **Risiko „normal“:** Der Bootloader des Geräts bleibt unangetastet.\n"
    "> Solange das so ist, ist der Weg zurück eigentlich immer offen, notfalls\n"
    "> über den Notfall-Modus per TFTP oder über die serielle Konsole.\n"
    ">\n"
    "> **Risiko „Bootloader“:** Hier wird der Bootloader selbst ersetzt oder\n"
    "> verändert. Geht dabei etwas schief, gibt es ohne Flash-Programmer meist\n"
    "> kein Zurück.")
WERKZEUG = {"browser", "taste-web", "netztools", "datentraeger", "programm", "seriell", "offen"}
RISIKO = {"normal", "bootloader", "offen"}


def level(m):
    """Level aus den Merkmalen; "offen", wenn eine entscheidende Angabe fehlt."""
    if m.get("l8") == "ja":
        return "L8"
    w = m.get("werkzeug", "offen")
    if w == "offen":
        return "offen"
    if w == "seriell":
        return {"ja": "L7", "nein": "L6"}.get(m.get("gehaeuse_oeffnen"), "offen")
    if w == "programm":
        return "L5"
    if w in ("netztools", "datentraeger"):
        return "L4"
    if m.get("dhcp") == "nein":
        return "L3"
    if m.get("dhcp") != "ja":
        return "offen"
    if w == "taste-web":
        return "L2"
    if m.get("zwischenfirmware") == "ja":
        return "L1"
    return {"sysupgrade": "L0", "factory": "L0.1"}.get(m.get("image"), "offen")


def pruefen(g):
    """Fehlermeldung, wenn Merkmale oder Risiko keine festen Werte haben, sonst None."""
    m = g.get("level_merkmale")
    if not isinstance(m, dict):
        return "level_merkmale fehlt"
    erlaubt = {
        "werkzeug": WERKZEUG,
        "image": {"sysupgrade", "factory", "offen", "-"},
        "zwischenfirmware": {"ja", "nein"},
        "dhcp": {"ja", "nein", "offen", "-"},
        "gehaeuse_oeffnen": {"ja", "nein", "offen", "-"},
        "l8": {"ja", "nein"},
    }
    if set(m) != set(erlaubt):
        return f"level_merkmale: Schlüssel {sorted(set(m) ^ set(erlaubt))}"
    for k, werte in erlaubt.items():
        if m[k] not in werte:
            return f"level_merkmale.{k} = {m[k]!r}"
    if g.get("risiko") not in RISIKO:
        return f"risiko = {g.get('risiko')!r}"
    return None
