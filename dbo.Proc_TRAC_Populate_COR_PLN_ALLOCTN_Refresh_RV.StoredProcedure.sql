USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_PLN_ALLOCTN_Refresh_RV]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Proc_TRAC_Populate_COR_PLN_ALLOCTN_Refresh_RV]      
AS       
DECLARE @JobID INT;                    
DECLARE @TEMPTIME DateTime;                    
                
SET @JobID = (SELECT isnull(MAX(JobID),0)                
              FROM MC_JobID                
              INNER JOIN MC_SourceFile                
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                
              WHERE logicalName = 'TRACPlanAllocation'                
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                
                                       FROM MC_SysProcessedLog                
                                       WHERE SystemID = 50                                           
                                       ));                    
SET @TEMPTIME = GETDATE();                    
      
--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COR_PLN_ALLOCTN_TODAY]') AND type in (N'U'))                        
--BEGIN                        
--DROP TABLE [dbo].[COR_PLN_ALLOCTN_TODAY]      
--END                     
      
--SELECT * INTO CORE1.DBO.[COR_PLN_ALLOCTN_TODAY] FROM COREETL.DBO.COR_PLN_ALLOCTN WHERE 1=2      
      
INSERT INTO CORE1.DBO.[COR_PLN_ALLOCTN_TODAY_RV](               
 PLAN_ID,              
 ALLOCATION_TYPE_CODE,              
 SRC_FUND_ID,              
 ASSET_SOURCE_CODE,              
 DATETIMESTAMP,              
 JOB_ID,              
 AMOUNT_TYPE_CODE,              
 AMOUNT,              
 REC_INSRT_DATE,              
 REC_INSRT_NAME,              
 REC_UPDT_DATE,              
 REC_UPDT_NAME,              
 REC_FROM_DATE,              
 REC_THRU_DATE,              
 RECORD_STATUS_CODE,              
 FRZ_DATE, 
 ADU              
    )                    
SELECT                
 GenIDPLPlan.PlanID,              
 TPA.ALLOCATION_TYPE_CODE,              
 ISNULL(GENID.SRC_FUND_ID,'999999999'),              
 convert(varchar(30),(TPA.CONTR_MONEY_TY_CDE+'+'+TPA.PLAN_TYPE_CDE)) AS ASSET_SOURCE_CODE,              
 @TEMPTIME,              
 @JobID,              
 TPA.AMOUNT_TYPE_CODE,              
 TPA.AMOUNT,              
 @TEMPTIME AS REC_INSRT_DATE,              
 CASE WHEN GENID.SRC_FUND_ID Is NULL THEN (RTRIM(TPA.SRC_SYS_ATTR_KEY1_TEXT)+'+'+RTRIM(TPA.SRC_SYS_ATTR_KEY2_TEXT)+'+'+RTRIM(TPA.SRC_SYS_ATTR_KEY3_TEXT)+'+'+RTRIM(TPA.SRC_SYS_ATTR_KEY4_TEXT))        
 ELSE  '477'        
 END AS REC_INSRT_NAME,         
 @TEMPTIME AS REC_UPDT_DATE,              
 NULL,              
 @TEMPTIME AS REC_FROM_DATE,              
 CASE WHEN RECORD_STATUS_CODE = 'A' THEN '2999-12-31'       
 WHEN RECORD_STATUS_CODE = 'I' THEN @TEMPTIME      
 ELSE NULL       
 END AS REC_THRU_DATE,              
 CASE WHEN RECORD_STATUS_CODE = 'A' THEN 'ACT'       
 WHEN RECORD_STATUS_CODE = 'I' THEN 'INACT'      
 ELSE NULL END as RECORD_STATUS_CODE,      
 FREEZE_DATE AS FRZ_DATE,
 'A'              
 FROM dbo.TRACPlanAlloctn_refresh_RV TPA              
 INNER JOIN dbo.GenIDPLPlan on GenIDPLPlan.SourceSystemKey1 = TPA.PLAN_SYS_ATTR_KEY1_TEXT              
       AND GenIDPLPlan.SourceSystemKey2 = TPA.PLAN_SYS_ATTR_KEY2_TEXT              
       AND GenIDPLPlan.SourceSystem = TPA.MNTC_SYS_CODE              
LEFT OUTER JOIN GENIDSRCFUND GENID  ON                   
         rtrim(GENID.SOURCESYSTEMKEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)                
        AND rtrim(GENID.SOURCESYSTEMKEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)                                    
        AND rtrim(GENID.SOURCESYSTEMKEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)        
        AND GENID.SOURCESYSTEM = TPA.MNTC_SYS_CODE    
    where TPA.MNTC_SYS_CODE = 'TRAC'  and (    
    (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(GENID.SOURCESYSTEMKEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT))     
    OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = ''))    
GO
