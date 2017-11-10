#!/bin/sh

export DIR=`dirname $0`
cd $DIR

~/scripts/remount-rw.sh

oscsend localhost 4002 /oled/setscreen i 1

oscsend localhost 4002 /enableauxsub i 1
oscsend localhost 4002 /oled/aux/clear i 1
oscsend localhost 4002 /oled/aux/line/0 s "install OTC"
oscsend localhost 4002 /oled/aux/line/5 s "do not interrupt!"
oscsend localhost 4002 /oled/aux/line/1 s "installing:"

echo installing otc > /usbdrive/otc_install.log

cd pip
oscsend localhost 4002 /oled/aux/line/2 s "Cython"
osceend localhost 4002 /oled/aux/line/3 s "takes a while!"
pip2 install Cython-0.27.3.tar.gz 2>&1 >>/usbdrive/otc_install.log
osceend localhost 4002 /oled/aux/line/3 s " "

oscsend localhost 4002 /oled/aux/line/2 s "pygame"
pip2 install pygame-1.9.3.tar.gz 2>&1 >>/usbdrive/otc_install.log

oscsend localhost 4002 /oled/aux/line/2 s "psutil"
pip2 install psutil-5.4.1.tar.gz 2>&1 >>/usbdrive/otc_install.log

oscsend localhost 4002 /oled/aux/line/2 s "pyliblo"
pip2 install pyliblo-0.10.0.tar.gz 2>&1 >>/usbdrive/otc_install.log

oscsend localhost 4002 /oled/aux/line/2 s "pyalsaaudio"
pip2 install pyalsaaudio-0.8.4.tar.gz 2>&1 >>/usbdrive/otc_install.log

cd ..

oscsend localhost 4002 /oled/aux/line/2 s "uEnv.txt"
cp /boot/uEnv.txt /boot/uEnv.orig
cp uEnv.txt /boot

echo install done  >>/usbdrive/otc_install.log


oscsend localhost 4002 /oled/aux/line/0 s "now will shutdown"
sync
sleep 2


oscsend localhost 4002 /oled/aux/line/2 s "shutting down"
~/scripts/shutdown.sh



