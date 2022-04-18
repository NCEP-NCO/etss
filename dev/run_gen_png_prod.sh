#!/bin/bash -l


module load prod_util

set -x

if [ $# -ne 3 ] ; then
  echo "This exec's the ETSS model but you miss something......."
  echo ""
  echo "Usage $0 <date 20130104> <cycle (00, 06, 12, 18)> <skip etss model run (Y/N)>"
  echo ""
  exit
fi

export PDY=$1
export cyc=$2
export jump=$3

export cycle=t${cyc}z

# Made it so we always have to get data

src=$(cd $(dirname $0)/.. && pwd)
root=${src}
export HOMEetss=${root}

export MDLTEST_DIR=${HOMEetss}/dev/etss.v2.3.0

export envir=prod
export COMROOT=${MDLTEST_DIR}/$envir/com
export COMIN=${MDLTEST_DIR}/$envir/com/etss/v2.4/etss.${PDY}

mkdir -p ${MDLTEST_DIR}/tmpnwprd1/

mkdir -p ${MDLTEST_DIR}/$envir/com/logs/

export job=etssImg_${PDY}_${cyc}
export outid="LL$job"
export jobid="${outid}.o${pid}"

export DATAROOT=${MDLTEST_DIR}/tmpnwprd1/
#export jlogfile=${COMROOT}/logs/jlogfile_Img.${PDY}.${cyc}

export RUN_ENVIR=MDLTEST
export KEEPDATA=NO



cd ${MDLTEST_DIR}/tmpnwprd1
setpdy.sh
. PDY


###############################################
# Kick off the LSF script
###############################################
${HOMEetss}/dev/myEcf/jetss_drawimages.ecf

############################################################

exit
############## END OF SCRIPT #######################
