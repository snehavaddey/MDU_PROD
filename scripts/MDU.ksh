#!/bin/ksh
#set -vx
####################################################################################
#   Script Name: MDU.ksh
#
#   Description:
#            Wrapper script to perfom Extract File, Move to NAS and Archive functions
#
#   Parameters :
#	     	Category - EXRT_FILE, NAS
#			Extract - ORG
#
#   AUDIT TRAIL
#   Modified By
#   =======================
#   Date       Person         		Description
#   --------   ------------------	------------------------------------------
#   06/18/12   Jibeesh Kumar Gopi  	Initial development.
#
####################################################################################

###########################################################################
# Make sure All required parameters were passed in.
###########################################################################
if [ $# -lt 1 ]
then
   echo
   echo
   echo $0 requires at least 1 parameter.
   echo Usage:  $0 \<Category\>
   echo
   echo
   exit 1
fi

v_Ctgy_Nm=$1
v_input=$2

###########################################################################
# Print All the parameters and Validate the Parameters
###########################################################################
echo "Printing All the Parameters Passed by the scripts"
echo "Category Type             		= " ${v_Ctgy_Nm}
echo ""

if [[ ${v_Ctgy_Nm} != "NAS" && ${v_Ctgy_Nm} != "EXRT_FILE" ]];
then
   echo "ERROR: Input Parameter are not set properly. Please Check. Exiting the Job..."
   exit 1
fi

###########################################################################
# Call Library.ksh  ( Common Module )
###########################################################################
. library.ksh

###########################################################################
# Check whether to run the NZ Extract (Initial/Incremental Load) / NAS / EXRT_FILE
###########################################################################

echo ""
echo "Actual Source Code Started : `date`"
echo ""

if [[ ${v_Ctgy_Nm} = "EXRT_FILE" ]];
then
	if [[ ${v_input} = "ORG" ]];
	then
		echo ""
		echo "Creating Organization Extract..."
		echo ""
		
		EXRT_FILE_NM=${ORG_FILE_NM}.${ORG_FILE_EXT}
		echo "Extract File Name: ${EXRT_FILE_NM}"
		export EXRT_FILE_NM
		execute.ksh MDU extract_nz_datadump.ksh NETEZZA_${ENVR}_MDU CVC_ORG sql

		if [ $? -ne 0 ]
       	then
         	echo ""
			echo "ERROR: Error occurred. Exiting the Job - `date`"
       		echo ""
			exit 1;
		else
       		echo ""
			echo "Success: Process completed successfully - `date`"
   	      	echo ""	
			exit 0;
   	  	fi
	else
		v_lst_mnth_nm=$(nzsql -host ${NZ_HOST} -db ${NZ_DATABASE_EXRT} -A -t -c "SELECT MO_NM FROM ${NZ_DATABASE_EXRT}..MDU_PREMISE_EXTRACT GROUP BY 1" )
	
		if (( $? != 0 ));
		then
			echo "ERROR: Error occurred while querying to find Month Name from the ${NZ_DATABASE_EXRT}..MDU_PREMISE_TABLE table."
			exit 1
		fi
		
		for lst in `echo ${v_lst_mnth_nm}`
		do

			EXRT_FILE_NM=${FILE_NM}_${lst}.${FILE_EXT}
			MNTH_NM=${lst}
			export EXRT_FILE_NM
			export MNTH_NM

	        if [[ -e ${DIR_DATATGT}/${EXRT_FILE_NM}.pipe ]];
	        then
	            rm ${DIR_DATATGT}/${EXRT_FILE_NM}.pipe
	        fi
	
	        if [[ -e ${DIR_TEMP}/${EXRT_FILE_NM}.ksh ]];
	        then
	            rm ${DIR_TEMP}/${EXRT_FILE_NM}.ksh
	        fi
	
			echo ""
	        echo "Creating Pipe File - ${DIR_DATATGT}/${EXRT_FILE_NM}.pipe - `date`"
	        mkfifo ${DIR_DATATGT}/${EXRT_FILE_NM}.pipe
	
	        echo ""
	        echo "Creating zip file ${DIR_DATATGT}/${EXRT_FILE_NM} to store the extract data - `date`"
	        echo "cat ${DIR_DATATGT}/${EXRT_FILE_NM}.pipe | gzip -c > ${DIR_DATATGT}/${EXRT_FILE_NM}" >> ${DIR_TEMP}/${EXRT_FILE_NM}.ksh
	        sh ${DIR_TEMP}/${EXRT_FILE_NM}.ksh &
					
			execute.ksh MDU extract_nz_datadump.ksh NETEZZA_${ENVR}_MDU MDU_PREMISE_EXTRACT_EXTERNAL sql
			
			if [ $? -ne 0 ]
	       	then
	         	echo ""
				echo "ERROR: Error occurred. Exiting the Job - `date`"
	       		echo ""
				exit 1;
			else
				echo ""
				echo "SUCCESS: Extract File ${EXRT_FILE_NM} created successfully."

	        
			if [[ -e ${DIR_DATATGT}/${EXRT_FILE_NM}.pipe ]];
	        then
	            rm ${DIR_DATATGT}/${EXRT_FILE_NM}.pipe
	        fi
	
	        if [[ -e ${DIR_TEMP}/${EXRT_FILE_NM}.ksh ]];
	        then
	            rm ${DIR_TEMP}/${EXRT_FILE_NM}.ksh
	        fi

			fi
		done
		
		if [ $? -ne 0 ]
       	then
         	echo ""
			echo "ERROR: Error occurred. Exiting the Job - `date`"
       		echo ""
			exit 1;
		fi
	fi

elif [[ ${v_Ctgy_Nm} = "NAS" ]];
then 
	if [[ ${v_input} = "ORG" ]];
	then
		EXRT_FILE_NM=${ORG_FILE_NM}.${ORG_FILE_EXT}
	else
		EXRT_FILE_NM=${FILE_NM}_*.${FILE_EXT}
	fi

	LST_FILES=`ls ${DIR_DATATGT}/${EXRT_FILE_NM}`
	
	if [[ ${LST_FILES} == '' ]];
	then
		echo ""
		echo "No File to be moved. Exiting the Job."
		exit 0
	else
		echo ""
		echo "Files to be moved are listed below."
		echo "Location: ${DIR_DATATGT}"
		echo "Files: ${LST_FILES}"
		echo ""
	fi

    if [[ ! -d ${DIR_NASTGT} ]];
    then
        echo ""
        echo "ERROR: NAS Location not defined. Please verify. Exiting the job."
        echo ""
        exit 1
    fi

	echo ""
	echo "Moving Extract File ${EXRT_FILE_NM} to ${DIR_DATATGT}..."
	echo ""

	cp -f ${DIR_DATATGT}/${EXRT_FILE_NM} ${DIR_NASTGT}

	if [[ $? != 0 ]];
	then
		echo ""
		echo "ERROR: Error occurred during moving the file to NAS Location. Verify and re-run. Exiting the Job."
		echo ""
		exit 1
	fi

	if [[ ! -d ${DIR_DATATGT_ARCHIVE} ]];
	then
    	echo ""
		echo "ERROR: File Archive Location not defined. Please verify. Exiting the job."
    	echo ""
    	exit 1
	fi

	echo ""
	echo "Archiving Files"
	echo ""

	if (ls ${DIR_DATATGT}/${EXRT_FILE_NM} >/dev/null)
	then
		mv ${DIR_DATATGT}/${EXRT_FILE_NM} ${DIR_DATATGT_ARCHIVE}/
		if [ $? -ne 0 ]
   		then
            echo ""
			echo "ERROR: Fail to archive the ${DIR_DATATGT}/${EXRT_FILE_NM} file - `date`"
			echo ""
           	exit 1;
		else
			echo ""
			echo "Success: Files moved to Archive Location ${DIR_DATATGT_ARCHIVE} successfully."	
			echo ""
    	fi
	else
    	echo ""
		echo "File(s) does not exist at location ${DIR_DATATGT}/${EXRT_FILE_NM}."
		echo ""
		exit 1;
	fi

	echo ""
	echo "Purge files"
	echo ""
	
	Del_File=`find ${DIR_DATATGT_ARCHIVE} -mtime +${ARCHIVE_CLEAN_DAY}`

	if [[ ${Del_File} == '' ]];
    then
        echo ""
        echo "No File to be removed."
		echo ""
    else

		find  ${DIR_DATATGT_ARCHIVE} -mtime +${ARCHIVE_CLEAN_DAY} -exec rm -f {} \;

		if [ $? -ne 0 ]
    	then
        	echo ""
			echo "ERROR: Error occurred while removing files more than ${ARCHIVE_CLEAN_DAY} days."
			echo ""
			exit 1;
		else
	        echo ""
			echo "Files more than ${ARCHIVE_CLEAN_DAY} days will be deleted."
			echo "Success: Files listed below are deleted successfully. "
			echo "Files: ${Del_File}"
	        echo ""	
		fi
	fi
fi

echo ""
echo "Process Completed Successfully - `date`"
echo ""


