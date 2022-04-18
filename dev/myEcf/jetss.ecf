#!/bin/bash



######################################################################
# The ECF options
######################################################################
#. ${HOMEetss:?}/dev/myEcf/etss.ver
. ${HOMEetss:?}/versions/run.ver

qsub << EOF 
  #PBS -N ETSS.${pid}
  #PBS -j oe
  #PBS -l walltime=1:50:00
  #PBS -q ${QUEUE:?}
  #PBS -A ETSS-DEV
  #PBS -l place=vscatter,select=1:ncpus=14:mem=15GB
  #PBS -l debug=true
  #PBS -V
  #PBS -W umask=022
  #PBS -W depend=afterok:${etss_prewnd_id}

  module purge
  module load envvar/$envvar_ver
  module load PrgEnv-intel/${PrgEnv_intel_ver}
  module load intel/${intel_ver}
  module load craype/${craype_ver}
  module load prod_util/${prod_util_ver}
  module load cray-pals/${cray_pals_ver}
  module load cfp/${cfp_ver}
  ${HOMEetss}/jobs/JETSS
EOF
