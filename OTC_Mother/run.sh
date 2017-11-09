#!/bin/sh

sudo systemctl stop serial-getty@ttymxc0.service
#sudo dmesg -n 1

export DIR=`dirname $0`
echo $DIR

oscsend localhost 4001 /oled/aux/clear i 1
oscsend localhost 4001 /oled/aux/line/1 s "running ETC"
oscsend localhost 4001 /oled/aux/line/2 s "in $DIR"
oscsend localhost 4001 /oled/setscreen i 1
killall python2

cd $DIR

./fsquares
cp splash /dev/fb0



export SDL_VIDEODRIVER=fbcon

python2 main.py &

