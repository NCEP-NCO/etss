#!/bin/bash

src=$(cd $(dirname $0) && pwd)
root=${src}/..

if test "$6" != ''
then
  echo "Usage $0 <'g' or 'other' for all other basins> <cycle> <PARMetss> <EXECetss>"
  echo "Example: g 00 $root/parm $root/exec V1" 
  exit
fi
if test "$5" == ''
then
  echo "Usage $0 <'g' or 'other' for all other basins> <cycle> <PARMetss> <EXECetss>"
  echo "Example: g 00 $root/parm $root/exec V1" 
  exit
fi

f_gulf=$1
cyc=$2
PARMetss=$3
EXECetss=$4
tide_v=$5

PARMetssmodel=${PARMetss}/model

if [[ ${tide_v} == 0 ]] ; then
   fle_ext="surge"
elif [[ ${tide_v} == T1 ]] ; then
   fle_ext="tide"
else
   fle_ext="surge_tide"
fi

# Set up magic export so export XLFUNIT works...
#export XLFRTEOPTS="unit_vars=yes"

######################################################################
# There are 6 basins for which forecasts are made.
#   1) e = East Coast Basin  (FQUS23 KWNO, MRP SSE)
#   2) g = Gulf Coast Basin  (FQGX23 KWNO, MRP SSG)
#   3) a = Alaska Basin      (FQAK23 KWNO, MRP SSB)
#   4) w = West Coast Basin  (FQPZ23 KWNO, MRP SSP)
#   5) z = Artic Basin       (FQAC23 KWNO, MRP SSA)
#   6) k = Gulf of AK        (FQGA23 KWNO, MRP SSC)
######################################################################
. prep_step

export FORT22=water-levels.dat
export iopt=2
if [[ ${tide_v} == T1 ]] ; then
   export iopt=0
