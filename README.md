# Laurel MIUI

This is the public release of MI A3 MIUI builder script developed by tmgallage (BITNET).

## Important Directories

1. Laurel_MIUI/BOOT/kernel-dtbo : You can add kernel "Image.gz-dtb" & "dtbo.img" here.
2. Laurel_MIUI/BOOT/TWRP        : You can add your preferred recovery.img here.
3. Laurel_MIUI/A3_ROM           : Put latest Mi A3 recovery flashable ROM here.
4. Laurel_MIUI/CC9E_ROM         : Put Mi CC9e xiaomi.eu/China recovery flashable ROM here.

## Requirements

Recommended operating system is Ubuntu 20.04 and newer.

Install bellow dependencies:

sudo apt install python3-pip brotli attr default-jre

sudo pip3 install bsdiff4

## How to build MIUI

1. Put latest Mi A3 recovery flashable stock ROM to "A3_ROM" folder.
2. Put Mi CC9e recovery flashable xiaomi.eu/China ROM to "CC9E_ROM" folder.
3. Open terminal in "Laurel MIUI Builder" directory.
4. Run "sudo ./build-eu.sh" for xiaomi.eu ROM or "sudo ./build-cn.sh" for MIUI China ROM.

After MIUI porting process done, see "output" folder for flashable zip.

### Special thanks to below projects
https://github.com/xpirt/sdat2img 
https://github.com/vm03/payload_dumper 
https://github.com/osm0sis/Android-Image-Kitchen 
https://ibotpeaches.github.io/Apktool/
