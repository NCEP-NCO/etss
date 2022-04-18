#!/bin/bash

# ###########################################################################################
# Author: Huiqing Liu (Huiqing.Liu@noaa.gov)                                      09-24-2021
#
# Abstract:
#   Creat poe-script and submit the jobs to draw gridded products image
#
# Parameters:
#  Inputs:  Various environmental variables defined either in ecflow or in the
#           j-job jobs/JETSS
#           girdded stormtide grib2 files - ${COMIN}/etss.t${cyc}z.stormtide*grib2
#  Outputs: poe-script - list of running scripts for mpiexec
#           - ${COMOUT}/etss.t00z.img.tar.gz
# ###########################################################################################

#############################################################################################
# 09-24-2021: Created by Huiqing Liu
#############################################################################################

export RANK=$1

if [[ ${RANK} == 0 ]] ; then

   ${USHetss}/etss_shp_img_web.sh ala 2.2 stormsurge
   echo "Model nesting EAST coast I complete" > msg_Done_ala2.2_1.txt

elif [[ ${RANK} == 1 ]] ; then

   ${USHetss}/etss_shp_img_web.sh con 2.2 stormtide
   echo "Model nesting EAST coast I complete" > msg_Done_con2.2_1.txt

elif [[ ${RANK} == 12 ]] ; then
   ${USHetss}/etss_shp_img_web.sh ala 2.2 stormtide
   echo "Model nesting EAST coast I complete" > msg_Done_ala2.2_2.txt
elif [[ ${RANK} == 13 ]] ; then

   ${USHetss}/etss_shp_img_web.sh con 2.2 stormsurge
   echo "Model nesting EAST coast I complete" > msg_Done_con2.2_2.txt

# Post process 625m NDFD cpu 2 to 21 (20 cpu)
else

##### for ETSS2.2 625m grid
  if [[ ${RANK} == 2 ]] ; then
     ${USHetss}/etss_shp_img_625m_web.sh 1 9 stormtide 2.2
     echo "625m part 1 is finished" > msg_img_625m_1v.txt

     while [[ ! -f msg_img_625m_2v.txt || ! -f msg_img_625m_3v.txt || ! -f msg_img_625m_4v.txt || ! -f msg_img_625m_5v.txt || ! -f msg_img_625m_6v.txt || ! -f msg_img_625m_7v.txt || ! -f msg_img_625m_8v.txt || ! -f msg_img_625m_9v.txt || ! -f msg_img_625m_10v.txt ]] ; do
         echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
         sleep 1
     done

  elif [[ ${RANK} == 3 ]] ; then
     ${USHetss}/etss_shp_img_625m_web.sh 10 19 stormtide 2.2
     echo "625m part 2 is finished" > msg_img_625m_2v.txt
     while [[ ! -f msg_img_625m_1v.txt || ! -f msg_img_625m_3v.txt || ! -f msg_img_625m_4v.txt || ! -f msg_img_625m_5v.txt || ! -f msg_img_625m_6v.txt || ! -f msg_img_625m_7v.txt || ! -f msg_img_625m_8v.txt || ! -f msg_img_625m_9v.txt || ! -f msg_img_625m_10v.txt ]] ; do
         echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
         sleep 1
     done

  elif [[ ${RANK} == 4 ]] ; then
     ${USHetss}/etss_shp_img_625m_web.sh 20 29 stormtide 2.2
     echo "625m part 3 is finished" > msg_img_625m_3v.txt
     while [[ ! -f msg_img_625m_1v.txt || ! -f msg_img_625m_2v.txt || ! -f msg_img_625m_4v.txt || ! -f msg_img_625m_5v.txt || ! -f msg_img_625m_6v.txt || ! -f msg_img_625m_7v.txt || ! -f msg_img_625m_8v.txt || ! -f msg_img_625m_9v.txt || ! -f msg_img_625m_10v.txt ]] ; do
         echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
         sleep 1 
     done 

  elif [[ ${RANK} == 5 ]] ; then
     ${USHetss}/etss_shp_img_625m_web.sh 30 39 stormtide 2.2
     echo "625m part 4 is finished" > msg_img_625m_4v.txt
     while [[ ! -f msg_img_625m_1v.txt || ! -f msg_img_625m_2v.txt || ! -f msg_img_625m_3v.txt || ! -f msg_img_625m_5v.txt || ! -f msg_img_625m_6v.txt || ! -f msg_img_625m_7v.txt || ! -f msg_img_625m_8v.txt || ! -f msg_img_625m_9v.txt || ! -f msg_img_625m_10v.txt ]] ; do
         echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
         sleep 1
     done

  elif [[ ${RANK} == 6 ]] ; then
     ${USHetss}/etss_shp_img_625m_web.sh 40 49 stormtide 2.2
     echo "625m part 5 is finished" > msg_img_625m_5v.txt
     while [[ ! -f msg_img_625m_1v.txt || ! -f msg_img_625m_2v.txt || ! -f msg_img_625m_3v.txt || ! -f msg_img_625m_4v.txt || ! -f msg_img_625m_6v.txt || ! -f msg_img_625m_7v.txt || ! -f msg_img_625m_8v.txt || ! -f msg_img_625m_9v.txt || ! -f msg_img_625m_10v.txt ]] ; do
         echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
         sleep 1
     done
  elif [[ ${RANK} == 7 ]] ; then
     ${USHetss}/etss_shp_img_625m_web.sh 50 59 stormtide 2.2
     echo "625m part 6 is finished" > msg_img_625m_6v.txt
     while [[ ! -f msg_img_625m_1v.txt || ! -f msg_img_625m_2v.txt || ! -f msg_img_625m_3v.txt || ! -f msg_img_625m_4v.txt || ! -f msg_img_625m_5v.txt || ! -f msg_img_625m_7v.txt || ! -f msg_img_625m_8v.txt || ! -f msg_img_625m_9v.txt || ! -f msg_img_625m_10v.txt ]] ; do
         echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
         sleep 1
     done
  elif [[ ${RANK} == 8 ]] ; then
     ${USHetss}/etss_shp_img_625m_web.sh 60 69 stormtide 2.2
     echo "625m part 7 is finished" > msg_img_625m_7v.txt
     while [[ ! -f msg_img_625m_1v.txt || ! -f msg_img_625m_2v.txt || ! -f msg_img_625m_3v.txt || ! -f msg_img_625m_4v.txt || ! -f msg_img_625m_5v.txt || ! -f msg_img_625m_6v.txt || ! -f msg_img_625m_8v.txt || ! -f msg_img_625m_9v.txt || ! -f msg_img_625m_10v.txt ]] ; do
         echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
         sleep 1
     done

  elif [[ ${RANK} == 9 ]] ; then
     ${USHetss}/etss_shp_img_625m_web.sh 70 79 stormtide 2.2
     echo "625m part 8 is finished" > msg_img_625m_8v.txt
     while [[ ! -f msg_img_625m_1v.txt || ! -f msg_img_625m_2v.txt || ! -f msg_img_625m_3v.txt || ! -f msg_img_625m_4v.txt || ! -f msg_img_625m_5v.txt || ! -f msg_img_625m_6v.txt || ! -f msg_img_625m_7v.txt || ! -f msg_img_625m_9v.txt || ! -f msg_img_625m_10v.txt ]] ; do
         echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
         sleep 1
     done

  elif [[ ${RANK} == 10 ]] ; then
     ${USHetss}/etss_shp_img_625m_web.sh 80 89 stormtide 2.2
     echo "625m part 9 is finished" > msg_img_625m_9v.txt
     while [[ ! -f msg_img_625m_1v.txt || ! -f msg_img_625m_2v.txt || ! -f msg_img_625m_3v.txt || ! -f msg_img_625m_4v.txt || ! -f msg_img_625m_5v.txt || ! -f msg_img_625m_6v.txt || ! -f msg_img_625m_7v.txt || ! -f msg_img_625m_8v.txt || ! -f msg_img_625m_10v.txt ]] ; do
         echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
         sleep 1
     done

  elif [[ ${RANK} == 11 ]] ; then
     ${USHetss}/etss_shp_img_625m_web.sh 90 103 stormtide 2.2
     echo "625m part 10 is finished" > msg_img_625m_10v.txt
     while [[ ! -f msg_img_625m_1v.txt || ! -f msg_img_625m_2v.txt || ! -f msg_img_625m_3v.txt || ! -f msg_img_625m_4v.txt || ! -f msg_img_625m_5v.txt || ! -f msg_img_625m_6v.txt || ! -f msg_img_625m_7v.txt || ! -f msg_img_625m_8v.txt || ! -f msg_img_625m_9v.txt ]] ; do
         echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
         sleep 1
     done
  fi
