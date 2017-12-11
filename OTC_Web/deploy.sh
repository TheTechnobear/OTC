#!/bin/sh

# should be run from motherhost package installer
cd ..
mkdir -p $USER_DIR/Web 
rm -rf $USER_DIR/Web/OTC_Web
mv OTC_Web $USER_DIR/Web

exit 1
