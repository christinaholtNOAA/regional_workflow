#
#-----------------------------------------------------------------------
#
# This file sets the experiment's configuration variables (which are
# global shell variables) to their default values.  For many of these
# variables, the valid values that they may take on are defined in the
# file $USHDIR/valid_param_vals.sh.
#
#-----------------------------------------------------------------------
#

#
#-----------------------------------------------------------------------
#
# Set the RUN_ENVIR variable that is listed and described in the WCOSS
# Implementation Standards document:
#
#  NCEP Central Operations
#  WCOSS Implementation Standards
#  April 17, 2019
#  Version 10.2.0
#
# RUN_ENVIR is described in this document as follows:
#
#   Set to "nco" if running in NCO's production environment. Used to
#   distinguish between organizations.
#
# Valid values are "nco" and "community".  Here, we use it to generate
# and run the experiment either in NCO mode (if RUN_ENVIR is set to "nco")
# or in community mode (if RUN_ENVIR is set to "community").  This has
# implications on the experiment variables that need to be set and the
# the directory structure used.
#
#-----------------------------------------------------------------------
#
RUN_ENVIR="community"
#
#-----------------------------------------------------------------------
#
# mach_doc_start
# Set machine and queue parameters.  Definitions:
#
# MACHINE:
# Machine on which the workflow will run.
#
# ACCOUNT:
# The account under which to submit jobs to the queue.
#
# QUEUE_DEFAULT:
# The default queue to which workflow tasks are submitted.  If a task
# does not have a specific variable that specifies the queue to which it
# will be submitted (e.g. QUEUE_HPSS, QUEUE_FCST; see below), it will be
# submitted to the queue specified by this variable.  If this is not set
# or is set to an empty string, it will be (re)set to a machine-dependent
# value.
#
# QUEUE_HPSS:
# The queue to which the tasks that get or create links to external model
# files [which are needed to generate initial conditions (ICs) and lateral
# boundary conditions (LBCs)] are submitted.  If this is not set or is
# set to an empty string, it will be (re)set to a machine-dependent value.
#
# QUEUE_FCST:
# The queue to which the task that runs a forecast is submitted.  If this
# is not set or set to an empty string, it will be (re)set to a machine-
# dependent value.
#
# mach_doc_end
#
#-----------------------------------------------------------------------
#
MACHINE="JET"
ACCOUNT="nrtrr"
QUEUE_DEFAULT="batch"
QUEUE_HPSS="service"
QUEUE_FCST="batch"
#
#-----------------------------------------------------------------------
#
# Set cron-related parameters.  Definitions:
#
# USE_CRON_TO_RELAUNCH:
# Flag that determines whether or not to add a line to the user's cron
# table to call the experiment launch script every CRON_RELAUNCH_INTVL_MNTS
# minutes.
#
# CRON_RELAUNCH_INTVL_MNTS:
# The interval (in minutes) between successive calls of the experiment
# launch script by a cron job to (re)launch the experiment (so that the
# workflow for the experiment kicks off where it left off).
#
#-----------------------------------------------------------------------
#
USE_CRON_TO_RELAUNCH="FALSE"
CRON_RELAUNCH_INTVL_MNTS="03"
#
#-----------------------------------------------------------------------
#
# dir_doc_start
# Set directories.  Definitions:
#
# EXPT_BASEDIR:
# The base directory in which the experiment directory will be created.
# If this is not specified or if it is set to an empty string, it will
# default to ${HOMErrfs}/../expt_dirs.
#
# EXPT_SUBDIR:
# The name that the experiment directory (without the full path) will
# have.  The full path to the experiment directory, which will be contained
# in the variable EXPTDIR, will be:
#
#   EXPTDIR="${EXPT_BASEDIR}/${EXPT_SUBDIR}"
#
# This cannot be empty.  If set to a null string here, it must be set to
# a (non-empty) value in the user-defined experiment configuration file.
#
# NET, envir, RUN, COMINgfs, STMP, PTMP:
# Directories or variables used to create directory names that are needed
# when generating and running an experiment in NCO mode (see the description
# of the RUN_ENVIR variable above).  These are defined in the WCOSS
# Implementation Standards document and thus will not be described here.
#
# dir_doc_end
#
#-----------------------------------------------------------------------
#
EXPT_BASEDIR="/mnt/lfs4/BMC/nrtrr/RRFS"
EXPT_SUBDIR="conus_dev2"

NET="rrfs_databasedir"
envir="para"
RUN="experiment_name"
COMINgfs="/path/to/directory/containing/gfs/input/files"
STMP="/path/to/temporary/directory/stmp"
PTMP="/path/to/temporary/directory/ptmp"
#
#-----------------------------------------------------------------------
#
# Set the sparator character(s) to use in the names of the grid, mosaic,
# and orography fixed files.
#
# Ideally, the same separator should be used in the names of these fixed
# files as the surface climatology fixed files (which always use a "."
# as the separator), i.e. ideally, DOT_OR_USCORE should be set to "."
#
#-----------------------------------------------------------------------
#
DOT_OR_USCORE="_"
#
#-----------------------------------------------------------------------
#
# Set file names.  Definitions:
#
# RGNL_GRID_NML_FN:
# Name of file containing the namelist settings for the code that generates
# a "JPgrid" type of regional grid.
#
# FV3_NML_FN:
# Name of file containing the forecast model's namelist settings.
#
# DIAG_TABLE_FN:
# Name of file that specifies the fields that the forecast model will
# output.
#
# FIELD_TABLE_FN:
# Name of file that specifies the tracers that the forecast model will
# read in from the IC/LBC files.
#
# DATA_TABLE_FN:
# Name of file that specifies ???
#
# MODEL_CONFIG_FN:
# Name of file that specifies ???
#
# NEMS_CONFIG_FN:
# Name of file that specifies ???
#
# WFLOW_XML_FN:
# Name of the rocoto workflow XML file that the experiment generation
# script creates and that defines the workflow for the experiment.
#
# GLOBAL_VAR_DEFNS_FN:
# Name of file containing the defintions of the primary experiment variables
# (parameters) defined in this default configuration script and in the
# user-specified configuration as well as secondary experiment variables
# generated by the experiment generation script.  This file is sourced
# by many scripts (e.g. the J-job scripts corresponding to each workflow
# task) in order to make all the experiment variables available in those
# scripts.
#
# WFLOW_LAUNCH_SCRIPT_FN:
# Name of the script that can be used to (re)launch the experiment's rocoto
# workflow.
#
# WFLOW_LAUNCH_LOG_FN:
# Name of the log file that contains the output from successive calls to
# the workflow launch script (WFLOW_LAUNCH_SCRIPT_FN).
#
#-----------------------------------------------------------------------
#
RGNL_GRID_NML_FN="regional_grid.nml"

