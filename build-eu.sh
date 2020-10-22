#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo MI A3 MIUI Porting Started ...

# CLEANING ###################################################

echo Cleaning Porting Environment ...
rm system_CC9E.img >/dev/null 2>&1
rm vendor_CC9E.img >/dev/null 2>&1
cd A3_ROM
rm -rf output >/dev/null 2>&1
rm payload.bin >/dev/null 2>&1
cd ..
cd CC9E_ROM
rm -rf firmware-update >/dev/null 2>&1
rm -rf META-INF >/dev/null 2>&1
rm *.br >/dev/null 2>&1
rm *.dat >/dev/null 2>&1
rm *.img >/dev/null 2>&1
rm *.list >/dev/null 2>&1
rm compatibility.zip >/dev/null 2>&1
cd ..
cd BOOT
rm boot.img >/dev/null 2>&1
./cleanup.sh >/dev/null 2>&1
cd TWRP
./cleanup.sh >/dev/null 2>&1
cd ..
cd ..
echo Cleaning Done ...

# EXTRACTION #################################################

echo Starting Extraction ...
cd A3_ROM
rm -rf output
mkdir output
echo Extracting Stock ROM Zip ...
unzip -p miui_LAURELSPROUT*.zip payload.bin >payload.bin

echo Extracting Stock ROM payload.bin ...
python3 payload_dumper.py payload.bin

echo Coping A3 vendor to working directory ...
mv output/vendor.img ../vendor_A3.img

cd ..
cd CC9E_ROM
echo Extracting CC9E ROM Zip ...
unzip xiaomi.eu_multi_MICC9e*.zip

echo Decompressing brotli files ...
brotli --decompress system.new.dat.br -o system.new.dat
brotli --decompress vendor.new.dat.br -o vendor.new.dat

echo Coverting DAT files to RAW ...
python3 sdat2img.py system.transfer.list system.new.dat system.img >/dev/null 2>&1
python3 sdat2img.py vendor.transfer.list vendor.new.dat vendor.img >/dev/null 2>&1

echo Coping CC9E system to working directory ...
mv system.img ../system_CC9E.img
echo Coping CC9E vendor to working directory ...
mv vendor.img ../vendor_CC9E.img
cd ..
echo Extraction Done ...

# SYSTEM #####################################################

umount /mnt/CC9E_ROM >/dev/null 2>&1
umount /mnt/A3_ROM >/dev/null 2>&1
umount /mnt/Extra_System_Files >/dev/null 2>&1
rm -rf /mnt/CC9E_ROM
rm -rf /mnt/A3_ROM
rm -rf /mnt/Extra_System_Files
mkdir /mnt/CC9E_ROM
mkdir /mnt/A3_ROM
mkdir /mnt/Extra_System_Files

