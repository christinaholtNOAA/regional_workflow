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
{ save_shell_opts; set -u -x; } > /dev/null 2>&1
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

This is the ex-script for the task that runs a analysis with FV3 for the
specified cycle.
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
valid_args=( "CYCLE_DIR" "ANALWORKDIR" "CYCLE_ROOT")
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
"THEIA")
#

  if [ "${USE_CCPP}" = "TRUE" ]; then
  
# Need to change to the experiment directory to correctly load necessary 
# modules for CCPP-version of FV3SAR in lines below
    cd_vrfy ${EXPTDIR}
  
    set +x
    source ./module-setup.sh
    module use $( pwd -P )
    module load modules.fv3
    module load contrib wrap-mpi
    module list
    set -x
  
  else
  
    . /apps/lmod/lmod/init/sh
    module purge
    module use /scratch4/NCEPDEV/nems/noscrub/emc.nemspara/soft/modulefiles
    module load intel/16.1.150 impi/5.1.1.109 netcdf/4.3.0 
    module load contrib wrap-mpi 
    module list
  
  fi

  ulimit -s unlimited
  ulimit -a
  np=${SLURM_NTASKS}
  APRUN="mpirun -np ${np}"
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
  NCKS=/apps/nco/4.9.1/intel/18.0.5.274/bin/ncks
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
START_DATE=`echo "${CDATE}" | sed 's/\([[:digit:]]\{2\}\)$/ \1/'`

YYYYMMDDHH=`date +%Y%m%d%H -d "${START_DATE}"`
JJJ=`date +%j -d "${START_DATE}"`

YYYYMMDDHHmInterv=`date +%Y%m%d%H -d "${START_DATE} ${DA_CYCLE_INTERV} hours ago"`
JJJm6=`date +%j -d "${START_DATE} ${DA_CYCLE_INTERV} hours ago"`

YYYY=${YYYYMMDDHH:0:4}
MM=${YYYYMMDDHH:4:2}
DD=${YYYYMMDDHH:6:2}
HH=${YYYYMMDDHH:8:2}
YYYYMMDD=${YYYYMMDDHH:0:8}
#
#-----------------------------------------------------------------------
#
# Create links in the INPUT subdirectory of the current cycle's run di-
# rectory to the grid and (filtered) orography files.
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Creating links in the INPUT subdirectory of the current cycle's run di-
rectory to the grid and (filtered) orography files ..."


# Create directory.

cd_vrfy ${ANALWORKDIR}

fixdir=$FIXgsi/$PREDEF_GRID_NAME
if [ ${BKTYPE} -eq 1 ]; then  # Use background from INPUT
  bkpath=${CYCLE_DIR}/INPUT
else
  bkpath=${CYCLE_ROOT}/${YYYYMMDDHHmInterv}/RESTART
fi

print_info_msg "$VERBOSE" "fixdir is $fixdir"
print_info_msg "$VERBOSE" "bkpath is $bkpath"

#
#-----------------------------------------------------------------------
#
# set default values for namelist
#
#-----------------------------------------------------------------------

cloudanalysistype=0
ifsatbufr=.false.
ifsoilnudge=.false.
beta1_inv=1.0
ifhyb=.false.
nummem=80
fv3sar_bg_type=0

#
#-----------------------------------------------------------------------
#
# link or copy background files
#
#-----------------------------------------------------------------------

FV3SARPATH=${CYCLE_DIR}
cp_vrfy ${fixdir}/fv3_akbk                               fv3_akbk
cp_vrfy ${fixdir}/fv3_grid_spec                          fv3_grid_spec

if [ ${BKTYPE} -eq 1 ]; then  # Use background from INPUT
  cp_vrfy ${bkpath}/gfs_data.tile7.halo0.nc                gfs_data.tile7.halo0.nc_b
  ${NCKS} -A -v  phis ${fixdir}/phis.nc                    gfs_data.tile7.halo0.nc_b
  ${NCKS} -A -v radar_tten ${fixdir}/radar_tten_input.nc   gfs_data.tile7.halo0.nc_b

  cp_vrfy ${bkpath}/sfc_data.tile7.halo0.nc        fv3_sfcdata
  cp_vrfy gfs_data.tile7.halo0.nc_b                fv3_dynvars
  ln_vrfy -s fv3_dynvars                           fv3_tracer

  fv3sar_bg_type=1
