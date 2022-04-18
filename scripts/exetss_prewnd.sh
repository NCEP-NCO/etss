#!/bin/bash
# ###########################################################################################
# exetss_prewnd.sh.ecf
# ###########################################################################################
# Author: Huiqing Liu (Huiqing.Liu@noaa.gov)                                         09/24/21
# Abstract:
#   Creat poe-script and submit the jobs to prepare wind stage
#
# Parameters:
#  Inputs:  Various environmental variables defined either in ecflow or in the
#           j-job jobs/JETSS
#  Outputs: poe-script - list of running scripts for mpiexec
#           WIND files for each of basins - ${COMOUT}/gfspuv.${cyc}* ${COMOUT}/cylf10${cyc}*
#
#############################################################################################
# 09-24-2021: Created by Huiqing Liu
#############################################################################################
set -x
#==============================================================================
# Create poe-script by iterating over the RANK
#------------------------------------------------------------------------------
rm -f poePreWnd
for (( c=0; c<13; c++ )) ; do
    echo "${USHetss:?}/etss_prewnd.sh ${c}" >> poePreWnd
done

cpreq $PARMetss/model/lon_GFST1534 ./
cpreq $PARMetss/model/lat_GFST1534 ./

chmod 755 poePreWnd
mpiexec -n 13 -ppn 13 --cpu-bind core cfp poePreWnd
export err=$?; err_chk

#####################################################################
# GOOD RUN
set +x
echo "**************JOB ETSS_PRE_WND COMPLETED NORMALLY"
echo "**************JOB ETSS_PRE_WND COMPLETED NORMALLY"
echo "**************JOB ETSS_PRE_WND COMPLETED NORMALLY"
set -x
#####################################################################

