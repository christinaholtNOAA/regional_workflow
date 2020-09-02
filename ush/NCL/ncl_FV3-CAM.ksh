#!/bin/ksh --login

if [ "${PBS_NODEFILE:-unset}" != "unset" ]; then
        THREADS=$(cat $PBS_NODEFILE | wc -l)
else
        THREADS=16
fi
echo "Using $THREADS thread(s) for procesing."

# Variables sent from xml
# DATAROOT
# DATAHOME
# START_TIME
# FCST_TIME


# Load modules
module purge
module load intel
module load szip hdf5 netcdf
module load imagemagick
module load ncl

# Make sure we are using GMT time zone for time computations
# export DATAROOT="/scratch3/BMC/det/beck/FV3-CAM/run_dirs/real_time"  # for testing
# export FCST_TIME=00  # for testing
# export START_TIME=2019042712  # for testing
export TZ="GMT"
# export NCARG_ROOT="/apps/ncl/6.5.0-CentOS6.10_64bit_nodap_gnu447"
# export NCARG_LIB="/apps/ncl/6.5.0-CentOS6.10_64bit_nodap_gnu447/lib"
export NCL_HOME="/whome/wrfruc/bin/ncl/nclhrrr"
export UDUNITS2_XML_PATH=$NCARG_ROOT/lib/ncarg/udunits/udunits2.xml

# Set up paths to shell commands
LS=/bin/ls
LN=/bin/ln
RM=/bin/rm
MKDIR=/bin/mkdir
CP=/bin/cp
MV=/bin/mv
ECHO=/bin/echo
CAT=/bin/cat
GREP=/bin/grep
CUT=/bin/cut
AWK="/bin/gawk --posix"
SED=/bin/sed
DATE=/bin/date
BC=/usr/bin/bc
XARGS=${XARGS:-/usr/bin/xargs}
BASH=${BASH:-/bin/bash}
NCL=`which ncl`
CTRANS=`which ctrans`
PS2PDF=/usr/bin/ps2pdf
CONVERT=`which convert`
MONTAGE=`which montage`
PATH=${NCARG_ROOT}/bin:${PATH}

#typeset -RZ2 FCST_TIME
typeset -RZ2 FCST_TIME_AHEAD1
typeset -RZ2 FCST_TIME_AHEAD2
typeset -RZ2 FCST_TIME_BACK1
typeset -RZ2 FCST_TIME_BACK3
typeset -Z6 j
typeset -Z6 k

# ulimit -s 512000
ulimit -s 1024000

EXE_ROOT=/whome/wrfruc/bin/ncl/nclhrrr

# Print run parameters
${ECHO}
${ECHO} "ncl.ksh started at `${DATE}`"
${ECHO}
${ECHO} "NCL = ${NCL}"
${ECHO} "CTRANS = ${CTRANS}"
${ECHO} "CONVERT = ${CONVERT}"
${ECHO} "MONTAGE = ${MONTAGE}"
${ECHO} "DATAROOT = ${DATAROOT}"
${ECHO} "DATAHOME = ${DATAHOME}"
${ECHO} "EXE_ROOT = ${EXE_ROOT}"

# Check to make sure the EXE_ROOT var was specified
if [ ! -d ${EXE_ROOT} ]; then
  ${ECHO} "ERROR: EXE_ROOT, '${EXE_ROOT}', does not exist"
  exit 1
fi

# Check to make sure that the DATAHOME exists
if [ ! -d ${DATAHOME} ]; then
  ${ECHO} "ERROR: DATAHOME, '${DATAHOME}', does not exist"
  exit 1
fi
# If START_TIME is not defined, use the current time
if [ ! "${START_TIME}" ]; then
  ${ECHO} "START_TIME not defined - get from date"
  START_TIME=$( date +"%Y%m%d %H" )
  START_TIME_BACK1=$( date +"%Y%m%d %H" -d "1 hour ago" )
  START_TIME_BACK2=$( date +"%Y%m%d %H" -d "2 hours ago" )
  INIT_HOUR=$( date +"%H" -d "${START_TIME}" )
  START_TIME=$( date +"%Y%m%d%H" -d "${START_TIME}" )
  START_TIME_BACK1=$( date +"%Y%m%d%H" -d "${START_TIME_BACK1}" )
  START_TIME_BACK2=$( date +"%Y%m%d%H" -d "${START_TIME_BACK2}" )
