#!/sbin/sh

sed -i '/package name="com.android.bluetooth"/,/package/d' /data/system/packages.xml
sed -i '/package name="com.miui.calculator"/,/package/d' /data/system/packages.xml
sed -i '/package name="com.miui.extraphoto"/,/package/d' /data/system/packages.xml
sed -i '/package name="com.miui.klo.bugreport"/,/package/d' /data/system/packages.xml

sed -i '/com.android.bluetooth/d' /data/system/packages.list
sed -i '/com.miui.calculator/d' /data/system/packages.list
sed -i '/com.miui.extraphoto/d' /data/system/packages.list
sed -i '/com.miui.klo.bugreport/d' /data/system/packages.list

rm -rf /data/data/com.android.mms/app_understand
rm -rf /data/data/com.android.providers.downloads/*
rm -rf /data/data/com.android.providers.downloads.ui/*
rm -rf /data/data/eu.xiaomi.ext/databases
rm -rf /data/data/pl.zdunex25.updater/*
rm -rf /data/system/package_cache/*
rm -rf /data/resource-cache/*
rm -rf /data/cust/*

if ! ls /sdcard/persist_backup_*.img &>/dev/null; then
  dd if=/dev/block/bootdevice/by-name/persist of=/sdcard/persist_backup_$(date +%s).img
fi