fi
if [[ ${f_gulf} == nep ]] ; then

   bsn=n
   bsnn=nep
   export pgm="etss_model_13consti"
   echo ${bsn} ${iopt} > fle20.${fle_ext}.${bsn}
   export FORT19=fle20.${fle_ext}.${bsn}
   export FORT21=${PARMetssmodel}/mdl_ft01.ega
   export FORT81=fle10.${fle_ext}.${bsn}
   export FORT84=fle40.${fle_ext}.${bsn}
   export FORT87=fle70.${fle_ext}.${bsn}
   export FORT96=sds.${cyc}

   export FORT8=${PARMetssmodel}/gfs_table.${bsn}
   export FORT9=lon_GFST1534
   export FORT10=lat_GFST1534

   export FORT11=${PARMetssmodel}/mdl_ft11.${bsn}
   export FORT14=${PARMetssmodel}/mdl_ettgp.${bsn}
   export FORT15=${PARMetssmodel}/mdl_ettgp.${bsn}_2nd
   export FORT33=cylf10.${cyc}${bsn}
   export FORT34=gfspuv.${cyc}${bsn}
   export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
   export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
   export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
   export FORT50=wl.${fle_ext}.${bsn}

   echo "`date`: Starting Run for ${bsn}" >> timing.txt
   startmsg
   if [[ $pgmout == '' ]] ; then
      pgmout=OUTPUT.0000
   fi
   ${EXECetss}/etss_model_13consti -basin ${bsnn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsnn}.${fle_ext}.etss2.0.rex -env ${bsnn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk
   echo "`date`: Finished Run for ${bsn}" >> timing.txt


elif [[ ${f_gulf} == m ]] ; then

   bsn=m
   export pgm="etss_model_13consti"
   echo ${bsn} ${iopt} > fle20.${fle_ext}.${bsn} 
   export FORT19=fle20.${fle_ext}.${bsn}
   export FORT21=${PARMetssmodel}/mdl_ft01.ega
   export FORT81=fle10.${fle_ext}.${bsn}
   export FORT84=fle40.${fle_ext}.${bsn}
   export FORT87=fle70.${fle_ext}.${bsn}
   export FORT96=sds.${cyc}

   export FORT8=${PARMetssmodel}/gfs_table.${bsn}
   export FORT9=lon_GFST1534
   export FORT10=lat_GFST1534

   export FORT11=${PARMetssmodel}/mdl_ft11.${bsn}
   export FORT14=${PARMetssmodel}/mdl_ettgp.${bsn}
   export FORT15=${PARMetssmodel}/mdl_ettgp.${bsn}_2nd
   export FORT33=cylf10.${cyc}${bsn}
   export FORT34=gfspuv.${cyc}${bsn}
   export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
   export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
   export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
   export FORT50=wl.${fle_ext}.${bsn}

   echo "`date`: Starting Run for ${bsn}" >> timing.txt
   startmsg
   if [[ $pgmout == '' ]] ; then
      pgmout=OUTPUT.0000
   fi
   ${EXECetss}/etss_model_13consti -basin ebbc -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ebbc.${fle_ext}.etss2.0.rex -env ebbc.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk
   echo "`date`: Finished Run for ${bsn}" >> timing.txt

elif [[ ${f_gulf} == g ]] ; then

  ####################################################################
  #  Run extratropical storm surge model for gulf of mexico then exit.
  ####################################################################
   export iopt=0
   bsn='g'
   bsnss="eglc"
   export pgm="etss_model"
   echo ${bsn} ${iopt} > fle20.${fle_ext}.${bsn} 
   export FORT19=fle20.${fle_ext}.${bsn}
   export FORT21=${PARMetssmodel}/mdl_ft01.ega
   export FORT81=fle10.${fle_ext}.${bsn}
   export FORT84=fle40.${fle_ext}.${bsn}
   export FORT87=fle70.${fle_ext}.${bsn}
   export FORT96=sds.${cyc}

   export FORT8=${PARMetssmodel}/gfs_table.${bsn}
   export FORT9=lon_GFST1534
   export FORT10=lat_GFST1534

   export FORT11=${PARMetssmodel}/mdl_ft11.${bsn}
   export FORT14=${PARMetssmodel}/mdl_ettgp.${bsn}
   export FORT15=${PARMetssmodel}/mdl_ettgp.${bsn}_2nd
   export FORT33=cylf10.${cyc}${bsn}
   export FORT34=gfspuv.${cyc}${bsn}
   export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
   export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
   export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
   export FORT50=wl.${fle_ext}.${bsn}
  
   if [[ ${tide_v} == 0 ]] ; then

  export FORT35=$PARMetss/nesting/outer_ij_inner_boun_slosh16.txt
  export FORT36=$PARMetss/nesting/outer_ij_inner_boun_slosh17.txt
  export FORT37=$PARMetss/nesting/outer_ij_inner_boun_slosh18.txt
  export FORT38=$PARMetss/nesting/outer_ij_inner_boun_slosh19.txt
  export FORT39=$PARMetss/nesting/outer_ij_inner_boun_slosh20.txt
  export FORT40=$PARMetss/nesting/outer_ij_inner_boun_slosh21.txt
  export FORT41=$PARMetss/nesting/outer_ij_inner_boun_slosh22.txt
  export FORT42=$PARMetss/nesting/outer_ij_inner_boun_slosh23.txt
  export FORT43=$PARMetss/nesting/outer_ij_inner_boun_slosh24.txt
  export FORT44=$PARMetss/nesting/outer_ij_inner_boun_slosh25.txt
  export FORT45=$PARMetss/nesting/outer_ij_inner_boun_slosh26.txt
  export FORT46=$PARMetss/nesting/outer_ij_inner_boun_slosh27.txt
  export FORT47=$PARMetss/nesting/outer_ij_inner_boun_slosh28.txt
  export FORT48=$PARMetss/nesting/outer_ij_inner_boun_slosh29.txt
  export FORT49=$PARMetss/nesting/outer_ij_inner_boun_slosh15.txt

  export FORT61=out_nesting16.bin
  export FORT62=out_nesting17.bin
  export FORT63=out_nesting18.bin
  export FORT64=out_nesting19.bin
  export FORT65=out_nesting20.bin
  export FORT66=out_nesting21.bin
  export FORT67=out_nesting22.bin
  export FORT68=out_nesting23.bin
  export FORT69=out_nesting24.bin
  export FORT70=out_nesting25.bin
  export FORT71=out_nesting26.bin
  export FORT72=out_nesting27.bin
  export FORT73=out_nesting28.bin
  export FORT74=out_nesting29.bin
  export FORT75=out_nesting30.bin

   fi

   startmsg
   if [[ $pgmout == '' ]] ; then
     pgmout=OUTPUT.0000
   fi
  
   if [[ ${tide_v} == 0 ]] ; then
     echo "`date`: Starting Run for ${bsn} in surge only" >> timing.txt
     $EXECetss/etss_model -basin ${bsnss} -rootDir $PARMetss -trk $PARMetss/trkfiles/tideOnly_14.trk -rex egm3.${fle_ext}.etss2.0.rex -env egm3.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 1 -verbose 1 >> $pgmout 2> errfile_${RANK}
     echo "`date`: Finished Run for ${bsn} in surge only" >> timing.txt
   else
     echo "`date`: Starting Run for ${bsn} in tide only" >> timing.txt
     $EXECetss/etss_model -basin ${bsnss} -rootDir $PARMetss -trk $PARMetss/trkfiles/tideOnly_14.trk -rex egm3.${fle_ext}.etss2.0.rex -env egm3.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
     echo "`date`: Finished Run for ${bsn} in tide only" >> timing.txt
   fi

   err=$?;export err; err_chk

elif [[ ${f_gulf} == e ]] ; then
   export iopt=0
   bsn=e
   export pgm="etss_model"
   echo ${bsn} ${iopt} > fle20.${fle_ext}.${bsn} 
   export FORT19=fle20.${fle_ext}.${bsn}
   export FORT21=$PARMetssmodel/mdl_ft01.ega
   export FORT81=fle10.${fle_ext}.${bsn}
   export FORT84=fle40.${fle_ext}.${bsn}
   export FORT87=fle70.${fle_ext}.${bsn}
   export FORT96=sds.${cyc}

   export FORT8=${PARMetssmodel}/gfs_table.${bsn}
   export FORT9=lon_GFST1534
   export FORT10=lat_GFST1534

   export FORT11=$PARMetssmodel/mdl_ft11.${bsn}
   export FORT14=$PARMetssmodel/mdl_ettgp.${bsn}
   export FORT15=$PARMetssmodel/mdl_ettgp.${bsn}_2nd
   export FORT33=cylf10.${cyc}${bsn}
   export FORT34=gfspuv.${cyc}${bsn}
   export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
   export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
   export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
   export FORT50=wl.${fle_ext}.${bsn}


   bsnss="exm"

   if [[ ${tide_v} == 0 ]] ; then

  export FORT35=$PARMetss/nesting/outer_ij_inner_boun_slosh1.txt
  export FORT36=$PARMetss/nesting/outer_ij_inner_boun_slosh2.txt
  export FORT37=$PARMetss/nesting/outer_ij_inner_boun_slosh3.txt
  export FORT38=$PARMetss/nesting/outer_ij_inner_boun_slosh4.txt
  export FORT39=$PARMetss/nesting/outer_ij_inner_boun_slosh5.txt
  export FORT40=$PARMetss/nesting/outer_ij_inner_boun_slosh6.txt
  export FORT41=$PARMetss/nesting/outer_ij_inner_boun_slosh7.txt
  export FORT42=$PARMetss/nesting/outer_ij_inner_boun_slosh8.txt
  export FORT43=$PARMetss/nesting/outer_ij_inner_boun_slosh9.txt
  export FORT44=$PARMetss/nesting/outer_ij_inner_boun_slosh10.txt
  export FORT45=$PARMetss/nesting/outer_ij_inner_boun_slosh11.txt
  export FORT46=$PARMetss/nesting/outer_ij_inner_boun_slosh12.txt
  export FORT47=$PARMetss/nesting/outer_ij_inner_boun_slosh13.txt
  export FORT48=$PARMetss/nesting/outer_ij_inner_boun_slosh14.txt
  export FORT49=$PARMetss/nesting/outer_ij_inner_boun_slosh15.txt

  export FORT61=out_nesting1.bin
  export FORT62=out_nesting2.bin
  export FORT63=out_nesting3.bin
  export FORT64=out_nesting4.bin
  export FORT65=out_nesting5.bin
  export FORT66=out_nesting6.bin
  export FORT67=out_nesting7.bin
  export FORT68=out_nesting8.bin
  export FORT69=out_nesting9.bin
  export FORT70=out_nesting10.bin
  export FORT71=out_nesting11.bin
  export FORT72=out_nesting12.bin
  export FORT73=out_nesting13.bin
  export FORT74=out_nesting14.bin
  export FORT75=out_nesting15.bin


   fi

   startmsg
   if [[ $pgmout == '' ]] ; then
     pgmout=OUTPUT.0000
   fi
   
   if [[ ${tide_v} == 0 ]] ; then
      echo "`date`: Starting Run for ${bsn} surge only" >> timing.txt
      $EXECetss/etss_model -basin $bsnss -rootDir $PARMetss -trk $PARMetss/trkfiles/tideOnly_14.trk -rex $bsnss.${fle_ext}.etss2.0.rex -env $bsnss.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 1 -verbose 1 >> $pgmout 2> errfile_${RANK}
      echo "`date`: Finished Run for ${bsn} surge only" >> timing.txt
   else
      echo "`date`: Starting Run for ${bsn} tide only" >> timing.txt
      $EXECetss/etss_model -basin $bsnss -rootDir $PARMetss -trk $PARMetss/trkfiles/tideOnly_14.trk -rex $bsnss.${fle_ext}.etss2.0.rex -env $bsnss.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
      echo "`date`: Finished Run for ${bsn} tide only" >> timing.txt
   fi

   err=$?;export err; err_chk
   echo "`date`: Finished Run for ${bsn}" >> timing.txt
  
elif [[ ${f_gulf} == ala ]] ; then
   bsn=k
  ####################################################################
  #  Run extratropical storm surge model.
  ####################################################################
   export pgm="etss_model_13consti"
   echo ${bsn} ${iopt} > fle20.${fle_ext}.${bsn} 
   export FORT19=fle20.${fle_ext}.${bsn}  

   export FORT21=$PARMetssmodel/mdl_ft01.ega
   export FORT81=fle10.${fle_ext}.${bsn}
   export FORT84=fle40.${fle_ext}.${bsn}
   export FORT87=fle70.${fle_ext}.${bsn}
   export FORT96=sds.${cyc}

   export FORT8=${PARMetssmodel}/gfs_table.${bsn}
   export FORT9=lon_GFST1534
   export FORT10=lat_GFST1534

   export FORT11=$PARMetssmodel/mdl_ft11.${bsn}
   export FORT14=$PARMetssmodel/mdl_ettgp.${bsn}
   export FORT15=$PARMetssmodel/mdl_ettgp.${bsn}_2nd
   export FORT33=cylf10.${cyc}${bsn}
   export FORT34=gfspuv.${cyc}${bsn}
   export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
   export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
   export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
   export FORT50=wl.${fle_ext}.${bsn}

   bsnss="egoa"

   echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt

   startmsg
   if [[ $pgmout == '' ]] ; then
      pgmout=OUTPUT.0000
   fi

   $EXECetss/etss_model_13consti -basin $bsnss -rootDir $PARMetss -trk $PARMetss/trkfiles/tideOnly_14.trk -rex $bsnss.${fle_ext}.etss2.0.rex -env $bsnss.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk

   tide_v="V2.2.10"
   fle_ext="surge_tide"
   export pgm="etss_model_13consti"

   export FORT21=$PARMetssmodel/mdl_ft01.ega
   export FORT81=fle10.${fle_ext}.${bsn}
   export FORT84=fle40.${fle_ext}.${bsn}
   export FORT87=fle70.${fle_ext}.${bsn}
   export FORT96=sds.${cyc}

   export FORT8=${PARMetssmodel}/gfs_table.${bsn}
   export FORT9=lon_GFST1534
   export FORT10=lat_GFST1534

   export FORT11=$PARMetssmodel/mdl_ft11.${bsn}
   export FORT14=$PARMetssmodel/mdl_ettgp.${bsn}
   export FORT15=$PARMetssmodel/mdl_ettgp.${bsn}_2nd
   export FORT33=cylf10.${cyc}${bsn}
   export FORT34=gfspuv.${cyc}${bsn}
   export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
   export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
   export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
   export FORT50=wl.${fle_ext}.${bsn}


   $EXECetss/etss_model_13consti -basin $bsnss -rootDir $PARMetss -trk $PARMetss/trkfiles/tideOnly_14.trk -rex $bsnss.${fle_ext}.etss2.0.rex -env $bsnss.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}          
   err=$?;export err; err_chk

   echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

  #########################################################
  # The following for Tide only run in 30 Tropical basins #
  #########################################################