# ended
fi

while [[ ! -f msg_Done_con2.2_1.txt || ! -f msg_Done_ala2.2_1.txt || ! -f msg_Done_con2.2_2.txt || ! -f msg_Done_ala2.2_2.txt ]] ; do
      echo "`date`: Rank ${RANK} Sleeping post processing" >> timing.txt
      sleep 1
done

if [[ ${RANK} == 1 ]] ; then

   while [[ ! -f msg_Done_final1.txt || ! -f msg_Done_final2.txt || ! -f msg_Done_final3.txt || ! -f msg_Done_final4.txt || ! -f msg_Done_final5.txt || ! -f msg_Done_final6.txt ]] ; do
         sleep 1
   done
   echo "`date`: Finished post processing" > png_${cyc}.txt
   echo ${PDY}${cyc} > PDY.txt
   cp PDY.txt ${COMOUT}/

   cd ${IMGetss}/../
   tar -czf ${COMOUT}/etss.t${cyc}z.img.tar.gz img/*
   
   cd ${DATA}

   if [[ ${RUN_ENVIR} == "MDLTEST" ]] ; then
      echo "Image generation is finished" > ${MDLTEST_DIR}/tmpnwprd1/image_finish.txt
   fi
# new images for esri animation web.
elif [[ ${RANK} == 2 ]] ; then
     ${USHetss}/etss_shp_img_web_ala.sh stormtide 3km
     echo "`date`: Finished post processing" > msg_Done_final1.txt
elif [[ ${RANK} == 3 ]] ; then 
     ${USHetss}/etss_shp_img_web_ala.sh stormsurge 3km
     echo "`date`: Finished post processing" > msg_Done_final2.txt
elif [[ ${RANK} == 4 ]] ; then
     ${USHetss}/etss_shp_img_web_wst.sh stormtide 2p5km
     echo "`date`: Finished post processing" > msg_Done_final3.txt
elif [[ ${RANK} == 5 ]] ; then
     ${USHetss}/etss_shp_img_web_wst.sh stormsurge 2p5km
     echo "`date`: Finished post processing" > msg_Done_final4.txt
elif [[ ${RANK} == 6 ]] ; then

     ${USHetss}/etss_shp_img_web_estglf.sh stormtide 625m

     echo "`date`: Finished post processing" > msg_Done_final5.txt


elif [[ ${RANK} == 7 ]] ; then
     ${USHetss}/etss_shp_img_web_estglf.sh stormsurge 2p5km
     echo "`date`: Finished post processing" > msg_Done_final6.txt
      
#--------------------------------------
fi

echo "`date`: Rank ${RANK} finished post processing" >> timing.txt
