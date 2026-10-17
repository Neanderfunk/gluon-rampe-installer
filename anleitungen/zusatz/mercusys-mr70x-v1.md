## Achtung

Einen einfachen Weg zurück zur Mercusys-Firmware gibt es nach der
Installation nicht.
Sobald einmal OpenWrt oder die Freifunk-Firmware auf dem MR70X war, nimmt
seine Notfall-Seite (Reset-Taste beim Einstecken) keine Mercusys-Firmware
mehr an. Sie meldet trotzdem jedes Mal Erfolg.

## Vorher prüfen

Das Image passt zum MR70X und zum baugleichen MR1800X mit Hardware 1 (auf
dem Aufkleber "1.0" oder "1.20"; mit 1.20 lief die Freifunk-Firmware bei
uns). Für Hardware 2 gilt diese Anleitung nicht.

## Wenn etwas schiefgeht

- **Der Router startet nur noch die Notfall-Seite** ("System error. The
  router cannot start up normally …"), auch nach erneutem Hochladen. Dann
  hat der Bootloader im Speicher eine Markierung gelöscht, ohne die er keine
  Firmware mehr startet. Warum, wissen wir nicht. Über die Notfall-Seite
  lässt sich das nicht beheben, ihre Erfolgsmeldung gilt nicht. Es geht nur
  noch mit einer seriellen Konsole bei geöffnetem Gehäuse, also etwas für
  Erfahrene (beschrieben im OpenWrt-Forum,
  [Thema 160069](https://forum.openwrt.org/t/160069)).

## Zurück zur Mercusys-Firmware

Nach der Installation geht das nicht mehr über die Notfall-Seite (siehe
"Achtung" oben). Zurück geht es dann nur noch mit einer seriellen Konsole
bei geöffnetem Gehäuse. Das haben wir ausprobiert, es ist aber nichts für
Endnutzer (Hintergrund im OpenWrt-Forum,
[Thema 160069](https://forum.openwrt.org/t/160069)).
