#!/bin/bash -l

#module load prod_util
#find /gpfs/hps3/mdl/mdlsurge/noscrub/mdl.surge/etss.v2.3.0_mdl/com/etss/prod/* -type d -ctime +5 | xargs rm -rf

if [ $# -eq 5 ] ; then
   YYYYMMDD=$1
   cycle=$2
   fgt_data=$3
   jump=$4
   web=$5
elif [ $# -eq 4 ] ; then
   YYYYMMDD=$(date +%Y%m%d)
   cycle=$1
   fgt_data=$2
   jump=$3
   web=$4
else
  now=$(date +"%Y%m%d")
  echo "You are trying to run the ETSS model system on ${SYSTEM}. But you missed something........."
  echo ""
  echo "[1]--You can run model using wind forcing from specifying date:"
  echo ""
  echo "Usage $0 <date ${now}> <cycle (00, 06, 12, 18)> <copy/no-copy GFS data> <skip ETSS model itself run (Y/N)> <generating web images (Y/N)>"
  echo ""
  echo "[2]--You can run model using today's wind forcing:"
  echo ""
  echo "Usage $0 <cycle (00, 06, 12, 18)> <copy/no-copy GFS data> <skip ETSS model itself run (Y/N)> <generating web images (Y/N)>"
  echo ""
  exit
fi

export pid=$$

root=$(cd $(dirname $0) && pwd)
#########################################################
#  Directory for etss2.3 tmp and local copy of com, pcom
#########################################################

if [ ! -e ${root}/etss.v2.3.0 ]; then
   if [[ ${USER} == 'mdl.surge' ]]; then  # MDL dev env
      mkdir -p /gpfs/hps3/ptmp/mdl.surge/etss.v2.3.0
      ln -s /gpfs/hps3/ptmp/mdl.surge/etss.v2.3.0 etss.v2.3.0
   else
      echo 'Please create output directory "etss.v2.3.0" under' ${root}
      echo 'e.g. you can create a "etss.v2.3.0" directory under the "ptmp"'
      echo 'directory and then make a symbolic link to it under' ${root}
      exit
   fi
fi
export ETSS_PRIORITY=dev
export QUEUE=${ETSS_PRIORITY:-dev}
if [[ ${jump} == "N" ]] ; then
   ${root}/runETSS_model.sh $YYYYMMDD ${cycle} ${fgt_data} ${web}  #submit ETSS model job
else
   ${root}/runPost_ETSS.sh $YYYYMMDD ${cycle} ${jump}              #submit PostETSS job
   ${root}/runETSS_gempak.sh $YYYYMMDD ${cycle} con ${jump}       #submit gempak job for conus grid
   ${root}/runETSS_gempak.sh $YYYYMMDD ${cycle} ala ${jump}       #submit gempak job for ala grid

   if [[ ${web} == "Y" ]] ; then
      ${root}/run_gen_png_prod.sh $YYYYMMDD ${cycle} ${jump}       #submit generating images job
   fi
fi