else
  ${ECHO} "START_TIME defined and is ${START_TIME}"
  START_TIME=$( date +"%Y%m%d %H" -d "${START_TIME%??} ${START_TIME#????????}" )
  START_TIME_BACK1=$( date +"%Y%m%d %H" -d "${START_TIME} 1 hour ago" )
  START_TIME_BACK2=$( date +"%Y%m%d %H" -d "${START_TIME} 2 hours ago" )
  INIT_HOUR=$( date +"%H" -d "${START_TIME}" )
  START_TIME=$( date +"%Y%m%d%H" -d "${START_TIME}" )
  START_TIME_BACK1=$( date +"%Y%m%d%H" -d "${START_TIME_BACK1}" )
  START_TIME_BACK2=$( date +"%Y%m%d%H" -d "${START_TIME_BACK2}" )
fi

#INIT_HOUR=$( date +"%H" -d "${START_TIME}" )

# To be valid at the same time, FCST_TIME_AHEAD1 matches with START_TIME_BACK1,
# and FCST_TIME_AHEAD2 matches with START_TIME_BACK2

FCST_TIME_AHEAD1=99
FCST_TIME_AHEAD2=99
if (( ${INIT_HOUR} == 00 || ${INIT_HOUR} == 06 || ${INIT_HOUR} == 12 || ${INIT_HOUR} == 18 )); then
  if (( ${FCST_TIME} <= 34 )); then
    FCST_TIME_AHEAD1=$(($FCST_TIME + 1))
    FCST_TIME_AHEAD2=$(($FCST_TIME + 2))
  else
    if (( ${FCST_TIME} == 35 )); then
      FCST_TIME_AHEAD1=$(($FCST_TIME + 1))
    fi  
  fi  
else
  if (( ${FCST_TIME} <= 16 )); then
    FCST_TIME_AHEAD1=$(($FCST_TIME + 1))
    FCST_TIME_AHEAD2=$(($FCST_TIME + 2))
  else
    if (( ${FCST_TIME} == 17 )); then
      FCST_TIME_AHEAD1=$(($FCST_TIME + 1))
    fi  
  fi  
fi

# These used for 1hr 80m wind speed change, and esbl 1h 80m change
FCST_TIME_BACK1=-9
if (( ${FCST_TIME} >= 1 )); then
  FCST_TIME_BACK1=$(($FCST_TIME - 1))
fi

# Used for 3h pressure change
FCST_TIME_BACK3=-9
if (( ${FCST_TIME} >= 3 )); then
  FCST_TIME_BACK3=$(($FCST_TIME - 3))
fi

# Print out times
# ${ECHO} "   START TIME = "`${DATE} +%Y%m%d%H -d "${START_TIME}"`
${ECHO} "   START_TIME = ${START_TIME}"
${ECHO} "   START_TIME_BACK1 = ${START_TIME_BACK1}"
${ECHO} "   START_TIME_BACK2 = ${START_TIME_BACK2}"
${ECHO} "   FCST_TIME = ${FCST_TIME}"
${ECHO} "   FCST_TIME_AHEAD1 = ${FCST_TIME_AHEAD1}"
${ECHO} "   FCST_TIME_AHEAD2 = ${FCST_TIME_AHEAD2}"
${ECHO} "   FCST_TIME_BACK1 = ${FCST_TIME_BACK1}"
if (( ${FCST_TIME} <= 3 )); then
  ${ECHO} "   FCST_TIME_BACK3 = ${FCST_TIME_BACK3}"
fi

# Set up the work directory and cd into it
# workdir=nclprd/${FCST_TIME}part1   # for testing
workdir=${DATAHOME}/nclprd/${START_TIME}${FCST_TIME}
${RM} -rf ${workdir}
${MKDIR} -p ${workdir}
cd ${workdir}
pwd

# Link to input file
BACK1_DATAROOT=${DATAROOT}/${START_TIME_BACK1}
BACK2_DATAROOT=${DATAROOT}/${START_TIME_BACK2}
# DATAHOME=${DATAROOT}/${START_TIME}  # for testing
# /scratch3/BMC/det/beck/FV3-CAM/run_dirs/real_time/2019061200/postprd/HRRR.t00z.bgdawp23.tm00
${LN} -s ${DATAHOME}/postprd/HRRR.t${INIT_HOUR}z.bgdawp${FCST_TIME}.tm${INIT_HOUR} hrrrfile.grb
${ECHO} "hrrrfile.grb" > arw_file.txt
# ${LN} -s ${DATAHOME}/postprd/wrfnat_hrconus_${FCST_TIME}.grib2 hrrrnatfile.grb
# ${ECHO} "hrrrnatfile.grb" > nat_file.txt
# if (( ${FCST_TIME_AHEAD1} != 99 )); then
#   ${LN} -s ${BACK1_DATAROOT}/postprd/wrfprs_hrconus_${FCST_TIME_AHEAD1}.grib2 back1file.grb
#   ${ECHO} "back1file.grb" > back1_file.txt
#   ${LN} -s ${BACK1_DATAROOT}/postprd/wrfprs_hrconus_${FCST_TIME}.grib2 back1fileback1hour.grb
#   ${ECHO} "back1fileback1hour.grb" > back1_file_back1_hour.txt
# fi
# if (( ${FCST_TIME_AHEAD2} != 99 )); then
#   ${LN} -s ${BACK2_DATAROOT}/postprd/wrfprs_hrconus_${FCST_TIME_AHEAD2}.grib2 back2file.grb
#   ${ECHO} "back2file.grb" > back2_file.txt
#   ${LN} -s ${BACK2_DATAROOT}/postprd/wrfprs_hrconus_${FCST_TIME_AHEAD1}.grib2 back2fileback1hour.grb
#   ${ECHO} "back2fileback1hour.grb" > back2_file_back1_hour.txt
# fi
# if (( ${FCST_TIME_BACK1} != -9 )); then
#   ${LN} -s ${DATAHOME}/postprd/wrfprs_hrconus_${FCST_TIME_BACK1}.grib2 back1hour.grb
#   ${ECHO} "back1hour.grb" > back1_hour.txt
# fi
# if (( ${FCST_TIME_BACK3} != -9 )); then
#   ${LN} -s ${DATAHOME}/postprd/wrfprs_hrconus_${FCST_TIME_BACK3}.grib2 back3file.grb
#   ${ECHO} "back3file.grb" > back3_file.txt
# fi

