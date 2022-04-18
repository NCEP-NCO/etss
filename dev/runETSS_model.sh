#!/bin/bash -l


module load prod_util

if [ $# -ne 4 ] ; then
  now=$(date +"%Y%m%d")
  echo "You are trying to run the ETSS model but you missed something--"
  echo ""
  echo "Usage $0 <date ${now}> <cycle (00, 06, 12, 18)> <COPY Data (copy/no-copy)>"
  echo ""
  exit
fi

set -x

export PDY=$1
export cyc=$2
export cycle=t${cyc}z

# Paramter to determin whether model need copy data from DATA TANK
export f_GetData=$3
export web=$4

export MDLFORCEDATE=yes

# Add some debugs...
set -xa

src=$(cd $(dirname $0) && pwd)
root=${src}

###############################################
#  Indicate to the J script that this is an 
#  "MDLTEST" and don't delete the running data
###############################################
export RUN_ENVIR=MDLTEST
export KEEPDATA=NO
export envir=prod
#export envir=canned

###############################################
#  Directory with MDL copy of jobs, scripts, ush, parm, fix
###############################################
export MDLTEST_HOME=${root}
export MDLTEST_DIR=${root}/etss.v2.3.0

###############################################
#  Directory for MDL copy of com, pcom, tmp
###############################################
cnt=0
while [ -e ${MDLTEST_DIR}/tmpnwprd1/take${cnt} && ! "$(ls -A ${MDLTEST_DIR}/tmpnwprd1/take${cnt})" ] ; do
   cnt=$[$cnt+1]
done

mkdir -p ${MDLTEST_DIR}/$envir/com
mkdir -p ${MDLTEST_DIR}/tmpnwprd1/take${cnt}
mkdir -p ${MDLTEST_DIR}/$envir/com/logs

export COMROOT=${MDLTEST_DIR}/$envir/com
export COMROOTp1=${MDLTEST_DIR}/$envir/com

export DATAROOT=${MDLTEST_DIR}/tmpnwprd1/take${cnt}
export DBNROOT=${MDLTEST_HOME}/dbnet
#export etss_ver=2.3.0
export HOMEetss=${MDLTEST_HOME}/..
export SENDDBN_NTC=YES

export SENDCOM=${SENDCOM:-YES}
export SENDDBN=${SENDDBN:-YES}
export SENDECF=${SENDECF:-YES}

# Need PDYm1, PDYm2, PDYm3

cd ${MDLTEST_DIR}/tmpnwprd1

setpdy.sh
. PDY

#export jlogfile=${COMROOT}/logs/jlogfile.${PDY}.${cyc}
###############################################
# COPY GFS data from DATA TANK
###############################################
#export GFS_V=$(compath.py gfs/prod/gfs.$PDY)
if [[ $f_GetData == "copy" && ${RUN_ENVIR} == "MDLTEST" ]] ; then
  if [ -f ${GFS_V}/${cyc}/atmos/gfs.${cycle}.sfluxgrbf102.grib2 ]; then
     ${root}/setup/setup.sh
  else
    ${root}/setup/setup_prod.sh
  fi
  
fi

if [[ ${RUN_ENVIR} == "MDLTEST" ]] ; then
  export COMPATH=${COMROOT}
  export CANNEDROOT=/lfs/h1/ops/canned
#  export COMINgfs=${COMROOT}/gfs/prod/gfs.${PDY}
#  export COMINgfsm1=${COMROOT}/gfs/prod/gfs.${PDYm1}
#  export COMINgfsm2=${COMROOT}/gfs/prod/gfs.${PDYm2}
#  export COMINgfsm3=${COMROOT}/gfs/prod/gfs.${PDYm3}
  export COMINSS=${COMROOT}/etss/v2.4
  export COMINgfs=${CANNEDROOT}/com/gfs/v16.2/gfs.${PDY}
  export COMINgfsm1=${CANNEDROOT}/com/gfs/v16.2/gfs.${PDYm1}
  export COMINgfsm2=${CANNEDROOT}/com/gfs/v16.2/gfs.${PDYm2}
  export COMINgfsm3=${CANNEDROOT}/com/gfs/v16.2/gfs.${PDYm3}
fi

###############################################
# Kick off the LSF script
###############################################

export job=etss_prewnd_${PDY}_${cyc}
export outid="LL$job"
export jobid="${outid}.o${pid}"
export etss_prewnd_id=$(${root}/myEcf/jetss_prewnd.ecf)

export job=etss_${PDY}_${cyc}
export outid="LL$job"
export jobid="${outid}.o${pid}"
export etss_id=$(${root}/myEcf/jetss.ecf)

export etss_merg_id=$(${root}/myEcf/jetss_merg.ecf)


${root}/runPost_ETSS.sh ${PDY} ${cyc} N
${root}/runETSS_gempak.sh ${PDY} ${cyc} con N       #submit gempak job for conus grid
${root}/runETSS_gempak.sh ${PDY} ${cyc} ala N       #submit gempak job for ala grid
if [[ ${web} == "Y" ]] ; then
   ${root}/run_gen_png_prod.sh ${PDY} ${cyc} N
fi
############################################################

exit
############## END OF SCRIPT #######################
