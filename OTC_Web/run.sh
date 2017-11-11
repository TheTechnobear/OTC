#!/bin/sh

export DIR=`dirname $0`
cd $DIR
#wget http://www.thepeacetreaty.org/ping/ping.php
cherryd -i cpapp -c prod.conf &

