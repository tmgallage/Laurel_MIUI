#!/sbin/sh

# Start BITNET MIUI post installation script

STRING="ro.system.build.version.incremental=V12."
FILE="/system/system/build.prop"

if  grep -q "$STRING" "$FILE" ; then
    echo Nothing to do
else

# Install Updater
cp -r /tmp/install/bin/MiuiUpdater /system/system/priv-app/

chmod 755 /system/system/priv-app/MiuiUpdater
chmod 644 /system/system/priv-app/MiuiUpdater/MiuiUpdater.apk
chown -hR root:root /system/system/priv-app/MiuiUpdater
chown -hR root:root /system/system/priv-app/MiuiUpdater/MiuiUpdater.apk

# Install AOD 2.0 to fix battery drain
rm -r /system/system/priv-app/MiuiAod/
cp -r /tmp/install/bin/MiuiAod /system/system/priv-app/

chmod 755 /system/system/priv-app/MiuiAod
chmod 644 /system/system/priv-app/MiuiAod/MiuiAod.apk
chown -hR root:root /system/system/priv-app/MiuiAod
chown -hR root:root /system/system/priv-app/MiuiAod/MiuiAod.apk

fi

# Disable encryption if was disabled before
if [ -f "/tmp/noencrypt" ] 
then
    sed -i 's/fileencryption=ice/encryptable=ice/g' /vendor/etc/fstab.qcom
fi