else
  if [ ${DA_CYCLE_INTERV} -eq ${FCST_LEN_HRS} ]; then
    restart_prefix=""
  elif [ ${DA_CYCLE_INTERV} -lt ${FCST_LEN_HRS} ]; then
    restart_prefix=${YYYYMMDD}.${HH}0000
  else
    print_err_msg_exit "\
Restart hour should not larger than forecast hour:
    Restart Hour = \"${DA_CYCLE_INTERV}\"
    Forecast Hour = \"${FCST_LEN_HRS}\""    
    exit
  fi

  cp_vrfy  ${bkpath}/${restart_prefix}.fv_core.res.tile1.nc             fv3_dynvars
  cp_vrfy  ${bkpath}/${restart_prefix}.fv_tracer.res.tile1.nc           fv3_tracer
  cp_vrfy  ${bkpath}/${restart_prefix}.sfc_data.nc                      fv3_sfcdata
  ${NCKS} -A -v radar_tten ${fixdir}/radar_tten_restart.nc              fv3_tracer
  fv3sar_bg_type=0
fi

# analysis time
cp_vrfy ${fixdir}/fv3_coupler.res                        coupler.res.tmp
cat coupler.res.tmp  | sed "s/yyyy/${YYYY}/" > coupler.res.newY
cat coupler.res.newY | sed "s/mm/${MM}/"     > coupler.res.newM
cat coupler.res.newM | sed "s/dd/${DD}/"     > coupler.res.newD
cat coupler.res.newD | sed "s/hh/${HH}/"     > coupler.res.newH
mv coupler.res.newH coupler.res
rm coupler.res.newY coupler.res.newM coupler.res.newD

# add radar tten array
#cp_vrfy ${USHDIR}/addtten.py                        addtten.py 
#/scratch1/BMC/wrfruc/Samuel.Trahan/soft/anaconda2-5.3.1/bin/python3.7 addtten.py fv3_tracer
#python addtten.py fv3_tracer
#
#-----------------------------------------------------------------------
#
# link observation files
# copy observation files to working directory 
#
#-----------------------------------------------------------------------

#obsdir=${OBSPATH}/gfs.${YYYYMMDD}/${HH}
#obs_file=${obsdir}/gfs.t${HH}z.prepbufr.nr
#obs_file=${OBSPATH}/${YYYY}${JJJ}${HH}00.rap.t${HH}z.prepbufr.tm00.${YYYYMMDD}
obs_file=${OBSPATH}/${YYYYMMDDHH}.rap.t${HH}z.prepbufr.tm00
print_info_msg "$VERBOSE" "obsfile is $obs_file"
if [ -r "${obs_file}" ]; then
   cp_vrfy "${obs_file}" "prepbufr"
else
   print_info_msg "$VERBOSE" "Warning: ${obs_file} does not exist!"
fi
#obs_file=${OBSPATH}/../satwnd/${YYYY}${JJJ}${HH}00.rap_e.t${HH}z.satwnd.tm00.bufr_d
obs_file=${OBSPATH}/${YYYYMMDDHH}.rap.t${HH}z.satwnd.tm00.bufr_d
if [ -r "${obs_file}" ]; then
   ln -s ${obs_file} satwndbufr
else
   print_info_msg "$VERBOSE" "Warning: ${obs_file} does not exist!"
fi
#obs_file=${OBSPATH}/../nexrad/${YYYY}${JJJ}${HH}00.rap.t${HH}z.nexrad.tm00.bufr_d
obs_file=${OBSPATH}/${YYYYMMDDHH}.rap.t${HH}z.nexrad.tm00.bufr_d
if [ -r "${obs_file}" ]; then
  ln -s ${obs_file} l2rwbufr
else
   print_info_msg "$VERBOSE" "Warning: ${obs_file} does not exist!"
fi

#-----------------------------------------------------------------------
#
# Create links to fix files in the FIXgsi directory.
# Set fixed files
#   berror   = forecast model background error statistics
#   specoef  = CRTM spectral coefficients
#   trncoef  = CRTM transmittance coefficients
#   emiscoef = CRTM coefficients for IR sea surface emissivity model
#   aerocoef = CRTM coefficients for aerosol effects
#   cldcoef  = CRTM coefficients for cloud effects
#   satinfo  = text file with information about assimilation of brightness temperatures
#   satangl  = angle dependent bias correction file (fixed in time)
#   pcpinfo  = text file with information about assimilation of prepcipitation rates
#   ozinfo   = text file with information about assimilation of ozone data
#   errtable = text file with obs error for conventional data (regional only)
#   convinfo = text file with information about assimilation of conventional data
#   bufrtable= text file ONLY needed for single obs test (oneobstest=.true.)
#   bftab_sst= bufr table for sst ONLY needed for sst retrieval (retrieval=.true.)
#
#-----------------------------------------------------------------------

