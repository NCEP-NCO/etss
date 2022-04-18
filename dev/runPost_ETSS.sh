#!/bin/bash -l

module load prod_util

if [ $# -ne 3 ] ; then
  echo "You are trying to run the ETSS post processing but you missed something--"
  echo ""
  echo "Usage $0 <date ${now}> <cycle (00, 06, 12, 18)> <skip etss model run (Y/N)>"
  echo ""
  exit
fi

set -x

export PDY=$1
export cyc=$2
export jump=$3

module load PrgEnv-intel

# ##################################################################################
# MDL-specific env vars that need to be declared here and/or get used by everything
# ##################################################################################
#export DCOMROOT="/gpfs/dell1/nco/ops/dcom"
# bufrTank b255/xx102 diretory (restricted access data)
#export DCOMROOT1="/gpfs/hps3/ptmp/Huiqing.Liu/petss.v1.2.0_ecmwf/com/bufrtank"
#export DCOMbase1=${DCOMROOT1}/prod

export HOMEetss=$(cd $(dirname $0) && cd ../ && pwd)

export MDLTEST_DIR=${HOMEetss}/dev/etss.v2.3.0

#export DCOMROOT="${MDLTEST_DIR}/dcom"
export CANNEDROOT=/lfs/h1/ops/canned
export DCOMROOT="${CANNEDROOT}/dcom"
export DCOMROOT1="${CANNEDROOT}/dcom"
export DCOMbase1=${DCOMROOT1}
export DCOMbase=${DCOMROOT}

export envir=prod

cnt=0
while [[ -e ${MDLTEST_DIR}/tmpnwprd1/take${cnt} && ! "$(ls -A ${MDLTEST_DIR}/tmpnwprd1/take${cnt})" ]] ; do
   cnt=$[$cnt+1]
done
mkdir -p ${MDLTEST_DIR}
mkdir -p ${MDLTEST_DIR}/tmpnwprd1/take${cnt}
mkdir -p ${MDLTEST_DIR}/$envir/com/logs

export COMROOT=${MDLTEST_DIR}/$envir/com
export COMIN=${MDLTEST_DIR}/$envir/com/etss/v2.4/
export DATAROOT=${MDLTEST_DIR}/tmpnwprd1/take${cnt}
export DBNROOT=$HOMEetss/dev/dbnet

export RUN_ENVIR=MDLTEST

# Get the current hour and use it to find last fcst cycle hour
export cycle="t${cyc}z"

# Options
export SENDECF="NO"
export SENDCOM="YES"
export SENDPCOM="YES"
export SENDDBN="YES"
export SENDDBN_NTC="YES"
export KEEPDATA="NO"

cd ${MDLTEST_DIR}/tmpnwprd1

setpdy.sh
. PDY

export jlogfile=${COMROOT}/logs/jlogfile_post.${PDY}.${cyc}

cd ${DATAROOT}

# #########################
# Execute the .ecf scripts
# #########################
declare -a jobs=('jetss_parsedat.sh.ecf' 'jetss_griddat.sh.ecf' 'jetss_combdat.sh.ecf')

## If this is being run by the SPA:
if test "$SENDECF" = "YES" ; then
  job=etss_test
  jobid=etss_test
  ECF_NAME=${ECF_NAME:-${HOMEetss}/ecf/}
  NETNAME=`echo $ECF_NAME | sed -e "s+/++g"`

  for job in `cat etsurge_joblist` ; do
   ecflow_client --force complete recursive $NETNAME/${job}
   ecflow_client --alter change defstatus queued $NETNAME/$job
   ecflow_client --requeue $NETNAME/${job}
   ecflow_client --alter change defstatus complete $NETNAME/$job
 done
else
  # Can't use ecflow, so use bsub
  for j in ${jobs[@]} ; do
    ecfName=${j}
    case "${j}" in
    jetss_parsedat.sh.ecf)
      export job=etss_parsedat
      export jobid=etss_parsedat_${cyc}.o${pid}
      export etss_parsedat_id=$(${HOMEetss}/dev/myEcf/${ecfName})
      ;;
    jetss_griddat.sh.ecf)
      export COMIN=${MDLTEST_DIR}/$envir/com/etss/v2.4/etss.${PDY}	    
      export job=etss_griddat
      export jobid=etss_griddat_${cyc}.o${pid}
      export etss_griddat_id=$(${HOMEetss}/dev/myEcf/${ecfName})
      ;;
    jetss_combdat.sh.ecf)
      export COMIN=${MDLTEST_DIR}/$envir/com/etss/v2.4/etss.${PDY}	    
      export job=etss_combdat
      export jobid=etss_combdat_${cyc}o${pid}
      export etss_combdat_id=$(${HOMEetss}/dev/myEcf/${ecfName})
      ;;
    esac
  done
fi

