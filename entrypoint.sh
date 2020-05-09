#!/bin/bash

groupmod -o -g $AUDIO_GID audio
groupmod -o -g $VIDEO_GID video

if [ $GID != $(echo `id -g qq`) ]; then
    groupmod -o -g $GID qq
fi
if [ $UID != $(echo `id -u qq`) ]; then
    usermod -o -u $UID qq
fi
chown qq:qq /TencentFiles

su qq <<EOF
    cd "/home/qq"
    rm dpi.reg
    touch dpi.reg
EOF

REGDPI=$(printf '%08x\n' $DPI)
cat > /home/qq/dpi.reg << EOF
REGEDIT4
[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
"LogPixels"=dword:$REGDPI
EOF

sed -i '290 ienv WINEPREFIX=/home/qq/.deepinwine/Deepin-$APP deepin-wine regedit /home/qq/dpi.reg' "/opt/deepinwine/tools/run.sh"

su qq <<EOF
   echo "启动 $APP"
   mkdir -p /home/qq/.deepinwine
   touch /home/qq/.deepinwine/.QQ_run
   "/opt/deepinwine/apps/Deepin-$APP/run.sh"
   sleep 300
EOF

#tail -fn 0 /home/qq/.deepinwine/.QQ_run
while [ $(pgrep QQProtect.exe | wc -l ) -ne 0 ]
do
    sleep 60
done
echo "退出"
