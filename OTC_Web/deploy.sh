#!/bin/sh

grep -q 'ID=archarm' /etc/os-release; 
if [ ! $? -eq 0 ] 
then 
   oscsend localhost 4001 /oled/aux/line/1 s "only valid for"
   oscsend localhost 4001 /oled/aux/line/2 s "organelle-1"
   cd ..
   rm -rf $1
   exit 128
fi

# should be run from motherhost package installer
cd ..
mkdir -p $USER_DIR/Web 
rm -rf $USER_DIR/Web/OTC_Web
mv OTC_Web $USER_DIR/Web

exit 1
