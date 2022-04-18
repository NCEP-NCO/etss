#!/bin/bash

src=$(cd $(dirname $0) && pwd)
root=${src}/..

if test "$6" != ''
then
  echo "Usage $0 <'g' or 'e' for all other basins> <cycle> <PARMetss> <EXECetss>"
  echo "Example: g 00 $root/parm $root/exec" 
  exit
fi
if test "$5" == ''
then
  echo "Usage $0 <'g' or 'e' for all other basins> <cycle> <PARMetss> <EXECetss>"
  echo "Example: g 00 $root/parm $root/exec" 
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
else
   fle_ext="surge_tide"
fi

######################################################################

. prep_step

export FORT22=water-levels.dat
export iopt=2

if [[ ${f_gulf} == cp5 ]] ; then

      bsn=cp5

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


      export FORT20=out_nesting5.bin

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
         ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

elif [[ ${f_gulf} == emo2 ]] ; then

      bsn=emo2

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

      export FORT20=out_nesting22.bin

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
         ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

elif [[ ${f_gulf} == hor3 ]] ; then

      bsn=hor3
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


      export FORT20=out_nesting6.bin

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
         ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

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


      export FORT20=out_nesting21.bin

   echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
   if [[ $pgmout == '' ]] ; then
      pgmout=OUTPUT.0000
   fi
   startmsg
   ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
   err=$?;export err; err_chk
   echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

elif [[ ${f_gulf} == ejx3 ]] ; then

      for bsn in ejx3
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

      case ${bsn} in

      ejx3)
         export FORT20=out_nesting11.bin ;;
      esac

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done

elif [[ ${f_gulf} == ebp3 ]] ; then

      for bsn in ebp3
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

      case ${bsn} in

      ebp3)
         export FORT20=out_nesting25.bin ;;
      esac

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done

elif [[ ${f_gulf} == ht3 ]] ; then

      for bsn in ht3
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

      case ${bsn} in

      ht3)
         export FORT20=out_nesting7.bin ;;
      esac

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done
elif [[ ${f_gulf} == ps2 ]] ; then

      bsn=ps2
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

      export FORT20=out_nesting27.bin 

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

elif [[ ${f_gulf} == ap3 ]] ; then

      bsn=ap3
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

      export FORT20=out_nesting19.bin

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg

      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}

      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

elif [[ ${f_gulf} == g1 ]] ; then


      for bsn in efm2 etp3 cd2 emo2 ms7 lf2 ps2
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

      case ${bsn} in
      
      efm2)
          export FORT20=out_nesting16.bin ;;
      etp3)
          export FORT20=out_nesting17.bin ;;
      cd2)
          export FORT20=out_nesting18.bin ;;
      emo2)
          export FORT20=out_nesting22.bin ;;
      ms7)
          export FORT20=out_nesting23.bin ;;
      lf2)
          export FORT20=out_nesting24.bin ;;
      eok3)
          export FORT20=out_nesting30.bin ;;
      ps2)
         export FORT20=out_nesting27.bin ;;
      esac

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
      if [ ${bsn} == eok3 ] ; then

         ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 0 -verbose 1 >> $pgmout 2> errfile_${RANK}
      else
         ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      fi
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done

elif [[ ${f_gulf} == g1a ]] ; then

      for bsn in etp3 lf2
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

      case ${bsn} in

      etp3)
          export FORT20=out_nesting17.bin ;;
      lf2)
          export FORT20=out_nesting24.bin ;;
      esac

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done

elif [[ ${f_gulf} == g1b ]] ; then

      for bsn in efm2 cd2 ms7
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

      case ${bsn} in
      efm2)
          export FORT20=out_nesting16.bin ;;
      cd2)
          export FORT20=out_nesting18.bin ;;
      ms7)
          export FORT20=out_nesting23.bin ;;
      esac

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done
elif [[ ${f_gulf} == g1c ]] ; then

      for bsn in ps2 ap3
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

      case ${bsn} in
      ps2)
         export FORT20=out_nesting27.bin ;;
      ap3)
         export FORT20=out_nesting19.bin ;;
      esac

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
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

      export FORT20=out_nesting20.bin

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      if [[ $pgmout == '' ]] ; then
         pgmout=OUTPUT.0000
      fi
      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

elif [[ ${f_gulf} == ny3 ]] ; then

      export pgm="etss_model"
      bsn=ny3
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


      export FORT20=out_nesting3.bin

      echo "`date`: Starting Run for ${bsn} in tide ${tide_v}" >> timing.txt
      startmsg

      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk

      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt

     
