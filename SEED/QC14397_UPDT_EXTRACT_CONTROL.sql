/*------------------------------------------------------------------------

	Created By: 	Jibeesh Kumar Gopi					   							
	Date:			10/26/12														
	Defect #:		14397															
	Desc:			Update to set Incremental Flag as 'N' in 
					EXTRACT_CONTROL Table								

------------------------------------------------------------------------*/

UPDATE PRD_XTR_1..EXTRACT_CONTROL 
	SET INCRMNTL_FLG = 'N'
WHERE PRJ_NM = 'MDU'
	AND TBL_NM = 'MDU_PREMISE_EXTRACT';