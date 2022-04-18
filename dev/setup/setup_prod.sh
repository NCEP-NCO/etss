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

module load grib_util/1.0.3
if [[ ${SITE} == 'LUNA' ]]; then
   export targtmac=surge
else
   export targtmac=luna
fi

cd ${COMIN}
mkdir tmp
for ZZ in $(seq -f "%03g" 0 1 102);do
    scp ${targtmac}:${WCOSS_COMIN}/${cyc}/${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2 ./tmp
    ${WGRIB2} tmp/${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} tmp/${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2 -i -grib ${RUN}.${cycle}.sfluxgrbf${ZZ}.grib2
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
    scp ${targtmac}:${WCOSS_COMIN}/${HH}/${RUN}.t${HH}z.sfluxgrbf000.grib2 ./tmp
    ${WGRIB2} tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf00.grib2
    rm tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2
done

cd ${COMINm1}
mkdir tmp
for HH in 00 06 12 18;do
    scp ${targtmac}:${WCOSS_COMINm1}/${HH}/${RUN}.t${HH}z.sfluxgrbf000.grib2 ./tmp
    ${WGRIB2} tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf00.grib2
    rm tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2
done

cd ${COMINm2}
mkdir tmp
for HH in 00 06 12 18;do
    scp ${targtmac}:${WCOSS_COMINm2}/${HH}/${RUN}.t${HH}z.sfluxgrbf000.grib2 ./tmp
    ${WGRIB2} tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf00.grib2
    rm tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2
done 


cd ${COMINm3}
mkdir tmp
for HH in 00 06 12 18;do
    scp ${targtmac}:${WCOSS_COMINm3}/${HH}/${RUN}.t${HH}z.sfluxgrbf000.grib2 ./tmp
    ${WGRIB2} tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2 | \
    awk '{if($4 == "UGRD" && $5 == "10 m above ground" || $4 == "VGRD" && $5 == "10 m above ground" || $4 == "PRES" && $5 == "surface") print $0}' FS=':' | \
    ${WGRIB2} tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2 -i -grib ${RUN}.t${HH}z.sfluxgrbf00.grib2
    rm tmp/${RUN}.t${HH}z.sfluxgrbf000.grib2
done 
