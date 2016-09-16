----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Created By: 	Jibeesh Kumar Gopi				  	        --
-- Date:	6/18/12								--
-- Defect #:	13152								--
-- Desc:	Seed Data for DAILY_JOB Table					--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

INSERT INTO DAILY_JOB (PRC_DT, PRJ_NM, LD_SEQ_KEY_FLG, PRJ_DESC) SELECT CURRENT_DATE-1 PRC_DT, 'MDU' PRJ_NM, 'N' LD_SEQ_KEY_FLG, 'MDU Premise Extract' PRJ_DESC;
