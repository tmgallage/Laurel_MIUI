#!/sbin/sh

STRING1="latemount,wait,check,encryptable=footer,wrappedkey,quota,reservedsize=128M"
STRING2="latemount,wait,check,encryptable=ice,wrappedkey,quota,reservedsize=128M"
FILE="/vendor/etc/fstab.qcom"

if  grep -q "$STRING1" "$FILE" ; then
    echo > /tmp/noencrypt
elif  grep -q "$STRING2" "$FILE" ; then
    echo > /tmp/noencrypt
else
    rm /tmp/noencrypt
fi
