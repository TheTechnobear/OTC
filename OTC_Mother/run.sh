#!/bin/sh

export USER_DIR=${USER_DIR:="/usbdrive"}
# PATCH_DIR=${PATCH_DIR:="/usbdrive/Patches"}
# FW_DIR=${FW_DIR:="/root"}
# SCRIPTS_DIR=$FW_DIR/scripts


echo start otc mother > $USER_DIR/otc_mother.log

sudo systemctl stop serial-getty@ttymxc0.service
#sudo dmesg -n 1

export DIR=`dirname $0`
echo $DIR

oscsend localhost 4001 /oled/clear i 1
oscsend localhost 4001 /oled/line/1 s "running OTC"
oscsend localhost 4001 /oled/line/2 s "modes : $USER_DIR"
oscsend localhost 4001 /oled/setscreen i 3
killall python2

cd $DIR

echo init fb0 >> $USER_DIR/otc_mother.log
./fsquares >> $USER_DIR/otc_mother.log 2>&1 
echo start splash >> $USER_DIR/otc_mother.log
cp splash /dev/fb0

export SDL_VIDEODRIVER=fbcon

mkdir -p /tmp/pids
echo start python >> $USER_DIR/otc_mother.log
python2 main.py >> $USER_DIR/otc_mother.log 2>&1 & echo $! > /tmp/pids/otc_mother.pid


