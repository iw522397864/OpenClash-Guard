include $(TOPDIR)/rules.mk

PKG_NAME:=openclash-guard
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKGARCH:=all
PKG_BUILD_DIR := $(BUILD_DIR)/dummy

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
	
	# ✅ [新增] 安装 init.d 启动脚本（用于 watchdog 服务控制）
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/openclash_watchdog $(1)/etc/init.d/openclash_watchdog
endef

define Package/openclash-guard/postinst
	echo "Running postinst..."
	
	# ✅ [原有] 备份 rc.local
	if [ -f /etc/rc.local ] && [ ! -f /etc/rc.local.bak ]; then
		cp /etc/rc.local /etc/rc.local.bak
	fi
	
	# ✅ [新增] 确保 rc.local 有 shebang
	sed -i '1s|^|#!/bin/sh\n|' /etc/rc.local
	
	# ✅ [原有] 注入启动脚本
	grep -q "openclash_launcher.sh" /etc/rc.local || sed -i '/^exit 0/i /root/openclash_launcher.sh &' /etc/rc.local
	chmod +x /etc/rc.local
	
	# ✅ 延迟重命名 watchdog 脚本，避免冲突
	(
	sleep 5
	if [ -f /usr/share/openclash/openclash_watchdog.sh ]; then
		mv /usr/share/openclash/openclash_watchdog.sh /usr/share/openclash/openclash_watchdog.sh.bak
		echo "$(date '+%Y-%m-%d %H:%M:%S') Renamed original watchdog to .bak" >> /tmp/openclash_guard_postinst.log
	else
		echo "$(date '+%Y-%m-%d %H:%M:%S') No original watchdog found to rename" >> /tmp/openclash_guard_postinst.log
	fi
	) &

	# 初始化状态文件
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

define Build/Compile
	# nothing to compile
endef

$(eval $(call BuildPackage,openclash-guard))