DATA_TABLE_FN="data_table"
DIAG_TABLE_FN="diag_table"
FIELD_TABLE_FN="field_table"
FV3_NML_FN="input.nml"
MODEL_CONFIG_FN="model_configure"
NEMS_CONFIG_FN="nems.configure"

WFLOW_XML_FN="rrfs_conus_fv3gfs.xml"
GLOBAL_VAR_DEFNS_FN="var_defns.sh"
WFLOW_LAUNCH_SCRIPT_FN="launch_FV3SAR_wflow.sh"
WFLOW_LAUNCH_LOG_FN="log.launch_FV3SAR_wflow"
#
#-----------------------------------------------------------------------
#
# Set forecast parameters.  Definitions:
#
# DATE_FIRST_CYCL:
# Starting date of the first forecast in the set of forecasts to run.
# Format is "YYYYMMDD".  Note that this does not include the hour-of-day.
#
# DATE_LAST_CYCL:
# Starting date of the last forecast in the set of forecasts to run.
# Format is "YYYYMMDD".  Note that this does not include the hour-of-day.
#
# CYCL_HRS:
# An array containing the hours of the day at which to launch forecasts.
# Forecasts are launched at these hours on each day from DATE_FIRST_CYCL
# to DATE_LAST_CYCL, inclusive.  Each element of this array must be a
# two-digit string representing an integer that is less than or equal to
# 23, e.g. "00", "03", "12", "23".
#
# FCST_LEN_HRS:
# The length of each forecast, in integer hours.
#
#-----------------------------------------------------------------------
#
DATE_FIRST_CYCL="20200413"
DATE_LAST_CYCL="20200415"
CYCL_HRS=( \
"00" \
"12" \
)
FCST_LEN_HRS="12"
RESTA_INTERV="3,6"
DA_CYCLE_INTERV="3"
#
#-----------------------------------------------------------------------
#
# Set initial and lateral boundary condition generation parameters.
# Definitions:
#
# EXTRN_MDL_NAME_ICS:
#`The name of the external model that will provide fields from which
# initial condition (including and surface) files will be generated for
# input into the forecast model.
#
# EXTRN_MDL_NAME_LBCS:
#`The name of the external model that will provide fields from which
# lateral boundary condition (LBC) files will be generated for input into
# the forecast model.
#
# LBC_UPDATE_INTVL_HRS:
# The interval (in integer hours) with which LBC files will be generated.
# We will refer to this as the boundary update interval.  Note that the
# model specified in EXTRN_MDL_NAME_LBCS must have data available at a
# frequency greater than or equal to that implied by LBC_UPDATE_INTVL_HRS.
# For example, if LBC_UPDATE_INTVL_HRS is set to 6, then the model must
# have data availble at least every 6 hours.  It is up to the user to
# ensure that this is the case.
#
# FV3GFS_FILE_FMT_ICS:
# If using the FV3GFS model as the source of the ICs (i.e. if EXTRN_MDL_NAME_ICS
# is set to "FV3GFS"), this variable specifies the format of the model
# files to use when generating the ICs.
#
# FV3GFS_FILE_FMT_LBCS:
# If using the FV3GFS model as the source of the LBCs (i.e. if
# EXTRN_MDL_NAME_LBCS is set to "FV3GFS"), this variable specifies the
# format of the model files to use when generating the LBCs.
#
#-----------------------------------------------------------------------
#
EXTRN_MDL_NAME_ICS="HRRRX"
EXTRN_MDL_NAME_LBCS="RAPX"
LBC_UPDATE_INTVL_HRS="3"
FV3GFS_FILE_FMT_ICS="nemsio"
FV3GFS_FILE_FMT_LBCS="nemsio"
#
#-----------------------------------------------------------------------
#
# Set CCPP related parameters.  Definitions:
#
# USE_CCPP:
# Flag controlling whether or not a CCPP-enabled version of the forecast
# model will be run.  Note that the user is responsible for ensuring that
# a CCPP-enabled forecast model executable is built and placed at the
# correct location (that is part of the build process).
#
# CCPP_PHYS_SUITE:
# If USE_CCPP has been set to "TRUE", this variable defines the physics
# suite that will run using CCPP.  The choice of physics suite determines
# the forecast model's namelist file, the diagnostics table file, the
# field table file, and the XML physics suite definition file that are
# staged in the experiment directory or the cycle directories under it.
# If USE_CCPP is set to "FALSE", the only physics suite that can be run
# is the GFS.
#
# Note that it is up to the user to ensure that the CCPP-enabled forecast
# model executable is built with either the dynamic build (which can
# handle any CCPP physics package but is slower to run) or the static
# build with the correct physics package.  If using a static build, the
# forecast will fail if the physics package specified in the experiment's
# variable defintions file (GLOBAL_VAR_DEFNS_FN) is not the same as the
# one that was used for the static build.
#
# OZONE_PARAM_NO_CCPP:
# The ozone parameterization to use if NOT using a CCPP-enabled forecast
# model executable.
#
#-----------------------------------------------------------------------
#
USE_CCPP="TRUE"
CCPP_PHYS_SUITE="FV3_GSD_SAR"
OZONE_PARAM_NO_CCPP="ozphys"
#
#-----------------------------------------------------------------------
#
# Set GRID_GEN_METHOD.  This variable specifies the method to use to
# generate a regional grid in the horizontal, or, if using pregenerated
# grid files instead of running the grid generation task, the grid generation
# method that was used to generate those files.  The values that
# GRID_GEN_METHOD can take on are:
#
# * "GFDLgrid":
#   This setting will generate a regional grid by first generating a
#   "parent" global cubed-sphere grid and then taking a portion of tile
#   6 of that global grid -- referred to in the grid generation scripts
#   as "tile 7" even though it doesn't correspond to a complete tile --
#   and using it as the regional grid.  Note that the forecast is run on
#   only on the regional grid (i.e. tile 7, not tiles 1 through 6).
#
# * "JPgrid":
#   This will generate a regional grid using the map projection developed
#   by Jim Purser of EMC.
#
#-----------------------------------------------------------------------
#
GRID_GEN_METHOD="GFDLgrid"
#
#-----------------------------------------------------------------------
#
# Set parameters specific to the "GFDLgrid" method of generating a regional
# grid (i.e. for GRID_GEN_METHOD set to "GFDLgrid").  The following
# parameters will be used only if GRID_GEN_METHOD is set to "GFDLgrid".
# In this grid generation method:
#
# * The regional grid is defined with respect to a "parent" global cubed-
#   sphere grid.  Thus, all the parameters for a global cubed-sphere grid
#   must be specified in order to define this parent global grid even
#   though the model equations are not integrated on (they are integrated
#   only on the regional grid).
#
# * GFDLgrid_RES is the number of grid cells in either one of the two
#   horizontal directions x and y on any one of the 6 tiles of the parent
#   global cubed-sphere grid.  The mapping from GFDLgrid_RES to a nominal
#   resolution (grid cell size) for a uniform global grid (i.e. Schmidt
#   stretch factor GFDLgrid_STRETCH_FAC set to 1) for several values of
#   GFDLgrid_RES is as follows:
#
#     GFDLgrid_RES      typical cell size
#     ------------      -----------------
#              192                  50 km
#              384                  25 km
#              768                  13 km
#             1152                 8.5 km
#             3072                 3.2 km
#
#   Note that these are only typical cell sizes.  The actual cell size on
#   the global grid tiles varies somewhat as we move across a tile.
#
# * Tile 6 has arbitrarily been chosen as the tile to use to orient the
#   global parent grid on the sphere (Earth).  This is done by specifying
#   GFDLgrid_LON_T6_CTR and GFDLgrid_LAT_T6_CTR, which are the longitude
#   and latitude (in degrees) of the center of tile 6.
#
# * Setting the Schmidt stretching factor GFDLgrid_STRETCH_FAC to a value
#   greater than 1 shrinks tile 6, while setting it to a value less than
#   1 (but still greater than 0) expands it.  The remaining 5 tiles change
#   shape as necessary to maintain global coverage of the grid.
#
# * The cell size on a given global tile depends on both GFDLgrid_RES and
#   GFDLgrid_STRETCH_FAC (since changing GFDLgrid_RES changes the number
#   of cells in the tile, and changing GFDLgrid_STRETCH_FAC modifies the
#   shape and size of the tile).
#
# * The regional grid is embedded within tile 6 (i.e. it doesn't extend
#   beyond the boundary of tile 6).  Its exact location within tile 6 is
#   is determined by specifying the starting and ending i and j indices
#   of the regional grid on tile 6, where i is the grid index in the x
#   direction and j is the grid index in the y direction.  These indices
#   are stored in the variables
#
#     GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G
#     GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G
#     GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G
#     GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G
#
# * In the forecast model code and in the experiment generation and workflow
#   scripts, for convenience the regional grid is denoted as "tile 7" even
#   though it doesn't map back to one of the 6 faces of the cube from
#   which the parent global grid is generated (it maps back to only a
#   subregion on face 6 since it is wholly confined within tile 6).  Tile
#   6 may be referred to as the "parent" tile of the regional grid.
#
# * GFDLgrid_REFINE_RATIO is the refinement ratio of the regional grid
#   (tile 7) with respect to the grid on its parent tile (tile 6), i.e.
#   it is the number of grid cells along the boundary of the regional grid
#   that abut one cell on tile 6.  Thus, the cell size on the regional
#   grid depends not only on GFDLgrid_RES and GFDLgrid_STRETCH_FAC (because
#   the cell size on tile 6 depends on these two parameters) but also on
#   GFDLgrid_REFINE_RATIO.  Note that as on the tiles of the global grid,
#   the cell size on the regional grid is not uniform but varies as we
#   move across the grid.
#
# Definitions of parameters that need to be specified when GRID_GEN_METHOD
# is set to "GFDLgrid":
#
# GFDLgrid_LON_T6_CTR:
# Longitude of the center of tile 6 (in degrees).
#
# GFDLgrid_LAT_T6_CTR:
# Latitude of the center of tile 6 (in degrees).
#
# GFDLgrid_RES:
# Number of points in each of the two horizontal directions (x and y) on
# each tile of the parent global grid.  Note that the name of this parameter
# is really a misnomer because although it has the stirng "RES" (for
# "resolution") in its name, it specifies number of grid cells, not grid
# size (in say meters or kilometers).  However, we keep this name in order
# to remain consistent with the usage of the word "resolution" in the
# global forecast model and other auxiliary codes.
#
# GFDLgrid_STRETCH_FAC:
# Stretching factor used in the Schmidt transformation applied to the
# parent cubed-sphere grid.
#
# GFDLgrid_REFINE_RATIO:
# Cell refinement ratio for the regional grid, i.e. the number of cells
# in either the x or y direction on the regional grid (tile 7) that abut
# one cell on its parent tile (tile 6).
#
# GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G:
# i-index on tile 6 at which the regional grid (tile 7) starts.
#
# GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G:
# i-index on tile 6 at which the regional grid (tile 7) ends.
#
# GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G:
# j-index on tile 6 at which the regional grid (tile 7) starts.
#
# GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G:
# j-index on tile 6 at which the regional grid (tile 7) ends.
#
# GFDLgrid_USE_GFDLgrid_RES_IN_FILENAMES:
# Flag that determines the file naming convention to use for grid, orography,
# and surface climatology files (or, if using pregenerated files, the
# naming convention that was used to name these files).  These files
# usually start with the string "C${RES}_", where RES is an integer.
# In the global forecast model, RES is the number of points in each of
# the two horizontal directions (x and y) on each tile of the global grid
# (defined here as GFDLgrid_RES).  If this flag is set to "TRUE", RES will
# be set to GFDLgrid_RES just as in the global forecast model.  If it is
# set to "FALSE", we calculate (in the grid generation task) an "equivalent
# global uniform cubed-sphere resolution" -- call it RES_EQUIV -- and
# then set RES equal to it.  RES_EQUIV is the number of grid points in
# each of the x and y directions on each tile that a global UNIFORM (i.e.
# stretch factor of 1) cubed-sphere grid would have to have in order to
# have the same average grid size as the regional grid.  This is a more
# useful indicator of the grid size because it takes into account the
# effects of GFDLgrid_RES, GFDLgrid_STRETCH_FAC, and GFDLgrid_REFINE_RATIO
# in determining the regional grid's typical grid size, whereas simply
# setting RES to GFDLgrid_RES doesn't take into account the effects of
# GFDLgrid_STRETCH_FAC and GFDLgrid_REFINE_RATIO on the regional grid's
# resolution.  Nevertheless, some users still prefer to use GFDLgrid_RES
# in the file names, so we allow for that here by setting this flag to
# "TRUE".
#
#-----------------------------------------------------------------------
#
GFDLgrid_LON_T6_CTR="-97.5"
GFDLgrid_LAT_T6_CTR="38.5"
GFDLgrid_RES="96"
GFDLgrid_STRETCH_FAC="1.0001"
GFDLgrid_REFINE_RATIO="36"
GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G="26"
GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G="71"
GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G="36"
GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G="61"
GFDLgrid_USE_GFDLgrid_RES_IN_FILENAMES="FALSE"
#
#-----------------------------------------------------------------------
#
# Set parameters specific to the "JPgrid" method of generating a regional
# grid (i.e. for GRID_GEN_METHOD set to "JPgrid").  Definitions:
#
# JPgrid_LON_CTR:
# The longitude of the center of the grid (in degrees).
#
# JPgrid_LAT_CTR:
# The latitude of the center of the grid (in degrees).
#
# JPgrid_DELX:
# The cell size in the zonal direction of the regional grid (in meters).
#
# JPgrid_DELY:
# The cell size in the meridional direction of the regional grid (in
# meters).
#
# JPgrid_NX:
# The number of cells in the zonal direction on the regional grid.
#
# JPgrid_NY:
# The number of cells in the meridional direction on the regional grid.
#
# JPgrid_WIDE_HALO_WIDTH:
# The width (in units of number of grid cells) of the halo to add around
# the regional grid before shaving the halo down to the width(s) expected
# by the forecast model.
#
# In order to generate grid files containing halos that are 3-cell and
# 4-cell wide and orography files with halos that are 0-cell and 3-cell
# wide (all of which are required as inputs to the forecast model), the
# grid and orography tasks first create files with halos around the regional
# domain of width JPgrid_WIDE_HALO_WIDTH cells.  These are first stored
# in files.  The files are then read in and "shaved" down to obtain grid
# files with 3-cell-wide and 4-cell-wide halos and orography files with
# 0-cell-wide (i.e. no halo) and 3-cell-wide halos.  For this reason, we
# refer to the original halo that then gets shaved down as the "wide"
# halo, i.e. because it is wider than the 0-cell-wide, 3-cell-wide, and
# 4-cell-wide halos that we will eventually end up with.  Note that the
# grid and orography files with the wide halo are only needed as intermediates
# in generating the files with 0-cell-, 3-cell-, and 4-cell-wide halos;
# they are not needed by the forecast model.  Usually, there is no reason
# to change this parameter from its default value set here.
#
#   NOTE: Probably don't need to make this a user-specified variable.
#         Just set it in the function set_gridparams_JPgrid.sh.
#
# JPgrid_ALPHA_PARAM:
# The alpha parameter used in the Jim Purser map projection/grid generation
# method.
#
# JPgrid_KAPPA_PARAM:
# The kappa parameter used in the Jim Purser map projection/grid generation
# method.
#
#-----------------------------------------------------------------------
#
JPgrid_LON_CTR="-97.5"
JPgrid_LAT_CTR="35.5"
JPgrid_DELX="3000.0"
JPgrid_DELY="3000.0"
JPgrid_NX="1000"
JPgrid_NY="1000"
JPgrid_WIDE_HALO_WIDTH="6"
JPgrid_ALPHA_PARAM="0.21423"
JPgrid_KAPPA_PARAM="-0.23209"
#
#-----------------------------------------------------------------------
#
# Set DT_ATMOS.  This is the main forecast model integraton time step.
# As described in the forecast model documentation, "It corresponds to
# the frequency with which the top level routine in the dynamics is called
# as well as the frequency with which the physics is called."
#
#-----------------------------------------------------------------------
#
DT_ATMOS="40"
#
#-----------------------------------------------------------------------
#
# Set LAYOUT_X and LAYOUT_Y.  These are the number of MPI tasks (processes)
# to use in the two horizontal directions (x and y) of the regional grid
# when running the forecast model.
#
#-----------------------------------------------------------------------
#
LAYOUT_X="18"
LAYOUT_Y="12"
#
#-----------------------------------------------------------------------
#
# Set BLOCKSIZE.  This is the amount of data that is passed into the cache
# at a time.  The number of vertical columns per MPI task needs to be
# divisible by BLOCKSIZE; otherwise, unexpected results may occur.
#
# GSK: IMPORTANT NOTE:
# I think Dom fixed the code so that the number of columns per MPI task
# no longer needs to be divisible by BLOCKSIZE.  If so, remove the check
# on blocksize in the experiment generation scripts.  Note that BLOCKSIZE
# still needs to be set to a value (probably machine-dependent).
#
#-----------------------------------------------------------------------
#
BLOCKSIZE="46"
#
#-----------------------------------------------------------------------
#
# Set write-component (quilting) parameters.  Definitions:
#
# QUILTING:
# Flag that determines whether or not to use the write component for
# writing output files to disk.
#
# WRTCMP_write_groups:
# The number of write groups (i.e. groups of MPI tasks) to use in the
# write component.
#
# WRTCMP_write_tasks_per_group:
# The number of MPI tasks to allocate for each write group.
#
# PRINT_ESMF:
# Flag for whether or not to output extra (debugging) information from
# ESMF routines.  Must be ".true." or ".false.".  Note that the write
# component uses ESMF library routines to interpolate from the native
# forecast model grid to the user-specified output grid (which is defined in the
# model configuration file MODEL_CONFIG_FN in the forecast's run direc-
# tory).
#
#-----------------------------------------------------------------------
#
QUILTING="TRUE"
PRINT_ESMF="FALSE"

