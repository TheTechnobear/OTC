#!/bin/sh

killall python2

/root/OTC_Sys/scripts/fsquares
cp /root/OTC_Sys/scripts/splash /dev/fb0

sleep 1

sudo systemctl stop serial-getty@ttymxc0.service
sudo dmesg -n 1

export SDL_VIDEODRIVER=fbcon

cd /root/OTC_Mother
python2 main.py &