anavinfo=${fixdir}/anavinfo_fv3sar_hrrr
BERROR=${fixdir}/rap_berror_stats_global_RAP_tune
SATINFO=${fixdir}/global_satinfo.txt
CONVINFO=${fixdir}/nam_regional_convinfo_RAP.txt
OZINFO=${fixdir}/global_ozinfo.txt
PCPINFO=${fixdir}/global_pcpinfo.txt
OBERROR=${fixdir}/nam_errtable.r3dv
ATMS_BEAMWIDTH=${fixdir}/atms_beamwidth.txt

# Fixed fields
cp_vrfy "${anavinfo}" "anavinfo"
cp_vrfy "${BERROR}"   "berror_stats"
cp_vrfy $SATINFO  satinfo
cp_vrfy $CONVINFO convinfo
cp      $OZINFO   ozinfo
cp      $PCPINFO  pcpinfo
cp_vrfy $OBERROR  errtable
cp_vrfy $ATMS_BEAMWIDTH atms_beamwidth.txt

# Get aircraft reject list and surface uselist
#cp ${AIRCRAFT_REJECT}/current_bad_aircraft.txt current_bad_aircraft
cp_vrfy ${AIRCRAFT_REJECT}/current_bad_aircraft.txt current_bad_aircraft

#sfcuselists=current_mesonet_uselist.txt
sfcuselists=gsd_sfcobs_uselist.txt
sfcuselists_path=${SFCOBS_USELIST}
cp_vrfy ${sfcuselists_path}/${sfcuselists} gsd_sfcobs_uselist.txt
cp_vrfy ${fixdir}/gsd_sfcobs_provider.txt gsd_sfcobs_provider.txt


#-----------------------------------------------------------------------
#
# CRTM Spectral and Transmittance coefficients
#
#-----------------------------------------------------------------------
CRTMFIX=${FIXcrtm}
emiscoef_IRwater=${CRTMFIX}/Nalli.IRwater.EmisCoeff.bin
emiscoef_IRice=${CRTMFIX}/NPOESS.IRice.EmisCoeff.bin
emiscoef_IRland=${CRTMFIX}/NPOESS.IRland.EmisCoeff.bin
emiscoef_IRsnow=${CRTMFIX}/NPOESS.IRsnow.EmisCoeff.bin
emiscoef_VISice=${CRTMFIX}/NPOESS.VISice.EmisCoeff.bin
emiscoef_VISland=${CRTMFIX}/NPOESS.VISland.EmisCoeff.bin
emiscoef_VISsnow=${CRTMFIX}/NPOESS.VISsnow.EmisCoeff.bin
emiscoef_VISwater=${CRTMFIX}/NPOESS.VISwater.EmisCoeff.bin
emiscoef_MWwater=${CRTMFIX}/FASTEM6.MWwater.EmisCoeff.bin
aercoef=${CRTMFIX}/AerosolCoeff.bin
cldcoef=${CRTMFIX}/CloudCoeff.bin

ln -s ${emiscoef_IRwater} Nalli.IRwater.EmisCoeff.bin
ln -s $emiscoef_IRice ./NPOESS.IRice.EmisCoeff.bin
ln -s $emiscoef_IRsnow ./NPOESS.IRsnow.EmisCoeff.bin
ln -s $emiscoef_IRland ./NPOESS.IRland.EmisCoeff.bin
ln -s $emiscoef_VISice ./NPOESS.VISice.EmisCoeff.bin
ln -s $emiscoef_VISland ./NPOESS.VISland.EmisCoeff.bin
ln -s $emiscoef_VISsnow ./NPOESS.VISsnow.EmisCoeff.bin
ln -s $emiscoef_VISwater ./NPOESS.VISwater.EmisCoeff.bin
ln -s $emiscoef_MWwater ./FASTEM6.MWwater.EmisCoeff.bin
ln -s $aercoef  ./AerosolCoeff.bin
ln -s $cldcoef  ./CloudCoeff.bin


# Copy CRTM coefficient files based on entries in satinfo file
for file in `awk '{if($1!~"!"){print $1}}' ./satinfo | sort | uniq` ;do
#   ln_vrfy -sf -t ${CRTMFIX}/${file}.SpcCoeff.bin  .
#   ln_vrfy -sf -t ${CRTMFIX}/${file}.TauCoeff.bin  .
   ln -s ${CRTMFIX}/${file}.SpcCoeff.bin ./
   ln -s ${CRTMFIX}/${file}.TauCoeff.bin ./
