USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_AGRMNT_ATHRZTN]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_AGRMNT_ATHRZTN] AS                        
DECLARE @JobID INT;                        
DECLARE @TEMPDATE DATETIME;                        
            
                        
SET @JobID = (SELECT isnull(MAX(JobID),0)                          
              FROM MC_JobID                          
              INNER JOIN MC_SourceFile                          
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                          
              WHERE logicalName = 'TRACAgreementAuthorization'                          
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                          
                                       FROM MC_SysProcessedLog                          
                                       WHERE SystemID = 49));                            
                        
SET @TEMPDATE = GETDATE();                        
                       
                    
INSERT INTO CoreETL.dbo.COR_AGRMNT_ATHRZTN                        
(                        
 AGREEMENT_ID,            
 AGRMNT_ATHRZTN_TYPE_CODE,            
 JOB_ID,            
 DATETIMESTAMP,            
 AGRMNT_ATHRZTN_VALUE,            
 START_DATE,            
 END_DATE,            
 REC_INSRT_DATE,            
 REC_INSRT_NAME,            
 REC_UPDT_DATE,            
 ADU                  
)                    
SELECT DISTINCT                    
GenAgrmnt.AgreementID,            
CASE WHEN Agrmnt_Athrztn_Value = 'MRP' THEN 'MRP'            
             WHEN Agrmnt_Athrztn_Value= 'ADVICE' THEN 'ADVICE'            
             WHEN LEFT(Agrmnt_Athrztn_Value,3) = 'ADV' THEN 'ADV'            
             WHEN LEFT(Agrmnt_Athrztn_Value,2) = 'MT' THEN 'MT'          
             ELSE 'UNK'          
        END as Agrmnt_Athrtn_type_code ,            
--Agrmnt_Athrtn_type_code,    
@JobID  AS JOB_ID ,              
@TEMPDATE,      
CASE WHEN ISNULL(TRACAUTH.AGRMNT_ATHRZTN_VALUE,'') = '' THEN 'UNK'        
ELSE  TracAuth.Agrmnt_Athrztn_Value        
END as Agrmnt_Athrztn_Value,   
   
CASE WHEN CAST (ltrim(rtrim (TRACAUTH.EFFECTIVE_DATE)) AS datetime) in ('','01-01-1900') THEN NULL      
ELSE TRACAUTH.EFFECTIVE_DATE END  AS StartDate,      
--TracAuth.Effective_Date  AS StartDate,            
CASE WHEN CAST (ltrim(rtrim(TRACAUTH.Termination_Date)) AS datetime) in ('','01-01-1900') THEN '12-31-2999'      
ELSE ISNULL(TRACAUTH.Termination_Date,'12-31-2999') END  AS EndDate, 
    
--ISNULL(CONVERT(DATE,TracAuth.Termination_Date),'12-31-2999') AS EndDate,            
--GETDATE(),            
@TEMPDATE,      
'428',          
--GETDATE(),            
@TEMPDATE,      
'U'               
FROM                    
 TRACAgreementAuthorization  AS TracAuth            
INNER JOIN                            
 GenIDFAAgreement   as GenAgrmnt                 
 ON  GenAgrmnt.SourceSystem = TracAuth.Mntc_Sys_Code                    
 AND GenAgrmnt.SourceSystemKey1 = TracAuth.Agrmnt_sys_attr_key1_text                    
 AND GenAgrmnt.SourceSystemKey2 = TracAuth.Agrmnt_sys_attr_key2_text                    
 AND GenAgrmnt.SourceSystemKey3 = TracAuth.Agrmnt_sys_attr_key3_text                    
 AND GenAgrmnt.SourceSystemKey4 = TracAuth.Agrmnt_sys_attr_key4_text               
 AND GenAgrmnt.SourceSystemKey5 = TracAuth.Agrmnt_sys_attr_key5_text  
GO
