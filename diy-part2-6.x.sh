#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# 修改uhttpd配置文件，启用nginx
# sed -i "/.*uhttpd.*/d" .config
# sed -i '/.*\/etc\/init.d.*/d' package/network/services/uhttpd/Makefile
# sed -i '/.*.\/files\/uhttpd.init.*/d' package/network/services/uhttpd/Makefile
sed -i "s/:80/:81/g" package/network/services/uhttpd/files/uhttpd.config
sed -i "s/:443/:4443/g" package/network/services/uhttpd/files/uhttpd.config
cp -a $GITHUB_WORKSPACE/configfiles/etc/* package/base-files/files/etc/
# ls package/base-files/files/etc/


# 集成CPU性能跑分脚本
cp -a $GITHUB_WORKSPACE/configfiles/coremark/* package/base-files/files/bin/
chmod 755 package/base-files/files/bin/coremark
chmod 755 package/base-files/files/bin/coremark.sh


# 复制 Orange pi 5 Plus dts设备树文件到指定目录下
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3588-orangepi-5-plus.dts target/linux/rockchip/dts/rk3588/rk3588-orangepi-5-plus.dts


# 定时限速插件
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus



# 增加nsy_g68-plus
echo -e "\\ndefine Device/nsy_g68-plus
\$(call Device/Legacy/rk3568,\$(1))
  DEVICE_VENDOR := NSY
  DEVICE_MODEL := G68
  DEVICE_DTS := rk3568/rk3568-nsy-g68-plus
  DEVICE_PACKAGES += kmod-nvme kmod-ata-ahci-dwc kmod-thermal kmod-switch-rtl8306 kmod-switch-rtl8366-smi kmod-switch-rtl8366rb kmod-switch-rtl8366s kmod-hwmon-pwmfan kmod-r8169 kmod-switch-rtl8367b swconfig kmod-swconfig kmod-mt7916-firmware
endef
TARGET_DEVICES += nsy_g68-plus" >> target/linux/rockchip/image/legacy.mk


# 增加nsy_g16-plus
echo -e "\\ndefine Device/nsy_g16-plus
\$(call Device/Legacy/rk3568,\$(1))
  DEVICE_VENDOR := NSY
  DEVICE_MODEL := G16
  DEVICE_DTS := rk3568/rk3568-nsy-g16-plus
  DEVICE_PACKAGES += kmod-nvme kmod-ata-ahci-dwc kmod-thermal kmod-switch-rtl8306 kmod-switch-rtl8366-smi kmod-switch-rtl8366rb kmod-switch-rtl8366s kmod-hwmon-pwmfan kmod-r8169 kmod-switch-rtl8367b swconfig kmod-swconfig kmod-mt7615-firmware
endef
TARGET_DEVICES += nsy_g16-plus" >> target/linux/rockchip/image/legacy.mk


# 增加bdy_g18-pro
echo -e "\\ndefine Device/bdy_g18-pro
\$(call Device/Legacy/rk3568,\$(1))
  DEVICE_VENDOR := BDY
  DEVICE_MODEL := G18
  DEVICE_DTS := rk3568/rk3568-bdy-g18-pro
  DEVICE_PACKAGES += kmod-nvme kmod-ata-ahci-dwc kmod-thermal kmod-switch-rtl8306 kmod-switch-rtl8366-smi kmod-switch-rtl8366rb kmod-switch-rtl8366s kmod-hwmon-pwmfan kmod-r8169 kmod-switch-rtl8367b swconfig kmod-swconfig kmod-mt7615-firmware
endef
TARGET_DEVICES += bdy_g18-pro" >> target/linux/rockchip/image/legacy.mk


rm -f target/linux/rockchip/armv8/base-files/etc/board.d/02_network
cp -f $GITHUB_WORKSPACE/configfiles/02_network target/linux/rockchip/armv8/base-files/etc/board.d/02_network


# 加入nsy_g68-plus初始化网络配置脚本
cp -f $GITHUB_WORKSPACE/configfiles/swconfig_install package/base-files/files/etc/init.d/swconfig_install
chmod 755 package/base-files/files/etc/init.d/swconfig_install


# 集成 nsy_g68-plus WiFi驱动
mkdir -p package/base-files/files/lib/firmware/mediatek
cp -f $GITHUB_WORKSPACE/configfiles/WirelessDriver/mt7916_eeprom.bin package/base-files/files/lib/firmware/mediatek/mt7916_eeprom.bin


# 暂时使用这样替换
wget https://github.com/xiaomeng9597/files/releases/download/files/rtl8367b-fix-gmac.tar.gz
tar -xvf rtl8367b-fix-gmac.tar.gz


cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-nsy-g68-plus.dts target/linux/rockchip/dts/rk3568/rk3568-nsy-g68-plus.dts
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-nsy-g16-plus.dts target/linux/rockchip/dts/rk3568/rk3568-nsy-g16-plus.dts
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-bdy-g18-pro.dts target/linux/rockchip/dts/rk3568/rk3568-bdy-g18-pro.dts