done

## satellite bias correction
#if [ ${FULLCYC} -eq 1 ]; then
#   latest_bias=${DATAHOME_PBK}/satbias/satbias_out_latest
#   latest_bias_pc=${DATAHOME_PBK}/satbias/satbias_pc.out_latest
#   latest_radstat=${DATAHOME_PBK}/satbias/radstat.rap_latest
#fi

# cp $latest_bias ./satbias_in
# cp $latest_bias_pc ./satbias_pc
# cp $latest_radstat ./radstat.rap
# listdiag=`tar xvf radstat.rap | cut -d' ' -f2 | grep _ges`
# for type in $listdiag; do
#       diag_file=`echo $type | cut -d',' -f1`
#       fname=`echo $diag_file | cut -d'.' -f1`
#       date=`echo $diag_file | cut -d'.' -f2`
#       gunzip $diag_file
#       fnameanl=$(echo $fname|sed 's/_ges//g')
#       mv $fname.$date $fnameanl
# done
#
#mv radstat.rap  radstat.rap.for_this_cycle

#-----------------------------------------------------------------------
#
# Build namelist and run GSI
#
#-----------------------------------------------------------------------
# Link the AMV bufr file
ifsatbufr=.false.

# Set some parameters for use by the GSI executable and to build the namelist
grid_ratio=1
cloudanalysistype=0

# Build the GSI namelist on-the-fly
. ${fixdir}/gsiparm.anl.sh
cat << EOF > gsiparm.anl
$gsi_namelist
EOF

#
#-----------------------------------------------------------------------
#
# Copy the GSI executable to the run directory.
#
#-----------------------------------------------------------------------
#
GSI_EXEC="${EXECDIR}/gsi.exe"

if [ -f $GSI_EXEC ]; then
  print_info_msg "$VERBOSE" "
Copying the GSI executable to the run directory..."
  cp_vrfy ${GSI_EXEC} ${ANALWORKDIR}/gsi.x
else
  print_err_msg_exit "\
The GSI executable specified in GSI_EXEC does not exist:
  GSI_EXEC = \"$GSI_EXEC\"
Build GSI and rerun."
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
# comment out for testing
$APRUN ./gsi.x < gsiparm.anl > stdout 2>&1 || print_err_msg_exit "\
Call to executable to run GSI returned with nonzero exit code."


#-----------------------------------------------------------------------
#
# Copy analysis results to INPUT for model forecast.
#
#-----------------------------------------------------------------------
#

if [ ${BKTYPE} -eq 1 ]; then  # INPUT 
  cp ${ANALWORKDIR}/fv3_dynvars ${CYCLE_DIR}/INPUT/gfs_data.tile7.halo0.nc
  cp ${ANALWORKDIR}/fv3_sfcdata ${CYCLE_DIR}/INPUT/sfc_data.tile7.halo0.nc
else                          # RESTART
  cp_vrfy ${bkpath}/${restart_prefix}.coupler.res               ${CYCLE_DIR}/INPUT/coupler.res
  cp_vrfy ${bkpath}/${restart_prefix}.fv_core.res.nc            ${CYCLE_DIR}/INPUT/fv_core.res.nc
  cp_vrfy ${bkpath}/${restart_prefix}.fv_srf_wnd.res.tile1.nc   ${CYCLE_DIR}/INPUT/fv_srf_wnd.res.tile1.nc
  cp_vrfy ${bkpath}/${restart_prefix}.phy_data.nc               ${CYCLE_DIR}/INPUT/phy_data.nc
  cp_vrfy ${ANALWORKDIR}/fv3_dynvars                            ${CYCLE_DIR}/INPUT/fv_core.res.tile1.nc
  cp_vrfy ${ANALWORKDIR}/fv3_tracer                             ${CYCLE_DIR}/INPUT/fv_tracer.res.tile1.nc
  cp_vrfy ${ANALWORKDIR}/fv3_sfcdata                            ${CYCLE_DIR}/INPUT/sfc_data.nc
  cp_vrfy ${CYCLE_ROOT}/${YYYYMMDDHHmInterv}/INPUT/gfs_ctrl.nc  ${CYCLE_DIR}/INPUT/gfs_ctrl.nc
fi

#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
ANALYSIS GSI completed successfully!!!

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

