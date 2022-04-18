#!/bin/bash
#
#!/bin/bash
# ###########################################################################################
# etss_merg.sh
# ###########################################################################################
# Author: Huiqing Liu (Huiqing.Liu@noaa.gov)                                      09-24-2021
# 1) Merging model native resolution data into CONUS/ALASKA common grids after model run
#    Stormtide data for CONUS 2p5km/625m, ALA 3km grids
#    Stormsurge data for CONUS 2p5km, ALA 3km grids
#    TideOnly data for CONUS 625m grid
# ###########################################################################################

#############################################################################################
# 09-24-2021: Created by Huiqing Liu
#############################################################################################

set -x
export RANK=$1

echo "`date`: Start Rank ${RANK}" >> timing.txt

msg="Begin job for $job"
postmsg "$jlogfile" "$msg"
  
#####################################################################
# Merge the results onto NDFD Conus (con) 
# This is a copy of what is in "gridmerge.sh.sms"
#####################################################################
  ####################################################################
  #  Run gridmerge program
  ####################################################################
  
if [[ ${RANK} == 0 ]] ; then

   . prep_step
   
   echo "`date`: Rank ${RANK} gridmerge 2.5km CONUS using nesting tropical basins for surge_tide run" >> timing.txt
   area=con
   area1=con1
   gridhighres=2p5km
   NESTYN=Y
   fle_ext=surge_tide
   fle_extf=stormtide

   export pgm="etss_out_grid"

   ##########set up date info... PDY is today, PDYm1 one day ago... etc.
   echo $PDY $cyc > $DATA/datetime.${area1}.txt
   export FORT48=$DATA/datetime.${area1}.txt
   ##########write area and cycle into control file
   echo $area $fle_extf $NESTYN 1 103 > $DATA/control.${area1}.txt
   export FORT11=$DATA/control.${area1}.txt

   export FORT10=$PARMetss/mergemask/mask_f.txt
   export FORT12=$PARMetss/mergemask/mdl_etgrids.${area}
   export FORT49=$PARMetss/mergemask/mdl_etconus_etss2.1.bin
   export FORT53=etss.${cycle}.${fle_extf}.${area}${gridhighres}
   export FORT54=etss.${cycle}.max.${fle_extf}.${area}${gridhighres}

   export FORT9=ssgrid.surge.${cyc}e

   export FORT13=fle40.surge.e
   export FORT14=fle40.surge.g
   export FORT15=fle40.${fle_ext}.n
   export FORT16=fle40.${fle_ext}.pn2
   export FORT17=fle40.${fle_ext}.pv2
   export FORT18=fle40.${fle_ext}.ny3
   export FORT19=fle40.${fle_ext}.de3
   export FORT20=fle40.${fle_ext}.cp5
   export FORT21=fle40.${fle_ext}.hor3
   export FORT22=fle40.${fle_ext}.ht3
   export FORT23=fle40.${fle_ext}.il3
   export FORT24=fle40.${fle_ext}.hch2
   export FORT25=fle40.${fle_ext}.esv4
   export FORT26=fle40.${fle_ext}.ejx3
   export FORT27=fle40.${fle_ext}.co2
   export FORT28=fle40.${fle_ext}.pb3
   export FORT29=fle40.${fle_ext}.hmi3
   export FORT30=fle40.${fle_ext}.eke2
   export FORT31=fle40.${fle_ext}.efm2
   export FORT32=fle40.${fle_ext}.etp3
   export FORT33=fle40.${fle_ext}.cd2
   export FORT34=fle40.${fle_ext}.ap3
   export FORT35=fle40.${fle_ext}.hpa2
   export FORT36=fle40.${fle_ext}.epn3
   export FORT37=fle40.${fle_ext}.emo2
   export FORT38=fle40.${fle_ext}.ms7
   export FORT39=fle40.${fle_ext}.lf2
   export FORT40=fle40.${fle_ext}.ebp3
   export FORT41=fle40.${fle_ext}.egl3
   export FORT42=fle40.${fle_ext}.ps2
   export FORT43=fle40.${fle_ext}.cr3
   export FORT44=fle40.${fle_ext}.ebr3
   export FORT45=fle40.tide.e
   export FORT46=fle40.tide.g
   startmsg
   $EXECetss/etss_out_grid >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk
   echo "`date`: Finished Creating GRIB message for 2.5km ${area} surge_tide run" >> timing.txt
   echo "Merge CONUS is complete" > msg_Done_newCONUS.txt