ls -al hrrrfile.grb
# ls -al hrrrnatfile.grb
# ls -al back1file.grb
# ls -al back1fileback1hour.grb
# ls -al back2file.grb
# ls -al back2fileback1hour.grb
# ls -al back1hour.grb
# ls -al back3file.grb

set -A ncgms  sfc_temp   \
              2m_temp    \
              2m_dewp    \
              2m_rh      \
              2ds_temp   \
              10m_wind   \
              80m_wind   \
              850_wind   \
              250_wind   \
              sfc_pwtr   \
              sfc_cref   \
              sfc_ptyp   \
              sfc_cape   \
              sfc_cin    \
              sfc_acp    \
              sfc_weasd  \
              sfc_1hsnw  \
              sfc_sfcp   \
              ua_rh      \
              850_rh     \
              700_vvel   \
              sfc_vis    \
              ua_ceil    \
              ua_ctop    \
              10m_gust   \
              sfc_hlcy  \
              in25_hlcy \
              sfc_lcl   \
              sfc_tcc   \
              sfc_lcc   \
              sfc_mcc   \
              sfc_hcc   \
              sfc_mucp  \
              sfc_mulcp \
              sfc_mxcp  \
              sfc_1hsm  \
              sfc_3hsm  \
              sfc_s1shr \
              sfc_6kshr \
              500_temp  \
              700_temp  \
              850_temp  \
              925_temp  \
              sfc_1ref  \
              sfc_bli   \
              nta_ulwrf \
              sfc_ulwrf \
              sfc_uswrf \
              sfc_lhtfl \
              sfc_shtfl \
              sfc_flru  \
              sfc_solar \
              sfc_rvil

set -A monpngs montage.png

set -A webpfx temp temp dewp rh temp wind wind wind wind pwtr cref \
              ptyp cape cin acp weasd 1hsnw \
              sfcp rh rh vvel vis ceil ctop gust hlcy hlcy \
              lcl tcc lcc mcc hcc \
              mucp mulcp mxcp 1hsm 3hsm s1shr 6kshr temp temp temp temp \
              1ref bli ulwrf ulwrf uswrf lhtfl shtfl flru solar rvil

set -A websfx sfc 2m 2m 2m 2ds 10m 80m 850 250 sfc sfc sfc sfc sfc sfc \
              sfc sfc sfc 500 850 700 sfc ua ua 10m \
              sfc in25 sfc sfc sfc sfc \
              sfc sfc sfc sfc sfc sfc sfc sfc 500 700 850 925 sfc sfc nta sfc sfc \
              sfc sfc sfc sfc sfc

set -A tiles dum t1 t2 t3 t4 t5 t6 t7 t8 z0 z1 z2 z3 z4 z5 z6 z7 z8 z9

set -A webmon montage

