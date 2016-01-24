#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=c-icap
PKG_REV:=HEAD
PKG_VERSION:=r$(PKG_REV)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://svn.code.sf.net/p/c-icap/code/c-icap-server/trunk/c-icap
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=svn

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libicapapi/Default
  URL:=http://c-icap.sourceforge.net/
  DEPENDS:=+libc +libpcre +libpthread +librt +zlib +libbz2
  MAINTAINER:=Jorge Vargas <jorge.vargas@saint-tech.com>
endef

define Package/libicapapi
  $(call Package/libicapapi/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A library to simplify ICAP programming
endef

define Package/libicapapi/description
	The goal of libicapapi is to simplify ICAP programming.
endef

define Package/$(PKG_NAME)
  $(call Package/libicapapi/Default)
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  DEPENDS+=+libicapapi
  TITLE:=An ICAP server
endef

define Package/$(PKG_NAME)/description
	c-icap is an implementation of an ICAP server. It can be
	used with HTTP proxies that support the ICAP protocol to
	implement content adaptation and filtering services.
endef

CONFIGURE_VARS += \
	ac_cv_10031b_ipc_sem=yes \
	ac_cv_fcntl=yes

define Build/Prepare
	$(call Build/Prepare/Default)
	echo $(PKG_VERSION) > $(PKG_BUILD_DIR)/VERSION.m4
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/lib $(1)/usr/include
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/c-icap-config $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/c-icap-libicapapi-config $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/c_icap $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libicapapi.{la,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/c_icap $(1)/usr/include
	$(SED) 's,^INCDIR=/usr/include,INCDIR=$(STAGING_DIR)/usr/include,g' $(1)/usr/bin/c-icap-config
	$(SED) 's,^INCDIR2=/usr/include/c_icap,INCDIR2=$(STAGING_DIR)/usr/include/c_icap,g' $(1)/usr/bin/c-icap-config
	$(SED) 's,^INCDIR=/usr/include,INCDIR=$(STAGING_DIR)/usr/include,g' $(1)/usr/bin/c-icap-libicapapi-config
	$(SED) 's,^INCDIR2=/usr/include/c_icap,INCDIR2=$(STAGING_DIR)/usr/include/c_icap,g' $(1)/usr/bin/c-icap-libicapapi-config
	ln -sf $(STAGING_DIR)/usr/bin/c-icap-config $(2)/bin/
	ln -sf $(STAGING_DIR)/usr/bin/c-icap-libicapapi-config $(2)/bin/
endef

define Package/libicapapi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libicapapi.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/c_icap
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/c_icap/* $(1)/usr/lib/c_icap
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	#$(INSTALL_DIR) $(1)/etc/config
	#$(INSTALL_DATA) $(PKG_BUILD_DIR)/c-icap.conf $(1)/etc/config
endef

$(eval $(call BuildPackage,libicapapi))
$(eval $(call BuildPackage,$(PKG_NAME)))