elif [[ ${f_gulf} == cp5 ]] ; then


   for bsn in cp5 hor3
   do

      export pgm="etss_model"
      echo e ${iopt} > fle20.${fle_ext}.${bsn}
      export FORT19=fle20.${fle_ext}.${bsn}

      export FORT21=${PARMetssmodel}/mdl_ft01.ega
      export FORT81=fle10.${fle_ext}.${bsn}
      export FORT84=fle40.${fle_ext}.${bsn}
      export FORT87=fle70.${fle_ext}.${bsn}
      export FORT96=sds.${cyc}

      export FORT8=${PARMetssmodel}/gfs_table.${bsn}
      export FORT9=lon_GFST1534
      export FORT10=lat_GFST1534

      export FORT11=${PARMetssmodel}/mdl_ft11.${bsn}
      export FORT14=${PARMetssmodel}/mdl_ettgp.${bsn}
      export FORT15=${PARMetssmodel}/mdl_ettgp.${bsn}_2nd
      export FORT33=cylf10.${cyc}${bsn}
      export FORT34=gfspuv.${cyc}${bsn}
      export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
      export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
      export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
      export FORT50=wl.${fle_ext}.${bsn}


      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt

      startmsg
         ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done

elif [[ ${f_gulf} == epn3 ]] ; then

   bsn=epn3
   export pgm="etss_model"

   echo g ${iopt} > fle20.${fle_ext}.${bsn}
   export FORT19=fle20.${fle_ext}.${bsn}

   export FORT21=${PARMetssmodel}/mdl_ft01.ega
   export FORT81=fle10.${fle_ext}.${bsn}
   export FORT84=fle40.${fle_ext}.${bsn}
   export FORT87=fle70.${fle_ext}.${bsn}
   export FORT96=sds.${cyc}

   export FORT8=${PARMetssmodel}/gfs_table.${bsn}
   export FORT9=lon_GFST1534
   export FORT10=lat_GFST1534

   export FORT11=${PARMetssmodel}/mdl_ft11.${bsn}
   export FORT14=${PARMetssmodel}/mdl_ettgp.${bsn}
   export FORT15=${PARMetssmodel}/mdl_ettgp.${bsn}_2nd
   export FORT33=cylf10.${cyc}${bsn}
   export FORT34=gfspuv.${cyc}${bsn}
   export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
   export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
   export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
   export FORT50=wl.${fle_ext}.${bsn}

   echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
   if [[ $pgmout == '' ]] ; then
      pgmout=OUTPUT.0000
   fi
   startmsg
   ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

