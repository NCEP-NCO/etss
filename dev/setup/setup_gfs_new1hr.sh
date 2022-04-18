#!/bin/bash

export PDY=$1
export cyc=$2
export cycle=t${cyc}z

cd ${MDLTEST_DIR}

setpdy.sh
. PDY

src=$(cd $(dirname $0)/.. && pwd)
root=${src}

export MDLTEST_HOME=${root}

###############################################
#  Directory for MDL copy of com, pcom, tmp
###############################################
mkdir -p ${MDLTEST_DIR}

export COMROOT=${MDLTEST_DIR}/com


NET=gfs
RUN=gfs
cycle=t${cyc}z
envir=prod

COMIN=${MDLTEST_DIR}/com/${NET}/${envir}/${NET}.${PDY}
mkdir -p ${COMIN}
COMINm1=${MDLTEST_DIR}/com/${NET}/${envir}/${NET}.${PDYm1}
mkdir -p ${COMINm1}
COMINm2=${MDLTEST_DIR}/com/${NET}/${envir}/${NET}.${PDYm2}
mkdir -p ${COMINm2}
COMINm3=${MDLTEST_DIR}/com/${NET}/${envir}/${NET}.${PDYm3}
mkdir -p ${COMINm3}

export WCOSS_COMIN=$(compath.py ${NET}/prod/${NET}.$PDY)
export WCOSS_COMINm1=$(compath.py ${NET}/prod/${NET}.$PDYm1)
export WCOSS_COMINm2=$(compath.py ${NET}/prod/${NET}.$PDYm2)
export WCOSS_COMINm3=$(compath.py ${NET}/prod/${NET}.$PDYm3)
if [[ ${SYSTEM} == 'CRAY' ]]; then
   module load grib_util/1.0.3
else
   module load grib_util
fi

cd ${COMIN}
for ZZ in $(seq -f "%02g" 0 1 102);do
    ${WGRIB2} ${WCOSS_COMIN}/${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${WCOSS_COMIN}/${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2 -i -grib ${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2
    cat ${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2 >> ${RUN}.${cycle}.sfluxgrbfALL.grib2
done
if [[ ${cyc} == 00 ]] ; then
   DDM=0
elif [[ ${cyc} == 06 ]] ; then
   DDM=6
elif [[ ${cyc} == 12 ]] ; then
   DDM=12
else
   DDM=18
fi
for HH in $(seq -f "%02g" 0 6 ${DDM});do
    ${WGRIB2} ${WCOSS_COMIN}/${RUN}.t${HH}z.sfluxgrbf00.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${WCOSS_COMIN}/${RUN}.t${HH}z.sfluxgrbf00.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf00.grib2
done

cd ${COMINm1}
for HH in 00 06 12 18;do
    ${WGRIB2} ${WCOSS_COMINm1}/${RUN}.t${HH}z.sfluxgrbf00.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${WCOSS_COMINm1}/${RUN}.t${HH}z.sfluxgrbf00.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf00.grib2
done

cd ${COMINm2}
for HH in 00 06 12 18;do
    ${WGRIB2} ${WCOSS_COMINm2}/${RUN}.t${HH}z.sfluxgrbf00.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${WCOSS_COMINm2}/${RUN}.t${HH}z.sfluxgrbf00.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf00.grib2
done 


cd ${COMINm3}
for HH in 00 06 12 18;do
    ${WGRIB2} ${WCOSS_COMINm3}/${RUN}.t${HH}z.sfluxgrbf00.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${WCOSS_COMINm3}/${RUN}.t${HH}z.sfluxgrbf00.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf00.grib2
done 