WRTCMP_write_groups="1"
WRTCMP_write_tasks_per_group="24"

WRTCMP_output_grid="lambert_conformal"
WRTCMP_cen_lon="-97.5"
WRTCMP_cen_lat="38.5"
#Using CLUE grid values here
WRTCMP_lon_lwr_left="-120.109008"
WRTCMP_lat_lwr_left="20.971"
#
# The following are used only for the case of WRTCMP_output_grid set to
# "'rotated_latlon'".
#
WRTCMP_lon_upr_rght=""
WRTCMP_lat_upr_rght=""
WRTCMP_dlon=""
WRTCMP_dlat=""
#
# The following are used only for the case of WRTCMP_output_grid set to
# "'lambert_conformal'".
#
WRTCMP_stdlat1="38.5"
WRTCMP_stdlat2="38.5"
WRTCMP_nx="1620"
WRTCMP_ny="1120"
WRTCMP_dx="3000.0"
WRTCMP_dy="3000.0"
#
#-----------------------------------------------------------------------
#
# Set PREDEF_GRID_NAME.  This parameter specifies a predefined regional
# grid, as follows:
#
# * If PREDEF_GRID_NAME is set to an empty string, the grid parameters,
#   time step (DT_ATMOS), computational parameters (e.g. LAYOUT_X, LAYOUT_Y),
#   and write component parameters set above (and possibly overwritten by
#   values in the user-specified configuration file) are used.
#
# * If PREDEF_GRID_NAME is set to a valid grid name, the grid parameters,
#   time step (DT_ATMOS), computational parameters (e.g. LAYOUT_X, LAYOUT_Y),
#   and write component parameters set above (and possibly overwritten by
#   values in the user-specified configuration file) are overwritten by
#   predefined values for the specified grid.
#
# This is simply a convenient way to quickly specify a set of parameters
# that depend on the grid.
#
#-----------------------------------------------------------------------
#
PREDEF_GRID_NAME=""
#
#-----------------------------------------------------------------------
#
# Set EMC_GRID_NAME.  This is a convenience parameter to allow EMC to use
# its original grid names.  It is simply used to determine a value for
# PREDEF_GRID_NAME.  Once EMC starts using PREDEF_GRID_NAME, this variable
# can be eliminated.
#
#-----------------------------------------------------------------------
#
EMC_GRID_NAME=""
#
#-----------------------------------------------------------------------
#
# Set PREEXISTING_DIR_METHOD.  This variable determines the method to use
# use to deal with preexisting directories [e.g ones generated by previous
# calls to the experiment generation script using the same experiment name
# (EXPT_SUBDIR) as the current experiment].  This variable must be set to
# one of "delete", "rename", and "quit".  The resulting behavior for each
# of these values is as follows:
#
# * "delete":
#   The preexisting directory is deleted and a new directory (having the
#   same name as the original preexisting directory) is created.
#
# * "rename":
#   The preexisting directory is renamed and a new directory (having the
#   same name as the original preexisting directory) is created.  The new
#   name of the preexisting directory consists of its original name and
#   the suffix "_oldNNN", where NNN is a 3-digit integer chosen to make
#   the new name unique.
#
# * "quit":
#   The preexisting directory is left unchanged, but execution of the
#   currently running script is terminated.  In this case, the preexisting
#   directory must be dealt with manually before rerunning the script.
#
#-----------------------------------------------------------------------
#
PREEXISTING_DIR_METHOD="delete"
#
#-----------------------------------------------------------------------
#
# Set VERBOSE.  This is a flag that determines whether or not the experiment
# generation and workflow task scripts tend to be print out more informational
# messages.
#
#-----------------------------------------------------------------------
#
VERBOSE="TRUE"
#
#-----------------------------------------------------------------------
#
# Set flags (and related directories) that determine whether the grid,
# orography, and/or surface climatology file generation tasks should be
# run.  Note that these are all cycle-independent tasks, i.e. if they are
# to be run, they do so only once at the beginning of the workflow before
# any cycles are run.  Definitions:
#
# RUN_TASK_MAKE_GRID:
# Flag that determines whether the grid file generation task is to be run.
# If this is set to "TRUE", the grid generation task is run and new grid
# files are generated.  If it is set to "FALSE", then the scripts look
# for pregenerated grid files in the directory specified by GRID_DIR (see
# below).
#
# GRID_DIR:
# The directory in which to look for pregenerated grid files if
# RUN_TASK_MAKE_GRID is set to "FALSE".
#
# RUN_TASK_MAKE_OROG:
# Same as RUN_TASK_MAKE_GRID but for the orography generation task.
#
# OROG_DIR:
# Same as GRID_DIR but for the orogrpahy generation task.
#
# RUN_TASK_MAKE_SFC_CLIMO:
# Same as RUN_TASK_MAKE_GRID but for the surface climatology generation
# task.
#
# SFC_CLIMO_DIR:
# Same as GRID_DIR but for the surface climatology generation task.
#
#-----------------------------------------------------------------------
#
RUN_TASK_MAKE_GRID="TRUE"
GRID_DIR="/mnt/lfs4/BMC/nrtrr/RRFS/conus_dev2/grid"

