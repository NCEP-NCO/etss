#!/bin/bash
# ###########################################################################################
# etss_pre.sh
# ###########################################################################################
# Author: Huiqing Liu (Huiqing.Liu@noaa.gov)                                      09-21-2021
# 1) Prepare data before running program to extract current and
#    forecast (future) global surface pressure, and U and V wind
#    vector fields.
# 2) Prepare data before running program to extract Past (historic)
#    global surface pressure, and U and V wind vector fields.
#    Needs 60 hours back...
#    (ie cycle 0Z day 0 needs back to cycle 12Z day -3)
#    Use PDYm1,PDYm2.... for -1 day, -2 day ...
# ###########################################################################################

#############################################################################################
# 09-21-2021: Created by Huiqing Liu 
#############################################################################################
set -x
export RANK=$1

echo "`date`: Start Rank ${RANK}" >> timing.txt

msg="Begin job for $job"
postmsg "$jlogfile" "$msg"

if [ ${RANK} -lt 11 ]; then
  bn_fcst=$((${RANK}*10))
  RK=$((${RANK}+1))
  if [[ ${RANK} == 10 ]]; then
    nd_fcst=102
  else
    nd_fcst=$((${RK}*10-1))
  fi
  for i in $(seq -f "%03g" ${bn_fcst} 1 ${nd_fcst}); do
    Start=$SECONDS
    while [[ ! -s $COMINgfs/${cyc}/atmos/${NETgfs}.${cycle}.sfluxgrbf$i.grib2 ]] ; do
      Dura=$((SECONDS-Start))
      if [ $Dura -ge 600 ]; then
        msg="$job Error: Wind file $COMINgfs/${cyc}/atmos/${NETgfs}.${cycle}.sfluxgrbf$i.grib2 is missed after 10 mins wait"
        postmsg "$jlogfile" "$msg"
        err_exit
      fi
      echo "`date`: Rank ${RANK} waiting for $COMINgfs/${cyc}/atmos/${NETgfs}.${cycle}.sfluxgrbf$i.grib2." >> timing.txt
      sleep 1
    done
    ${WGRIB2} ${COMINgfs}/${cyc}/atmos/${NETgfs}.${cycle}.sfluxgrbf$i.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${COMINgfs}/${cyc}/atmos/${NETgfs}.${cycle}.sfluxgrbf$i.grib2 -i -grib pgrb2fore$i
  done
  echo "RANK ${RANK} finished forecast wind" >> msg_wgrib2

  m_num2=$(grep "RANK" msg_wgrib2 | wc -l)
  while [[ ${m_num2} -ne 11 ]] ; do
    echo "`date`: Rank ${RANK} Sleeping nums msg_wgrib2=${m_num2}" >> timing.txt
    m_num2=$(grep "RANK" msg_wgrib2 | wc -l)
    sleep 1
  done

  if [[ ${RANK} == 0 ]] ; then
    for i in $(seq -f "%03g" 0 1 102); do
      cat pgrb2fore$i >> pgrb2foreALL
    done
    echo "`date`: Finished first file copies" >> timing.txt
    echo " finished first file copies" > msg_Done_first_cp.txt
  fi

elif [[ ${RANK} == 12 ]] ; then

  CYCLE1='t00z'
  CYCLE2='t06z'
  CYCLE3='t12z'
  CYCLE4='t18z'

  CYC1='00'
  CYC2='06'
  CYC3='12'
  CYC4='18'

