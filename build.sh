#!/bin/bash

#directories
CURRENT=`pwd`
OUT="${CURRENT}/out"
SRC="${CURRENT}/src"

#colors
RED='\033[0;31m'
NC='\033[0m' # No Color


mkdir -p $OUT
echo "${RED} -- Removing old files -- ${NC}"
rm -v $OUT/*

#do not ignore errors
set -e

#compile 
echo "${RED} -- Compiling -- ${NC}"
set -xe 

ca65 $SRC/init.s -o $OUT/init.o -g
ca65 $SRC/main.s -o $OUT/main.o -g

cd $OUT
ld65 -t nes init.o main.o -o nestest.nes --dbgfile nestest.dbg -Ln nestest.labels.txt -m nestest.map.txt
cd $CURRENT
