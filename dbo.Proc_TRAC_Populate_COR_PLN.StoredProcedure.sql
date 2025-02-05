USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_PLN]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_PLN]            
AS            
DECLARE @JobID INT;            
DECLARE @TempTime DateTime;            
        
SET @JobID = (SELECT isnull(MAX(JobID),0)        
              FROM MC_JobID        
              INNER JOIN MC_SourceFile        
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID        
              WHERE logicalName = 'TRACPlan'        
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)        
                                       FROM MC_SysProcessedLog        
                                       WHERE SystemID = 49));            
SET @TempTime = GETDATE();            
            
          
INSERT INTO COREETL.dbo.COR_PLN(            
 PLAN_ID,            
 DATETIMESTAMP,            
 JOB_ID,            
 ERISA,            
 SBG_PLAN_DOCUMENT,            
 SBG_SERVICED,            
 SBG_DOES_TAX_REPORTING,            
 EFFECTIVE_DATE,            
 BUS_PARTY_ID,            
 MNTC_SYSTEM_CODE,            
 PLAN_NUMBER,            
 REC_INSRT_DATE,            
 REC_INSRT_NAME,            
 REC_UPDT_DATE,            
 REC_UPDT_NAME,            
 REC_FROM_DATE,            
 REC_THRU_DATE,            
 RECORD_STATUS_CODE,            
 ADMINISTRATOR,            
 IRS_NUMBER,            
 SBG_LOAN_SERVICING,            
 ACCSS_RSTRCT_ID,            
 NAV_IND,            
 GROUP_SGMNT_CODE,          
 CNTRCT_TRMNTN_ENDRSMNT,            
 ADU,          
 FID_SRVC_END_DATE,          
 FID_SRVC_START_DATE,          
 FID_SRVC_TYPE_CODE,          
 PLAN_NAME,      
 FIRST_ASSET_DATE,    
 MODEL_PLAN      
 )            
 SELECT            
 GenIDPLPlan.PlanID,            
 @TempTime,            
 @JobID,            
 IsNull(LTRIM(RTRIM(TP.ERISA)),'U'),            
 TP.SBG_PLAN_DOCUMENT,            
 TP.SBG_SERVICED,            
 TP.SBG_DOES_TAX_REPORTING,            
 TP.EFFECTIVE_DATE,            
 dbo.KeyTRACBusinessPartyID.BusinessPartyID,            
 TP.MNTC_SYSTEM_CODE,            
 TP.Plan_Sys_Attr_Key1_Text,            
 @TempTime ,            
 '403',            
 @TempTime,            
 null,            
 @TempTime,            
 '12/31/2999',            
 TP.RECORD_STATUS_CODE,            
 TP.ADMINISTRATOR,            
 TP.IRS_NUMBER,            
 TP.SBG_LOAN_SERVICING,            
 DBO.TRAC_ACCESS_RESTRICTION(TP.ACCESS_RESTRCTN_ID),        
 TP.NAV_IND,            
 case when IsNull(TP.GROUP_SGMNT_CODE,'') = '' then 'UNK'      
 else TP.GROUP_SGMNT_CODE end,           
 TP.CNTRCT_TRMNTN_ENDRSMNT,          
  'U' ,      
 TP.FID_SRVC_END_DATE,          
 TP.FID_SRVC_START_DATE,          
 TP.FID_SRVC_TYPE_CODE,          
 TP.PLAN_NAME,      
 TP.FIRST_ASSET_DATE ,    
 --TP_Model.PlanID        
 TP.MODEL_PLAN  
 FROM DBO.TRACPlan TP            
 INNER JOIN GenIDPLPlan ON TP.PLAN_SYS_ATTR_KEY1_TEXT = GenIDPLPlan.SourceSystemKey1       
     AND TP.PLAN_SYS_ATTR_KEY2_TEXT = GenIDPLPlan.SourceSystemKey2       
     AND TP.MNTC_SYSTEM_CODE =GenIDPLPlan.SourceSystem            
 INNER JOIN dbo.KeyTRACBusinessPartyID ON TP.MNTC_SYSTEM_CODE =dbo.KeyTRACBusinessPartyID.SourceSystem       
        AND  TP.BUSPARTY_SYS_ATTR_KEY1_TEXT = dbo.KeyTRACBusinessPartyID.SourceSystemKey1            
        and  TP.BUSPARTY_SYS_ATTR_KEY2_TEXT =  dbo.KeyTRACBusinessPartyID.SourceSystemKey2         
        AND  TP.BUSPARTY_SYS_ATTR_KEY3_TEXT = dbo.KeyTRACBusinessPartyID.SourceSystemKey3            
        and  TP.BUSPARTY_SYS_ATTR_KEY4_TEXT =  dbo.KeyTRACBusinessPartyID.SourceSystemKey4    
 --LEFT OUTER JOIN DBO.GenIDPLPlan TP_Model    
 --ON TP.MODEL_PLAN = TP_Model.SourceSystemKey2       
 --    AND TP.MNTC_SYSTEM_CODE =TP_Model.SourceSystem            
         
RETURN 
GO