# Files needed by all cycles (0,6,12,18)...
#     6Z of -2 day to 18Z of -1 day

  Start=$SECONDS
  while [[ ! -s $COMINgfsm2/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 || ! -s $COMINgfsm2/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 || ! -s $COMINgfsm2/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 || ! -s $COMINgfsm1/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 || ! -s $COMINgfsm1/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 || ! -s $COMINgfsm1/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 || ! -s $COMINgfsm1/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 ]] ; do
    Dura=$((SECONDS-Start))
    if [ $Dura -ge 600 ]; then
      msg="$job Error: Hindcast Wind file ${NETgfs}.*.sfluxgrbf00.grib2 is missed after 10 mins wait"
      postmsg "$jlogfile" "$msg"
      err_exit
    fi
    echo "`date`: Rank ${RANK} waiting for Hindcast Wind file ${NETgfs}.*.sfluxgrbf00.grib2." >> timing.txt
    sleep 1
  done
  ${WGRIB2} $COMINgfsm2/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 | \
  awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
  ${WGRIB2} $COMINgfsm2/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 -i -grib pgrb2hind206

  ${WGRIB2} $COMINgfsm2/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 | \
  awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
  ${WGRIB2} $COMINgfsm2/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 -i -grib pgrb2hind212

  ${WGRIB2} $COMINgfsm2/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 | \
  awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
  ${WGRIB2} $COMINgfsm2/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 -i -grib pgrb2hind218

  ${WGRIB2} $COMINgfsm1/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 | \
  awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
  ${WGRIB2} $COMINgfsm1/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 -i -grib pgrb2hind100

  ${WGRIB2} $COMINgfsm1/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 | \
  awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
  ${WGRIB2} $COMINgfsm1/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 -i -grib pgrb2hind106

  ${WGRIB2} $COMINgfsm1/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 | \
  awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
  ${WGRIB2} $COMINgfsm1/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 -i -grib pgrb2hind112

  ${WGRIB2} $COMINgfsm1/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 | \
  awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
  ${WGRIB2} $COMINgfsm1/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 -i -grib pgrb2hind118

  case "$cyc" in
  00)
# Cycle 0 needs 12Z 18Z of -3 day and 0Z of -2 day
    Start=$SECONDS
    while [[ ! -s $COMINgfsm3/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 || ! -s $COMINgfsm3/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 || ! -s $COMINgfsm2/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 ]] ; do
      Dura=$((SECONDS-Start))
      if [ $Dura -ge 600 ]; then
        msg="$job Error: Hindcast Wind file ${NETgfs}.*.sfluxgrbf00.grib2 is missed after 10 mins wait"
        postmsg "$jlogfile" "$msg"
        err_exit
      fi

      echo "`date`: Rank ${RANK} waiting for $COMINgfsm3/${NETgfs}.$CYCLE3.sfluxgrbf00.grib2" >> timing.txt
      sleep 1
    done
    ${WGRIB2} $COMINgfsm3/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfsm3/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 -i -grib pgrb2hind312

    ${WGRIB2} $COMINgfsm3/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfsm3/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 -i -grib pgrb2hind318

    ${WGRIB2} $COMINgfsm2/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfsm2/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 -i -grib pgrb2hind200
    ;;
  06)
# Cycle 6 needs 18Z of -3 day and 0Z of -2 day
    Start=$SECONDS
    while [[ ! -s $COMINgfsm3/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 || ! -s $COMINgfsm2/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 || ! -s $COMINgfs/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 ]] ; do
      Dura=$((SECONDS-Start))
      if [ $Dura -ge 600 ]; then
        msg="$job Error: Hindcast Wind file ${NETgfs}.*.sfluxgrbf00.grib2 is missed after 10 mins wait"
        postmsg "$jlogfile" "$msg"
        err_exit
      fi
      echo "`date`: Rank ${RANK} waiting for ${NETgfs}.*.sfluxgrbf00.grib2" >> timing.txt
      sleep 1
    done
    ${WGRIB2} $COMINgfsm3/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfsm3/${CYC4}/atmos/${NETgfs}.$CYCLE4.sfluxgrbf000.grib2 -i -grib pgrb2hind318

    ${WGRIB2} $COMINgfsm2/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfsm2/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 -i -grib pgrb2hind200

 # Cycle 6 needs 0Z of current day
    ${WGRIB2} $COMINgfs/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfs/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 -i -grib pgrb2hind000
    ;;
  12)
# Cycle 12 needs 0Z of -2 day
    Start=$SECONDS
    while [[ ! -s $COMINgfsm2/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 || ! -s $COMINgfs/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 || ! -s $COMINgfs/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 ]] ; do
      Dura=$((SECONDS-Start))
      if [ $Dura -ge 600 ]; then
        msg="$job Error: Hindcast Wind file ${NETgfs}.*.sfluxgrbf00.grib2 is missed after 10 mins wait"
        postmsg "$jlogfile" "$msg"
        err_exit
      fi
      echo "`date`: Rank ${RANK} waiting for ${NETgfs}.*.sfluxgrbf00.grib2" >> timing.txt
      sleep 1
    done
    ${WGRIB2} $COMINgfsm2/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfsm2/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 -i -grib pgrb2hind200