elif [[ ${f_gulf} == e1 ]] ; then


      for bsn in pn2 pv2 de3 eke2 hmi3 
      do
      export pgm="etss_model"
      if [[ ${bsn} == eke2 ]] ; then
         echo g ${iopt} > fle20.${fle_ext}.${bsn}
      else
         echo e ${iopt} > fle20.${fle_ext}.${bsn}
      fi
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
      case ${bsn} in

      pn2)
         export FORT20=out_nesting1.bin ;;
      pv2)
         export FORT20=out_nesting2.bin ;;
      de3)
         export FORT20=out_nesting4.bin ;;
      eke2)
         export FORT20=out_nesting15.bin ;;
      hmi3)
         export FORT20=out_nesting14.bin ;;
      esac 
      startmsg
      if [[ ${bsn} == pn2 ]] && [[ ${tide_v} == V3 ]] ; then

        ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide VDEF -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      else

        ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}

      fi
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt


   done

  ####################################################################################
  #  Nesting run extratropical storm surge model in the following tropical basins,
  #  in which nesting boundary conditions are generated from eex2 (East Coastal) basin
  ####################################################################################
elif [[ ${f_gulf} == egl3 ]] ; then

      bsn=egl3
      export pgm="etss_model"
      echo g ${iopt} > fle20.${fle_ext}.${bsn}
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

      export FORT20=out_nesting26.bin

      startmsg

      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
elif [[ ${f_gulf} == e2a ]] ; then

      for bsn in hch2 ebr3
      do
      export pgm="etss_model"
      if [[ ${bsn} == hch2 ]] ; then
         echo e ${iopt} > fle20.${fle_ext}.${bsn}
      else
         echo g ${iopt} > fle20.${fle_ext}.${bsn}
      fi
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
      case ${bsn} in

      hch2)
         export FORT20=out_nesting9.bin ;;
      ebr3)
         export FORT20=out_nesting29.bin ;;
      esac

      startmsg
      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done      #  Basin loop
elif [[ ${f_gulf} == e2b ]] ; then

      for bsn in il3 esv4 co2 pb3 cr3
      do
      export pgm="etss_model"
      if [[ ${bsn} == cr3 ]] ; then
         echo g ${iopt} > fle20.${fle_ext}.${bsn}
      else
         echo e ${iopt} > fle20.${fle_ext}.${bsn}
      fi
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
      case ${bsn} in

      il3)
         export FORT20=out_nesting8.bin ;;
      esv4)
         export FORT20=out_nesting10.bin ;;
      co2)
         export FORT20=out_nesting12.bin ;;
      pb3)
         export FORT20=out_nesting13.bin ;;
      cr3)
         export FORT20=out_nesting28.bin ;;
      esac

      startmsg

      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}

      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done      #  Basin loop

elif [[ ${f_gulf} == e2 ]] ; then

      for bsn in il3 hch2 esv4 co2 pb3 ebr3 cr3
      do
      export pgm="etss_model"
      if [[ ${bsn} == ebr3 || ${bsn} == cr3 ]] ; then
         echo g ${iopt} > fle20.${fle_ext}.${bsn}
      else
         echo e ${iopt} > fle20.${fle_ext}.${bsn}
      fi
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
      case ${bsn} in

      il3)
         export FORT20=out_nesting8.bin ;;
      hch2)
         export FORT20=out_nesting9.bin ;;
      esv4)
         export FORT20=out_nesting10.bin ;;
      co2)
         export FORT20=out_nesting12.bin ;;
      pb3)
         export FORT20=out_nesting13.bin ;;
      ebr3)
         export FORT20=out_nesting29.bin ;;
      cr3)
         export FORT20=out_nesting28.bin ;;
      esac

      startmsg

      ${EXECetss}/etss_model -basin ${bsn} -rootDir ${PARMetss} -trk ${PARMetss}/trkfiles/tideOnly_14.trk -rex ${bsn}.${fle_ext}.etss2.0.rex -env ${bsn}.${fle_ext}.etss2.0.env -f_tide ${tide_v} -TideDatabase 2014 -spinUp 0 -rexSave 6 -nest 21 -verbose 1 >> $pgmout 2> errfile_${RANK}
      err=$?;export err; err_chk
      echo "`date`: Finished Run for ${bsn} in tide ${tide_v}" >> timing.txt
   done      #  Basin loop
fi
