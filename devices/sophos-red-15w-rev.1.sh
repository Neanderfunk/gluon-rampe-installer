# Sophos RED 15w Rev. 1 (mpc85xx-p1010, P1010, 128 MB RAM, 128 MB NAND)
#
# Weg: Konsole am "Console port" (Bauform im Commit nicht genannt), U-Boot
# anhalten, bootcmd setzen, RAMpe per TFTP laden:
#   setenv bootargs_owrt "setenv bootargs console=ttyS0,115200"
#   setenv bootcmd "run bootargs_owrt; nand read 0x1000000 0x300000 0x800000; bootm 0x1000000;"
#   saveenv
#   run bootargs_owrt; tftpboot 0x1000000 192.168.1.2:kernel.bin; bootm 0x1000000;
# TFTP-Server 192.168.1.2/24 an einem LAN-Port, Datei kernel.bin (= RAMpe).
# Vor dem sysupgrade laut Commit Schritt 7:
#   ubiformat /dev/mtd4 -y
# dann Community-sysupgrade ueber die Upload-Seite.
# Quelle: OpenWrt 97e4311fca73d064d17065e7844699aa777cb157 [geprueft].
# Vorbereitungsskript noetig: prepare.d/sophos,red-15w-rev1 (Vorschlag) sucht
# die mtd "ubi" (laut red-15w-rev1.dts mtd4: u-boot, u-boot-env,
# provisioning, kernel, ubi [geprueft]) und formatiert sie. nand.sh wuerde
# nur formatieren, wenn ubiattach scheitert; haengt dort ein Sophos-UBI an,
# fehlt sonst der Platz [abgeleitet aus nand_attach_ubi].
# Danach: platform.sh -> nand_do_upgrade [geprueft: mpc85xx platform.sh];
# Kernel in die raw-mtd "kernel" (0x300000, 8 MB), passt zu
# "nand read 0x1000000 0x300000 0x800000" im bootcmd [abgeleitet].
# Image: ...-sophos_red-15w-rev1-initramfs-kernel.bin, KERNEL = kernel-bin |
# gzip | fit gzip <dtb> -> FIT [geprueft: p1010.mk]. TFTP an 0x1000000;
# Kernel-Ladeadresse mpc85xx-Default 0x0 [geprueft: mpc85xx/image/Makefile].
# Gluon-Geraetename enthaelt einen Punkt (sophos-red-15w-rev.1); build.sh
# reicht ihn unveraendert an find/grep weiter, der Punkt passt dort auch auf
# sich selbst [abgeleitet].
# RAM 128 MB: unkritisch. Werte: OpenWrt-initramfs 8652 KB [geprueft].
# Ungetestet.
ensure_target_config mpc85xx-p1010 TARGET_ROOTFS_INITRAMFS
