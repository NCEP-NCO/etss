#!/bin/sh

# ###########################################################################################
# Author: Huiqing Liu (Huiqing.Liu@noaa.gov)                                      09-24-2021
#
# Abstract:
#   Creat poe-script and submit the jobs to create obs, surge, and tide grid data in
#   post-processing stage
#
# Parameters:
#  Inputs:  Various environmental variables defined either in ecflow or in the
#           j-job jobs/JETSS
#  Outputs: poe-script - list of running scripts for mpiexec
# ###########################################################################################

#############################################################################################
# 09-24-2021: Created by Huiqing Liu
#############################################################################################

set -xa
#==============================================================================
# Create poe-script by iterating over the RANK
#------------------------------------------------------------------------------
rm -f poeGriddat
for (( c=0; c<3; c++ )) ; do
    echo "${USHetss:?}/etss_griddat.sh ${c}" >> poeGriddat
done

chmod 755 poeGriddat
mpiexec -n 3 -ppn 3 --cpu-bind core cfp poeGriddat
export err=$?; err_chk

#####################################################################
# GOOD RUN
set +x
echo "**************JOB ETSS_GRIDDAT COMPLETED NORMALLY"
echo "**************JOB ETSS_GRIDDAT COMPLETED NORMALLY"
echo "**************JOB ETSS_GRIDDAT COMPLETED NORMALLY"
set -x
#####################################################################