elif [[ ${f_gulf} == ejx3 ]] ; then

   for bsn in ejx3 ht3 ebp3
   do
      export pgm="etss_model"
      if [[ ${bsn} == ebp3 ]] ; then
         echo g ${iopt} > fle20.${fle_ext}.${bsn}
      else
         echo e ${iopt} > fle20.${fle_ext}.${bsn}
      fi
      export FORT19=fle20.${fle_ext}.${bsn}
      export FORT21=${PARMetssmodel}/mdl_ft01.ega
      export FORT81=fle10.${fle_ext}.${bsn}
      export FORT84=fle40.${fle_ext}.${bsn}
      export FORT87=fle70.${fle_ext}.${bsn}
      export FORT96=sds.${cyc}

      export FORT8=${PARMetssmodel}/gfs_table.${bsn}
      export FORT9=lon_GFST1534
      export FORT10=lat_GFST1534

      export FORT11=${PARMetssmodel}/mdl_ft11.${bsn}
      export FORT14=${PARMetssmodel}/mdl_ettgp.${bsn}
      export FORT15=${PARMetssmodel}/mdl_ettgp.${bsn}_2nd
      export FORT33=cylf10.${cyc}${bsn}
      export FORT34=gfspuv.${cyc}${bsn}
      export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
      export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
      export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
      export FORT50=wl.${fle_ext}.${bsn}

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done