RUN_TASK_MAKE_OROG="TRUE"
OROG_DIR="/mnt/lfs4/BMC/nrtrr/RRFS/conus_dev2/orog"

RUN_TASK_MAKE_SFC_CLIMO="TRUE"
SFC_CLIMO_DIR="/mnt/lfs4/BMC/nrtrr/RRFS/conus_dev2/sfc_climo"
#
#-----------------------------------------------------------------------
#
# Set the names of (some of the) global data files that are assumed to
# exist in a system directory (this directory is machine-dependent; the
# the experiment generation script will set it and store it in the variable
# FIXgsm).  These file names also appear directly in the forecast model's
# input namelist file.
#
#-----------------------------------------------------------------------
#
FNGLAC="global_glacier.2x2.grb"
FNMXIC="global_maxice.2x2.grb"
FNTSFC="RTGSST.1982.2012.monthly.clim.grb"
FNSNOC="global_snoclim.1.875.grb"
FNZORC="igbp"
FNALBC="global_snowfree_albedo.bosu.t126.384.190.rg.grb"
FNALBC2="global_albedo4.1x1.grb"
FNAISC="CFSR.SEAICE.1982.2012.monthly.clim.grb"
FNTG3C="global_tg3clim.2.6x1.5.grb"
FNVEGC="global_vegfrac.0.144.decpercent.grb"
FNVETC="global_vegtype.igbp.t126.384.190.rg.grb"
FNSOTC="global_soiltype.statsgo.t126.384.190.rg.grb"
FNSMCC="global_soilmgldas.t126.384.190.grb"
FNMSKH="seaice_newland.grb"
FNTSFA=""
FNACNA=""
FNSNOA=""
FNVMNC="global_shdmin.0.144x0.144.grb"
FNVMXC="global_shdmax.0.144x0.144.grb"
FNSLPC="global_slope.1x1.grb"
FNABSC="global_mxsnoalb.uariz.t126.384.190.rg.grb"