echo Making empty system.img for MIUI port ...
cp system_CC9E.img system_A3.img
mount -o rw,noatime system_A3.img /mnt/A3_ROM
rm -rf /mnt/A3_ROM/*
umount /mnt/A3_ROM
e2fsck -y -f system_A3.img >/dev/null 2>&1
resize2fs system_A3.img 786432

echo Mounting CC9E system ...
mount -o rw,noatime system_CC9E.img /mnt/CC9E_ROM
echo Mounting Stock system ...
mount -o rw,noatime system_A3.img /mnt/A3_ROM
# Mounting image that contaings extra system files. This files added inside image file to minimize selinux problems.
mount -o rw,noatime Extra_Files/extra_system_files.img /mnt/Extra_System_Files

echo Removing bloatwares ...
rm -rf /mnt/CC9E_ROM/system/priv-app/Updater >/dev/null 2>&1
rm -rf /mnt/CC9E_ROM/system/app/Lens >/dev/null 2>&1
rm -rf /mnt/CC9E_ROM/system/priv-app/MiMover >/dev/null 2>&1
rm -rf /mnt/CC9E_ROM/system/priv-app/MiService >/dev/null 2>&1
rm -rf /mnt/CC9E_ROM/system/product/priv-app/Velvet >/dev/null 2>&1
rm -rf /mnt/CC9E_ROM/system/app/MiuiVideoGlobal >/dev/null 2>&1
rm -rf /mnt/CC9E_ROM/system/app/Email >/dev/null 2>&1
rm -rf /mnt/CC9E_ROM/system/app/MiuiBugReport >/dev/null 2>&1
rm -rf /mnt/CC9E_ROM/system/priv-app/CleanMaster >/dev/null 2>&1

# Coping some files from xiaomi.eu to use in china ROM
rm -rf Extra_Files/EU_Files/*
cp -Raf /mnt/CC9E_ROM/system/priv-app/DownloadProvider Extra_Files/EU_Files/
cp -Raf /mnt/CC9E_ROM/system/priv-app/DownloadProviderUi Extra_Files/EU_Files/
cp -Raf /mnt/CC9E_ROM/system/priv-app/Music Extra_Files/EU_Files/
cp -Raf /mnt/CC9E_ROM/system/app/MiRadio Extra_Files/EU_Files/
cp -Raf /mnt/CC9E_ROM/system/app/FM Extra_Files/EU_Files/
cp -Raf /mnt/CC9E_ROM/system/media/theme Extra_Files/EU_Files/

# Adding china theme to xiaomi.eu
if [ -d "Extra_Files/China_Files/theme" ] 
then
	rm -rf /mnt/CC9E_ROM/system/media/theme
	cp -Raf Extra_Files/EU_Files/theme/default/powermenu Extra_Files/China_Files/theme/default/powermenu 
	cp -Raf Extra_Files/China_Files/theme /mnt/CC9E_ROM/system/media/
fi

echo Porting CC9E system to A3 system ...
rm -rf /mnt/A3_ROM/*
cp -Raf /mnt/Extra_System_Files/* /mnt/A3_ROM/
cp -Raf /mnt/CC9E_ROM/* /mnt/A3_ROM/
sed -i '/ro.build.version.incremental/s/$/-BITNET/' /mnt/A3_ROM/system/build.prop
sed -i '/ro.build.version.incremental./ { s/QFMCNXM-BITNET/BITNET/g; }' /mnt/A3_ROM/system/build.prop
sed -i '/ro.product.system.model/ a \ro.product.model=MI A3\' /mnt/A3_ROM/system/build.prop
sed -i "/ro.product.system.model=/c\ro.product.system.model=MI A3" /mnt/A3_ROM/system/build.prop
echo 'ro.netflix.bsp_rev=Q6125-17995-1' >> /mnt/A3_ROM/system/build.prop

echo Changing MIUI Camera Watermark ...
cp /mnt/CC9E_ROM/system/priv-app/MiuiCamera/MiuiCamera.apk APKTool/
cp /mnt/CC9E_ROM/system/framework/framework-ext-res/framework-ext-res.apk APKTool/
cp /mnt/CC9E_ROM/system/framework/framework-res.apk APKTool/
cp /mnt/CC9E_ROM/system/app/miui/miui.apk APKTool/
cp /mnt/CC9E_ROM/system/app/miuisystem/miuisystem.apk APKTool/
cd APKTool
rm -rf MiuiCamera
./apktool if framework-res.apk
./apktool if miui.apk
./apktool if framework-ext-res.apk
./apktool if miuisystem.apk
./apktool d MiuiCamera.apk
find . -type f -print0 | xargs -0 sed -i 's/CC\ 9e/A3/g'
rm MiuiCamera.apk
./apktool b MiuiCamera -c -o MiuiCamera-new.apk
java -jar signapk.jar certificate.x509.pem key.pk8 MiuiCamera-new.apk MiuiCamera.apk
rm MiuiCamera-new.apk
cp MiuiCamera.apk /mnt/A3_ROM/system/priv-app/MiuiCamera/
chmod 644 /mnt/A3_ROM/system/priv-app/MiuiCamera/MiuiCamera.apk
chown -hR root:root /mnt/A3_ROM/system/priv-app/MiuiCamera/MiuiCamera.apk
cd ..

cp -f Extra_Files/com.amirsoland.mia3_updater.xml /mnt/A3_ROM/system/etc/permissions/
chmod 644 /mnt/A3_ROM/system/etc/permissions/com.amirsoland.mia3_updater.xml
chown -hR root:root /mnt/A3_ROM/system/etc/permissions/com.amirsoland.mia3_updater.xml
setfattr -h -n security.selinux -v u:object_r:system_file:s0 /mnt/A3_ROM/system/etc/permissions/com.amirsoland.mia3_updater.xml

umount /mnt/CC9E_ROM
umount /mnt/A3_ROM
umount /mnt/Extra_System_Files
echo System Porting Done ...

# VENDOR #####################################################

umount /mnt/CC9E_ROM >/dev/null 2>&1
umount /mnt/A3_ROM >/dev/null 2>&1

echo Mounting CC9E vendor ...
mount -o rw,noatime vendor_CC9E.img /mnt/CC9E_ROM

echo Mounting Stock vendor ...
mount -o rw,noatime vendor_A3.img /mnt/A3_ROM

echo Porting CC9E vendor to A3 vendor ...
shopt -s extglob 

cp -Raf /mnt/A3_ROM/etc/fstab.qcom /mnt/CC9E_ROM/etc/

rm -rf /mnt/A3_ROM/lib/android.hardware.sensors@2.0-impl.so
rm -rf /mnt/A3_ROM/lib64/android.hardware.sensors@2.0-impl.so
rm -rf /mnt/A3_ROM/etc/init/android.hardware.sensors@2.0-service.rc
rm -rf /mnt/A3_ROM/bin/hw/android.hardware.sensors@2.0-service

rm -rf /mnt/A3_ROM/app
rm -rf /mnt/A3_ROM/overlay

###############################################################
# If you mess with this line, your device will hard brick. 
# Even EDL flash can't recover your device. 
# You shouldn't use CC9E /vendor/firmware on A3. It's a KILLER
rm -rf /mnt/CC9E_ROM/firmware
###############################################################

rm -rf /mnt/CC9E_ROM/etc/mixer_paths_qrd.xml
rm -rf /mnt/CC9E_ROM/data-app >/dev/null 2>&1
cp -Raf /mnt/CC9E_ROM/!('firmware') /mnt/A3_ROM/

sed -i '/target-level/ a \ <hal format="hidl"> <name>android.hardware.boot</name> <transport>hwbinder</transport> <version>1.0</version> <interface> <name>IBootControl</name>  <instance>default</instance> </interface> <fqname>@1.0::IBootControl/default</fqname> </hal>\' /mnt/A3_ROM/etc/vintf/manifest.xml

sed -i '/hvdcp_opti 0770 root system/ a \    exec u:object_r:system_file:s0 -- /system/bin/bootctl mark-boot-successful\' /mnt/A3_ROM/etc/init/hw/init.qcom.rc
sed -i '/fw_name/ a \    exec u:object_r:system_file:s0 -- /system/bin/setenforce 1\' /mnt/A3_ROM/etc/init/hw/init.qcom.rc
sed -i 's/,avb//g' /mnt/A3_ROM/etc/fstab.qcom

sed -i "/ro.product.vendor.model=/c\ro.product.vendor.model=MI A3" /mnt/A3_ROM/build.prop
sed -i "/ro.product.odm.model=/c\ro.product.odm.model=MI A3" /mnt/A3_ROM/odm/etc/build.prop

umount /mnt/CC9E_ROM
umount /mnt/A3_ROM
echo Vendor Porting Done ...

# Flashable Zip ################################################

echo Creating boot image ...
cp A3_ROM/output/boot.img BOOT/
cd BOOT
sudo ./cleanup.sh >/dev/null 2>&1
sudo ./unpackimg.sh >/dev/null 2>&1
cd TWRP
sudo ./cleanup.sh >/dev/null 2>&1
sudo ./unpackimg.sh >/dev/null 2>&1
cd ..
sudo rm -rf ramdisk
sudo cp -Raf  TWRP/ramdisk ramdisk
sudo sed -i 's/androidboot.memcg=1/androidboot.memcg=1 androidboot.selinux=permissive/g' split_img/boot.img-cmdline
year=$(date +'%Y')
month=`date +'%m'`
sudo echo "$year-$month" > boot.img-oslevel
sudo mv boot.img-oslevel split_img/
sudo cp kernel-dtbo/Image.gz-dtb split_img/boot.img-zImage >/dev/null 2>&1
sudo ./repackimg.sh >/dev/null 2>&1
cd ..

cd output
rm system.img >/dev/null 2>&1
rm vendor.img >/dev/null 2>&1
rm boot.img >/dev/null 2>&1
rm firmware-update/vbmeta.img >/dev/null 2>&1
rm firmware-update/dtbo.img >/dev/null 2>&1
cd ..

echo Collecting Image Files to output directory ...
cp -rf A3_ROM/output/cmnlib64.img output/firmware-update/
cp -rf A3_ROM/output/imagefv.img output/firmware-update/
cp -rf A3_ROM/output/cmnlib.img output/firmware-update/
cp -rf A3_ROM/output/hyp.img output/firmware-update/
cp -rf A3_ROM/output/keymaster.img output/firmware-update/
cp -rf A3_ROM/output/tz.img output/firmware-update/
cp -rf A3_ROM/output/xbl_config.img output/firmware-update/
cp -rf A3_ROM/output/bluetooth.img output/firmware-update/
cp -rf A3_ROM/output/uefisecapp.img output/firmware-update/
cp -rf A3_ROM/output/modem.img output/firmware-update/
cp -rf A3_ROM/output/qupfw.img output/firmware-update/
cp -rf A3_ROM/output/abl.img output/firmware-update/
cp -rf A3_ROM/output/dsp.img output/firmware-update/
cp -rf A3_ROM/output/devcfg.img output/firmware-update/
cp -rf A3_ROM/output/storsec.img output/firmware-update/
cp -rf A3_ROM/output/xbl.img output/firmware-update/
cp -rf A3_ROM/output/rpm.img output/firmware-update/
cp CC9E_ROM/firmware-update/vbmeta.img output/firmware-update/
cp -rf CC9E_ROM/META-INF/com/xiaomieu output/META-INF/com/
cp BOOT/image-new.img output/boot.img
cp A3_ROM/output/dtbo.img output/firmware-update/
cp BOOT/kernel-dtbo/dtbo.img output/firmware-update/ >/dev/null 2>&1
mv system_A3.img output/system.img
mv vendor_A3.img output/vendor.img

echo Making TWRP Flashable Zip ...
cd CC9E_ROM
file=$(find . -type f -iname "xiaomi.eu*.zip")
cd ..
if [[ $file =~ ./xiaomi.eu_(.*)_(.*)_(.*)_(.*)\.zip$ ]]; then
  part1=${BASH_REMATCH[1]}
  part2=${BASH_REMATCH[2]}
  part3=${BASH_REMATCH[3]}
  part4=${BASH_REMATCH[4]}
fi
cd output
rm xiaomi.eu_MIA3_"$part3"_"$part4"-BITNET.zip >/dev/null 2>&1
rm xiaomi.eu_MIA3_"$part3"_"$part4"-BITNET.zip.md5 >/dev/null 2>&1
zip -r xiaomi.eu_MIA3_"$part3"_"$part4"-BITNET.zip firmware-update install META-INF boot.img system.img vendor.img
md5sum xiaomi.eu_MIA3_"$part3"_"$part4"-BITNET.zip > xiaomi.eu_MIA3_"$part3"_"$part4"-BITNET.zip.md5
cd ..

# CLEANING ###################################################

echo Cleaning Porting Environment ...
rm system_CC9E.img
rm vendor_CC9E.img
cd A3_ROM
rm -rf output
rm payload.bin
cd ..
cd CC9E_ROM
rm -rf firmware-update
rm -rf META-INF
rm *.br
rm *.dat
rm *.img
rm *.list
rm compatibility.zip >/dev/null 2>&1
cd ..
cd BOOT
rm boot.img
./cleanup.sh >/dev/null 2>&1
cd TWRP
./cleanup.sh >/dev/null 2>&1
cd ..
cd ..
echo Cleaning Done ...
echo CC9E to A3 Porting Process Done : output/xiaomi.eu_MIA3_"$part3"_"$part4"-BITNET.zip
