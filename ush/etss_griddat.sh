#!/bin/sh

# ##############################################################################
# exetsurge_griddat.sh
# ##############################################################################
# Author: Ryan Schuster (ryan.schuster@noaa.gov)
# Abstract: 
# 1) Copy parsed BUFR files and surge text products to working directory
# 2) Call obsAll executable to create a grid of observed water levels
#    where each row represents a date and each column represents a station
# 3) Call surgeAll executable to parse surge text products and create a
#    similar grid of surge values
# 4) Call tideAll to calculate tides encompasing the five-day hindcast to
#    the 96-hour forecast and create a grid of those tides
#
# Parameters:
#  Inputs:  Various environmental variables declared upstream in ecflow
#           and in the j-job jobs/JETSURGE_GRIDDAT
#  Outputs: poescript_grid - list of executables for mpirun.lsf
#           obsGrid, tideGrid, surgeGrid - grids of obs, tide and surge
#                                          values
################################################################################
################################################################################
# Updated by: Huiqing.Liu 04/2016
#             1) Extended forecast hour from 96 to 102 hr
#             2) Move from WCOSS to CRAY
# Updated by: Huiqing.Liu 03/2018
#             Don't use POE at all.
# Updated by: Huiqing.Liu 07/2020
#             1) Added more bufr tank data
################################################################################

set -xa
msg="Starting job $job"
postmsg "$jlogfile" "$msg"

export RANK=$1

#export pgm=poescript_grid
. prep_step

# ################################
# Fortran file unit variables
# ################################
# Any file's path length can change (assuming max possible path length of 255 characters)

# General I/O used by everyone
export FORT11=${HOMEetss}/parm/master.csv
export FORT12=datelist

# I/O used by lib/sorc/mybufr/combineObs.f (i.e. exec/obsAll)
export FORT13=fns_obs.txt
# FORT54 is a placeholder. '00000000' will be overwritten with date-based filenames
# from fns_obs.txt
export FORT54=out/00000000.shef12 # in sorc/etss_post_obsALL/combineObs.f
export FORT55=out/00000000.shef05 # in sorc/etss_post_obsALL/combineObs.f
export FORT56=out/00000000.shef13 # in sorc/etss_post_obsALL/combineObs.f
export FORT51=obsGrid

# I/O used by sorc/surgeAll.fd/getsurge.f (i.e. exec/surgeAll)
export FORT14=fns_ss.txt
export FORT52=surgeGrid

# I/O used by lib/sorc/tide/gettide.f, sectide.f, calctide.f (i.e. exec/tideAll)
export FORT15=HSBY
export FORT16=${HOMEetss}/parm/tide/reordFT03.csv
# FORT17 is a placeholder. The '0000000' part will be overwritten with different station id's
export FORT17=${HOMEetss}/parm/tide/constits/0000000.csv # in lib/sorc/tide/gettide.f
export FORT53=tideGrid

# ########################################################
# Copy over surge text products and parsed and BUFR files
# ########################################################
if [[ ${RANK} == 1 ]] ; then
   mkdir -p out
   cd out
   cp $COMIN/*.shef12 .
   cp $COMIN/*.shef05 .
   cp $COMIN/*.shef13 .
   cd ..
   cp $COMIN/*.ss .
   cpreq $COMIN/fns_ss.txt .
   cpreq $COMIN/fns_obs.txt .
   cpreq $COMIN/datelist .
   cpreq $COMIN/HSBY .
   echo "Bufr Tank data is copied" > msg_Done_cp.txt
fi

while [[ ! -f msg_Done_cp.txt ]] ; do
  echo "`date`: Rank ${RANK} Sleeping." >> timing.txt
  sleep 1
done

if [[ ${RANK} == 0 ]] ; then
   export pgm=etss_post_obsAll
   startmsg
   ${EXECetss}/etss_post_obsAll >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk
   if [ $SENDCOM = "YES" ] ; then
    cpreq obsGrid $COMOUT
   fi
elif [[ ${RANK} == 1 ]] ; then
   export pgm=etss_post_surgeAll
   startmsg
   ${EXECetss}/etss_post_surgeAll >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk
   if [ $SENDCOM = "YES" ] ; then
    cpreq surgeGrid $COMOUT
   fi
elif [[ ${RANK} == 2 ]] ; then
   export pgm=etss_post_tideAll
   startmsg
   ${EXECetss}/etss_post_tideAll >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk
   if [ $SENDCOM = "YES" ] ; then
    cpreq tideGrid $COMOUT
   fi
fi

msg="$job completed normally"
postmsg "$jlogfile" "$msg"