#
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
# Section 2:
# This section defines variables that have been derived from the ones
# above by the setup script (setup.sh) and which are needed by one or
# more of the scripts that perform the workflow tasks (those scripts
# source this variable definitions file).
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#

#
#-----------------------------------------------------------------------
#
# Workflow launcher script and cron table line.
#
#-----------------------------------------------------------------------
#
WFLOW_LAUNCH_SCRIPT_FP="/home/rtrr/RRFS/ush/conus_dev2/launch_FV3SAR_wflow.sh"
WFLOW_LAUNCH_LOG_FP="/mnt/lfs4/BMC/nrtrr/RRFS/conus_dev2/log/log.launch_FV3SAR_wflow"
CRONTAB_LINE=""
#
#-----------------------------------------------------------------------
#
# Directories.
#
#-----------------------------------------------------------------------
#
HOMErrfs="/home/rtrr/RRFS"
USHDIR="/home/rtrr/RRFS/ush/conus_dev2"
SCRIPTSDIR="/home/rtrr/RRFS/scripts"
JOBSDIR="/home/rtrr/RRFS/jobs"
SORCDIR="/home/rtrr/RRFS/sorc"
PARMDIR="/home/rtrr/RRFS/parm"
MODULES_DIR="/home/rtrr/RRFS/modulefiles"
EXECDIR="/home/rtrr/RRFS/exec"
FIXrrfs="/home/rtrr/rrfs_databasedir/fix"
FIXam="${FIXrrfs}/fix_am"
FIXsar="${FIXrrfs}/fix_sar/conus"
FIXgsm="/lfs3/projects/hpc-wof1/ywang/regional_fv3/fix/fix_am"
FIXupp="${FIXrrfs}/fix_upp"
FIXgsd="${FIXrrfs}/fix_gsd"
COMROOT=""
TEMPLATE_DIR="${USHDIR}/templates"
UFS_WTHR_MDL_DIR="${SORCDIR}/ufs_weather_model"
UFS_UTILS_DIR="${SORCDIR}/UFS_UTILS_develop"
CHGRES_DIR="${SORCDIR}/UFS_UTILS_chgres_grib2"
SFC_CLIMO_INPUT_DIR="/lfs1/HFIP/hwrf-data/git/fv3gfs/fix/fix_sfc_climo"

