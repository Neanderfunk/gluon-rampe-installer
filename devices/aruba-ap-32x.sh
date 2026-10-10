# Aruba AP-324/AP-325, Siemens Scalance W1750D (ipq806x-generic, IPQ8068, 512 MB RAM)
#
# TEILWEISE (K5), und NUR MIT BACKPORT. Weg laut OpenWrt
# d2a75029a5f8e54e1fd2f252f73b9a430a030116 (25.12: 65f01eb3576f69233e8b6c67d85ffd38fde47a1a),
# Commit-Text im Neanderfunk-Backport gluon-patches-hardware v2025.1.x
# ab19bf1b46d34315a92f61974dd37f8a9ede9604, devices/aruba-ap-32x/0004-...patch
# [geprueft]. Alles seriell (RJ45, Cisco-Pinout):
#  1. Stock-APBoot (9600): gepatchtes APBoot laden und schreiben
#       setenv serverip <TFTP>; setenv autostart n
#       netget 44000000 openwrt-ipq806x-generic-aruba_ap-32x-apboot.mbn
#       sf probe 0; sf erase 220000 100000; sf write 44000000 220000 100000; reset
#  2. Gepatchtes APBoot (115200): NAND loeschen und neu aufteilen
#       nand device 0; nand erase.chip; reset
#       ubi part ubifs; ubi remove ubifs; ubi create ubifs 1; ubi create rootfs_data
#  3. setenv serverip <TFTP>; tftpboot <rampe>-initramfs.ari
#  4. RAMpe unter http://192.168.1.1, Community-sysupgrade.
# Die RAMpe ersetzt nur Schritt 3/4. apboot.mbn baut sie nicht (optionales
# Paket 0005 liegt im Backport unter optional/ und wird nicht abgelegt);
# Download nur als OpenWrt-Snapshot [Inventar, geprueft].
# Den NAND-Umbau (2.) in ein Vorbereitungsskript zu ziehen, liesse sich mit
# ubiformat/ubimkvol nachbauen, steht aber so in keiner Quelle: nicht
# vorgeschlagen, offen.
#
# Backport: OpenWrt 24.10 kennt das Profil nicht. Vor "make update" die
# Patches 0001-0004 aus gluon-patches-hardware devices/aruba-ap-32x unter
# patches/openwrt ablegen (Praefix 5100-hw-aruba-ap-32x, wie dort openwrt.sh).
# Achtung: 0001/0002 aendern nand.sh fuer alle NAND-Geraete (README des
# Backports) [geprueft]. Gluon-Eintrag per ensure_device mit
# packages = QCA9980_PACKAGES wie im Backport (targets-ipq806x-generic-aruba.patch).
#
# Image: rohes initramfs mit Aruba-Kopf: KERNEL_SUFFIX := .ari, KERNEL =
# kernel-bin | append-dtb | uImage none | apboot-addfwhdr Octomore,
# KERNEL_INITRAMFS = $(KERNEL) -> openwrt-ipq806x-generic-aruba_ap-32x-initramfs.ari
# [geprueft: Patch 0004 und ipq806x image/Makefile]. Kein ARTIFACT; als
# extra_images {'-initramfs', '-initramfs', '.ari'}.
# Target-Configs: TARGET_ROOTFS_INITRAMFS. KERNEL_SIZE 30720k (sysupgrade).
# RAM 512 MB [Commit]. QCA9990: kein 802.11s.
# Vorbereitungsskript: keins (Umbau laeuft im APBoot).
# Ungetestet. Braucht ensure_openwrt_backport, ensure_device mit Optionen
# und RAMPE_HW_PATCHES (Vorschlag).
ensure_openwrt_backport aruba-ap-32x 5100-hw-aruba-ap-32x
ensure_device ipq806x-generic aruba-ap-32x aruba_ap-32x "packages = QCA9980_PACKAGES,"
ensure_target_config ipq806x-generic TARGET_ROOTFS_INITRAMFS
ensure_extra_image ipq806x-generic aruba-ap-32x -initramfs -initramfs .ari
