#!/bin/bash
#
# qemu-x86-64.sh - Ende-zu-Ende-Test des Installers in QEMU (x86-64).
#
#   test/qemu-x86-64.sh <installer-initramfs-kernel.bin> <gluon-factory.img.gz> <gluon-sysupgrade.img.gz>
#
# Die Platte der VM ist das factory-Image einer beliebigen Gluon-Firmware (nur
# damit es ein Ziel mit Partitionstabelle gibt), hochgeladen wird das
# sysupgrade-Image einer ANDEREN Firmware. Stufen:
#   1. Installer per -kernel starten; Startseite = Upload-Seite?
#   2. sysupgrade hochladen und bestaetigen; sysupgrade -n laeuft?
#   3. von der Platte starten; laeuft jetzt die hochgeladene Firmware (Config-Mode)?
#
# Kniffe: "/" leitet per meta-refresh weiter - Einstieg ist /cgi-bin/config.
# gluon-web verlangt bei POST einen Origin-Header, der zum Host passt.
# Seit 15.10.2026 auch: gluon.css?v= und die Umleitung https (Port 443) -> http,
# und der Vorbereitungshaken vor dem sysupgrade (/lib/gluon-rampe/prepare/):
# ein Skript, das scheitert, darf nichts flashen und muss auf der Seite
# stehen; eines, das klappt, laeuft vor dem sysupgrade. Die Skripte legt der
# Test zur Laufzeit ueber die serielle Konsole (Unix-Socket) an.
# Braucht qemu-system-x86_64 (mit KVM deutlich schneller), curl, sfdisk, openssl,
# socat.

set -u
KERNEL=${1:?installer-initramfs-kernel.bin}; FACTORY=${2:?factory.img.gz}; UPLOAD=${3:?sysupgrade.img.gz}
WORK="$(cd "$(dirname "$0")" && pwd)/work"; mkdir -p "$WORK"; cd "$WORK"
PORT=${PORT:-18080}
TLSPORT=${TLSPORT:-18443}
NET="-netdev user,id=n0,net=192.168.1.0/24,host=192.168.1.2,dhcpstart=192.168.1.100,hostfwd=tcp:127.0.0.1:$PORT-192.168.1.1:80,hostfwd=tcp:127.0.0.1:$TLSPORT-192.168.1.1:443 -device e1000,netdev=n0"
KVM=$([ -w /dev/kvm ] && echo -enable-kvm)
URL="http://127.0.0.1:$PORT"

gunzip -c "$FACTORY" > disk.img 2>/dev/null
PARTUUID=$(sfdisk --part-uuid disk.img 2 2>/dev/null | tr 'A-Z' 'a-z')
[ -n "$PARTUUID" ] || { echo "PARTUUID der Root-Partition nicht lesbar"; exit 1; }

SOCK="$WORK/konsole.sock"
# Befehl auf der seriellen Konsole; das erste Enter aktiviert die Konsole.
konsole () { printf '\n%s\n' "$1" | socat -t 2 - "UNIX-CONNECT:$SOCK" >/dev/null 2>&1; }
# Wartet, bis die Ausgabe (nicht das Echo des Befehls) im Log steht.
warte_log () { local i; for i in $(seq 1 "$2"); do grep -q "$1" konsole-installer.log && return 0; sleep 1; done; return 1; }
warte () { local i; for i in $(seq 1 "$1"); do curl -s -m 3 -o /dev/null "$URL/" && return 0; sleep 1; done; return 1; }
ende () { kill "$QPID" 2>/dev/null; wait "$QPID" 2>/dev/null; }

echo "== 1. Installer starten"
rm -f "$SOCK" konsole-installer.log
qemu-system-x86_64 $KVM -m 512 -display none \
	-chardev "socket,id=s0,path=$SOCK,server=on,wait=off,logfile=konsole-installer.log" -serial chardev:s0 \
	-kernel "$KERNEL" -append "root=PARTUUID=$PARTUUID console=ttyS0,115200n8" \
	-drive file=disk.img,format=raw,if=ide $NET &
QPID=$!
warte 180 || { echo "FEHLER: Installer antwortet nicht"; ende; tail -20 konsole-installer.log; exit 1; }
curl -s -L "$URL/cgi-bin/config" -o seite1.html -w '   Startseite: %{url_effective}\n'
ACTION=$(grep -o 'action="[^"]*"' seite1.html | head -1 | sed 's/action="//; s/"$//')
grep -q 'name="image"' seite1.html && ! grep -q keepcfg seite1.html && echo "   Upload-Seite ohne 'Einstellungen behalten': ja" \
	|| { echo "FEHLER: keine Installer-Upload-Seite"; ende; exit 1; }