elif [[ ${RANK} == 1 ]] ; then

   . prep_step

   echo "`date`: Rank ${RANK} gridmerge 2.5km CONUS using nesting tropical basins surge only" >> timing.txt
   area=con
   area1=con3
   gridhighres=2p5km
   NESTYN=Y
   fle_ext=surge
   fle_extf=stormsurge

   export pgm="etss_out_grid"

   ##########set up date info... PDY is today, PDYm1 one day ago... etc.
   echo $PDY $cyc > $DATA/datetime.${area1}.txt
   export FORT48=$DATA/datetime.${area1}.txt
   ##########write area and cycle into control file
   echo $area $fle_extf $NESTYN 1 103 > $DATA/control.${area1}.txt
   export FORT11=$DATA/control.${area1}.txt

   export FORT10=$PARMetss/mergemask/mask_f.txt
   export FORT12=$PARMetss/mergemask/mdl_etgrids.${area}
   export FORT49=$PARMetss/mergemask/mdl_etconus_etss2.1.bin
   export FORT53=etss.${cycle}.${fle_extf}.${area}${gridhighres}
   export FORT54=etss.${cycle}.max.${fle_extf}.${area}${gridhighres}
   export FORT9=ssgrid.surge.${cyc}e

   export FORT13=fle40.${fle_ext}.e
   export FORT14=fle40.${fle_ext}.g
   export FORT15=fle40.${fle_ext}.n
   export FORT16=fle40.${fle_ext}.pn2
   export FORT17=fle40.${fle_ext}.pv2
   export FORT18=fle40.${fle_ext}.ny3
   export FORT19=fle40.${fle_ext}.de3
   export FORT20=fle40.${fle_ext}.cp5
   export FORT21=fle40.${fle_ext}.hor3
   export FORT22=fle40.${fle_ext}.ht3
   export FORT23=fle40.${fle_ext}.il3
   export FORT24=fle40.${fle_ext}.hch2
   export FORT25=fle40.${fle_ext}.esv4
   export FORT26=fle40.${fle_ext}.ejx3
   export FORT27=fle40.${fle_ext}.co2
   export FORT28=fle40.${fle_ext}.pb3
   export FORT29=fle40.${fle_ext}.hmi3
   export FORT30=fle40.${fle_ext}.eke2
   export FORT31=fle40.${fle_ext}.efm2
   export FORT32=fle40.${fle_ext}.etp3
   export FORT33=fle40.${fle_ext}.cd2
   export FORT34=fle40.${fle_ext}.ap3
   export FORT35=fle40.${fle_ext}.hpa2
   export FORT36=fle40.${fle_ext}.epn3
   export FORT37=fle40.${fle_ext}.emo2
   export FORT38=fle40.${fle_ext}.ms7
   export FORT39=fle40.${fle_ext}.lf2
   export FORT40=fle40.${fle_ext}.ebp3
   export FORT41=fle40.${fle_ext}.egl3
   export FORT42=fle40.${fle_ext}.ps2
   export FORT43=fle40.${fle_ext}.cr3
   export FORT44=fle40.${fle_ext}.ebr3

   startmsg
   $EXECetss/etss_out_grid >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk
   echo "`date`: Finished Creating GRIB message for 2.5km ${area} surge only run" >> timing.txt
   echo "Merge CONUS is complete" > msg_Done_newCONUS_surge.txt
   echo "`date`: Skipped Creating GRIB message for 5km ${area} surge only run" >> timing.txt
   echo " Merge CONUS is skipped" > msg_Done_5kmCONUS_surge.txt