i=0
p=0
while [ ${i} -lt ${#ncgms[@]} ]; do
  j=000000
  k=000000
  numtiles=${#tiles[@]}
  (( numtiles=numtiles - 1 )) 
  while [ ${j} -le ${numtiles} ]; do
    (( k=j + 1 )) 
    pngs[${p}]=${ncgms[${i}]}.${k}.png
#    echo ${pngs[${p}]}
    if [ ${j} -eq 000000 ]; then 
      if [ "${websfx[${i}]}" = "ua" ]; then 
        webnames[${p}]=${webpfx[${i}]}
      else 
        webnames[${p}]=${webpfx[${i}]}_${websfx[${i}]}
      fi   
    else 
      if [ "${websfx[${i}]}" = "ua" ]; then 
        webnames[${p}]=${webpfx[${i}]}_${tiles[${j}]}
      else 
        webnames[${p}]=${webpfx[${i}]}_${tiles[${j}]}${websfx[${i}]}
      fi   
    fi   
#    echo ${webnames[${p}]}
    (( j=j + 1 )) 
# p is total number of images (image index)
    (( p=p + 1 )) 
  done 
  (( i=i + 1 )) 
done

ncl_error=0

# Run the NCL scripts for each plot
cp ${EXE_ROOT}/Airpor* .
cp ${EXE_ROOT}/names_grib2.txt .
i=0
echo "FIRST While, ${#ncgms[@]} items"
CMDFN=/tmp/cmd.hrrrx.$$
${RM} -f $CMDFN

while [ ${i} -lt ${#ncgms[@]} ]; do

  plot=${ncgms[${i}]}
  ${ECHO} "Starting rr_${plot}.ncl at `${DATE}`"
#  ${NCL} < ${EXE_ROOT}/rr_${plot}.ncl
#  error=$?
#  if [ ${error} -ne 0 ]; then
#    ${ECHO} "ERROR: rr_${plot} crashed!  Exit status=${error}"
#    ncl_error=${error}
#  fi
#  ${ECHO} "Finished rr_${plot}.ncl at `${DATE}`"

  echo ${NCL} ${EXE_ROOT}/rr_${plot}.ncl >> $CMDFN

  (( i=i + 1 ))

done

${CAT} $CMDFN | ${XARGS} -P $THREADS -I {} ${BASH} -c "{}" 
ncl_error=$?
${RM} -f $CMDFN

# Copy png files to their proper names
i=0
while [ ${i} -lt ${#pngs[@]} ]; do
  ${ECHO} "i = ${i} at `${DATE}`"
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  fulldir=${DATAHOME}/nclprd/full
  ${MKDIR} -p ${fulldir}
  webfile=${fulldir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  t1dir=${DATAHOME}/nclprd/t1
  ${MKDIR} -p ${t1dir}
  webfile=${t1dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  t2dir=${DATAHOME}/nclprd/t2
  ${MKDIR} -p ${t2dir}
  webfile=${t2dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  t3dir=${DATAHOME}/nclprd/t3
  ${MKDIR} -p ${t3dir}
  webfile=${t3dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  t4dir=${DATAHOME}/nclprd/t4
  ${MKDIR} -p ${t4dir}
  webfile=${t4dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  t5dir=${DATAHOME}/nclprd/t5
  ${MKDIR} -p ${t5dir}
  webfile=${t5dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  t6dir=${DATAHOME}/nclprd/t6
  ${MKDIR} -p ${t6dir}
  webfile=${t6dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  t7dir=${DATAHOME}/nclprd/t7
  ${MKDIR} -p ${t7dir}
  webfile=${t7dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  t8dir=${DATAHOME}/nclprd/t8
  ${MKDIR} -p ${t8dir}
  webfile=${t8dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  z0dir=${DATAHOME}/nclprd/z0
  ${MKDIR} -p ${z0dir}
  webfile=${z0dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  z1dir=${DATAHOME}/nclprd/z1
  ${MKDIR} -p ${z1dir}
  webfile=${z1dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  z2dir=${DATAHOME}/nclprd/z2
  ${MKDIR} -p ${z2dir}
  webfile=${z2dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  z3dir=${DATAHOME}/nclprd/z3
  ${MKDIR} -p ${z3dir}
  webfile=${z3dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  z4dir=${DATAHOME}/nclprd/z4
  ${MKDIR} -p ${z4dir}
  webfile=${z4dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  z5dir=${DATAHOME}/nclprd/z5
  ${MKDIR} -p ${z5dir}
  webfile=${z5dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  z6dir=${DATAHOME}/nclprd/z6
  ${MKDIR} -p ${z6dir}
  webfile=${z6dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  z7dir=${DATAHOME}/nclprd/z7
  ${MKDIR} -p ${z7dir}
  webfile=${z7dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  z8dir=${DATAHOME}/nclprd/z8
  ${MKDIR} -p ${z8dir}
  webfile=${z8dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
  pngfile=${pngs[${i}]}
  ${CONVERT} -colors 255 -trim ${pngfile} ${pngfile}
  z9dir=${DATAHOME}/nclprd/z9
  ${MKDIR} -p ${z9dir}
  webfile=${z9dir}/${webnames[${i}]}_f${FCST_TIME}.png
  ${MV} ${pngfile} ${webfile}
  (( i=i + 1 ))
done

# Remove the workdir
${RM} -rf ${workdir}

${ECHO} "ncl.ksh completed at `${DATE}`"

exit ${ncl_error}


