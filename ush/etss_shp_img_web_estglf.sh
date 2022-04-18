#!/bin/bash
if test "$2" == ''
then
  echo "Usage $0 <'con'> <2.0> "
  exit
fi
if test "$3" != ''
then
  echo "Usage $0 <'con'> <2.0> "
  exit
fi

prodc=$1
res=$2

area=con 
verp=2.2
vverp=2_2

if [ "$prodc" = 'stormtide' ]; then
   fieldname=ETCWL
else
   fieldname=ETSRG
fi


etsurge_grib=${COMIN}/etss.${cycle}.${prodc}.${area}${res}.grib2

box=(-98.0 23.61 -64.0 46.08) #good small est & gulf of MX
inifile=etsurge_sample_con_1km_estglf.ini

export pgm="drawshp"
for i in `seq 1 103`;
do
  if [ "${res}" = '625m' ]; then
     shpfile=${SHPetss}/${area}_${cyc}_${prodc}_msg_${i}_${res}_v${vverp}.shp
  else
     shpfile=${SHPetss}/${area}_${cyc}_${prodc}_msg_${i}_v${vverp}.shp
  fi

  outfile=${IMGetss}/${area}_06_${prodc}_msg_${i}_v${verp}_1km_glfest

  sed \
    -e s#LAT1#${box[1]}#g \
    -e s#LAT2#${box[3]}#g \
    -e s#LON1#${box[0]}#g \
    -e s#LON2#${box[2]}#g \
    -e s#FILENAME#${outfile}#g \
    -e s#INFILE#${shpfile}#g \
    -e s#FIELDNAME#${fieldname}#g \
       ${PARMetss}/${inifile} > ${DATA}/etsurge_1km_estglf_${prodc}_${res}_tmp.ini
    startmsg
    ${EXECetss}/drawshp ${DATA}/etsurge_1km_estglf_${prodc}_${res}_tmp.ini >> $pgmout 2> errfile
    err=$?;export err; err_chk
    adv=$(( adv + 1 ))
    convert ${IMGetss}/${area}_06_${prodc}_msg_${i}_v${verp}_1km_glfest.png -fuzz 10% -transparent white ${IMGetss}/${area}_06_${prodc}_msg_${i}_v${verp}_1km_glfest_trans.png
done    