elif [[ ${RANK} == 2 ]] ; then
 #
 #  Merging CONUS NDFD 625 m high resolution grids tide only
 #

   . prep_step

   echo "`date`: Rank ${RANK} gridmerge 2.5km CONUS using nesting tropical basins surge only" >> timing.txt
   area=con
   area1=con5
   gridhighres=625m

   fle_ext=tide
   fle_extf=tide
   NESTYN=H

   export pgm="etss_out_grid"

   ##########set up date info... PDY is today, PDYm1 one day ago... etc.
   echo $PDY $cyc > $DATA/datetime.${area1}.txt
   export FORT48=$DATA/datetime.${area1}.txt
   ##########write area and cycle into control file
   echo $area $fle_extf $NESTYN 1 103 > $DATA/control.${area1}.txt
   export FORT11=$DATA/control.${area1}.txt

   export FORT10=$PARMetss/mergemask/mask_f_high_tide.txt
   export FORT12=$PARMetss/mergemask/mdl_etgrids.${area}
   export FORT49=$PARMetss/mergemask/mdl_etconus_etss2.1_625m.bin
   export FORT53=etss.${cycle}.${fle_extf}.${area}${gridhighres}
   export FORT54=etss.${cycle}.max.${fle_extf}.${area}${gridhighres}

   export FORT9=ssgrid.surge.${cyc}e


   export FORT13=fle40.${fle_ext}.e
   export FORT14=fle40.${fle_ext}.g
   export FORT15=fle40.${fle_ext}.n
   export FORT16=fle40.${fle_ext}.pn2
   export FORT17=fle40.${fle_ext}.pv2
   export FORT18=fle40.${fle_ext}.ny3
   export FORT19=fle40.${fle_ext}.de3
   export FORT20=fle40.${fle_ext}.cp5
   export FORT21=fle40.${fle_ext}.hor3
   export FORT22=fle40.${fle_ext}.ht3
   export FORT23=fle40.${fle_ext}.il3
   export FORT24=fle40.${fle_ext}.hch2
   export FORT25=fle40.${fle_ext}.esv4
   export FORT26=fle40.${fle_ext}.ejx3
   export FORT27=fle40.${fle_ext}.co2
   export FORT28=fle40.${fle_ext}.pb3
   export FORT29=fle40.${fle_ext}.hmi3
   export FORT30=fle40.${fle_ext}.eke2
   export FORT31=fle40.${fle_ext}.efm2
   export FORT32=fle40.${fle_ext}.etp3
   export FORT33=fle40.${fle_ext}.cd2
   export FORT34=fle40.${fle_ext}.ap3
   export FORT35=fle40.${fle_ext}.hpa2
   export FORT36=fle40.${fle_ext}.epn3
   export FORT37=fle40.${fle_ext}.emo2
   export FORT38=fle40.${fle_ext}.ms7
   export FORT39=fle40.${fle_ext}.lf2
   export FORT40=fle40.${fle_ext}.ebp3
   export FORT41=fle40.${fle_ext}.egl3
   export FORT42=fle40.${fle_ext}.ps2
   export FORT43=fle40.${fle_ext}.cr3
   export FORT44=fle40.${fle_ext}.ebr3

   startmsg
   $EXECetss/etss_out_grid >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk
   echo "`date`: Finished Creating GRIB message for 625m ${area} tide only run" >> timing.txt
   echo "Merge CONUS is complete" > msg_Done_CONUS_high_tide.txt

