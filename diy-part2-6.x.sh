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


# rtl8367b驱动压缩包，暂时使用这样替换
wget https://github.com/xiaomeng9597/files/releases/download/files/rtl8367b-fix-gmac.tar.gz
tar -xvf rtl8367b-fix-gmac.tar.gz


# 复制dts设备树文件到指定目录下
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3588-orangepi-5-plus.dts target/linux/rockchip/dts/rk3588/rk3588-orangepi-5-plus.dts
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-nsy-g68-plus.dts target/linux/rockchip/dts/rk3568/rk3568-nsy-g68-plus.dts
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-nsy-g16-plus.dts target/linux/rockchip/dts/rk3568/rk3568-nsy-g16-plus.dts
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-bdy-g18-pro.dts target/linux/rockchip/dts/rk3568/rk3568-bdy-g18-pro.dts

# 添加支持 sgmii 补丁
# 下载补丁文件
echo 下载 300-nvmem-rockchip-otp-Add-support-for-rk3568-otp.patch
curl -o target/linux/rockchip/patches-6.6/300-nvmem-rockchip-otp-Add-support-for-rk3568-otp.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/300-nvmem-rockchip-otp-Add-support-for-rk3568-otp.patch

echo 下载 301-arm64-dts-rockchip-rk3568-Add-otp-device-node.patch
curl -o target/linux/rockchip/patches-6.6/301-arm64-dts-rockchip-rk3568-Add-otp-device-node.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/301-arm64-dts-rockchip-rk3568-Add-otp-device-node.patch

echo 下载 304-01-arm64-dts-rockchip-add-cpuinfo-support-for-rk3328.patch
curl -o target/linux/rockchip/patches-6.6/304-01-arm64-dts-rockchip-add-cpuinfo-support-for-rk3328.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/304-01-arm64-dts-rockchip-add-cpuinfo-support-for-rk3328.patch
  
echo 下载 304-02-arm64-dts-rockchip-add-cpuinfo-support-for-rk3399.patch
curl -o target/linux/rockchip/patches-6.6/304-02-arm64-dts-rockchip-add-cpuinfo-support-for-rk3399.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/304-02-arm64-dts-rockchip-add-cpuinfo-support-for-rk3399.patch
  
echo 下载 304-03-arm64-dts-rockchip-add-cpuinfo-node-for-rk3568.patch
curl -o target/linux/rockchip/patches-6.6/304-03-arm64-dts-rockchip-add-cpuinfo-node-for-rk3568.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/304-03-arm64-dts-rockchip-add-cpuinfo-node-for-rk3568.patch

echo 下载 700-phy-rockchip-snps-pcie3-rk3568-update-fw-when-init.patch 
curl -o target/linux/rockchip/patches-6.6/700-phy-rockchip-snps-pcie3-rk3568-update-fw-when-init.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/700-phy-rockchip-snps-pcie3-rk3568-update-fw-when-init.patch
  
echo 下载 701-irqchip-gic-v3-add-hackaround-for-rk3568-its.patch
curl -o target/linux/rockchip/patches-6.6/701-irqchip-gic-v3-add-hackaround-for-rk3568-its.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/701-irqchip-gic-v3-add-hackaround-for-rk3568-its.patch
  
echo 下载 703-arm64-rk3568-update-gicv3-its-and-pci-msi-map.patch
curl -o target/linux/rockchip/patches-6.6/703-arm64-rk3568-update-gicv3-its-and-pci-msi-map.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/703-arm64-rk3568-update-gicv3-its-and-pci-msi-map.patch
  
echo 下载 710-ethernet-stmicro-stmmac-Add-SGMII-QSGMII-support-for.patch
curl -o target/linux/rockchip/patches-6.6/710-ethernet-stmicro-stmmac-Add-SGMII-QSGMII-support-for.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/710-ethernet-stmicro-stmmac-Add-SGMII-QSGMII-support-for.patch
  
echo 下载 711-arm64-dts-rockchip-rk3568-Add-xpcs-support.patch
curl -o target/linux/rockchip/patches-6.6/711-arm64-dts-rockchip-rk3568-Add-xpcs-support.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/711-arm64-dts-rockchip-rk3568-Add-xpcs-support.patch

echo 下载 997-rockchip-naneng-combo-phy-add-sgmii-mac-sel.patch
curl -o target/linux/rockchip/patches-6.6/997-rockchip-naneng-combo-phy-add-sgmii-mac-sel.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/997-rockchip-naneng-combo-phy-add-sgmii-mac-sel.patch
  
echo 下载 /9999-add-mode-gmac-number.patch
curl -o target/linux/rockchip/patches-6.6/9999-add-mode-gmac-number.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/9999-add-mode-gmac-number.patch
  
echo 下载 9999-drivers-net-ethernet-stmicro-stmmac-rockchip.patch
cp -f $GITHUB_WORKSPACE/patches-6.6/9999-drivers-net-ethernet-stmicro-stmmac-rockchip.patch target/linux/rockchip/patches-6.6/9999-drivers-net-ethernet-stmicro-stmmac-rockchip.patch

echo 下载 9999-ethernet-stmmac-dwmac-rk-Disable-Auto-Nego-for-1000.patch
curl -o target/linux/rockchip/patches-6.6/9999-ethernet-stmmac-dwmac-rk-Disable-Auto-Nego-for-1000.patch \
  https://raw.githubusercontent.com/zhoufuli/immortalwrt-rk356x/main/target/linux/rockchip/patches-6.6/9999-ethernet-stmmac-dwmac-rk-Disable-Auto-Nego-for-1000.patch

# 验证下载文件

ls -l target/linux/rockchip/patches-6.6/300-nvmem-rockchip-otp-Add-support-for-rk3568-otp.patch
ls -l target/linux/rockchip/patches-6.6/301-arm64-dts-rockchip-rk3568-Add-otp-device-node.patch
ls -l target/linux/rockchip/patches-6.6/304-01-arm64-dts-rockchip-add-cpuinfo-support-for-rk3328.patch
ls -l target/linux/rockchip/patches-6.6/304-02-arm64-dts-rockchip-add-cpuinfo-support-for-rk3399.patch
ls -l target/linux/rockchip/patches-6.6/304-03-arm64-dts-rockchip-add-cpuinfo-node-for-rk3568.patch
ls -l target/linux/rockchip/patches-6.6/700-phy-rockchip-snps-pcie3-rk3568-update-fw-when-init.patch
ls -l target/linux/rockchip/patches-6.6/701-irqchip-gic-v3-add-hackaround-for-rk3568-its.patch
ls -l target/linux/rockchip/patches-6.6/703-arm64-rk3568-update-gicv3-its-and-pci-msi-map.patch
ls -l target/linux/rockchip/patches-6.6/710-ethernet-stmicro-stmmac-Add-SGMII-QSGMII-support-for.patch
ls -l target/linux/rockchip/patches-6.6/711-arm64-dts-rockchip-rk3568-Add-xpcs-support.patch
ls -l target/linux/rockchip/patches-6.6/997-rockchip-naneng-combo-phy-add-sgmii-mac-sel.patch
ls -l target/linux/rockchip/patches-6.6/9999-add-mode-gmac-number.patch
ls -l target/linux/rockchip/patches-6.6/9999-drivers-net-ethernet-stmicro-stmmac-rockchip.patch
ls -l target/linux/rockchip/patches-6.6/9999-ethernet-stmmac-dwmac-rk-Disable-Auto-Nego-for-1000.patch

