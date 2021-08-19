#!/bin/bash -e
echo "gpio=19=op,a5" >> ${ROOTFS_DIR}/boot/config.txt
rm -rf ${ROOTFS_DIR}/home/glimmrtv/glimmr
echo "done" > "${ROOTFS_DIR}/home/glimmrtv/firstrun"
git clone -b dev https://github.com/d8ahazard/glimmr ${ROOTFS_DIR}/home/glimmrtv/glimmr
# Install update script to init.d 
chmod 777 ${ROOTFS_DIR}/home/glimmrtv/glimmr/script/update_linux.sh
cd ${ROOTFS_DIR}/home/glimmrtv/glimmr
/opt/dotnet/dotnet restore ${ROOTFS_DIR}/home/glimmrtv/glimmr/src/Glimmr/Glimmr.csproj
/opt/dotnet/dotnet publish ${ROOTFS_DIR}/home/glimmrtv/glimmr/src/Glimmr/Glimmr.csproj /p:PublishProfile=LinuxARM -o ${ROOTFS_DIR}/home/glimmrtv/glimmr/bin/
chmod -R 777 ${ROOTFS_DIR}/home/glimmrtv/glimmr/bin
install -m 755 ${ROOTFS_DIR}/home/glimmrtv/glimmr/lib/bass.dll ${ROOTFS_DIR}/usr/lib/bass.dll
cp -r ${ROOTFS_DIR}/home/glimmrtv/glimmr/lib/LinuxARM/* ${ROOTFS_DIR}/usr/lib/
# Install service
echo "
[Unit]
Description=GlimmrTV

[Service]
Type=simple
RemainAfterExit=yes
StandardOutput=tty
Restart=always
User=root
WorkingDirectory=/home/glimmrtv/glimmr/bin
ExecStart=sudo /opt/dotnet/dotnet /home/glimmrtv/glimmr/bin/Glimmr.dll
KillMode=process

[Install]
WantedBy=multi-user.target

" > ${ROOTFS_DIR}/etc/systemd/system/glimmr.service