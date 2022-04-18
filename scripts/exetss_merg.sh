#!/bin/bash
# ###########################################################################################
# Author: Huiqing Liu (Huiqing.Liu@noaa.gov)                                      09-24-2021
#
# Abstract:
#   Creat poe-script and submit the jobs to merging gridded products stage
#
# Parameters:
#  Inputs:  Various environmental variables defined either in ecflow or in the
#           j-job jobs/JETSS
#  Outputs: poe-script - list of running scripts for mpiexec
#           Merging model native resolution data into CONUS/ALASKA common grids after model run
#           Stormtide data for CONUS 2p5km/625m, ALA 3km grids
#           Stormsurge data for CONUS 2p5km, ALA 3km grids
#           TideOnly data for CONUS 625m grid
#           - ${COMOUT}/etss.t${cyc}z.*grib2
# ###########################################################################################

#############################################################################################
# 09-24-2021: Created by Huiqing Liu
#############################################################################################

set -x
#==============================================================================
# Create poe-script by iterating over the RANK
#------------------------------------------------------------------------------
rm -f poeMerg
for (( c=0; c<4; c++ )) ; do
    echo "${USHetss:?}/etss_merg.sh ${c}" >> poeMerg
done

chmod 755 poeMerg
mpiexec -n 4 -ppn 4 --cpu-bind core cfp poeMerg
export err=$?; err_chk

#####################################################################
# GOOD RUN
set +x
echo "**************JOB ETSS_MERG COMPLETED NORMALLY"
echo "**************JOB ETSS_MERG COMPLETED NORMALLY"
echo "**************JOB ETSS_MERG COMPLETED NORMALLY"
set -x
#####################################################################

