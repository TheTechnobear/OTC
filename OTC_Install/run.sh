#!/bin/sh

export DIR=`dirname $0`
cd $DIR

~/scripts/remount-rw.sh

oscsend localhost 4001 /oled/setscreen i 1

oscsend localhost 4001 /enableauxsub i 1
oscsend localhost 4001 /oled/aux/clear i 1
oscsend localhost 4001 /oled/aux/line/1 s "installing OTC"
oscsend localhost 4001 /oled/aux/line/5 s "do not interrupt!"

echo installing otc > /usbdrive/otc_install.log
cd pkg
cp * /var/cache/pacman/pkg
oscsend localhost 4001 /oled/aux/line/2 s "dependent pkgs"
pacman -U --noconfirm /var/cache/pacman/pkg/sdl-1.2.15-7-armv7h.pkg.tar.xz  2>&1 >> /usbdrive/otc_install.log 
pacman -U --noconfirm * 2>&1 > /usbdrive/otc_install.log 2>&1 >> /usbdrive/otc_install.log
oscsend localhost 4001 /oled/aux/line/2 s "install old pygame"
pacman -U --noconfirm /var/cache/pacman/pkg/python2-pygame-1.9.1-10-armv7h.pkg.tar.xz 2>&1 >> /usbdrive/otc_install.log
oscsend localhost 4001 /oled/aux/line/2 s "remove old pygame!"
pacman -R --noconfirm python2-pygame 2>&1 >> /usbdrive/otc_install.log

cd ..

cd pip
oscsend localhost 4001 /oled/aux/line/2 s "pip 9.01"
pip2 install --upgrade pip-9.0.1-py2.py3-none-any.whl 

oscsend localhost 4001 /oled/aux/line/2 s "pygame"
pip2 install pygame-1.9.3.tar.gz 2>&1 >>/usbdrive/otc_install.log

oscsend localhost 4001 /oled/aux/line/2 s "psutil"
pip2 install psutil-5.4.1.tar.gz 2>&1 >>/usbdrive/otc_install.log

oscsend localhost 4001 /oled/aux/line/2 s "pyliblo"
pip2 install pyliblo-0.10.0.tar.gz 2>&1 >>/usbdrive/otc_install.log

oscsend localhost 4001 /oled/aux/line/2 s "pyalsaaudio"
pip2 install pyalsaaudio-0.8.4.tar.gz 2>&1 >>/usbdrive/otc_install.log

cd ..

oscsend localhost 4001 /oled/aux/line/2 s "uEnv.txt"
cp /boot/uEnv.txt /boot/uEnv.orig
cp uEnv.txt /boot

echo install done  >>/usbdrive/otc_install.log


oscsend localhost 4001 /oled/aux/line/0 s "now will shutdown"
sync
sleep 2


oscsend localhost 4001 /oled/aux/line/2 s "shutting down"
~/scripts/shutdown.sh



