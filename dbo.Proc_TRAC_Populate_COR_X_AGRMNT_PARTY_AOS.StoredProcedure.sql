USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_X_AGRMNT_PARTY_AOS]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Proc_TRAC_Populate_COR_X_AGRMNT_PARTY_AOS] AS                          
DECLARE @JobID INT;                          
DECLARE @TEMPDATE DATETIME;                          
DECLARE @CYCLEDATE DATETIME;                          
                          
SET @JobID = (SELECT isnull(MAX(JobID),0)                            
              FROM MC_JobID                            
              INNER JOIN MC_SourceFile                            
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                            
              WHERE logicalName = 'TracAgreementParty'                            
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                            
                                       FROM MC_SysProcessedLog                            
                                       WHERE SystemID = 49));                              
                          
SET @TEMPDATE = GETDATE();                          
SELECT @CYCLEDATE = CycleDate from SourceSystemCycleDate where systemid = 48                          
            
INSERT INTO CoreETL.dbo.COR_X_AGRMNT_PARTY_AOS                          
(                          
 AGRMNT_PARTY_ID,                          
 ACCSS_RSTRCT_ID,                          
 AGRMNT_ID,                          
 BUS_PARTY_ID,                          
 AGRMNT_PARTY_ROLE_TYPE_CODE,                          
 AGRMNT_PARTY_STAT_CODE,                          
 JOB_ID,                          
 DATETIMESTAMP,                          
 AGRMNT_PARTY_PCT,                          
 AGRMNT_PARTY_FROM_DATE,                          
 AGRMNT_PARTY_THRU_DATE,                          
 MNTC_SYS_CODE,                          
 MNTC_SYS_ATTR_ID,                          
 MNTC_SYS_ATTR_KEY1_TEXT,                          
 MNTC_SYS_ATTR_KEY2_TEXT,                          
 MNTC_SYS_ATTR_KEY3_TEXT,                        
 MNTC_SYS_ATTR_KEY4_TEXT,                      
 REC_INSRT_NAME,      
 REC_UPDT_NAME,                    
 ADU                      
)                      
SELECT DISTINCT                      
 GenIDBPAgreementParty.AgreementPartyID,                      
 COM_X_AGRMNT_PARTY.ACCESS_RSTRCTN,                      
 GenIDFAAgreement.AgreementID,                      
 CASE WHEN COM_X_AGRMNT_PARTY.AGRMNT_PARTY_ROLE_TYPE_CODE IN (3,4)     
  THEN ISNULL(D.BUS_PARTY_ID,'999999999')            
 ELSE ISNULL(GenIDBPBusinessParty.BusinessPartyID,'999999999')   
 END As BUS_PARTY_ID,            
 COM_X_AGRMNT_PARTY.AGRMNT_PARTY_ROLE_TYPE_CODE,                      
 case when COM_X_AGRMNT_PARTY.AGRMNT_PARTY_THRU_DATE <= @TEMPDATE then 'T'      
  else   AGRMNT_PARTY_STAT_CODE end as  AGRMNT_PARTY_STAT_CODE, -- Added by  rajan for duplicate issue                  
 @JobID,                      
 @TEMPDATE,                      
 COM_X_AGRMNT_PARTY.AGRMNT_PARTY_PCT,                      
 ISNULL(COM_X_AGRMNT_PARTY.AGRMNT_PARTY_FROM_DATE, @TEMPDATE),                      
 ISNULL(COM_X_AGRMNT_PARTY.AGRMNT_PARTY_THRU_DATE, '31-DEC-2999'),                      
 COM_X_AGRMNT_PARTY.MNTC_SYSTEM_CODE,                      
 GenIDSPMaintenanceSystemAttributeName.MaintenanceSystemAttributeID,                      
 COM_X_AGRMNT_PARTY.AGRMNT_PARTY1_KEY,                      
 COM_X_AGRMNT_PARTY.AGRMNT_PARTY2_KEY,                      
 COM_X_AGRMNT_PARTY.AGRMNT_PARTY3_KEY,                      
 COM_X_AGRMNT_PARTY.AGRMNT_PARTY4_KEY,                      
 --'N/A' AS MNTC_SYS_ATTR_KEY4_TEXT,                
 '414' as REC_INSRT_NAME,                      
 CASE WHEN D.BUS_PARTY_ID IS NULL AND COM_X_AGRMNT_PARTY.AGRMNT_PARTY_ROLE_TYPE_CODE IN (3,4) THEN COM_X_AGRMNT_PARTY.BUS_PARTY1_KEY      
 ELSE '414'    
 END AS REC_UPDT_NAME,     
 COM_X_AGRMNT_PARTY.ADU            
