----------------------------------------------------------------------------------
-- Created By: 	Jibeesh Kumar Gopi					   							--
-- Date:	06/21/12															--
-- Defect #:	13152															--
-- Desc:	Seed Data for EXTRACT_CONTROL Table									--
----------------------------------------------------------------------------------

INSERT INTO ${NZ_DATABASE_EXRT}..EXTRACT_CONTROL (PRJ_NM, TBL_NM, XTRC_DESC, INCRMNTL_FLG) SELECT 'MDU' PRJ_NM, 'MDU_PREMISE_EXTRACT' TBL_NM, 'MDU EXTRACT' XTRC_DESC, 'N' INCRMNTL_FLG;