# Cycle 12 needs 0Z 6Z of current day
    ${WGRIB2} $COMINgfs/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfs/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 -i -grib pgrb2hind000

    ${WGRIB2} $COMINgfs/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfs/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 -i -grib pgrb2hind006
    ;;
  18)
    Start=$SECONDS
# Cycle 18 needs 0Z 6Z 12Z of current day
    while [[ ! -s $COMINgfs/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 || ! -s $COMINgfs/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 || ! -s $COMINgfs/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 ]] ; do
      Dura=$((SECONDS-Start))
      if [ $Dura -ge 600 ]; then
        msg="$job Error: Hindcast Wind file ${NETgfs}.*.sfluxgrbf00.grib2 is missed after 10 mins wait"
        postmsg "$jlogfile" "$msg"
        err_exit
      fi
      echo "`date`: Rank ${RANK} waiting for ${NETgfs}.*.sfluxgrbf00.grib2" >> timing.txt
      sleep 1
    done
    ${WGRIB2} $COMINgfs/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfs/${CYC1}/atmos/${NETgfs}.$CYCLE1.sfluxgrbf000.grib2 -i -grib pgrb2hind000

    ${WGRIB2} $COMINgfs/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfs/${CYC2}/atmos/${NETgfs}.$CYCLE2.sfluxgrbf000.grib2 -i -grib pgrb2hind006

    ${WGRIB2} $COMINgfs/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} $COMINgfs/${CYC3}/atmos/${NETgfs}.$CYCLE3.sfluxgrbf000.grib2 -i -grib pgrb2hind012
    ;;
  esac

  echo "`date`: Rank ${RANK} Finished Second copy of files" >> timing.txt
  echo "Finished second copy of files" > msg_Done_second_cp.txt

fi


while [[ ! -f msg_Done_second_cp.txt || ! -f msg_Done_first_cp.txt ]] ; do
  echo "`date`: Rank ${RANK} waiting for copying files." >> timing.txt
  sleep 1
done