elif [[ ${f_gulf} == g1 ]] ; then
  ########################################################################################
  #  Nesting run extratropical storm surge model for following tropical basins then exit.
  #  in which the nesting boundary are generated from egm3 (gulf of mexico basin) run
  ########################################################################################

   for bsn in efm2 etp3 cd2 ap3 emo2 ms7 lf2 ps2
   do
      export pgm="etss_model"
      echo g ${iopt} > fle20.${fle_ext}.${bsn}
      export FORT19=fle20.${fle_ext}.${bsn}

      export FORT21=${PARMetssmodel}/mdl_ft01.ega
      export FORT81=fle10.${fle_ext}.${bsn}
      export FORT84=fle40.${fle_ext}.${bsn}
      export FORT87=fle70.${fle_ext}.${bsn}
      export FORT96=sds.${cyc}

      export FORT8=${PARMetssmodel}/gfs_table.${bsn}
      export FORT9=lon_GFST1534
      export FORT10=lat_GFST1534

      export FORT11=${PARMetssmodel}/mdl_ft11.${bsn}
      export FORT14=${PARMetssmodel}/mdl_ettgp.${bsn}
      export FORT15=${PARMetssmodel}/mdl_ettgp.${bsn}_2nd
      export FORT33=cylf10.${cyc}${bsn}
      export FORT34=gfspuv.${cyc}${bsn}
      export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
      export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
      export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
      export FORT50=wl.${fle_ext}.${bsn}


      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt

      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg

         ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done

