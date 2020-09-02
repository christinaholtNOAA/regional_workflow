#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that runs radar reflectivity preprocess
with FV3 for the specified cycle.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  
# Then process the arguments provided to this script/function (which 
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
valid_args=( "CYCLE_DIR" "WORKDIR")
process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Load modules.
#
#-----------------------------------------------------------------------
#
case $MACHINE in
#
"WCOSS_C" | "WCOSS")
#

  if [ "${USE_CCPP}" = "TRUE" ]; then
  
# Needed to change to the experiment directory because the module files
# for the CCPP-enabled version of FV3 have been copied to there.

    cd_vrfy ${CYCLE_DIR}
  
    set +x
    source ./module-setup.sh
    module use $( pwd -P )
    module load modules.fv3
    module list
    set -x
  
  else
  
    . /apps/lmod/lmod/init/sh
    module purge
    module use /scratch4/NCEPDEV/nems/noscrub/emc.nemspara/soft/modulefiles
    module load intel/16.1.150 impi/5.1.1.109 netcdf/4.3.0 
    module list
  
  fi

  ulimit -s unlimited
  ulimit -a
  APRUN="mpirun -l -np ${PE_MEMBER01}"
  ;;
#
"HERA")
  ulimit -s unlimited
  ulimit -a
  APRUN="srun"
  LD_LIBRARY_PATH="${UFS_WTHR_MDL_DIR}/FV3/ccpp/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  ;;
#
"JET")
  ulimit -s unlimited
  ulimit -a
  APRUN="srun"
  LD_LIBRARY_PATH="${UFS_WTHR_MDL_DIR}/FV3/ccpp/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  ;;
#
"ODIN")
#
  module list

  ulimit -s unlimited
  ulimit -a
  APRUN="srun -n ${PE_MEMBER01}"
  ;;
#
esac
#
#-----------------------------------------------------------------------
#
# Extract from CDATE the starting year, month, day, and hour of the
# forecast.  These are needed below for various operations.
#
#-----------------------------------------------------------------------
#
set -x
START_DATE=`echo "${CDATE}" | sed 's/\([[:digit:]]\{2\}\)$/ \1/'`
  YYYYMMDDHH=`date +%Y%m%d%H -d "${START_DATE}"`
  JJJ=`date +%j -d "${START_DATE}"`

YYYY=${YYYYMMDDHH:0:4}
MM=${YYYYMMDDHH:4:2}
DD=${YYYYMMDDHH:6:2}
HH=${YYYYMMDDHH:8:2}
YYYYMMDD=${YYYYMMDDHH:0:8}
#
#-----------------------------------------------------------------------
#
# Create links in the subdirectory of the current cycle's run di-
# rectory for radar reflectivity process.
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Creating links in the subdirectory of the current cycle's run di-
rectory for radar reflectivity process ..."


# Create directory.

cd ${WORKDIR}

fixdir=$FIXgsi/$PREDEF_GRID_NAME

print_info_msg "$VERBOSE" "fixdir is $fixdir"

#
#-----------------------------------------------------------------------
#
# link or copy background files
#
#-----------------------------------------------------------------------

FV3SARPATH=${CYCLE_DIR}
cp_vrfy ${fixdir}/fv3_grid_spec          fv3sar_grid_spec.nc

#
# link observation files
# copy observation files to working directory 
#
#-----------------------------------------------------------------------

#HH=17
NSSL=${OBSPATH_NSSLMOSIAC}
mrms="MRMS_EXP_MergedReflectivityQC"
echo "${MM0} ${MM1} ${MM2} ${MM3}"

