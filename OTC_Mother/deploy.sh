#!/bin/sh

export USER_DIR=${USER_DIR:="/usbdrive"}
# PATCH_DIR=${PATCH_DIR:="/usbdrive/Patches"}
# FW_DIR=${FW_DIR:="/root"}
# SCRIPTS_DIR=$FW_DIR/scripts
SYSTEM_DIR=$USER_DIR/System

echo installing vnc > $USER_DIR/install.log

grep -q 'ID=archarm' /etc/os-release; 
if [ ! $? -eq 0 ] 
then 
	echo platform organelle-m  2>&1 >> $USER_DIR/install.log
else 
	echo platform organelle-1  2>&1 >> $USER_DIR/install.log
fi



oscsend localhost 4001 /oled/aux/line/2 s "move system"
rm -rf ${SYSTEM_DIR}/OTC_Mother
mkdir ${SYSTEM_DIR}/OTC_Mother
cp -r . ${SYSTEM_DIR}/OTC_Mother


oscsend localhost 4001 /oled/aux/line/2 s "done"

echo install done  >>$USER_DIR/install.log

cd ..
rm -rf $1

exit 1