if [[ ${RANK} == 0 || ${RANK} == 1 || ${RANK} == 2 || ${RANK} == 3 || ${RANK} == 4 || ${RANK} == 5 ]] ; then
######################################################################
#  Run program to extract current and forecast (future) global
#    surface pressure, and U and V wind vector fields.
######################################################################
  export pgm="etss_in_wind_fcst"
  . prep_step

  export FORT9=lon_GFST1534
  export FORT10=lat_GFST1534
  export FORT11=pgrb2foreALL

  if [[ ${RANK} == 0 ]] ; then

    export pgm="etss_in_wind_fcst"

    export FORT49=$PARMetss/model/mdl_ft11.egnkmw
    export FORT51=gfspuv.${cyc}e
    export FORT52=gfspuv.${cyc}g
    export FORT53=gfspuv.${cyc}n
    export FORT54=gfspuv.${cyc}k
    export FORT55=gfspuv.${cyc}m
    export FORT56=gfspuv.${cyc}w

    export FORT96=sds.${cyc}

    startmsg
    $EXECetss/etss_in_wind_fcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq gfspuv.${cyc}e gfspuv.${cyc}g gfspuv.${cyc}n gfspuv.${cyc}k gfspuv.${cyc}m gfspuv.${cyc}w $COMOUT/
    echo "Finished creating ForeCast Winds1" >> msg_FcstWinds1.txt
    echo "`date`: Rank ${RANK} Finished with Forecast winds" >> timing.txt

  elif [[ ${RANK} == 1 ]] ; then

    export FORT49=$PARMetss/model/mdl_ft11.nest1
    export FORT51=gfspuv.${cyc}pn2
    export FORT52=gfspuv.${cyc}pv2
    export FORT53=gfspuv.${cyc}ny3
    export FORT54=gfspuv.${cyc}de3
    export FORT55=gfspuv.${cyc}cp5
    export FORT56=gfspuv.${cyc}hor3

    export FORT96=sds.${cyc}

    startmsg
    $EXECetss/etss_in_wind_fcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq gfspuv.${cyc}pn2 gfspuv.${cyc}pv2 gfspuv.${cyc}ny3 gfspuv.${cyc}de3 gfspuv.${cyc}cp5 gfspuv.${cyc}hor3 $COMOUT/
    echo "`date`: Rank ${RANK} Finished with Forecast winds" >> timing.txt
    echo "Finished creating ForeCast Winds2" >> msg_FcstWinds2.txt

  elif [[ ${RANK} == 2 ]] ; then

    export FORT49=$PARMetss/model/mdl_ft11.nest2
    export FORT51=gfspuv.${cyc}ht3
    export FORT52=gfspuv.${cyc}il3
    export FORT53=gfspuv.${cyc}hch2
    export FORT54=gfspuv.${cyc}esv4
    export FORT55=gfspuv.${cyc}ejx3
    export FORT56=gfspuv.${cyc}co2

    export FORT96=sds.${cyc}
    startmsg
    $EXECetss/etss_in_wind_fcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq gfspuv.${cyc}ht3 gfspuv.${cyc}il3 gfspuv.${cyc}hch2 gfspuv.${cyc}esv4 gfspuv.${cyc}ejx3 gfspuv.${cyc}co2 $COMOUT/
    echo "`date`: Rank ${RANK} Finished with Forecast winds" >> timing.txt
    echo "Finished creating ForeCast Winds3" >> msg_FcstWinds3.txt

  elif [[ ${RANK} == 3 ]] ; then

    export FORT49=$PARMetss/model/mdl_ft11.nest3
    export FORT51=gfspuv.${cyc}pb3
    export FORT52=gfspuv.${cyc}hmi3
    export FORT53=gfspuv.${cyc}eke2
    export FORT54=gfspuv.${cyc}efm2
    export FORT55=gfspuv.${cyc}etp3
    export FORT56=gfspuv.${cyc}cd2

    export FORT96=sds.${cyc}

    startmsg
    $EXECetss/etss_in_wind_fcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq gfspuv.${cyc}pb3 gfspuv.${cyc}hmi3 gfspuv.${cyc}eke2 gfspuv.${cyc}efm2 gfspuv.${cyc}etp3 gfspuv.${cyc}cd2 $COMOUT/
    echo "`date`: Rank ${RANK} Finished with Forecast winds" >> timing.txt
    echo "Finished creating ForeCast Winds4" >> msg_FcstWinds4.txt

  elif [[ ${RANK} == 4 ]] ; then

    export FORT49=$PARMetss/model/mdl_ft11.nest4
    export FORT51=gfspuv.${cyc}ap3
    export FORT52=gfspuv.${cyc}hpa2
    export FORT53=gfspuv.${cyc}epn3
    export FORT54=gfspuv.${cyc}emo2
    export FORT55=gfspuv.${cyc}ms7
    export FORT56=gfspuv.${cyc}lf2

    export FORT96=sds.${cyc}
    startmsg
    $EXECetss/etss_in_wind_fcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq gfspuv.${cyc}ap3 gfspuv.${cyc}hpa2 gfspuv.${cyc}epn3 gfspuv.${cyc}emo2 gfspuv.${cyc}ms7 gfspuv.${cyc}lf2 $COMOUT/
    echo "`date`: Rank ${RANK} Finished with Forecast winds" >> timing.txt
    echo "Finished creating ForeCast Winds5" >> msg_FcstWinds5.txt

  elif [[ ${RANK} == 5 ]] ; then

    export FORT49=$PARMetss/model/mdl_ft11.nest5
    export FORT51=gfspuv.${cyc}ebp3
    export FORT52=gfspuv.${cyc}egl3
    export FORT53=gfspuv.${cyc}ps2
    export FORT54=gfspuv.${cyc}cr3
    export FORT55=gfspuv.${cyc}ebr3
    export FORT56=gfspuv.${cyc}eok3

    export FORT96=sds.${cyc}

    startmsg
    $EXECetss/etss_in_wind_fcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq gfspuv.${cyc}ebp3 gfspuv.${cyc}egl3 gfspuv.${cyc}ps2 gfspuv.${cyc}cr3 gfspuv.${cyc}ebr3 gfspuv.${cyc}eok3 $COMOUT/
    echo "`date`: Rank ${RANK} Finished with Forecast winds" >> timing.txt

    echo "Finished creating ForeCast Winds6" >> msg_FcstWinds6.txt
  fi

