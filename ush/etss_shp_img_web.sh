#!/bin/bash

if test "$3" == ''
then
  echo "Usage $0 <'con'> <2.0> "
  exit
fi
if test "$4" != ''
then
  echo "Usage $0 <'con'> <2.0> "
  exit
fi

area=$1
verp=$2
prodc=$3

echo "area= $area"
echo "verp= $verp"
echo "product= $prodc"

if [ "$prodc" = 'stormtide' ]; then
   fieldname=STORMTIDE
else
   fieldname=ETSRG
fi

if [ "$area" = 'con' ]; then
    etsurge_grib=${COMIN}/etss.${cycle}.${prodc}.${area}2p5km.grib2
    vverp=2_2
    num=103
    box=(-130.00 15.0 -63.00 53)

elif [ "$area" = 'ala' ]; then
    etsurge_grib=${COMIN}/etss.${cycle}.${prodc}.${area}3km.grib2
    vverp=2_2
    num=103
    box=(195.00 47.70 250.00 71.20)
fi
export pgm="degrib"
for i in `seq 1 ${num}`;
do
   
  shpfile=${SHPetss}/${area}_${cyc}_${prodc}_msg_${i}_v${vverp}.shp
  startmsg
  ${EXECetss}/degrib ${etsurge_grib} -out ${shpfile} -C -msg $i -Shp -poly 2 -nMissing  >> $pgmout 2> errfile
  err=$?;export err; err_chk

done    