elif [[ ${f_gulf} == hpa2 ]] ; then
  ########################################################################################
  #  Nesting run extratropical storm surge model for following tropical basins then exit.
  #  in which the nesting boundary are generated from egm3 (gulf of mexico basin) run
  ########################################################################################
      bsn=hpa2 
      export pgm="etss_model"
      echo g ${iopt} > fle20.${fle_ext}.${bsn}
      export FORT19=fle20.${fle_ext}.${bsn}

      export FORT21=${PARMetssmodel}/mdl_ft01.ega
      export FORT81=fle10.${fle_ext}.${bsn}
      export FORT84=fle40.${fle_ext}.${bsn}
      export FORT87=fle70.${fle_ext}.${bsn}
      export FORT96=sds.${cyc}

      export FORT8=${PARMetssmodel}/gfs_table.${bsn}
      export FORT9=lon_GFST1534
      export FORT10=lat_GFST1534

      export FORT11=${PARMetssmodel}/mdl_ft11.${bsn}
      export FORT14=${PARMetssmodel}/mdl_ettgp.${bsn}
      export FORT15=${PARMetssmodel}/mdl_ettgp.${bsn}_2nd
      export FORT33=cylf10.${cyc}${bsn}
      export FORT34=gfspuv.${cyc}${bsn}
      export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
      export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
      export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
      export FORT50=wl.${fle_ext}.${bsn}

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt

      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg

         ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt


elif [[ ${f_gulf} == e1 ]] ; then


   for bsn in pn2 pv2 ny3 de3 eke2 hmi3
   do
      export pgm="etss_model"
      echo e ${iopt} > fle20.${fle_ext}.${bsn}
      export FORT19=fle20.${fle_ext}.${bsn}

      export FORT21=$PARMetssmodel/mdl_ft01.ega
      export FORT81=fle10.${fle_ext}.${bsn}
      export FORT84=fle40.${fle_ext}.${bsn}
      export FORT87=fle70.${fle_ext}.${bsn}
      export FORT96=sds.${cyc}

      export FORT8=${PARMetssmodel}/gfs_table.${bsn}
      export FORT9=lon_GFST1534
      export FORT10=lat_GFST1534

      export FORT11=$PARMetssmodel/mdl_ft11.${bsn}
      export FORT14=$PARMetssmodel/mdl_ettgp.${bsn}
      export FORT15=$PARMetssmodel/mdl_ettgp.${bsn}_2nd
      export FORT33=cylf10.${cyc}${bsn}
      export FORT34=gfspuv.${cyc}${bsn}
      export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
      export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
      export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
      export FORT50=wl.${fle_ext}.${bsn}

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt

      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

   done

elif [[ ${f_gulf} == e2 ]] ; then

   for bsn in il3 hch2 esv4 co2 pb3 ebr3 egl3 cr3
   do
      export pgm="etss_model"
      case ${bsn} in

      il3)
          echo e ${iopt} > fle20.${fle_ext}.${bsn} ;;
      hch2)
          echo e ${iopt} > fle20.${fle_ext}.${bsn} ;;
      esv4)
          echo e ${iopt} > fle20.${fle_ext}.${bsn} ;;
      co2)
          echo e ${iopt} > fle20.${fle_ext}.${bsn} ;;
      pb3)
          echo e ${iopt} > fle20.${fle_ext}.${bsn} ;;
      ebr3)
          echo g ${iopt} > fle20.${fle_ext}.${bsn} ;;
      egl3)
          echo g ${iopt} > fle20.${fle_ext}.${bsn} ;;
      cr3)
          echo g ${iopt} > fle20.${fle_ext}.${bsn} ;;
      esac

      export FORT19=fle20.${fle_ext}.${bsn}
      export FORT21=$PARMetssmodel/mdl_ft01.ega
      export FORT81=fle10.${fle_ext}.${bsn}
      export FORT84=fle40.${fle_ext}.${bsn}
      export FORT87=fle70.${fle_ext}.${bsn}
      export FORT96=sds.${cyc}

      export FORT8=${PARMetssmodel}/gfs_table.${bsn}
      export FORT9=lon_GFST1534
      export FORT10=lat_GFST1534
  
      export FORT11=$PARMetssmodel/mdl_ft11.${bsn}
      export FORT14=$PARMetssmodel/mdl_ettgp.${bsn}
      export FORT15=$PARMetssmodel/mdl_ettgp.${bsn}_2nd
      export FORT33=cylf10.${cyc}${bsn}
      export FORT34=gfspuv.${cyc}${bsn}
      export FORT52=sshistory.${fle_ext}.${cyc}${bsn}
      export FORT55=sshistory.${fle_ext}.${cyc}${bsn}_2nd
      export FORT53=ssgrid.${fle_ext}.${cyc}${bsn}
      export FORT50=wl.${fle_ext}.${bsn}

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      startmsg

      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done      #  Basin loop

fi

