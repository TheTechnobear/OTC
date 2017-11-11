#!/bin/sh

export USER_DIR=${USER_DIR:="/usbdrive"}
# PATCH_DIR=${PATCH_DIR:="/usbdrive/Patches"}
# FW_DIR=${FW_DIR:="/root"}
# SCRIPTS_DIR=$FW_DIR/scripts


IP=$(ip -o -4 addr list wlan0 | awk '{print $4}' | cut -d/ -f1)
oscsend localhost 4001 /oled/aux/clear i 1

oscsend localhost 4001 /oled/aux/line/1 s "Started OTC Web."
oscsend localhost 4001 /oled/aux/line/2 s "Visit here:"
oscsend localhost 4001 /oled/aux/line/3 s "$IP:8080"
oscsend localhost 4001 /oled/aux/line/4 s "with your browser."
oscsend localhost 4001 /oled/aux/line/5 s " "

# set to aux screen, signals screen update
oscsend localhost 4001 /oled/setscreen i 1


export DIR=`dirname $0`
cd $DIR
killall cherryd
#wget http://www.thepeacetreaty.org/ping/ping.php
cherryd -i cpapp -c prod.conf &

