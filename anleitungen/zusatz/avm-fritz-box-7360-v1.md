## Vorher prüfen

Die 7360 gibt es als SL, v1 und v2, und auf dem Aufkleber steht das nicht
immer. Entscheidend ist die Hardware-Kennung: `181` (SL) und `183` (v1)
nehmen dieselbe Freifunk-Firmware, `196` (v2) die für die
[7360 v2](avm-fritz-box-7360-v2.md). fritzflash.py liest die Kennung selbst
und wählt passend; von Hand fragst du sie im Bootloader mit
`quote GETENV HWRevision` ab ([Der Bootloader von AVM (EVA)](grundlagen/avm-eva.md)).
Diese Anleitung ist für **v1**. Manche Communities bieten die Firmware nur
unter dem Namen [7360 SL](avm-fritz-box-7360-sl.md) an; das ist dieselbe
Datei.

## Wenn etwas schiefgeht

- **An LAN 1 klappt die Verbindung nicht.** Laut OpenWrt: LAN 3 versuchen.