FROM                      
 COM_X_AGRMNT_PARTY_AOS  as COM_X_AGRMNT_PARTY                    
INNER JOIN                      
 GenIDBPAgreementParty                      
 ON  GenIDBPAgreementParty.SourceSystem = COM_X_AGRMNT_PARTY.AGRMNT_PARTY_SRC_TEXT                      
 AND GenIDBPAgreementParty.SourceSystemKey1 = COM_X_AGRMNT_PARTY.AGRMNT_PARTY1_KEY                      
 AND GenIDBPAgreementParty.SourceSystemKey2 = COM_X_AGRMNT_PARTY.AGRMNT_PARTY2_KEY                      
 AND GenIDBPAgreementParty.SourceSystemKey3 = COM_X_AGRMNT_PARTY.AGRMNT_PARTY3_KEY                      
 AND GenIDBPAgreementParty.SourceSystemKey4 = COM_X_AGRMNT_PARTY.AGRMNT_PARTY4_KEY                      
 AND GenIDBPAgreementParty.SourceSystemKey5 = COM_X_AGRMNT_PARTY.AGRMNT_PARTY5_KEY        
 AND GenIDBPAgreementParty.SourceSystemKey6 = COM_X_AGRMNT_PARTY.AGRMNT_PARTY6_KEY                  
INNER JOIN                      
 GenIDFAAgreement                      
 ON  GenIDFAAgreement.SourceSystem = COM_X_AGRMNT_PARTY.AGRMNT_SRC_TEXT                      
 AND GenIDFAAgreement.SourceSystemKey1 = COM_X_AGRMNT_PARTY.AGRMNT1_KEY                      
 AND GenIDFAAgreement.SourceSystemKey2 = COM_X_AGRMNT_PARTY.AGRMNT2_KEY                      
 AND GenIDFAAgreement.SourceSystemKey3 = COM_X_AGRMNT_PARTY.AGRMNT3_KEY            
 --AND GenIDFAAgreement.SourceSystemKey4 = COM_X_AGRMNT_PARTY.AGRMNT4_KEY                    
 INNER JOIN                      
 GenIDSPMaintenanceSystemAttributeName                
 ON  GenIDSPMaintenanceSystemAttributeName.SourceSystem = COM_X_AGRMNT_PARTY.MNTC_SYS_ATTR_SRC_TEXT                      
 AND GenIDSPMaintenanceSystemAttributeName.SourceSystemKey1 = COM_X_AGRMNT_PARTY.MNTC_SYS_ATTR1_KEY                      
 AND GenIDSPMaintenanceSystemAttributeName.SourceSystemKey2 = COM_X_AGRMNT_PARTY.MNTC_SYS_ATTR2_KEY                      
LEFT OUTER JOIN            
 GenIDBPBusinessParty                      
 ON  GenIDBPBusinessParty.SourceSystem = COM_X_AGRMNT_PARTY.BUS_PARTY_SRC_TEXT                      
 AND GenIDBPBusinessParty.SourceSystemKey1 = COM_X_AGRMNT_PARTY.BUS_PARTY1_KEY                      
 AND GenIDBPBusinessParty.SourceSystemKey2 = COM_X_AGRMNT_PARTY.BUS_PARTY2_KEY                      
 AND GenIDBPBusinessParty.SourceSystemKey3 = COM_X_AGRMNT_PARTY.BUS_PARTY3_KEY      
 ANd GenIDBPBusinessParty.SourceSystemKey4 = COM_X_AGRMNT_PARTY.BUS_PARTY4_KEY    
 ANd GenIDBPBusinessParty.SourceSystemKey5 = COM_X_AGRMNT_PARTY.BUS_PARTY5_KEY                    
LEFT OUTER JOIN             
  CORE..SBGCORE.COR_SALES_PARTY_OTHER_KEY  D ON ltrim(rtrim(D.OTHER_KEY_NUM)) = ltrim(rtrim(COM_X_AGRMNT_PARTY.BUS_PARTY1_KEY))
  --AND COR_SALES_PARTY_OTHER_KEY.MNTC_SYS_CODE = COM_X_AGRMNT_PARTY.MNTC_SYSTEM_CODE        
  AND D.OTHER_KEY_TYPE_CODE IN ('MCS2TRCEXTID')
