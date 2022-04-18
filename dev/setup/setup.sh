#!/bin/bash

######
# Assumed variables...
# cyc = 00, 06, 12, 18
# PDY = 20130104
# PDYm1 = 20130103 
# PDYm2 = 20130102 
# PDYm3 = 20130101 
# MDLTEST_DIR = ${root}/tmp
# envir = prod
######

NET=gfs
RUN=gfs
cycle=t${cyc}z

CYC00=00
CYC06=06
CYC12=12
CYC18=18

COMIN=${MDLTEST_DIR}/com/${NET}/${envir}/${NET}.${PDY}
mkdir -p ${COMIN}/${CYC00} ${COMIN}/${CYC06}
mkdir -p ${COMIN}/${CYC12} ${COMIN}/${CYC18}
COMINm1=${MDLTEST_DIR}/com/${NET}/${envir}/${NET}.${PDYm1}
mkdir -p ${COMINm1}/${CYC00} ${COMINm1}/${CYC06}
mkdir -p ${COMINm1}/${CYC12} ${COMINm1}/${CYC18}
COMINm2=${MDLTEST_DIR}/com/${NET}/${envir}/${NET}.${PDYm2}
mkdir -p ${COMINm2}/${CYC00} ${COMINm2}/${CYC06}
mkdir -p ${COMINm2}/${CYC12} ${COMINm2}/${CYC18}
COMINm3=${MDLTEST_DIR}/com/${NET}/${envir}/${NET}.${PDYm3}
mkdir -p ${COMINm3}/${CYC00} ${COMINm3}/${CYC06}
mkdir -p ${COMINm3}/${CYC12} ${COMINm3}/${CYC18}

export WCOSS_COMIN=$(compath.py ${NET}/prod/${NET}.$PDY)
export WCOSS_COMINm1=$(compath.py ${NET}/prod/${NET}.$PDYm1)
export WCOSS_COMINm2=$(compath.py ${NET}/prod/${NET}.$PDYm2)
export WCOSS_COMINm3=$(compath.py ${NET}/prod/${NET}.$PDYm3)
if [[ ${SYSTEM} == 'CRAY' ]]; then
   module load grib_util/1.0.5
else
   module load grib_util
fi

cd ${COMIN}/${cyc}
for ZZ in $(seq -f "%03g" 0 1 102);do
    ${WGRIB2} ${WCOSS_COMIN}/${cyc}/atmos/${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${WCOSS_COMIN}/${cyc}/atmos/${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2 -i -grib ${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2
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
    cd ${COMIN}/${HH}
    ${WGRIB2} ${WCOSS_COMIN}/${HH}/atmos/${RUN}.t${HH}z.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${WCOSS_COMIN}/${HH}/atmos/${RUN}.t${HH}z.sfluxgrbf000.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf000.grib2
done

for HH in 00 06 12 18;do
    cd ${COMINm1}/${HH}
    ${WGRIB2} ${WCOSS_COMINm1}/${HH}/atmos/${RUN}.t${HH}z.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${WCOSS_COMINm1}/${HH}/atmos/${RUN}.t${HH}z.sfluxgrbf000.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf000.grib2
done

for HH in 00 06 12 18;do
    cd ${COMINm2}/${HH}
    ${WGRIB2} ${WCOSS_COMINm2}/${HH}/atmos/${RUN}.t${HH}z.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${WCOSS_COMINm2}/${HH}/atmos/${RUN}.t${HH}z.sfluxgrbf000.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf000.grib2
done 


for HH in 00 06 12 18;do
    cd ${COMINm3}/${HH}
    ${WGRIB2} ${WCOSS_COMINm3}/${HH}/atmos/${RUN}.t${HH}z.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} ${WCOSS_COMINm3}/${HH}/atmos/${RUN}.t${HH}z.sfluxgrbf000.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf000.grib2
done 


