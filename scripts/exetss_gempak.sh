#!/bin/bash
###################################################################
echo "----------------------------------------------------"
echo "exnawips - convert NCEP GRIB files into GEMPAK Grids"
echo "----------------------------------------------------"
echo "History: Mar 2000 - First implementation of this new script."
#####################################################################

set -xa

cd $DATA

msg="Begin job for $job"
postmsg "$jlogfile" "$msg"

yymmdd=`echo $PDY | cut -c 3-8`

NAGRIB=nagrib2_nc

#set default gempak variables
cpyfil=gds
gbtbls=
maxgrd=4999
kxky=
grdarea=
proj=
output=T
pdsext=no

# loop removed, now done in two separate calls for ala and con
#for domain in ala con; do
    if [ $domain = "ala" ] ; then
	resol="3km"
	label=( "ala"  "ala_arctic"      "ala_bering"      "ala_wgulf"          "ala_egulf" )
	garea=( ""     "61;177;75;-138"  "51;175;66;-160"  "42;-179.6;62;-148"  "46;-150;56;-111" )
    elif [ $domain = "con" ] ; then
	resol="2p5km"
	label=( "con"  "con_nwcoast"        "con_swcoast"          "con_necoast"        "con_secoast"           "con_gulf" )
	garea=( ""     "39;-126.2;50;-122"  "26;-122.8;41;-115.8"  "35;-78;45.6;-62.8"  "22.22;-84;35.5;-72.5"  "22.6;-98.5;31;-81"  )
    else
	echo "FATAL ERROR: Unknown domain: " $domain
	postmsg  "$jlogfile"  "FATAL ERROR in GEMPAK: Unknown domain"
	err=1; export err; err_chk

    fi

    for extf in surge tide ; do

    if [ ${extf} = "surge" ] ; then
       outf="surge"
    else
       outf="surge_tide"
    fi

    GRIBIN=${COMIN}/etss.${cycle}.storm${extf}.${domain}${resol}.grib2
    sleep 20
    cpfs $GRIBIN grib${domain}

    index=0
    for region in ${label[@]} ; do
	GEMGRD=${outf}_${resol}_${region}_${PDY}
	rm -f $GEMGRD

	$NAGRIB << EOF
   GBFILE   = grib${domain}
   INDXFL   = 
   GDOUTF   = $GEMGRD
   PROJ     = $proj
   GRDAREA  = $grdarea
   KXKY     = $kxky
   MAXGRD   = $maxgrd
   CPYFIL   = $cpyfil
   GAREA    = ${garea[index]}
   OUTPUT   = $output
   G2TBLS   = $gbtbls
   G2DIAG   = $g2diag
   PDSEXT   = $pdsext
  l
  r
EOF
    
	export err=$?;err_chk

	if [ $SENDCOM = "YES" ] ; then
            cpfs $GEMGRD $COMOUT/${GEMGRD}${cyc}
	fi
	
	if [ $SENDDBN = "YES" ] ; then
            $DBNROOT/bin/dbn_alert MDLFCST ${DBN_ALERT_TYPE} $job $COMOUT/${GEMGRD}${cyc}
	else
            echo "##### DBN_ALERT_TYPE is: ${DBN_ALERT_TYPE} - $COMOUT/$GEMGRD$cyc #####"
	fi
	
	(( ++index ))
    done
    
    done
#####################################################################
# GOOD RUN
set +x
msg='ETSS GEMPAK JOB COMPLETED NORMALLY'
echo "**************"
echo "************** $msg"
echo "**************"
set -x
#####################################################################

postmsg "$jlogfile" "$msg"

############################### END OF SCRIPT #######################
