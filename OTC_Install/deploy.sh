#!/bin/sh


#!/bin/sh


~/scripts/remount-rw.sh


echo installing otc > $USER_DIR/otc_install.log

cd pkg

cp * /var/cache/pacman/pkg
oscsend localhost 4001 /oled/aux/line/2 s "dependent pkgs"
pacman -U --noconfirm /var/cache/pacman/pkg/sdl-1.2.15-7-armv7h.pkg.tar.xz  2>&1 >> $USER_DIR/otc_install.log 
pacman -U --noconfirm * 2>&1 >> $USER_DIR/otc_install.log

oscsend localhost 4001 /oled/aux/line/2 s "uninstall new pygame"
yes | pip2 uninstall pygame 2>&1 >> $USER_DIR/otc_install.log

oscsend localhost 4001 /oled/aux/line/2 s "install old pygame"
pacman -U --noconfirm /var/cache/pacman/pkg/python2-pygame-1.9.1-10-armv7h.pkg.tar.xz 2>&1 >> $USER_DIR/otc_install.log

oscsend localhost 4001 /oled/aux/line/2 s "uninstall old pygame!"
pacman -R --noconfirm python2-pygame 2>&1 >> $USER_DIR/otc_install.log

cd ..

cd pip

oscsend localhost 4001 /oled/aux/line/2 s "pygame"
pip2 install --upgrade pygame-1.9.3.tar.gz 2>&1 >>$USER_DIR/otc_install.log

oscsend localhost 4001 /oled/aux/line/2 s "psutil"
pip2 install --upgrade psutil-5.4.1.tar.gz 2>&1 >>$USER_DIR/otc_install.log


oscsend localhost 4001 /oled/aux/line/2 s "pyalsaaudio"
pip2 install --upgrade pyalsaaudio-0.8.4.tar.gz 2>&1 >>$USER_DIR/otc_install.log

cd ..

oscsend localhost 4001 /oled/aux/line/2 s "uEnv.txt"
cp /boot/uEnv.txt /boot/uEnv.orig
cp uEnv.txt /boot

echo install done  >>$USER_DIR/otc_install.log

cd ..
rm -rf $1

exit 2



