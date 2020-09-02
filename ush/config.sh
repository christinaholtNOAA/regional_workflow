MACHINE="jet"
ACCOUNT="nrtrr"
EXPT_SUBDIR="test"

QUEUE_DEFAULT="batch"
QUEUE_HPSS="service"
QUEUE_FCST="batch"

VERBOSE="TRUE"

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="delete"

PREDEF_GRID_NAME="GSD_HRRR3km"

GRID_GEN_METHOD="GFDLgrid"

GFDLgrid_LON_T6_CTR="-97.5"
GFDLgrid_LAT_T6_CTR="38.5"
GFDLgrid_STRETCH_FAC="1.0001"
GFDLgrid_RES="96"
GFDLgrid_REFINE_RATIO="36"

#num_margin_cells_T6_left=9
#GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G=$(( num_margin_cells_T6_left + 1 ))
GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G="26"

#num_margin_cells_T6_right=9
#GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G=$(( GFDLgrid_RES - num_margin_cells_T6_right ))
GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G="71"

#num_margin_cells_T6_bottom=9
#GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G=$(( num_margin_cells_T6_bottom + 1 ))
GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G="36"

#num_margin_cells_T6_top=9
#GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G=$(( GFDLgrid_RES - num_margin_cells_T6_top ))
GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G="61"

GFDLgrid_USE_GFDLgrid_RES_IN_FILENAMES="FALSE"

DT_ATMOS="40"

LAYOUT_X="36"
LAYOUT_Y="24"
BLOCKSIZE="26"

QUILTING="TRUE"

if [ "$QUILTING" = "TRUE" ]; then
  WRTCMP_write_groups="1"
  WRTCMP_write_tasks_per_group=$(( 1*LAYOUT_Y ))
  WRTCMP_output_grid="lambert_conformal"
  WRTCMP_cen_lon="${GFDLgrid_LON_T6_CTR}"
  WRTCMP_cen_lat="${GFDLgrid_LAT_T6_CTR}"
  WRTCMP_stdlat1="${GFDLgrid_LAT_T6_CTR}"
  WRTCMP_stdlat2="${GFDLgrid_LAT_T6_CTR}"
  WRTCMP_nx="1650"
  WRTCMP_ny="930"
#lon1:                    -122.21414225
#lat1:                    22.41403305
  WRTCMP_lon_lwr_left="-122"
  WRTCMP_lat_lwr_left="22.5"
  WRTCMP_dx="3000.0"
  WRTCMP_dy="3000.0"
fi

USE_CCPP="TRUE"
CCPP_PHYS_SUITE="FV3_GSD_SAR"
FCST_LEN_HRS="36"
LBC_UPDATE_INTVL_HRS="3"

DATE_FIRST_CYCL="20200409"
DATE_LAST_CYCL="20200410"
CYCL_HRS=( "00" "12" )

EXTRN_MDL_NAME_ICS="HRRRX"
EXTRN_MDL_NAME_LBCS="RAPX"

RUN_TASK_MAKE_GRID="TRUE"
RUN_TASK_MAKE_OROG="TRUE"
RUN_TASK_MAKE_SFC_CLIMO="TRUE"