EXPTDIR="/home/rtrr/rrfs_databasedir/conus_dev2"
LOGDIR="${EXPTDIR}/log"
GRID_DIR="${EXPTDIR}/grid"
OROG_DIR="${EXPTDIR}/orog"
SFC_CLIMO_DIR="${EXPTDIR}/sfc_climo"

# for data assimilation
OBSPATH="/public/data/grids/rap/obs"
OBSPATH_NSSLMOSIAC="/public/data/radar/mrms"

FIXgsi="${HOMErrfs}/fix/${EXPT_SUBDIR}/fix_gsi"
FIXcrtm="${HOMErrfs}/fix/${EXPT_SUBDIR}/fix_crtm"
AIRCRAFT_REJECT="$FIXgsi"
SFCOBS_USELIST="$FIXgsi"

#
#-----------------------------------------------------------------------
#
# Files.
#
#-----------------------------------------------------------------------
#
GLOBAL_VAR_DEFNS_FP="/home/rtrr/RRFS/xml/conus_dev2/var_defns.sh"

DATA_TABLE_TMPL_FN="data_table"
DIAG_TABLE_TMPL_FN="diag_table.FV3_GSD_SAR"
FIELD_TABLE_TMPL_FN="field_table.FV3_GSD_SAR"
FV3_NML_TMPL_FN="input.nml.FV3_GSD_SAR"
MODEL_CONFIG_TMPL_FN="model_configure.FV3_GSD_SAR"
NEMS_CONFIG_TMPL_FN="nems.configure"

