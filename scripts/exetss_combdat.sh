#!/bin/sh

# ####################################################################################
# exetsurge_combdat.sh
# ####################################################################################
# Author: Ryan Schuster (ryan.schuster@noaa.gov)
# Abstract:
# 1) Calls the combAll executable to combine tideGrid, obsGrid, and
#    surgeGrid (see exetsurge_griddat.sh)
# 2) combAll uses the grids to create output SHEF-encoded files which
#    stored in ${COMIN}, along with specially-formatted .csv files
#
# Parameters:
#  Inputs:  Various envrionmental variables declared upstream in ecflow
#           and in the j-job jobs/JETSURGE_COMBDAT
#  Outputs: ${COMOUT}/xxxxxxx.csv - specially-formatted .csv files containing tide,
#                                   obs, and surge data where the 'xxxxxxx' is the 
#                                   station's COOPS ID number
#           ${COMOUT}/shef.etss.t${HH}z.totalwater.${label}  - 
#             output shef files where HH is the latest forecast cycle and 
#             label is the relevant geographical basin
# Revised by Huiqing Liu 
# Format of xxxxxxx.csv
#
# Time, Tide, Obs (stations with NWSLI), Surge, Diff between obs and tide, bias corrected total water
#
######################################################################################
######################################################################################
# Updated by: Huiqing.Liu 04/2016
#             1) Extended forecast hour from 96 to 102 hr
#             2) Move from WCOSS to CRAY
# Updated by: Huiqing.Liu 07/2020
#             1) Added more bufr tank data
######################################################################################

set -xa
msg="Starting job $job"
postmsg "$jlogfile" "$msg"


# Get latest forecast hour
declare -a  hrs=('00' '06' '12' '18')
ind=$((${cyc}/6))
HH=${hrs[${ind}]}

# ################################
# Fortran file unit variables
# ################################
export pgm=combAll
. prep_step
# Any file's path length can change (assuming max possible path length of 255 characters)

# General I/O used by everyone
export FORT10=${HOMEetss}/parm/model/mllw.csv
export FORT11=${HOMEetss}/parm/master.csv
export FORT12=${DATA}/datelist

# I/O used by sorc/combAll.fd/combineAll.f
export FORT13=${DATA}/surgeGrid
export FORT14=${DATA}/tideGrid
export FORT15=${DATA}/obsGrid

declare -a shef=(FORT51 FORT52 FORT53 FORT54 FORT55)
declare -a area=('US' 'US' 'US' 'AK' 'AK')
declare -a awips=('TWE' 'TWG' 'TWP' 'TWC' 'TWB')
declare -a label=('est' 'gom' 'wst' 'goa' 'ber')
declare -a member=('srus70_est' 'srus70_gom' 'srus70_wst' 'srak70_goa' 'srak70_ber')
for i in `seq 0 4` ; do
  export ${shef[${i}]}=${COMOUT}/shef.etss.t${HH}z.totalwater.${label[$i]}
done

# This is a placeholder in sorc/combAll.fd/combineAll.f where '0000000' is replaced with
# station COOPS ID if necessary
mkdir -p ${COMOUT}/t${HH}z_csv
export FORT57=${COMOUT}/t${HH}z_csv/0000000.csv

# ###############################################
# Copy all necessary input files from $COMIN
# ###############################################
cpreq $COMIN/tideGrid .
cpreq $COMIN/surgeGrid .
cpreq $COMIN/obsGrid .
cpreq $COMIN/datelist .
cpreq $COMIN/HSBY .

# Execute...
startmsg
${EXECetss}/etss_post_combAll >> $pgmout 2> errfile
err=$?; export err; err_chk

# ################################
# Create DBnet alert
# ################################

if [[ $SENDCOM == "YES" ]] ; then
    cd ${COMOUT}/../
    tar  -cvf ${COMOUT}/etss.t${HH}z.shef_tar ${RUN}.${PDY}/shef.etss.t${HH}z.*
    tar -zcvf ${COMOUT}/etss.t${HH}z.csv_tar ${RUN}.${PDY}/t${HH}z_csv/*.csv
    cd ${DATA}
fi

if [ $SENDDBN = "YES" ] ; then
    $DBNROOT/bin/dbn_alert MDLFCST ETSSCSV $job ${COMOUT}/etss.t${HH}z.csv_tar
    $DBNROOT/bin/dbn_alert MDLFCST ETSSBULL $job ${COMOUT}/etss.t${HH}z.shef_tar
    if [ $SENDDBN_NTC = "YES" ]
    then

	for i in `seq 0 4` ; do
	    file=shef.etss.t${HH}z.totalwater.${label[$i]}
            $USHutil/form_ntc.pl -d ${member[$i]} -f ${COMOUT}/$file -j $job -m $NET -p $COMOUTwmo -s $SENDDBN_NTC -o $file -n
            export err=$?; err_chk
	done

    fi
fi

msg="$job completed normally"
postmsg "$jlogfile" "$msg"

if [[ ${RUN_ENVIR} == "MDLTEST" ]] ; then
   echo $msg > ${MDLTEST_DIR}/tmpnwprd1/post_finish.txt
fi
