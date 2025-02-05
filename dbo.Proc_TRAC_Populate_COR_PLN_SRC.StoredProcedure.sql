USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_PLN_SRC]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_PLN_SRC]      
AS      
DECLARE @JobID INT;      
DECLARE @TEMPTIME DateTime;      
  
SET @JobID = (SELECT isnull(MAX(JobID),0)  
              FROM MC_JobID  
              INNER JOIN MC_SourceFile  
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID  
              WHERE logicalName = 'TRACPlanSrc'  
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)  
                                       FROM MC_SysProcessedLog  
                                       WHERE SystemID = 49));      
SET @TEMPTIME = GETDATE();      
      
INSERT INTO COREETL.dbo.COR_PLN_SRC(      
	PLAN_ID,
	ASSET_SOURCE_CODE,
	PLAN_ASSET_SRC_DESC,			
	PLAN_ASSET_SRC_DESC_ABBR,		
	DATETIMESTAMP,
	JOB_ID,
	REC_INSRT_DATE,
	REC_INSRT_NAME,
	ADU
	   )      
 SELECT      
 GenIDPLPlan.PlanID										AS PLAN_ID, 
 LEFT ((TP.CONTR_MONEY_TY_CDE+'+'+TP.PLAN_TYPE_CDE),30) AS ASSET_SOURCE_CODE,
 LEFT (VALID_PLN_MNY_LNG,30)							AS PLAN_ASSET_SRC_DESC,
 VALID_PLN_MNY_SHRT										AS PLAN_ASSET_SRC_DESC_ABBR,
 @TEMPTIME												As DATETIMESTAMP,      
 @JobID													AS JOB_ID,      
 @TEMPTIME												AS REC_INSRT_DATE,     
 '412'													AS REC_INSRT_NAME,
 ADU
 FROM TRACPlanSrc TP
 INNER JOIN GenIDPLPlan ON TP.PLAN_SYS_ATTR_KEY1_TEXT = GenIDPLPlan.SourceSystemKey1 
					   AND TP.PLAN_SYS_ATTR_KEY2_TEXT = GenIDPLPlan.SourceSystemKey2 
					   AND TP.MNTC_SYSTEM_CODE =GenIDPLPlan.SourceSystem        
Where TP.MNTC_SYSTEM_CODE = 'TRAC'
        
RETURN
GO