DATA_TABLE_TMPL_FP="${USHDIR}/templates/data_table"
DIAG_TABLE_TMPL_FP="${USHDIR}/templates/diag_table.FV3_GSD_SAR"
FIELD_TABLE_TMPL_FP="${USHDIR}/templates/field_table.FV3_GSD_SAR"
FV3_NML_TMPL_FP="${USHDIR}/templates/input.nml.FV3_GSD_SAR"
MODEL_CONFIG_TMPL_FP="${USHDIR}/templates/model_configure.FV3_GSD_SAR"
NEMS_CONFIG_TMPL_FP="${USHDIR}/templates/nems.configure"

CCPP_PHYS_SUITE_FN="suite_FV3_GSD_SAR.xml"
CCPP_PHYS_SUITE_IN_CCPP_FP="${SORCDIR}/ufs_weather_model/FV3/ccpp/suites/suite_FV3_GSD_SAR.xml"
CCPP_PHYS_SUITE_FP="${EXPTDIR}/suite_FV3_GSD_SAR.xml"

DATA_TABLE_FP="${EXPTDIR}/data_table"
FIELD_TABLE_FP="${EXPTDIR}/field_table"
FV3_NML_FP="${EXPTDIR}/input.nml"
FV3_NML_RESTART_FN="${EXPTDIR}/input.nml_restart"
NEMS_CONFIG_FP="${EXPTDIR}/nems.configure"

WRTCMP_PARAMS_TMPL_FP="${USHDIR}/templates/wrtcmp_lambert_conformal"
#
#-----------------------------------------------------------------------
#
# Names of the tasks in the rocoto workflow XML.
#
#-----------------------------------------------------------------------
#
MAKE_GRID_TN="make_grid"
MAKE_OROG_TN="make_orog"
MAKE_SFC_CLIMO_TN="make_sfc_climo"
GET_EXTRN_ICS_TN="get_extrn_ics"
GET_EXTRN_LBCS_TN="get_extrn_lbcs"
MAKE_ICS_TN="make_ics"
MAKE_LBCS_TN="make_lbcs"
RUN_FCST_TN="run_fcst"
RUN_POST_TN="run_post"

ANAL_GSI_INPUT_TN="anal_gsi_input"
ANAL_GSI_RESTA_TN="anal_gsi_resta"
PROCESS_RADAR_REF_TN="process_radarref"
RADAR_REFL2TTEN_TN="radar_refl2tten"

#
#-----------------------------------------------------------------------
#
# Grid configuration parameters needed regardless of grid generation me-
# thod used.
#
#-----------------------------------------------------------------------
#
GTYPE="regional"
TILE_RGNL="7"
NH0="0"
NH3="3"
NH4="4"

LON_CTR="-97.5"
LAT_CTR="38.5"
NX="1656"
NY="936"
NHW="36"
STRETCH_FAC="1.0001"

