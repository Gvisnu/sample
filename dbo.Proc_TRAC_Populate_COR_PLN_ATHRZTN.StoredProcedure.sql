USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_PLN_ATHRZTN]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_PLN_ATHRZTN]      
AS      
DECLARE @JobID INT;      
DECLARE @TEMPTIME DateTime;      
  
SET @JobID = (SELECT isnull(MAX(JobID),0)  
              FROM MC_JobID  
              INNER JOIN MC_SourceFile  
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID  
              WHERE logicalName = 'TRACPlanAthrztn'  
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)  
                                       FROM MC_SysProcessedLog  
                                       WHERE SystemID = 49));      
SET @TEMPTIME = GETDATE();      
          
    
INSERT INTO COREETL.dbo.COR_PLN_ATHRZTN( 
	PLAN_ID,
	JOB_ID,
	DATETIMESTAMP,
	PLN_ATHRZTN_TYPE_CODE,
	PLAN_AUTHORIZATION_VALUE,
	PLAN_ATHRZTN_FROM_DATE,
	PLAN_ATHRZTN_THROUGH_DATE,
	REC_INSRT_DATE,
	REC_INSRT_NAME,
	ADU
	   )      
 SELECT  
 GenIDPLPlan.PlanID,
 @JobID,
 @TEMPTIME,
 PLN_ATHRZTN_TYPE_CODE,
 PLAN_AUTHORIZATION_VALUE,
 PLAN_ATHRZTN_FROM_DATE,
 PLAN_ATHRZTN_THROUGH_DATE,
 @TEMPTIME AS REC_INSRT_DATE,
 '429' AS REC_INSRT_NAME,
 'U'
 FROM dbo.TRACPlanAuthorization TPA
 INNER JOIN dbo.GenIDPLPlan on GenIDPLPlan.SourceSystemKey1 =  TPA.PLAN_SYS_ATTR_KEY1_TEXT
							AND GenIDPLPlan.SourceSystemKey2 = TPA.PLAN_SYS_ATTR_KEY2_TEXT
							AND GenIDPLPlan.SourceSystem =     TPA.MNTC_SYS_CODE
 WHERE TPA.MNTC_SYS_CODE = 'TRAC'
        
RETURN
GO