elif [[ ${RANK} == 3 ]] ; then
 #
 #  Merging CONUS NDFD 625 m high resolution grids surge+tide
 #
   . prep_step

   export pgm="etss_out_grid"

   echo "`date`: Rank ${RANK} gridmerge 625m CONUS grid surge_tide run" >> timing.txt

   area=con
   area1=con4
   gridhighres=625m
   fle_ext=surge_tide
   fle_extf=stormtide
   NESTYN=H

   ##########set up date info... PDY is today, PDYm1 one day ago... etc.
   echo $PDY $cyc > $DATA/datetime.${area1}.txt
   export FORT48=$DATA/datetime.${area1}.txt
   ##########write area and cycle into control file
   echo $area $fle_extf $NESTYN 1 103 > $DATA/control.${area1}.txt
   export FORT11=$DATA/control.${area1}.txt


   export FORT10=$PARMetss/mergemask/mask_f.txt
   export FORT12=$PARMetss/mergemask/mdl_etgrids.${area}
   export FORT49=$PARMetss/mergemask/mdl_etconus_etss2.1_625m.bin
   export FORT53=etss.${cycle}.${fle_extf}.${area}${gridhighres}
   export FORT54=etss.${cycle}.max.${fle_extf}.${area}${gridhighres}

   export FORT9=ssgrid.surge.${cyc}e
   export FORT13=fle40.surge.e
   export FORT14=fle40.surge.g
   export FORT15=fle40.${fle_ext}.n
   export FORT16=fle40.${fle_ext}.pn2
   export FORT17=fle40.${fle_ext}.pv2
   export FORT18=fle40.${fle_ext}.ny3
   export FORT19=fle40.${fle_ext}.de3
   export FORT20=fle40.${fle_ext}.cp5
   export FORT21=fle40.${fle_ext}.hor3
   export FORT22=fle40.${fle_ext}.ht3
   export FORT23=fle40.${fle_ext}.il3
   export FORT24=fle40.${fle_ext}.hch2
   export FORT25=fle40.${fle_ext}.esv4
   export FORT26=fle40.${fle_ext}.ejx3
   export FORT27=fle40.${fle_ext}.co2
   export FORT28=fle40.${fle_ext}.pb3
   export FORT29=fle40.${fle_ext}.hmi3
   export FORT30=fle40.${fle_ext}.eke2
   export FORT31=fle40.${fle_ext}.efm2
   export FORT32=fle40.${fle_ext}.etp3
   export FORT33=fle40.${fle_ext}.cd2
   export FORT34=fle40.${fle_ext}.ap3
   export FORT35=fle40.${fle_ext}.hpa2
   export FORT36=fle40.${fle_ext}.epn3
   export FORT37=fle40.${fle_ext}.emo2
   export FORT38=fle40.${fle_ext}.ms7
   export FORT39=fle40.${fle_ext}.lf2
   export FORT40=fle40.${fle_ext}.ebp3
   export FORT41=fle40.${fle_ext}.egl3
   export FORT42=fle40.${fle_ext}.ps2
   export FORT43=fle40.${fle_ext}.cr3
   export FORT44=fle40.${fle_ext}.ebr3
   export FORT45=fle40.tide.e
   export FORT46=fle40.tide.g

   startmsg
   $EXECetss/etss_out_grid >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk

   echo "`date`: Finished Creating GRIB message for 625m grid ${area} from nesting basins surge_tide run" >> timing.txt
   echo "Merge CONUS is complete" > msg_Done_CONUS_high.txt

fi

while [[ ! -f msg_Done_CONUS_high.txt || ! -f msg_Done_newCONUS_surge.txt || ! -f msg_Done_newCONUS.txt || ! -f msg_Done_CONUS_high_tide.txt ]] ; do
  echo "`date`: Rank ${RANK} Sleeping." >> timing.txt
  sleep 1
done

  ####################################################################
  # Add WMO super header and new individual header to new output grids
  ####################################################################
