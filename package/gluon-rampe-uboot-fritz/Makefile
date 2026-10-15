# Gluon-RAMpe: OpenWrt-U-Boot fuer AVM FRITZ!Box 7520/7530 und FRITZ!Repeater
# 1200/3000 als Datei im RAMpe-Image, fuer /lib/gluon-rampe/prepare/.
#
# Die U-Boot-Pakete selbst (u-boot-fritzXXXX aus package/boot/uboot-fritz4040)
# lassen sich in Gluon nicht je Geraet waehlen: OpenWrt fuehrt sie nicht als
# Modul ("symbol value 'm' invalid for PACKAGE_u-boot-fritz7530" im Bau-Log
# vom 15.10.2026), also landete die .bin nie im Image. Dieses Paket nimmt die
# Datei aus $(STAGING_DIR_IMAGE), wo Build/InstallDev von uboot-fritz4040 sie
# ablegt, und ist ein normales, je Geraet waehlbares Paket.
#
# build.sh kopiert das Verzeichnis vor "make update" nach gluon/package/.
#
# SPDX-License-Identifier: BSD-3-Clause

include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-rampe-uboot-fritz
PKG_RELEASE:=1
PKG_BUILD_DEPENDS:=uboot-fritz4040

include $(INCLUDE_DIR)/package.mk

define Package/gluon-rampe-uboot-fritz/Default
  SECTION:=gluon
  CATEGORY:=Gluon
  DEPENDS:=@TARGET_ipq40xx
endef

define Package/gluon-rampe-uboot-fritz7530
  $(Package/gluon-rampe-uboot-fritz/Default)
  TITLE:=OpenWrt-U-Boot fuer FRITZ!Box 7530 und 7520 (Gluon-RAMpe)
endef

define Package/gluon-rampe-uboot-fritz1200
  $(Package/gluon-rampe-uboot-fritz/Default)
  TITLE:=OpenWrt-U-Boot fuer FRITZ!Repeater 1200 (Gluon-RAMpe)
endef

define Package/gluon-rampe-uboot-fritz3000
  $(Package/gluon-rampe-uboot-fritz/Default)
  TITLE:=OpenWrt-U-Boot fuer FRITZ!Repeater 3000 (Gluon-RAMpe)
endef

define Build/Compile
endef

define Package/gluon-rampe-uboot-fritz7530/install
	$(INSTALL_DIR) $(1)/lib/gluon-rampe/uboot
	$(INSTALL_DATA) $(STAGING_DIR_IMAGE)/uboot-fritz7530.bin $(1)/lib/gluon-rampe/uboot/
	$(INSTALL_DATA) $(STAGING_DIR_IMAGE)/uboot-fritz7520.bin $(1)/lib/gluon-rampe/uboot/
endef

define Package/gluon-rampe-uboot-fritz1200/install
	$(INSTALL_DIR) $(1)/lib/gluon-rampe/uboot
	$(INSTALL_DATA) $(STAGING_DIR_IMAGE)/uboot-fritz1200.bin $(1)/lib/gluon-rampe/uboot/
endef

define Package/gluon-rampe-uboot-fritz3000/install
	$(INSTALL_DIR) $(1)/lib/gluon-rampe/uboot
	$(INSTALL_DATA) $(STAGING_DIR_IMAGE)/uboot-fritz3000.bin $(1)/lib/gluon-rampe/uboot/
endef

$(eval $(call BuildPackage,gluon-rampe-uboot-fritz7530))
$(eval $(call BuildPackage,gluon-rampe-uboot-fritz1200))
$(eval $(call BuildPackage,gluon-rampe-uboot-fritz3000))
