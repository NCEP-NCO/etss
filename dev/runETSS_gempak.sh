#!/bin/bash -l

if [ $# -ne 4 ] ; then
  now=$(date +"%Y%m%d")
  echo "You are trying to run the Gempak but you missed something--"
  echo ""
  echo "Usage $0 <date ${now}> <cycle (00, 06, 12, 18)> <domain (con,ala)> <skip etss model run (Y/N)>"
  echo ""
  exit
fi

set -x

module load prod_util

# Determin which system do you run the model

export PDY=$1
export cyc=$2
export dom=$3
export jump=$4
export cycle=t${cyc}z




export MDLFORCEDATE=yes

# Add some debugs...
set -xa

src=$(cd $(dirname $0) && pwd)
root=${src}

###############################################
#  Indicate to the J script that this is an 
#  "MDLTEST" and don't delete the running data
###############################################
export KEEPDATA=NO
###############################################
#  Directory for MDL copy of com, pcom, tmp
###############################################

export HOMEetss=$(cd $(dirname $0) && cd ../ && pwd)

export MDLTEST_DIR=${HOMEetss}/dev/etss.v2.3.0

export envir=prod
cnt=0
while [ -e ${MDLTEST_DIR}/tmpnwprd1/take${cnt} && ! "$(ls -A ${MDLTEST_DIR}/tmpnwprd1/take${cnt})" ] ; do
#while [[ ! "$(ls -A ${MDLTEST_DIR}/tmpnwprd1/take${cnt})" ]] ; do
   cnt=$[$cnt+1]
done
mkdir -p ${MDLTEST_DIR}
mkdir -p ${MDLTEST_DIR}/tmpnwprd1/take${cnt}
mkdir -p ${MDLTEST_DIR}/$envir/com/logs


export COMROOT=${MDLTEST_DIR}/$envir/com
export COMIN=${MDLTEST_DIR}/$envir/com/etss/v2.4/etss.${PDY}
#export PCOMROOT=${MDLTEST_DIR}/pcom
export DATAROOT=${MDLTEST_DIR}/tmpnwprd1/take${cnt}
export DBNROOT=$HOMEetss/dev/dbnet

cd ${MDLTEST_DIR}/tmpnwprd1
setpdy.sh
. PDY


#export jlogfile=${COMROOT}/logs/jlogfile_gempak.${PDY}.${cyc}

export SENDCOM=${SENDCOM:-YES}
export SENDDBN=${SENDDBN:-YES}

export job=${dom}_${PDY}_${cyc}
export outid="gempak_$job"
export jobid="${outid}.o${pid}"

export job=etss_gempak_${PDY}_${cyc}

###############################################
# Kick off the LSF script
###############################################
if [[ ${dom} == con ]] ; then
   export domain=con
else
   export domain=ala
fi
   ${HOMEetss}/dev/myEcf/jetss_gempak.ecf


############################################################

exit
############## END OF SCRIPT #######################