if [[ ${RANK} == 0 ]] ; then
  
  area=con
  gridhighres=2p5km
  for fle_extf in stormsurge stormtide ; do
      . prep_step

      export pgm=tocgrib2

      export FORT11=etss.${cycle}.${fle_extf}.${area}${gridhighres}
      export FORT31=""
      export FORT51=etss.${cycle}.${fle_extf}.${area}${gridhighres}.grib2

      startmsg
      ${TOCGRIB2} < $PARMetss/wmoheader/grib2.t${cyc}z.mdl_${fle_extf}_${area}_102  >> $pgmout 2> errfile_${RANK}
      export err=$?; err_chk

  done

  if [ $SENDCOM = YES ]
  then
     cpreq etss.${cycle}.stormsurge.${area}${gridhighres} $COMOUT/etss.${cycle}.stormsurge.${area}${gridhighres}.grib2
     cpreq etss.${cycle}.stormtide.${area}${gridhighres} $COMOUT/etss.${cycle}.stormtide.${area}${gridhighres}.grib2
     cpreq etss.${cycle}.max.stormtide.${area}${gridhighres} $COMOUT/etss.${cycle}.max.stormtide.${area}${gridhighres}.grib2

  fi

  ################################################
  # Alert the file (WOC SBN)
  ################################################

  cpreq etss.${cycle}.stormtide.${area}${gridhighres}.grib2 $COMOUTwmo/grib2.etss.${cycle}.stormtide.${area}${gridhighres}.etss_${cyc}
  cpreq etss.${cycle}.stormsurge.${area}${gridhighres}.grib2 $COMOUTwmo/grib2.etss.${cycle}.stormsurge.${area}${gridhighres}.etss_${cyc}
  if [ $SENDDBN_NTC = YES ]
  then
     $DBNROOT/bin/dbn_alert NTC_LOW ${RUN} $job $COMOUTwmo/grib2.etss.${cycle}.stormsurge.${area}${gridhighres}.etss_${cyc}
     $DBNROOT/bin/dbn_alert NTC_LOW ${RUN} $job $COMOUTwmo/grib2.etss.${cycle}.stormtide.${area}${gridhighres}.etss_${cyc}
  fi


  ################################################
  # Alert the file (WOC ftp)
  ################################################
  if test "$SENDDBN" = 'YES'
  then
    $DBNROOT/bin/dbn_alert MDLFCST ETSSGB2 $job $COMOUT/etss.${cycle}.stormsurge.${area}${gridhighres}.grib2
    $DBNROOT/bin/dbn_alert MDLFCST ETSSGB2 $job $COMOUT/etss.${cycle}.stormtide.${area}${gridhighres}.grib2
    $DBNROOT/bin/dbn_alert MDLFCST ETSSGB2 $job $COMOUT/etss.${cycle}.max.stormtide.${area}${gridhighres}.grib2
  fi
# done
elif [[ ${RANK} == 1 ]] ; then
   ####################################
   # Add headers to 625m output grids
   ####################################
  area=con
  gridhighres=625m

     for fle_extf in tide stormtide ; do
         
         . prep_step

         export pgm=tocgrib2

         export FORT11=etss.${cycle}.${fle_extf}.${area}${gridhighres}
         export FORT31=""
         export FORT51=etss.${cycle}.${fle_extf}.${area}${gridhighres}.grib2

         startmsg
         ${TOCGRIB2} < $PARMetss/wmoheader/grib2.t${cyc}z.mdl_${fle_extf}_${area}625m_102  >> $pgmout 2> errfile_${RANK}
         export err=$?; err_chk

     done
     if [ $SENDCOM = YES ]
     then
        cpreq etss.${cycle}.stormtide.${area}${gridhighres} $COMOUT/etss.${cycle}.stormtide.${area}${gridhighres}.grib2
        cpreq etss.${cycle}.tide.${area}${gridhighres} $COMOUT/etss.${cycle}.tide.${area}${gridhighres}.grib2
        cpreq etss.${cycle}.max.stormtide.${area}${gridhighres} $COMOUT/etss.${cycle}.max.stormtide.${area}${gridhighres}.grib2
     fi

  ################################################
  # Alert the file (WOC SBN)
  ################################################

     cpreq etss.${cycle}.stormtide.${area}${gridhighres}.grib2 $COMOUTwmo/grib2.etss.${cycle}.stormtide.${area}${gridhighres}.etss_${cyc}
     cpreq etss.${cycle}.tide.${area}${gridhighres}.grib2 $COMOUTwmo/grib2.etss.${cycle}.tide.${area}${gridhighres}.etss_${cyc}
     if [ $SENDDBN_NTC = YES ]
     then
        $DBNROOT/bin/dbn_alert NTC_LOW ${RUN} $job $COMOUTwmo/grib2.etss.${cycle}.stormtide.${area}${gridhighres}.etss_${cyc}
        $DBNROOT/bin/dbn_alert NTC_LOW ${RUN} $job $COMOUTwmo/grib2.etss.${cycle}.tide.${area}${gridhighres}.etss_${cyc}
     fi

  ################################################
  # Alert the file (WOC ftp)
  ################################################
    if test "$SENDDBN" = 'YES'
    then
      $DBNROOT/bin/dbn_alert MDLFCST ETSSGB2 $job $COMOUT/etss.${cycle}.tide.${area}${gridhighres}.grib2
      $DBNROOT/bin/dbn_alert MDLFCST ETSSGB2 $job $COMOUT/etss.${cycle}.stormtide.${area}${gridhighres}.grib2
      $DBNROOT/bin/dbn_alert MDLFCST ETSSGB2 $job $COMOUT/etss.${cycle}.max.stormtide.${area}${gridhighres}.grib2
    fi

