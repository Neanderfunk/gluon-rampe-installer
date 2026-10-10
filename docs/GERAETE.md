# Geräte

## Wann lohnt der Installer?

Immer dann, wenn Gluon für ein Gerät **kein factory-Image** hat und der Weg
über ein OpenWrt-Zwischenimage führt, das der Hersteller-Weg (Web-UI,
Recovery-Seite, Rescue-Tool) annimmt. Der Installer ersetzt genau dieses
Zwischenimage – statt OpenWrt/LuCI kommt eine Gluon-Seite mit einem Upload.

Nicht nötig, wenn schon der Bootloader oder die Hersteller-Firmware das
Gluon-sysupgrade direkt nimmt (z.B. GL.iNet-U-Boot-Web, Cudys eigene
OpenWrt-Zwischenfirmware).

## Im Zweifel mitbauen

Ist unklar, ob Gluons eigenes factory-Image auf einem Gerät überhaupt
brauchbar ist (Beispiel MikroTik hAP ac2: Gluons "factory" ist dort selbst ein
initramfs, und ein Gluon-initramfs startet ohne `91_installer_initramfs` nie
im Config-Mode), wird das Installer-Image für dieses Gerät mitgebaut
(adorfer 10.10.2026). Ein Installer-Image zu viel kostet nur Bauzeit.

Vollständiges Inventar aller Gluon-2025.1-Geräte mit Weg ab Werk,
Übertragung, Konsole, Links und Installer-Eignung:
[ERSTINSTALLATION-2025.1.md](ERSTINSTALLATION-2025.1.md).

## Stand: Geräte mit Rezept

Rezepte unter `devices/<gluon-name>.sh`. "Entwurf, nicht gebaut" heißt: per
Trockenlauf gegen `targets/` von Gluon v2025.1.3 geprüft (Rezept läuft,
Targetdatei bleibt gültiges Lua), aber noch kein Bau und kein Hardware-Test.
Alias-Namen (z. B. Instant On AP11 zu AP-303) haben kein eigenes Rezept: Gluon
legt das Image des Hauptnamens unter beiden Namen ab.

<!-- BEGIN erzeugt:rezepte -->
<!-- erzeugt von scripts/erstinstallation.py aus data/geraete-2025.1.json, nicht von Hand ändern -->

