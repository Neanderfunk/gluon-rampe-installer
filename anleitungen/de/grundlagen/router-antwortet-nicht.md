---
thema: router-antwortet-nicht
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# Die Router-Seite antwortet nicht

Du öffnest `http://192.168.1.1` (oder die Adresse aus der Anleitung), aber
der Browser wartet nur und meldet irgendwann, dass die Seite nicht erreichbar
ist. Das passiert besonders oft direkt nach einem Wechsel der Firmware.

## Kabel einmal kurz ziehen

Dein Rechner merkt sich, welches Gerät hinter einer Adresse steckt, genauer
seine Hardware-Adresse (MAC). Ein Switch zwischen Rechner und Router merkt
sich das auch. Bei der Installation wechselt hinter derselben Adresse
`192.168.1.1` aber oft das Gerät: Erst antwortet eine Zwischenfirmware oder
eine Notfall-Seite, nach dem Neustart die Einrichtungsseite der
Freifunk-Firmware, und die meldet sich mit einer anderen MAC. Rechner oder
Switch schicken dann noch eine Weile an die alte, und es kommt nichts an.

**Abhilfe:** Zieh das Netzwerkkabel am Rechner einmal kurz ab und steck es
wieder ein. Hängt ein Switch dazwischen, zieh das Kabel zum Router dort
ebenso kurz ab. Dann die Seite neu laden. Ohne das geht es oft erst nach
einigen Minuten von selbst.

## Ein Ping beweist nichts

Die alte Regel "erst mal pingen, dann siehst du, ob er da ist" trägt hier
nicht. Manche Notfall-Seiten antworten nur dem Browser und überhaupt nicht
auf ping. Bei den Notfall-Seiten von D-Link ist das so; bei welchen Geräten
noch, haben wir nicht für jedes geprüft. Bleibt ping stumm, heißt das also
nicht, dass der Router nicht da ist. Versuch es trotzdem im Browser, und
mach nicht wegen eines stummen ping etwas anderes als in der Anleitung.

## Was du sonst prüfen kannst

- **Adresse am Rechner:** Verlangt die Anleitung eine feste Adresse, muss
  sie genau stimmen, ebenso die Netzmaske `255.255.255.0`
  ([Feste IP-Adresse einstellen](feste-ip.md)). Verlangt sie "automatisch",
  darf keine feste Adresse mehr eingestellt sein.
- **WLAN und VPN aus:** Ist der Rechner zugleich per WLAN in einem anderen
  Netz oder läuft ein VPN, landen die Anfragen leicht dort.
- **Der Browser macht `https://` daraus:** siehe
  [Browser macht https daraus](browser-https.md).
- **Es kommt "Not Found":** Dann antwortet der Router, aber der Browser
  springt auf eine alte Seite, siehe
  [Der Browser zeigt "Not Found"](browser-not-found.md).