RES_IN_FIXSAR_FILENAMES=""
#
# If running the make_grid task, CRES will be set to a null string du-
# the grid generation step.  It will later be set to an actual value af-
# ter the make_grid task is complete.
#
CRES="C3246"
#
#-----------------------------------------------------------------------
#
# Grid configuration parameters for a regional grid generated from a
# global parent cubed-sphere grid.  This is the method originally sug-
# gested by GFDL since it allows GFDL's nested grid generator to be used
# to generate a regional grid.  However, for large regional domains, it
# results in grids that have an unacceptably large range of cell sizes
# (i.e. ratio of maximum to minimum cell size is not sufficiently close
# to 1).
#
#-----------------------------------------------------------------------
#
ISTART_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG="49"
IEND_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG="144"
JSTART_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG="69"
JEND_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG="124"
#
#-----------------------------------------------------------------------
#
# Name of the ozone parameterization.  If USE_CCPP is set to "FALSE", 
# then this will be equal to OZONE_PARAM_NO_CCPP.  If USE_CCPP is set to
# "TRUE", then the value this gets set to depends on the CCPP physics
# suite being used.
#
#-----------------------------------------------------------------------
#
OZONE_PARAM="ozphys_2015"
#
#-----------------------------------------------------------------------
#
# Number of files expected in the FIXam directory.
#
#-----------------------------------------------------------------------
#
NUM_FIXam_FILES="34"
#
#-----------------------------------------------------------------------
#
# The names of the files in the FIXgsm system directory and the FIXam
# directory (located in the experiment directory).
#
#-----------------------------------------------------------------------
#
FIXgsm_FILENAMES=( \
"global_glacier.2x2.grb" \
"global_maxice.2x2.grb" \
"RTGSST.1982.2012.monthly.clim.grb" \
"global_snoclim.1.875.grb" \
"global_snowfree_albedo.bosu.t126.384.190.rg.grb" \
"global_albedo4.1x1.grb" \
"CFSR.SEAICE.1982.2012.monthly.clim.grb" \
"global_tg3clim.2.6x1.5.grb" \
"global_vegfrac.0.144.decpercent.grb" \
"global_vegtype.igbp.t126.384.190.rg.grb" \
"global_soiltype.statsgo.t126.384.190.rg.grb" \
"global_soilmgldas.t126.384.190.grb" \
"seaice_newland.grb" \
"global_shdmin.0.144x0.144.grb" \
"global_shdmax.0.144x0.144.grb" \
"global_slope.1x1.grb" \
"global_mxsnoalb.uariz.t126.384.190.rg.grb" \
"global_climaeropac_global.txt" \
"global_h2o_pltc.f77" \
"global_zorclim.1x1.grb" \
"global_sfc_emissivity_idx.txt" \
"global_solarconstant_noaa_an.txt" \
"fix_co2_proj/global_co2historicaldata_2010.txt" \
"fix_co2_proj/global_co2historicaldata_2011.txt" \
"fix_co2_proj/global_co2historicaldata_2012.txt" \
"fix_co2_proj/global_co2historicaldata_2013.txt" \
"fix_co2_proj/global_co2historicaldata_2014.txt" \
"fix_co2_proj/global_co2historicaldata_2015.txt" \
"fix_co2_proj/global_co2historicaldata_2016.txt" \
"fix_co2_proj/global_co2historicaldata_2017.txt" \
"fix_co2_proj/global_co2historicaldata_2018.txt" \
"global_co2historicaldata_glob.txt" \
"co2monthlycyc.txt" \
"ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77" \
)

FIXam_FILENAMES=( \
"global_glacier.2x2.grb" \
"global_maxice.2x2.grb" \
"RTGSST.1982.2012.monthly.clim.grb" \
"global_snoclim.1.875.grb" \
"global_snowfree_albedo.bosu.t126.384.190.rg.grb" \
"global_albedo4.1x1.grb" \
"CFSR.SEAICE.1982.2012.monthly.clim.grb" \
"global_tg3clim.2.6x1.5.grb" \
"global_vegfrac.0.144.decpercent.grb" \
"global_vegtype.igbp.t126.384.190.rg.grb" \
"global_soiltype.statsgo.t126.384.190.rg.grb" \
"global_soilmgldas.t126.384.190.grb" \
"seaice_newland.grb" \
"global_shdmin.0.144x0.144.grb" \
"global_shdmax.0.144x0.144.grb" \
"global_slope.1x1.grb" \
"global_mxsnoalb.uariz.t126.384.190.rg.grb" \
"aerosol.dat" \
"global_h2oprdlos.f77" \
"global_zorclim.1x1.grb" \
"sfc_emissivity_idx.txt" \
"solarconstant_noaa_an.txt" \
"co2historicaldata_2010.txt" \
"co2historicaldata_2011.txt" \
"co2historicaldata_2012.txt" \
"co2historicaldata_2013.txt" \
"co2historicaldata_2014.txt" \
"co2historicaldata_2015.txt" \
"co2historicaldata_2016.txt" \
"co2historicaldata_2017.txt" \
"co2historicaldata_2018.txt" \
"co2historicaldata_glob.txt" \
"co2monthlycyc.txt" \
"global_o3prdlos.f77" \
)
#
#-----------------------------------------------------------------------
#
# System directory in which to look for the files generated by the ex-
# ternal model specified in EXTRN_MDL_NAME_ICS.  These files will be
# used to generate the input initial condition and surface files for the
# FV3SAR.
#
#-----------------------------------------------------------------------
#
EXTRN_MDL_FILES_SYSBASEDIR_ICS="/misc/whome/rtrr/hrrr"
#
#-----------------------------------------------------------------------
#
# System directory in which to look for the files generated by the ex-
# ternal model specified in EXTRN_MDL_NAME_LBCS.  These files will be 
# used to generate the input lateral boundary condition files for the 
# FV3SAR.
#
#-----------------------------------------------------------------------
#
EXTRN_MDL_FILES_SYSBASEDIR_LBCS="/misc/whome/rtrr/rap"
#
#-----------------------------------------------------------------------
#
# Shift back in time (in units of hours) of the starting time of the ex-
# ternal model specified in EXTRN_MDL_NAME_LBCS.
#
#-----------------------------------------------------------------------
#
EXTRN_MDL_LBCS_OFFSET_HRS="3"
#
#-----------------------------------------------------------------------
#
# Boundary condition update times (in units of forecast hours).  Note that
# LBC_UPDATE_FCST_HRS is an array, even if it has only one element.
#
#-----------------------------------------------------------------------
#
LBC_UPDATE_FCST_HRS=(0 3 6 9 12 15)
#
#-----------------------------------------------------------------------
#
# Computational parameters.
#
#-----------------------------------------------------------------------
#
NCORES_PER_NODE="24"
PE_MEMBER01="240"

#-----------------------------------------------------------------------
#
# Analysis parameters.
#
#-----------------------------------------------------------------------
#
MM0="00"
MM1="01"
MM2="02"
MM3="03"