| Gerät | Gluon-Name | Target | Kat. | Rezept und Stand |
|---|---|---|---|---|
| D-Link DIR-505 | `d-link-dir-505` | ath79-generic | K4 | devices/d-link-dir-505.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (lzma) per U-Boot-TFTP; UART, IPs und Ladeadresse nicht belegt; 64 MB RAM |
| Enterasys WS-AP3705i | `enterasys-ws-ap3705i` | ath79-generic | K4 | devices/enterasys-ws-ap3705i.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (lzma) als `1401A8C0.img` per U-Boot-TFTP; `bootcmd` bleibt seriell |
| Extreme Networks WS-AP3805i | `extreme-networks-ws-ap3805i` | ath79-generic | K4 | devices/extreme-networks-ws-ap3805i.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (lzma) als `1D01A8C0.img` per U-Boot-TFTP; `bootcmd` bleibt seriell |
| Ocedo Koala | `ocedo-koala` | ath79-generic | K1 | devices/ocedo-koala.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (lzma) als `koala-uImage-initramfs-lzma.bin` per TFTP; Vorbereitung vor dem sysupgrade fehlt der RAMpe noch (`fw_setenv bootcmd run bootcmd_1`) |
| Ocedo Raccoon | `ocedo-raccoon` | ath79-generic | K1 | devices/ocedo-raccoon.sh (Rezept-Entwurf, nicht gebaut): wie Koala, als `raccoon-uImage-initramfs-lzma.bin`; Vorbereitung vor dem sysupgrade fehlt der RAMpe noch (`fw_setenv`) |
| Siemens WS-AP3610 | `siemens-ws-ap3610` | ath79-generic | K4 | devices/siemens-ws-ap3610.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (lzma statt unkomprimiert wie bei OpenWrt) als `1401A8C0.img` per U-Boot-TFTP |
| Sophos AP15 (broken) | `sophos-ap15` | ath79-generic | K4 | devices/sophos-ap15.sh (Rezept-Entwurf, nicht gebaut): baut das Gluon-"broken"-Gerät gezielt; `initramfs-kernel.bin` (lzma) per U-Boot-TFTP; RAM nicht belegt |
| TP-Link Archer D50 v1 (broken) | `tp-link-archer-d50-v1` | ath79-generic | K4 | devices/tp-link-archer-d50-v1.sh (Rezept-Entwurf, nicht gebaut): baut das Gluon-"broken"-Gerät gezielt; `initramfs-kernel.bin` (lzma, TP-Link-Header) per U-Boot-TFTP; 64 MB RAM knapp |
| MikroTik RouterBOARD 951Ui-2nD (hAP) | `mikrotik-routerboard-951ui-2nd-hap` | ath79-mikrotik | K1 | devices/mikrotik-routerboard-951ui-2nd-hap.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin`; Netboot (BOOTP/DHCP + TFTP); 64 MB RAM knapp |
| MikroTik RouterBOARD mAPL-2nD (mAP lite) | `mikrotik-routerboard-mapl-2nd` | ath79-mikrotik | K1 | devices/mikrotik-routerboard-mapl-2nd.sh (Rezept-Entwurf, nicht gebaut): trägt das Gerät in Gluon ein; `initramfs-kernel.bin`; Netboot (BOOTP/DHCP + TFTP); 64 MB RAM knapp |
| MikroTik RouterBOARD wAP G-5HacT2HnD (wAP AC) | `mikrotik-routerboard-wap-g-5hact2hnd` | ath79-mikrotik | K1 | devices/mikrotik-routerboard-wap-g-5hact2hnd.sh (Rezept-Entwurf, nicht gebaut): trägt das Gerät in Gluon ein; `initramfs-kernel.bin`; Netboot (BOOTP/DHCP + TFTP); 64 MB RAM mit ath10k am knappsten |
| MikroTik RouterBOARD wAPR-2nD (wAP R) | `mikrotik-routerboard-wapr-2nd` | ath79-mikrotik | K1 | devices/mikrotik-routerboard-wapr-2nd.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin`; Netboot (BOOTP/DHCP + TFTP); 64 MB RAM knapp |
| Aerohive HiveAP 121 | `aerohive-hiveap-121` | ath79-nand | K4 | devices/aerohive-hiveap-121.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (lzma) per U-Boot-TFTP; Gluon-factory per `nand write` ist der einfachere Weg |
| ZTE MF281 (broken) | `zte-mf281` | ath79-nand | K4 | devices/zte-mf281.sh (Rezept-Entwurf, nicht gebaut): baut das Gluon-"broken"-Gerät gezielt; `initramfs-kernel.bin` als `speedbox-2.bin` per U-Boot-TFTP; Vorbereitung vor dem sysupgrade fehlt der RAMpe noch (`ubiformat`, nicht durch den Commit gedeckt) |
| ZTE MF286R (broken) | `zte-mf286r` | ath79-nand | K1 | devices/zte-mf286r.sh (Rezept-Entwurf, nicht gebaut): trägt das Gerät in Gluon ein; `initramfs-kernel.bin` per `nandwrite` nach dem Exploit (Weg nur für die MF286A belegt) |
| Aruba AP-303 | `aruba-ap-303` | ipq40xx-generic | K4 | devices/aruba-ap-303.sh (Rezept-Entwurf, nicht gebaut): `-initramfs-uImage.itb` als `ipq40xx.ari` per APBoot-TFTP; Vorbereitung vor dem sysupgrade fehlt der RAMpe-Seite noch (`ubiformat`) |
| Aruba AP-303H | `aruba-ap-303h` | ipq40xx-generic | K4 | devices/aruba-ap-303h.sh (Rezept-Entwurf, nicht gebaut): wie AP-303; Vorbereitung vor dem sysupgrade fehlt der RAMpe-Seite noch (`ubiformat`) |
| Aruba AP-365 | `aruba-ap-365` | ipq40xx-generic | K4 | devices/aruba-ap-365.sh (Rezept-Entwurf, nicht gebaut): wie AP-303; Vorbereitung vor dem sysupgrade fehlt der RAMpe-Seite noch (`ubiformat`) |
| Aruba Instant On AP11 (Alias von aruba-ap-303) | `aruba-instant-on-ap11` | ipq40xx-generic | K5 | Alias: Image aus devices/aruba-ap-303.sh; apboot gesperrt (K5) |
| Aruba Instant On AP11D (Alias von aruba-ap-303h) | `aruba-instant-on-ap11d` | ipq40xx-generic | K4 | Alias: Image aus devices/aruba-ap-303h.sh; ob apboot gesperrt ist wie beim AP11: offen |
| Aruba Instant On AP17 (Alias von aruba-ap-365) | `aruba-instant-on-ap17` | ipq40xx-generic | K4 | Alias: Image aus devices/aruba-ap-365.sh; ob apboot gesperrt ist wie beim AP11: offen |
| ASUS Lyra MAP-AC2200 | `asus-lyra-map-ac2200` | ipq40xx-generic | K1 | devices/asus-lyra-map-ac2200.sh (Rezept-Entwurf, nicht gebaut): `-initramfs-uImage.itb` per SSH `mtd-write -d linux` |
| AVM FRITZ!Box 7520 (Alias von avm-fritz-box-7530) | `avm-fritz-box-7520` | ipq40xx-generic | K2 | Alias: Image aus devices/avm-fritz-box-7530.sh (dort auch `uboot-fritz7520.bin`); TFTP-Dateiname für die 7520: offen |
| AVM FRITZ!Box 7530 | `avm-fritz-box-7530` | ipq40xx-generic | K2 | devices/avm-fritz-box-7530.sh (Rezept-Entwurf, nicht gebaut): `-initramfs-uImage.itb` als `FRITZ7530.bin`, dazu `uboot-fritz7530.bin` für `eva_ramboot.py`; Vorbereitung vor dem sysupgrade fehlt der RAMpe-Seite noch (U-Boot schreiben, `ubirmvol`); 7520/7530 im System nicht unterscheidbar |
| AVM FRITZ!Repeater 1200 | `avm-fritz-repeater-1200` | ipq40xx-generic | K2 | devices/avm-fritz-repeater-1200.sh (Rezept-Entwurf, nicht gebaut): `-initramfs-uImage.itb` als `FRITZ1200.bin` + `uboot-fritz1200.bin`; Vorbereitung vor dem sysupgrade fehlt der RAMpe-Seite noch (U-Boot schreiben, `ubirmvol`) |
| AVM FRITZ!Repeater 3000 (Gluon: broken, drittes Radio ungetestet) | `avm-fritz-repeater-3000` | ipq40xx-generic | K2 | devices/avm-fritz-repeater-3000.sh (Rezept-Entwurf, nicht gebaut): trägt das Gerät in Gluon ein; `FRITZ3000.bin` + `uboot-fritz3000.bin`; Vorbereitung vor dem sysupgrade fehlt der RAMpe-Seite noch (U-Boot schreiben, `ubirmvol`) |
| Extreme Networks WS-AP3915i | `extreme-networks-ws-ap3915i` | ipq40xx-generic | K4 | devices/extreme-networks-ws-ap3915i.sh (Rezept-Entwurf, nicht gebaut): `-initramfs-uImage.itb` als `openwrt-3915.bin` per U-Boot-TFTP |
| ZTE MF289F | `zte-mf289f` | ipq40xx-generic | K4 | devices/zte-mf289f.sh (Rezept-Entwurf, nicht gebaut): baut das Gluon-"broken"-Gerät gezielt; `-initramfs-zImage.itb` per U-Boot-TFTP; Vorbereitung (`ubirmvol`) muss schon vor der Imageprüfung laufen, fehlt der RAMpe-Seite noch |
| MikroTik DISC Lite5 ac (Alias von mikrotik-sxtsq-5-ac-rbsxtsqg-5acd) | `mikrotik-discg-5acd` | ipq40xx-mikrotik | K1 | Alias: Image aus devices/mikrotik-sxtsq-5-ac-rbsxtsqg-5acd.sh; RAM des DISC nicht belegt |
| MikroTik hAP ac2 (RBD52G-5HacD2HnD) | `mikrotik-hap-ac2` | ipq40xx-mikrotik | K1 | devices/mikrotik-hap-ac2.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin`; Netboot (BOOTP/DHCP + TFTP); schaltet Gluons "factory" (= Community-initramfs ohne Config-Mode) ab |
| MikroTik SXTsq 5 ac (RBSXTsqG-5acD) | `mikrotik-sxtsq-5-ac-rbsxtsqg-5acd` | ipq40xx-mikrotik | K1 | devices/mikrotik-sxtsq-5-ac-rbsxtsqg-5acd.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin`; Netboot (BOOTP/DHCP + TFTP) |
| MikroTik wAP ac (RBwAPG-5HacD2HnD, ipq40xx) | `mikrotik-wap-ac` | ipq40xx-mikrotik | K1 | devices/mikrotik-wap-ac.sh (Rezept-Entwurf, nicht gebaut): trägt das Gerät in Gluon ein; `initramfs-kernel.bin`; Netboot (BOOTP/DHCP + TFTP) |
| Aruba AP-324/AP-325, Siemens Scalance W1750D | `aruba-ap-32x` | ipq806x-generic | K5 | devices/aruba-ap-32x.sh (Rezept-Entwurf, nicht gebaut): Backport aus gluon-patches-hardware (`RAMPE_HW_PATCHES`); `-initramfs.ari` per APBoot-TFTP; APBoot-Tausch und NAND-Umbau bleiben seriell |
| Extreme Networks AP3935i/e | `extreme-networks-ap3935` | ipq806x-generic | K4 | devices/extreme-networks-ap3935.sh (Rezept-Entwurf, nicht gebaut): `-initramfs-uImage` (ohne Endung) per U-Boot-TFTP |
| AVM FRITZ!Box 3390 | `avm-fritz-box-3390` | lantiq-xrx200 | K1 | devices/avm-fritz-box-3390.sh (Rezept-Entwurf, nicht gebaut): trägt das Gerät in Gluon ein; `initramfs-kernel.bin` (lzma) für `eva_ramboot.py` |
| AVM FRITZ!Box 7362 SL | `avm-fritz-box-7362-sl` | lantiq-xrx200 | K1 | devices/avm-fritz-box-7362-sl.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (lzma) für `eva_ramboot.py` |
| AVM FRITZ!Box 7412 | `avm-fritz-box-7412` | lantiq-xrx200 | K1 | devices/avm-fritz-box-7412.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (lzma) für `eva_ramboot.py`; Prüfung `linux_fs_start` vor dem sysupgrade fehlt der RAMpe noch |
| AVM FRITZ!Box 7430 | `avm-fritz-box-7430` | lantiq-xrx200 | K1 | devices/avm-fritz-box-7430.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (lzma) für `eva_ramboot.py`; Prüfung `linux_fs_start` vor dem sysupgrade fehlt der RAMpe noch |
| ASUS RT-AX52 | `asus-rt-ax52` | mediatek-filogic | K1 | devices/asus-rt-ax52.sh (Rezept-Entwurf, nicht gebaut): `-initramfs.trx` (OpenWrt-ARTIFACT) für die ASUS-Web-UI |
| ASUS RT-AX59U | `asus-rt-ax59u` | mediatek-filogic | K2 | devices/asus-rt-ax59u.sh (Rezept-Entwurf, nicht gebaut): trägt das Gerät in Gluon ein; nur `initramfs-kernel.bin` für den UART-Weg, für die Web-UI fehlt ein eigenes TRX |
| ASUS TUF-AX4200 | `asus-tuf-ax4200` | mediatek-filogic | K2 | devices/asus-tuf-ax4200.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` mit eingebettetem initramfs (`TARGET_ROOTFS_INITRAMFS_SEPARATE` aus) für SSH `mtd-write` oder UART + TFTP; eigener Bau-Lauf |
| ASUS TUF-AX6000 | `asus-tuf-ax6000` | mediatek-filogic | K2 | devices/asus-tuf-ax6000.sh (Rezept-Entwurf, nicht gebaut): wie TUF-AX4200; eigener Bau-Lauf |
| Cudy TR3000 v1 (128 MB Flash) | `cudy-tr3000-v1` | mediatek-filogic | K4 | devices/cudy-tr3000-v1.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` per U-Boot-TFTP |
| D-Link AQUILA PRO AI M30 A1 | `d-link-aquila-pro-ai-m30-a1` | mediatek-filogic | K1 | devices/d-link-aquila-pro-ai-m30-a1.sh: `-recovery.bin` (D-Link-Header) für die D-Link-Recovery; gebaut, Inhalt geprüft, Hardware-Test offen |
| D-Link AQUILA PRO AI M60 A1 | `d-link-aquila-pro-ai-m60-a1` | mediatek-filogic | K1 | devices/d-link-aquila-pro-ai-m60-a1.sh (Rezept-Entwurf, nicht gebaut): `-recovery.bin` (D-Link-Header) für die D-Link-Recovery |
| Mercusys MR80X v3 | `mercusys-mr80x-v3` | mediatek-filogic | K4 | devices/mercusys-mr80x-v3.sh (Rezept-Entwurf, nicht gebaut): trägt das Gerät in Gluon ein (`ensure_device`); `initramfs-kernel.bin` per UART + TFTP |
| Mercusys MR90X v1 | `mercusys-mr90x-v1` | mediatek-filogic | K2 | devices/mercusys-mr90x-v1.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` per `ubiupdatevol` aus der Stock-Shell |
| Xiaomi Mi Router AX3000T | `xiaomi-mi-router-ax3000t` | mediatek-filogic | K2 | devices/xiaomi-mi-router-ax3000t.sh (Rezept-Entwurf, nicht gebaut): `-initramfs-factory.ubi` (OpenWrt-ARTIFACT); Exploit bleibt |
| Enterasys WS-AP3715i | `enterasys-ws-ap3715i` | mpc85xx-p1010 | K4 | devices/enterasys-ws-ap3715i.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (lzma) als `ap3715.bin` per U-Boot-TFTP; entpackt über 11 MB droht Überlappung |
| Sophos RED 15w Rev. 1 | `sophos-red-15w-rev.1` | mpc85xx-p1010 | K4 | devices/sophos-red-15w-rev.1.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (FIT) als `kernel.bin` per U-Boot-TFTP; Vorbereitung vor dem sysupgrade fehlt der RAMpe noch (`ubiformat`) |
| Aerohive HiveAP 330 | `aerohive-hiveap-330` | mpc85xx-p1020 | K4 | devices/aerohive-hiveap-330.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` per U-Boot-TFTP; der U-Boot-Patch bleibt Handarbeit (Entwurf in docs/ENTWURF-VORBEREITUNG.md) |
| Enterasys WS-AP3710i | `enterasys-ws-ap3710i` | mpc85xx-p1020 | K4 | devices/enterasys-ws-ap3710i.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` als `01C8A8C0.img` per U-Boot-TFTP; `bootcmd` bleibt seriell |
| Extreme Networks WS-AP3825i | `extreme-networks-ws-ap3825i` | mpc85xx-p1020 | K4 | devices/extreme-networks-ws-ap3825i.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (FIT) per U-Boot-TFTP; `bootcmd` bleibt seriell |
| OCEDO Panda | `ocedo-panda` | mpc85xx-p1020 | K1 | devices/ocedo-panda.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` als `panda-uimage-factory` + DTB als `panda.fdt`; Vorbereitung vor dem sysupgrade fehlt der RAMpe noch (`ubirmvol`, `fw_setenv`) |
| NETGEAR WAX218 | `netgear-wax218` | qualcommax-ipq807x | K1 | devices/netgear-wax218.sh (Rezept-Entwurf, nicht gebaut): trägt das Gerät in Gluon ein; `-web-ui-factory.fit` (OpenWrt-ARTIFACT) für die Web-UI |
| TP-Link EAP620 HD v1 | `tp-link-eap620-hd-v1` | qualcommax-ipq807x | K4 | devices/tp-link-eap620-hd-v1.sh (Rezept-Entwurf, nicht gebaut): Backport aus gluon-patches-hardware (`RAMPE_HW_PATCHES`); `-initramfs-uImage.itb` per U-Boot-TFTP |
| Xiaomi AX3600 | `xiaomi-ax3600` | qualcommax-ipq807x | K2 | devices/xiaomi-ax3600.sh (Rezept-Entwurf, nicht gebaut): `-initramfs-factory.ubi` (OpenWrt-ARTIFACT); Exploit bleibt |
| ASUS RT-AX53U (RT-AX1800U) | `asus-rt-ax53u` | ramips-mt7621 | K1 | devices/asus-rt-ax53u.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` per ASUS-Rescue (TFTP put) |
| Genexis/Inteno Pulse EX400 | `genexis-pulse-ex400` | ramips-mt7621 | K1 | devices/genexis-pulse-ex400.sh (Rezept-Entwurf, nicht gebaut): `-factory.bin` (initramfs in UBIFS-bootfs, Inteno-Kopf); bootfs höchstens etwa 11.6 MiB |
| MikroTik hEX RB750Gr3 (Alias mikrotik-routerboard-hex-v3) | `mikrotik-routerboard-750gr3` | ramips-mt7621 | K1 | devices/mikrotik-routerboard-750gr3.sh (Rezept-Entwurf, nicht gebaut): trägt das Gerät in Gluon ein; `initramfs-kernel.bin` (ELF); Netboot (BOOTP/DHCP + TFTP) |
| ZyXEL WSM20 (Multy M1) | `zyxel-wsm20` | ramips-mt7621 | K1 | devices/zyxel-wsm20.sh (Rezept-Entwurf, nicht gebaut): `initramfs-kernel.bin` (znet-Header schon drin) für die versteckte Upgrade-Seite |
| x86 (x86-64) | `x86-64` | x86-64 | K0 | devices/x86-64.sh: Testgerät, in QEMU Ende-zu-Ende geprüft |

<!-- END erzeugt:rezepte -->

### Bau-Läufe

Ein `build.sh`-Lauf je Target. Die TUF-Geräte brauchen einen eigenen Lauf, weil
ihr Schalter `TARGET_ROOTFS_INITRAMFS_SEPARATE` das ganze Target betrifft (das
Rezept bricht sonst ab). AP-32x und EAP620 HD brauchen die OpenWrt-Backports
aus [gluon-patches-hardware](https://github.com/Neanderfunk/gluon-patches-hardware)
(Branch v2025.1.x) über `RAMPE_HW_PATCHES`.

```sh
contrib/docker/run.sh ./build.sh mediatek-filogic d-link-aquila-pro-ai-m30-a1 d-link-aquila-pro-ai-m60-a1 mercusys-mr90x-v1 mercusys-mr80x-v3 asus-rt-ax52 asus-rt-ax59u xiaomi-mi-router-ax3000t cudy-tr3000-v1
contrib/docker/run.sh ./build.sh mediatek-filogic asus-tuf-ax4200 asus-tuf-ax6000
contrib/docker/run.sh ./build.sh ramips-mt7621 asus-rt-ax53u genexis-pulse-ex400 zyxel-wsm20
contrib/docker/run.sh ./build.sh ipq40xx-generic aruba-ap-303 aruba-ap-303h aruba-ap-365 asus-lyra-map-ac2200 zte-mf289f extreme-networks-ws-ap3915i avm-fritz-box-7530 avm-fritz-repeater-1200 avm-fritz-repeater-3000
RAMPE_HW_PATCHES=<pfad>/gluon-patches-hardware contrib/docker/run.sh ./build.sh qualcommax-ipq807x netgear-wax218 xiaomi-ax3600 tp-link-eap620-hd-v1
RAMPE_HW_PATCHES=<pfad>/gluon-patches-hardware contrib/docker/run.sh ./build.sh ipq806x-generic extreme-networks-ap3935 aruba-ap-32x
contrib/docker/run.sh ./build.sh ipq40xx-mikrotik mikrotik-hap-ac2 mikrotik-wap-ac mikrotik-sxtsq-5-ac-rbsxtsqg-5acd
contrib/docker/run.sh ./build.sh ath79-mikrotik mikrotik-routerboard-951ui-2nd-hap mikrotik-routerboard-mapl-2nd mikrotik-routerboard-wapr-2nd mikrotik-routerboard-wap-g-5hact2hnd
contrib/docker/run.sh ./build.sh ramips-mt7621 mikrotik-routerboard-750gr3
contrib/docker/run.sh ./build.sh lantiq-xrx200 avm-fritz-box-3390 avm-fritz-box-7362-sl avm-fritz-box-7412 avm-fritz-box-7430
contrib/docker/run.sh ./build.sh ath79-generic ocedo-koala ocedo-raccoon enterasys-ws-ap3705i extreme-networks-ws-ap3805i siemens-ws-ap3610 sophos-ap15 tp-link-archer-d50-v1 d-link-dir-505
contrib/docker/run.sh ./build.sh ath79-nand zte-mf286r zte-mf281 aerohive-hiveap-121
contrib/docker/run.sh ./build.sh mpc85xx-p1020 ocedo-panda enterasys-ws-ap3710i extreme-networks-ws-ap3825i aerohive-hiveap-330
contrib/docker/run.sh ./build.sh mpc85xx-p1010 enterasys-ws-ap3715i sophos-red-15w-rev.1
```

`ramips-mt7621` lässt sich auch in einem Lauf mit RT-AX53U, EX400 und WSM20
bauen. Alias-Namen (DISC Lite5 ac zu SXTsq 5 ac) nicht als Gerät angeben,
Gluon bricht sonst mit "unknown devices" ab.

### Offen bei den Rezepten

- **Vorbereitung vor dem sysupgrade:** Aruba AP-303/303H/365 (`ubiformat`),
  AVM 7530/Repeater 1200/3000 (OpenWrt-U-Boot schreiben, `ubirmvol`) und ZTE
  MF289F (`ubirmvol`, schon vor der Imageprüfung) bauen, aber die RAMpe-Seite
  führt den Schritt noch nicht aus. Entwurf für einen Hook im Controller:
  [ENTWURF-VORBEREITUNG.md](ENTWURF-VORBEREITUNG.md) (Skripte je
  `board_name`, synchron vor `sysupgrade`), noch nicht übernommen. 7520 und 7530 teilen `board_name` und Image, brauchen aber
  verschiedene U-Boots: ohne sichere Erkennung kein automatisches Schreiben.
- **Vorbereitung, Gruppe B:** OCEDO Koala/Raccoon (`fw_setenv`), OCEDO Panda
  (`ubirmvol`, `fw_setenv`), Sophos RED 15w und ZTE MF281 (`ubiformat`),
  AVM 7412/7430 (`linux_fs_start` prüfen). Zweiter Entwurf über
  `platform_pre_upgrade`, ebenfalls in ENTWURF-VORBEREITUNG.md.
- **ath79 mit lzma:** Die ath79-Rezepte packen das initramfs mit lzma statt
  unkomprimiert wie OpenWrt, weil entpackt rund 23.7 MB über die Ladeadresse
  hinausragen könnten [abgeleitet]. Der erste Hardware-Test entscheidet.
- **64 MB RAM:** die vier ath79-MikroTik, Archer D50, DIR-505; knapp, aber
  voraussichtlich ausreichend [abgeleitet]. Beim ersten Test `free` nach dem
  Upload notieren.
- **ARTIFACTS:** `extra_images` sammelt OpenWrt-ARTIFACTS laut Code ein
  (`copy_output.lua` baut den Quellnamen aus Suffix und Endung), im Bau bestätigt
  ist das noch nicht (RT-AX52 `.trx`, AX3000T/AX3600 `.ubi`, WAX218 `.fit`).
- **Größengrenzen:** RouterBOOT-Netboot, Ladeadressen bei OCEDO, Siemens,
  DIR-505 und WS-AP3715i (entpackt über 11 MB), EX400 (bootfs höchstens etwa 11.6 MiB), WSM20 (liest der
  Stock-U-Boot mehr als 8 MiB?), TUF/Lyra (Volume `linux`), WAX218
  (mtd12/mtd14), AP3935 (Ladeadresse bei größerem initramfs).
- **RT-AX59U:** über die Web-UI nur mit einem fremden "transit TRX"; ein eigenes
  TRX bräuchte einen Eingriff in OpenWrt, ob die Stock-UI es nimmt, ist offen.

## Kandidaten (alle ungeprüft)

Abgeglichen mit dem Inventar aller Gluon-2025.1-Geräte
([ERSTINSTALLATION-2025.1.md](ERSTINSTALLATION-2025.1.md), Stand 10.10.2026; dort je Gerät Weg,
Übertragung, Konsole, Links und Quelle). Nichts davon auf Hardware getestet.

### Passt (Ramboot ohne Öffnen, danach Upload)

| Gerät | Target | Hersteller-Weg | Format/Bedingung | RAM |
|---|---|---|---|---|
| D-Link M60 A1 | mediatek-filogic | D-Link-Recovery 192.168.200.1 | D-Link-Header wie M30; Gluons eigenes `-recovery.bin` vermutlich mit dem Config-Mode-Fehler | 512 MB |
| ASUS RT-AX52 | mediatek-filogic | Web-UI 192.168.50.1 | `initramfs.trx` (OpenWrt-ARTIFACT) einsammeln | 256 MB |
| ASUS RT-AX53U | ramips-mt7621 | ASUS-Rescue, TFTP-Server im Gerät 192.168.1.1 | initramfs | 256 MB |
| Genexis Pulse EX400 | ramips-mt7621 | Web-UI / Recovery 192.168.1.1 | OpenWrt-factory ist initramfs mit Inteno-Header; Gluon setzt `factory = false` nur wegen des initramfs-Schalters. Bester neuer Kandidat | 256 MB |
| Zyxel WSM20 | ramips-mt7621 | versteckte Upgrade-Seite | initramfs mit znet-Header; Zyxel-Cloud-Registrierung nötig | 256 MB |
| MikroTik hAP ac2, wAP ac, SXTsq 5 ac, DISC | ipq40xx-mikrotik | Netboot (eigener BOOTP/DHCP- und TFTP-Server) | initramfs; Gluons "factory" ist selbst ein initramfs ohne Config-Mode, daher mitbauen | 128-256 MB |
| MikroTik hAP (951Ui-2nD), mAP lite, wAP, wAP G-5HacT2HnD | ath79-mikrotik | Netboot | wie oben | 64 MB, knapp |
| MikroTik RB750Gr3 | ramips-mt7621 | Netboot | ELF-initramfs | 256 MB |
| AVM FRITZ!Box 3390, 7362 SL, 7412, 7430 | lantiq-xrx200 | `eva_ramboot.py` (FTP 192.168.178.1) | initramfs lzma-komprimiert | 128 MB |
| Netgear WAX218 | qualcommax-ipq807x | Web-UI | `web-ui-factory.fit` (ARTIFACT); Gluon baut für qualcommax kein initramfs | 512 MB |
| OCEDO Koala, Raccoon | ath79-generic | Reset beim Einschalten, Gerät holt per TFTP von 192.168.100.8 | zusätzlich `fw_setenv bootcmd run bootcmd_1` nötig | 128 MB |
| ZTE MF286R | ath79-nand | Exploit im Web-UI, initramfs per `nandwrite` | Weg für die MF286A belegt | 128 MB |
| ASUS Lyra (MAP-AC2200) | ipq40xx-generic | SSH, initramfs per `mtd-write` | | 256 MB |

### Teilweise (Installer ersetzt nur das Zwischenimage)

- **Seriell + TFTP, Konsole außen (Gehäuse bleibt zu):** Enterasys
  WS-AP3705i, WS-AP3710i, WS-AP3715i; Extreme WS-AP3825i, WS-AP3805i,
  WS-AP3915i, AP3935; Siemens WS-AP3610 (initramfs unkomprimiert); Aerohive
  HiveAP 330 (RJ45 mit RS232-Pegel). Der Installer ersetzt "scp + sysupgrade",
  `bootcmd`/`saveenv` bleiben seriell.
- **Seriell, Gehäuse auf:** Sophos AP15, Archer D50, DIR-505, Aerohive
  HiveAP 121, ZTE MF281, Cudy TR3000 v1, TP-Link EAP620 HD.
- **Vorbereitender Schritt fehlt dem Installer:** Aruba AP-303/303H/365/AP11D/AP17
  und Instant On AP11 (`ubiformat`; AP11 zusätzlich apboot-Entsperrung, K5);
  AVM 7520/7530/Repeater 1200/3000 (U-Boot schreiben, `ubirmvol`); ZTE MF289F
  (`ubirmvol`); OCEDO Panda und Sophos RED 15w (`ubirmvol`/`ubiformat`,
  `fw_setenv`). Ein Installer bräuchte je Gerät ein Vorbereitungsskript.
- **Exploit bleibt:** Xiaomi AX3000T, AX3600 (`initramfs-factory.ubi`),
  Mercusys MR90X, ASUS TUF-AX4200/AX6000, ASUS RT-AX59U (kein `initramfs.trx`
  in OpenWrt).
- **Bootloader tauschen:** Aruba AP-32x (Format `.ari`).

### Nicht Kandidat

- **D-Link COVR-X1860:** Gluon baut factory und ein eigenes recovery (squashfs).
- **Ubiquiti EdgeRouter X / X-SFP:** Der 6.6-Kernel passt nicht in den
  3-MB-Kernel-Slot von EdgeOS, OpenWrt 24.10.8 baut kein factory.tar mehr.
  oszilloskops Ursprungsfall ist unter 2025.1 kein Fall für den Installer,
  dafür gibt es die ERX-Migration (router-werkstatt `docs/erx-migration-howto.md`).
- **Cudy:** Stock und Recovery prüfen Cudys Signatur; die Cudy-Zwischenfirmware
  ist schon der Zwischenschritt.
- **GL.iNet, Open-Mesh/Plasma Cloud, devolo, Sophos AP55/100, UniFi, Wavlink,
  AVM mit EVA-Image:** Der Hersteller- oder Bootloader-Weg nimmt das
  Gluon-Image direkt (Kategorie K1d im Inventar).
- **TP-Link mit `-tftp-recovery`/`-bootloader.bin` (mt76x8):** installiert
  Gluon direkt über die TFTP-Recovery.
- **Linksys E8450 (UBI), Xiaomi AX3000T im OpenWrt-U-Boot-Layout:**
  Bootloader-Tausch, das kann der Installer nicht.
- **Meraki MR33, Google WiFi:** Bootloader bzw. Signatur.

### Wahrscheinlich besser in Gluon zu lösen

Linksys MR8300, Netgear WNDR3700 v5, Archer C60 v1 und MikroTik mAP lite/wAP ac
haben `factory = false` ohne erkennbaren Grund, obwohl OpenWrt (teils) ein
brauchbares factory baut.

### Für jedes Rezept zu beachten

Gluon schaltet `TARGET_ROOTFS_INITRAMFS` nur für mediatek-filogic und
ipq40xx-mikrotik ein; ipq40xx-generic, ipq806x, qualcommax und mt7622 brauchen
`ensure_target_config`. Viele Hersteller-Wege wollen ein verpacktes initramfs
(ASUS-TRX, D-Link-Header, Netgear `web-ui-factory.fit`, Xiaomi
`initramfs-factory.ubi`, Aruba `.ari`, Inteno-Header), das OpenWrt als
IMAGES/ARTIFACTS baut. Gluons `extra_images` sammelt beides ein (laut Code,
für ARTIFACTS im Bau noch nicht bestätigt). Weitere Fallstricke: `packages` im
`device()` ersetzt die Standardliste (zusätzliche Pakete per
`ensure_site_packages`), Gluon-"broken"-Geräte brauchen `ensure_site_unbroken`,
und `copy_output.lua` entfernt eingesammelte Images aus `openwrt/bin/targets`.

## Ein Gerät ergänzen

1. OpenWrt-Wiki/Geräteseite: welches Image nimmt der Hersteller-Weg?
   Meist `…-initramfs-kernel.bin`, `…-squashfs-recovery.bin` oder ein
   `…-initramfs-factory.*`. Auf ein **initramfs** ist der Installer
   ausgelegt (`91_installer_initramfs`). Nimmt der Hersteller-Weg nur
   squashfs, ist es ohnehin ein Fall für ein normales Gluon-factory-Image.
2. `devices/<gluon-geraetename>.sh` anlegen (Name = erster Parameter von
   `device(...)` in `gluon/targets/<target>`):

   ```sh
   # <Gerät>: <Weg in einem Satz>
   ensure_target_config <target> TARGET_ROOTFS_INITRAMFS
   ensure_extra_image  <target> <gluon-geraet> -squashfs-recovery -recovery .bin
   ```

   `ensure_extra_image` nur, wenn Gluon das Hersteller-Image nicht ohnehin
   einsammelt. Gluon legt es unter `output/images/other/` ab, `build.sh`
   kopiert es nach `out/`.
3. `./build.sh <target> <gluon-geraet>` (bzw. per `contrib/docker/run.sh`).
4. Prüfen, bevor es an Hardware geht:
   - Das Image enthält ein initramfs mit `lib/preinit/91_installer_initramfs`
     (`binwalk`/`unsquashfs` bzw. cpio im Kernel).
   - Bei Hersteller-Headern (z.B. D-Link `DLK6E6110001`): Header wie beim
     OpenWrt-Image.
5. Hardware-Test: Installer einspielen → 192.168.1.1 zeigt die Upload-Seite →
   Community-sysupgrade hochladen → Router bootet in deren Config-Mode.
   Ergebnis in die Tabelle oben.
