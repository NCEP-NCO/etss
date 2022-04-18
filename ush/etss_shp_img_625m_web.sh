#!/bin/bash

if test "$4" == ''
then
  echo "Usage $0 <'start mes #'> <end mes #> "
  exit
fi
if test "$5" != ''
then
  echo "Usage $0 <'start mes #'> <end mes #> "
  exit
fi


num1=$1
num2=$2
prodc=$3
verp=$4

etsurge_grib=${COMIN}/etss.${cycle}.${prodc}.con625m.grib2
vverp=v2_2
box=(-135.00 22.296806 -55.00 46.175496)

valdate=${PDY}
PDYa1=${PDY}
adv=${cyc}
export pgm="degrib"
for i in `seq ${num1} ${num2}`;
do
   shpfile=${SHPetss}/con_${cyc}_${prodc}_msg_${i}_625m_${vverp}.shp
   
   startmsg
   ${EXECetss}/degrib ${etsurge_grib} -out ${shpfile} -C -msg $i -Shp -poly 2 -nMissing  >> $pgmout 2> errfile
   err=$?;export err; err_chk

done    



