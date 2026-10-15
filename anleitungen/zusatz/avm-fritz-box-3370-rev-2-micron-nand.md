## Vorher prüfen

- Die 3370 Rev. 2 gibt es mit zwei verschiedenen Speicherchips (Hynix und
  Micron), und jede Sorte braucht ihr eigenes Image. **Von außen sieht man
  das nicht**, nur nach dem Öffnen. Wer nicht öffnen will: einfach mit einer
  Sorte anfangen. Startet die Box danach immer wieder neu, war es die
  falsche; dann dasselbe mit der anderen. Laut OpenWrt geht die Box dabei
  nicht kaputt. Ein Chip von ST-Micro (512 MB) läuft mit dem Hynix-Image.
- Nur ab Hardware-Revision 2 (`quote GETENV HWSubRevision`).
- Bei Bootloader-Version 2186 (`quote GETENV urlader-version`) startet die
  Box nach 30 Sekunden von selbst neu. Dann muss alles in diesen 30 Sekunden
  erledigt sein; also die Befehle vorher bereitlegen.
- fritzflash.py kann dieses Gerät nicht, hier geht es von Hand.

Diese Anleitung ist für **Micron**; für Hynix gibt es eine [eigene](avm-fritz-box-3370-rev-2-hynix-nand.md).