# Link to the MRMS operational data
for min in ${MM0} ${MM1} ${MM2} ${MM3}
do
  echo "Looking for data valid:"${YYYY}"-"${MM}"-"${DD}" "${HH}":"${min}
  s=0
  while [[ $s -le 59 ]]; do
    if [ $s -lt 10 ]; then
      ss=0${s}
    else
      ss=$s
    fi
    nsslfile=${NSSL}/${YYYY}${MM}${DD}-${HH}${min}${ss}.${mrms}_00.50_${YYYY}${MM}${DD}-${HH}${min}${ss}.grib2
    if [ -s $nsslfile ]; then
      echo 'Found '${nsslfile}
      numgrib2=`ls ${NSSL}/${YYYY}${MM}${DD}-${HH}${min}*.${mrms}_*_${YYYY}${MM}${DD}-${HH}${min}*.grib2 | wc -l`
      echo 'Number of GRIB-2 files: '${numgrib2}
      if [ ${numgrib2} -ge 10 ] && [ ! -e filelist_mrms ]; then
        ln -sf ${NSSL}/${YYYY}${MM}${DD}-${HH}${min}*.${mrms}_*_${YYYY}${MM}${DD}-${HH}${min}*.grib2 . 
        ls ${YYYY}${MM}${DD}-${HH}${min}*.${mrms}_*_${YYYY}${MM}${DD}-${HH}${min}*.grib2 > filelist_mrms
        echo 'Creating links for ${YYYY}${MM}${DD}-${HH}${min}'
      fi
    fi
    ((s+=1))
  done
done

# remove filelist_mrms if zero bytes
if [ ! -s filelist_mrms ]; then
  rm -f filelist_mrms
fi

if [ -s filelist_mrms ]; then
   numgrib2=`more filelist_mrms | wc -l`
   print_info_msg "$VERBOSE" "Using radar data from: `head -1 filelist_mrms | cut -c10-15`"
   print_info_msg "$VERBOSE" "NSSL grib2 file levels = $numgrib2"
else
   echo "ERROR: Not enough radar reflectivity files available."
   exit 1
fi

#-----------------------------------------------------------------------
#
# Create links to fix files in the FIXgsi directory.
# Set fixed files
#   BUFR_TABLE= bufr table for sst ONLY needed for sst retrieval (retrieval=.true.)
#
#-----------------------------------------------------------------------
BUFR_TABLE=${fixdir}/prepobs_prep_RAP.bufrtable

# Fixed fields
cp_vrfy $BUFR_TABLE prepobs_prep.bufrtable

#-----------------------------------------------------------------------
#
# Build namelist and run GSI
#
#-----------------------------------------------------------------------

cat << EOF > mosaic.namelist
 &setup
  tversion=1,
  bkversion=1,
  analysis_time = ${YYYYMMDDHH},
  dataPath = './',
 /

EOF

#
#-----------------------------------------------------------------------
#
# Copy the GSI executable to the run directory.
#
#-----------------------------------------------------------------------
#
EXEC="${EXECDIR}/process_NSSL_mosaic.exe"

if [ -f $EXEC ]; then
  print_info_msg "$VERBOSE" "
Copying the radar process  executable to the run directory..."
  cp_vrfy ${EXEC} ${WORKDIR}/process_NSSL_mosaic.exe
else
  print_err_msg_exit "\
The GSI executable specified in GSI_EXEC does not exist:
  GSI_EXEC = \"$EXEC\"
Build radar process and rerun."
fi
#
#-----------------------------------------------------------------------
#
# Set and export variables.
#
#-----------------------------------------------------------------------
#
export KMP_AFFINITY=scatter
export OMP_NUM_THREADS=1 #Needs to be 1 for dynamic build of CCPP with GFDL fast physics, was 2 before.
export OMP_STACKSIZE=1024m
#
#-----------------------------------------------------------------------
#
# Run the GSI.  Note that we have to launch the forecast from
# the current cycle's run directory because the GSI executable will look
# for input files in the current directory.
#
#-----------------------------------------------------------------------
#
$APRUN ./process_NSSL_mosaic.exe > stdout 2>&1 || print_err_msg_exit "\
Call to executable to run radar refl process returned with nonzero exit code."
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
RADAR REFL PROCESS completed successfully!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