else

  CYCLE1='t00z'
  CYCLE2='t06z'
  CYCLE3='t12z'
  CYCLE4='t18z'
######################################################################
#  Run program to extract Past (historic) global surface pressure,
#    and U and V wind vector fields.
######################################################################
  export pgm="etss_in_wind_hindcst"
  . prep_step

  export FORT9=lon_GFST1534
  export FORT10=lat_GFST1534

  case "$cyc" in
  00)  # 00Z cycle
    export FORT11=pgrb2hind312
    export FORT12=pgrb2hind318
    export FORT13=pgrb2hind200
    export FORT14=pgrb2hind206
    export FORT15=pgrb2hind212
    export FORT16=pgrb2hind218
    export FORT17=pgrb2hind100
    export FORT18=pgrb2hind106
    export FORT19=pgrb2hind112
    export FORT20=pgrb2hind118
    ;;
  06)  # 06Z cycle
    export FORT11=pgrb2hind318
    export FORT12=pgrb2hind200
    export FORT13=pgrb2hind206
    export FORT14=pgrb2hind212
    export FORT15=pgrb2hind218
    export FORT16=pgrb2hind100
    export FORT17=pgrb2hind106
    export FORT18=pgrb2hind112
    export FORT19=pgrb2hind118
    export FORT20=pgrb2hind000
    ;;
  12)  # 12Z cycle
    export FORT11=pgrb2hind200
    export FORT12=pgrb2hind206
    export FORT13=pgrb2hind212
    export FORT14=pgrb2hind218
    export FORT15=pgrb2hind100
    export FORT16=pgrb2hind106
    export FORT17=pgrb2hind112
    export FORT18=pgrb2hind118
    export FORT19=pgrb2hind000
    export FORT20=pgrb2hind006
    ;;
  18)  # 18z cycle
    export FORT11=pgrb2hind206
    export FORT12=pgrb2hind212
    export FORT13=pgrb2hind218
    export FORT14=pgrb2hind100
    export FORT15=pgrb2hind106
    export FORT16=pgrb2hind112
    export FORT17=pgrb2hind118
    export FORT18=pgrb2hind000
    export FORT19=pgrb2hind006
    export FORT20=pgrb2hind012
    ;;
  esac

  if [[ ${RANK} == 6 ]] ; then

    export pgm="etss_in_wind_hindcst"

    export FORT30=$PARMetss/model/mdl_ft11.egnkmw
    export FORT51=cylf10.${cyc}e
    export FORT52=cylf10.${cyc}g
    export FORT53=cylf10.${cyc}n
    export FORT54=cylf10.${cyc}k
    export FORT55=cylf10.${cyc}m
    export FORT56=cylf10.${cyc}w

    export FORT96=sds.${cyc}

    startmsg
    $EXECetss/etss_in_wind_hindcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq cylf10.${cyc}e cylf10.${cyc}g cylf10.${cyc}n cylf10.${cyc}k cylf10.${cyc}m cylf10.${cyc}w $COMOUT/
    echo "Finished creating Hind Cast Winds for Extra Tropical Basins" >> msg_HindWinds1.txt
    echo "`date`: Rank ${RANK} Finished with Hind Cast winds." >> timing.txt

  elif [[ ${RANK} == 7 ]] ; then

    export FORT30=$PARMetss/model/mdl_ft11.nest1
    export FORT51=cylf10.${cyc}pn2
    export FORT52=cylf10.${cyc}pv2
    export FORT53=cylf10.${cyc}ny3
    export FORT54=cylf10.${cyc}de3
    export FORT55=cylf10.${cyc}cp5
    export FORT56=cylf10.${cyc}hor3

    export FORT96=sds.${cyc}

    startmsg
    $EXECetss/etss_in_wind_hindcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq cylf10.${cyc}pn2 cylf10.${cyc}pv2 cylf10.${cyc}ny3 cylf10.${cyc}de3 cylf10.${cyc}cp5 cylf10.${cyc}hor3 $COMOUT/
    echo "`date`: Rank ${RANK} Finished with Hind Cast winds." >> timing.txt
    echo "Finished creating Hind Cast Winds for Extra Tropical Basins" >> msg_HindWinds2.txt

  elif [[ ${RANK} == 8 ]] ; then

    export FORT30=$PARMetss/model/mdl_ft11.nest2
    export FORT51=cylf10.${cyc}ht3
    export FORT52=cylf10.${cyc}il3
    export FORT53=cylf10.${cyc}hch2
    export FORT54=cylf10.${cyc}esv4
    export FORT55=cylf10.${cyc}ejx3
    export FORT56=cylf10.${cyc}co2

    export FORT96=sds.${cyc}

    startmsg
    $EXECetss/etss_in_wind_hindcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq cylf10.${cyc}ht3 cylf10.${cyc}il3 cylf10.${cyc}hch2 cylf10.${cyc}esv4 cylf10.${cyc}ejx3 cylf10.${cyc}co2 $COMOUT/
    echo "`date`: Rank ${RANK} Finished with Hind Cast winds." >> timing.txt
    echo "Finished creating Hind Cast Winds for Extra Tropical Basins" >> msg_HindWinds3.txt

  elif [[ ${RANK} == 9 ]] ; then

    export FORT30=$PARMetss/model/mdl_ft11.nest3
    export FORT51=cylf10.${cyc}pb3
    export FORT52=cylf10.${cyc}hmi3
    export FORT53=cylf10.${cyc}eke2
    export FORT54=cylf10.${cyc}efm2
    export FORT55=cylf10.${cyc}etp3
    export FORT56=cylf10.${cyc}cd2

    export FORT96=sds.${cyc}

    startmsg
    $EXECetss/etss_in_wind_hindcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq cylf10.${cyc}pb3 cylf10.${cyc}hmi3 cylf10.${cyc}eke2 cylf10.${cyc}efm2 cylf10.${cyc}etp3 cylf10.${cyc}cd2 $COMOUT/
    echo "`date`: Rank ${RANK} Finished with Hind Cast winds." >> timing.txt
    echo "Finished creating Hind Cast Winds for Extra Tropical Basins" >> msg_HindWinds4.txt

  elif [[ ${RANK} == 10 ]] ; then

    export FORT30=$PARMetss/model/mdl_ft11.nest4
    export FORT51=cylf10.${cyc}ap3
    export FORT52=cylf10.${cyc}hpa2
    export FORT53=cylf10.${cyc}epn3
    export FORT54=cylf10.${cyc}emo2
    export FORT55=cylf10.${cyc}ms7
    export FORT56=cylf10.${cyc}lf2

    export FORT96=sds.${cyc}

    startmsg
    $EXECetss/etss_in_wind_hindcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq cylf10.${cyc}ap3 cylf10.${cyc}hpa2 cylf10.${cyc}epn3 cylf10.${cyc}emo2 cylf10.${cyc}ms7 cylf10.${cyc}lf2 $COMOUT/
    echo "`date`: Rank ${RANK} Finished with Hind Cast winds." >> timing.txt
    echo "Finished creating Hind Cast Winds for Extra Tropical Basins" >> msg_HindWinds5.txt

  elif [[ ${RANK} == 11 ]] ; then

    export FORT30=$PARMetss/model/mdl_ft11.nest5
    export FORT51=cylf10.${cyc}ebp3
    export FORT52=cylf10.${cyc}egl3
    export FORT53=cylf10.${cyc}ps2
    export FORT54=cylf10.${cyc}cr3
    export FORT55=cylf10.${cyc}ebr3
    export FORT56=cylf10.${cyc}eok3

    export FORT96=sds.${cyc}

    startmsg
    $EXECetss/etss_in_wind_hindcst >> $pgmout 2> errfile_${RANK}
    err=$?;export err; err_chk
#    cpreq cylf10.${cyc}ebp3 cylf10.${cyc}egl3 cylf10.${cyc}ps2 cylf10.${cyc}cr3 cylf10.${cyc}ebr3 cylf10.${cyc}eok3 $COMOUT/
    echo "`date`: Rank ${RANK} Finished with Hind Cast winds." >> timing.txt
    echo "Finished creating Hind Cast Winds for Extra Tropical Basins" >> msg_HindWinds6.txt
  fi
fi

exit
