#!/bin/bash
# --- 02/07/97 ---------- EXSURGE SCRIPT --------------------------
#
set +x
echo " ---------------------------------------------------------"
echo "  "
echo "              EXTROPICAL STORM SURGE"
echo "  "
echo "  "
echo "                   JOB ETSS "
echo "  "
echo "          ANALYSIS CYCLE TIME IS .. $CYCLE"
echo "  "
echo "  "
echo " ---------------------------------------------------------"
echo " ---------------------------------------------------------"
   # Author: Huiqing Liu (Huiqing.Liu@noaa.gov)
   # Abstract:
   #   Creat poe-script and submit the jobs to run the etss model stage
   #
   # " 09/16/21 - The First Version of ETSS2.4 for WCOSS 2
   # " ---------------------------------------------------------"
   # Parameters:
   #  Inputs:  Various environmental variables defined either in ecflow or in the
   #           j-job jobs/JETSS
   #  Outputs: poe-script - list of running scripts for mpiexec
   #           ETSS text products - ${COMOUT}/etss.t${cyc}z.storm*.txt
   #           ETSS native resolution gridded data - ${DATA}/fle*


set -x
#==============================================================================
# Create poe-script by iterating over the RANK
#------------------------------------------------------------------------------
rm -f poeSLOSH
for (( c=0; c<14; c++ )) ; do
    echo "${USHetss:?}/etss_model.sh ${c}" >> poeSLOSH
done

chmod 755 poeSLOSH
mpiexec -n 14 -ppn 14 --cpu-bind core cfp poeSLOSH
export err=$?; err_chk

#####################################################################
# GOOD RUN
set +x
echo "**************JOB ETSS_MODEL COMPLETED NORMALLY"
echo "**************JOB ETSS_MODEL COMPLETED NORMALLY"
echo "**************JOB ETSS_MODEL COMPLETED NORMALLY"
set -x
#####################################################################

