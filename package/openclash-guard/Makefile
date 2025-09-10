include $(TOPDIR)/rules.mk

PKG_NAME:=openclash-guard
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/openclash-guard
	SECTION:=net
	CATEGORY:=Network
	TITLE:=OpenClash watchdog system using rc.local startup method with LuCI control
	MAINTAINER:=ming
	DEPENDS:=+bash
endef

define Package/openclash-guard/install
	# 安装脚本到 /root
	$(INSTALL_DIR) $(1)/root
	$(INSTALL_BIN) ./files/root/openclash_watchdog.sh $(1)/root/openclash_watchdog.sh
	$(INSTALL_BIN) ./files/root/openclash_launcher.sh $(1)/root/openclash_launcher.sh

	# 安装 LuCI 控制器
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/openclash_custom.lua $(1)/usr/lib/lua/luci/controller/openclash_custom.lua
endef

define Package/openclash-guard/postinst
	echo "Running postinst..."
	if [ -f /etc/rc.local ] && [ ! -f /etc/rc.local.bak ]; then
		cp /etc/rc.local /etc/rc.local.bak
	fi
	grep -q "openclash_launcher.sh" /etc/rc.local || sed -i '/^exit 0/i /root/openclash_launcher.sh &' /etc/rc.local
	chmod +x /etc/rc.local
	echo "on" > /tmp/openclash_status
	rm -f /tmp/openclash_manual_stop
endef

define Package/openclash-guard/prerm
	pkill -f openclash_watchdog.sh 2>/dev/null
	rm -f /tmp/openclash_watchdog.pid
endef

define Package/openclash-guard/postrm
	rm -f /root/openclash_watchdog.sh
	rm -f /root/openclash_launcher.sh
	[ -f /etc/rc.local.bak ] && mv /etc/rc.local.bak /etc/rc.local
	rm -f /usr/lib/lua/luci/controller/openclash_custom.lua
	rm -f /tmp/openclash_status
	rm -f /tmp/openclash_manual_stop
	rm -f /tmp/openclash_watchdog_debug.log
endef

$(eval $(call BuildPackage,openclash-guard))