grep -q 'gluon.css?v=' seite1.html && echo "   gluon.css mit Versionsanhang: ja" \
	|| { echo "FEHLER: gluon.css ohne ?v= (Cache-Schutz fehlt)"; ende; exit 1; }
# Port 443: selbstsigniertes Zertifikat, jede Adresse leitet auf http:// um
for pfad in / /irgendwas; do
	curl -sk "https://127.0.0.1:$TLSPORT$pfad" -o seite-https.html -w "   https $pfad: %{http_code}\n"
	grep -q "location.replace('http://'" seite-https.html \
		|| { echo "FEHLER: https $pfad leitet nicht auf http um"; ende; exit 1; }
done
echo | openssl s_client -connect "127.0.0.1:$TLSPORT" 2>/dev/null | openssl x509 -noout -subject 2>/dev/null | sed 's/^/   Zertifikat: /'

echo "== 2a. Vorbereitungshaken: scheitert -> nichts flashen"
HAKEN='b=$(sed s/,/_/g /tmp/sysinfo/board_name); mkdir -p /lib/gluon-rampe/prepare; f=/lib/gluon-rampe/prepare/$b.sh'
konsole "$HAKEN; echo 'echo Testvorbereitung scheitert; exit 1' > \$f; echo HAKEN-\$((1+1))"
warte_log 'HAKEN-2' 30 || { echo "FEHLER: Konsole nimmt keine Befehle an"; ende; exit 1; }
curl -s -L "$URL/cgi-bin/config" -o seite1b.html
grep -q 'bereitet die RAMpe den Speicher vor' seite1b.html && echo "   Hinweis auf die Vorbereitung: ja" \
	|| { echo "FEHLER: kein Hinweis auf die Vorbereitung"; ende; exit 1; }
curl -s -H "Origin: $URL" -F step=2 -F "image=@$UPLOAD" "$URL$ACTION" -o seite2a.html
curl -s -H "Origin: $URL" -F step=3 "$URL$ACTION" -o seite3a.html -w '   Bestaetigung: %{http_code}\n'
grep -q 'Vorbereitung dieses Geräts ist fehlgeschlagen' seite3a.html && grep -q 'Testvorbereitung scheitert' seite3a.html \
	&& echo "   Fehler und Protokoll auf der Seite: ja" || { echo "FEHLER: Fehlschlag nicht angezeigt"; ende; exit 1; }
sleep 5
grep -q 'Performing system upgrade' konsole-installer.log && { echo "FEHLER: trotz Fehlschlag geflasht"; ende; exit 1; }
echo "   nicht geflasht: ja"
konsole "$HAKEN; echo 'echo Testvorbereitung ok > /dev/console' > \$f; echo HAKEN-\$((2+1))"
warte_log 'HAKEN-3' 30 || { echo "FEHLER: zweites Skript nicht angelegt"; ende; exit 1; }

echo "== 2. hochladen und bestaetigen"
curl -s -H "Origin: $URL" -F step=2 -F "image=@$UPLOAD" "$URL$ACTION" -o seite2.html -w '   Upload: %{http_code}\n'
grep -qi 'not valid' seite2.html && { echo "FEHLER: Image abgelehnt"; ende; exit 1; }
curl -s -H "Origin: $URL" -F step=3 "$URL$ACTION" -o seite3.html -w '   Bestaetigung: %{http_code}\n'
for i in $(seq 1 240); do grep -qE 'Upgrade completed|reboot: Restarting' konsole-installer.log && break; sleep 1; done
grep -E 'Testvorbereitung ok|Performing system upgrade|Upgrade completed' konsole-installer.log | grep -v "echo '" | sed 's/^/   /'
grep -v "echo '" konsole-installer.log | grep -q 'Testvorbereitung ok' || { echo "FEHLER: Vorbereitung lief nicht vor dem sysupgrade"; ende; exit 1; }
sleep 2; ende

echo "== 3. von der Platte starten"
qemu-system-x86_64 $KVM -m 512 -display none -serial file:konsole-platte.log \
	-drive file=disk.img,format=raw,if=ide $NET &
QPID=$!
warte 240 || { echo "FEHLER: hochgeladene Firmware antwortet nicht"; ende; tail -20 konsole-platte.log; exit 1; }
sleep 5
curl -s -L "$URL/cgi-bin/config" -o seite4.html -w '   Config-Mode: %{url_effective}\n'
grep -o '<title>[^<]*' seite4.html | sed 's/<title>/   Titel: /'
grep -q 'Gluon-RAMpe' seite4.html && { echo "FEHLER: immer noch der Installer"; ende; exit 1; }
ende
echo "== bestanden"
