###########################################################################
#       Script Name:    eim_override_config_set_passwd.ksh
#
#       Description:    Environment specific script to set ID's, passwords,
#                       database names, and root directories.
#
#       AUDIT TRAIL
#       Modified By
#       ==================================================================
#       Date        Person              Description
#       --------    ------------        ----------------------------------
#       06/20/2012  Jibeesh Kumar Gopi  Initial development.
#
###########################################################################

NZ_USER=${ENVR}_DL_EXTRACT                                              	; export NZ_USER
NZ_DATA_DELIM=124                                                   		; export NZ_DATA_DELIM

DIR_DATATGT=/product/nz_data/MDU/TgtFiles                           		; export DIR_DATATGT
DIR_DATATGT_ARCHIVE=/product/nz_data/MDU/TgtFiles/Archive           		; export DIR_DATATGT_ARCHIVE
DIR_NASTGT=/EIM-Prod/MDU/TgtFiles                                    		; export DIR_NASTGT

FILE_NM=CVC_DTL_REP                                                 		; export FILE_NM
FILE_EXT=txt.gz                                                     		; export FILE_EXT

DATE=`date '+%m_%Y'`                                                		; export DATE
ORG_FILE_NM=CVC_ORG_REP_${DATE}                                     		; export ORG_FILE_NM
ORG_FILE_EXT=txt                                                    		; export ORG_FILE_EXT


ARCHIVE_CLEAN_DAY=45                                                		; export ARCHIVE_CLEAN_DAY

StartOfTime='1900-01-01'							; export StartOfTime