elif [[ ${RANK} == 2 ]] ; then
   bsn_f=('pn2' 'pv2' 'ny3' 'de3' 'cp5' 'hor3' 'ht3' 'il3' 'hch2' 'esv4' 'ejx3' 'co2' 'pb3' 'hmi3' 'eke2' 'efm2' 'etp3' 'cd2' 'ap3' 'hpa2' 'epn3' 'emo2' 'ms7' 'lf2' 'ebp3' 'egl3' 'ps2' 'cr3' 'ebr3' 'e' 'g' 'n' 'k' 'm')

   basin_f=('Penobscot Bay' 'Providence/Boston' 'New York' 'Delaware Bay' 'Chesapeake Bay' 'Norfolk' 'Pamlico Sound' 'Wilmington/Myrtle Beach' 'Charleston Harbor' 'Savannah/Hilton Head' 'Jacksonville' 'Cape Canaveral' 'Palm Beach' 'Biscayne Bay' 'Florida Bay' 'Fort Myers' 'Tampa Bay' 'Cedar Key' 'Apalachicola Bay' 'Panama City' 'Pensacola Bay' 'Mobile Bay' 'New Orleans' 'Vermilion Bay' 'Sabine lake' 'Galveston Bay' 'Matagorda Bay' 'Corpus Christi Bay' 'Laguna Madre' 'Eastern Coast' 'Gulf of Mexico' 'Western Coast' 'Gulf of Alaska' 'Bering Sea and Arctic')

     echo 'Initial-Water-Level (ft), Abbrev, Basin' > etss.${cycle}.init_wl.txt

     for i in $(seq -f "%1g" 0 33); do
         while read line; do
               printf -v newLline "%7.2f" $line
               echo $newLline, ${bsn_f[${i}]}, ${basin_f[${i}]} >> etss.${cycle}.init_wl.txt
         done < wl.surge.${bsn_f[${i}]}
     done
   #  cp wl.* $COMOUT/
     if [ $SENDCOM = YES ]
     then
        cpreq etss.${cycle}.init_wl.txt $COMOUT/

        if test "$SENDDBN" = 'YES'
        then
           $DBNROOT/bin/dbn_alert MDLFCST ETSSTXT $job $COMOUT/etss.${cycle}.init_wl.txt
        fi

     fi

fi
### Excute final script for MDL test
MDLTEST_FINALSCRIPT=${MDLTEST_FINALSCRIPT:-None}
if [[ ${MDLTEST_FINALSCRIPT} != "None" ]] ; then
   ${MDLTEST_FINALSCRIPT}
fi

echo "`date`: Rank ${RANK} Finished." >> timing.txt

############## END OF SCRIPT #######################