WHERE                      
 COM_X_AGRMNT_PARTY.MNTC_SYSTEM_CODE = 'TRAC'      
     
          
INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM)    
SELECT GETDATE(),    
 'UNABLE TO LOAD '+CAST(CNT AS VARCHAR)+' RECORD(S) INTO COR_X_AGRMNT_PARTY DUE TO A BUS_PARTY_ID OF 999999999',    
 'REFER TO ERR TABLE FOR DETAIL',    
 'REP',    
 'TRAC'    
FROM (SELECT COUNT(*) AS CNT FROM COREETL.DBO.COR_X_AGRMNT_PARTY WHERE BUS_PARTY_ID = 999999999) Q    
WHERE CNT > 0    
    
INSERT INTO COREERRLOG.DBO.ERR_X_AGRMNT_PARTY    
SELECT *,    
 (SELECT DISTINCT @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG)    
FROM COREETL.DBO.COR_X_AGRMNT_PARTY    
WHERE BUS_PARTY_ID = 999999999;    
    
DELETE COREETL.DBO.COR_X_AGRMNT_PARTY    
WHERE BUS_PARTY_ID =999999999;    
    
----- If a BUS_PARTY_ID was 999999999 and has been corrected, move to COR table and delete ERR row    
    
INSERT INTO COREETL.DBO.COR_X_AGRMNT_PARTY    
 (    
 AGRMNT_PARTY_ID,                          
 ACCSS_RSTRCT_ID,                          
 AGRMNT_ID,                          
 BUS_PARTY_ID,                          
 AGRMNT_PARTY_ROLE_TYPE_CODE,                          
 AGRMNT_PARTY_STAT_CODE,                          
 JOB_ID,                          
 DATETIMESTAMP,                          
 AGRMNT_PARTY_PCT,                          
 AGRMNT_PARTY_FROM_DATE,                          
 AGRMNT_PARTY_THRU_DATE,                          
 MNTC_SYS_CODE,                         
 MNTC_SYS_ATTR_ID,                          
 MNTC_SYS_ATTR_KEY1_TEXT,                          
 MNTC_SYS_ATTR_KEY2_TEXT,                          
 MNTC_SYS_ATTR_KEY3_TEXT,                        
 MNTC_SYS_ATTR_KEY4_TEXT,                      
 REC_INSRT_NAME,             
 ADU      
 )    
SELECT    
    
 A.AGRMNT_PARTY_ID,                          
 A.ACCSS_RSTRCT_ID,                          
 A.AGRMNT_ID,                          
 A.BUS_PARTY_ID,                          
 A.AGRMNT_PARTY_ROLE_TYPE_CODE,                          
 A.AGRMNT_PARTY_STAT_CODE,                          
 A.JOB_ID,                          
 A.DATETIMESTAMP,                          
 A.AGRMNT_PARTY_PCT,                          
 A.AGRMNT_PARTY_FROM_DATE,                          
 A.AGRMNT_PARTY_THRU_DATE,                          
 A.MNTC_SYS_CODE,                          
 A.MNTC_SYS_ATTR_ID,                          
 A.MNTC_SYS_ATTR_KEY1_TEXT,                          
 A.MNTC_SYS_ATTR_KEY2_TEXT,                          
 A.MNTC_SYS_ATTR_KEY3_TEXT,                        
 A.MNTC_SYS_ATTR_KEY4_TEXT,                      
 --A.REC_INSRT_NAME,                      
 '414',    
 ADU      
FROM COREERRLOG.DBO.ERR_X_AGRMNT_PARTY A    
INNER JOIN COREERRLOG.DBO.REPERRORLOG B    
ON  A.REPERRORID = B.ERRORID    
WHERE B.ERRORMESSAGE LIKE '%DUE TO A BUS_PARTY_ID OF 999999999'    
  AND A.BUS_PARTY_ID <> 999999999;    
      
    
DELETE COREERRLOG.DBO.ERR_X_AGRMNT_PARTY     
FROM COREERRLOG.DBO.ERR_X_AGRMNT_PARTY A    
INNER JOIN COREERRLOG.DBO.REPERRORLOG B ON  A.REPERRORID = B.ERRORID    
WHERE B.ERRORMESSAGE LIKE '%DUE TO A BUS_PARTY_ID OF 999999999'    
  AND A.BUS_PARTY_ID <> 999999999;    
      
    
                        
RETURN                            
SET QUOTED_IDENTIFIER OFF 
GO
