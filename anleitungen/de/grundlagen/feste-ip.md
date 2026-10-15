---
thema: feste-ip
sprache: de
status: ungeprüft
---

> **Noch nicht gegengelesen.** Diese Grundlagen-Seite ist ein Entwurf.

# Feste IP-Adresse am Rechner einstellen

Viele Router-Notfallseiten (Recovery, Bootloader) verteilen keine Adressen.
Dein Rechner braucht dann für die Installation eine feste Adresse im selben
Netz. Welche, steht in der Anleitung zu deinem Gerät, zum Beispiel
`192.168.200.66` mit der Netzmaske `255.255.255.0` (auch geschrieben als
`/24`). Ein Gateway und DNS brauchst du dafür nicht.

Danach stellst du den Anschluss wieder auf "automatisch" (DHCP) zurück, sonst
kommt der Rechner später nicht mehr ins Internet.

## Windows 10 und 11

1. Netzwerkkabel stecken.
2. Win + R drücken, `ncpa.cpl` eingeben, Enter.
3. Rechtsklick auf den Ethernet-Anschluss, "Eigenschaften".
4. "Internetprotokoll, Version 4 (TCP/IPv4)" auswählen, "Eigenschaften".
5. "Folgende IP-Adresse verwenden": IP-Adresse und Subnetzmaske eintragen,
   Standardgateway leer lassen. "OK".

Zurück: dieselben Schritte, "IP-Adresse automatisch beziehen".

## Linux

Mit NetworkManager in den Einstellungen unter "Netzwerk", Kabelverbindung,
IPv4, Methode "Manuell". Oder im Terminal, wenn der Anschluss `eth0` heißt
(Name mit `ip link` nachsehen):

```sh
sudo ip addr add 192.168.200.66/24 dev eth0
```

Wieder entfernen:

```sh
sudo ip addr del 192.168.200.66/24 dev eth0
```

## macOS

Systemeinstellungen, "Netzwerk", Ethernet-Anschluss, "Details", "TCP/IP":
"IPv4 konfigurieren" auf "Manuell", IP-Adresse und Teilnetzmaske eintragen.
Zurück: "DHCP".

## Prüfen

Ob der Router erreichbar ist, prüfst du im Browser mit der Adresse aus der
Anleitung. Viele Recovery-Seiten antworten nicht auf `ping`, das ist dort kein
Fehler.
