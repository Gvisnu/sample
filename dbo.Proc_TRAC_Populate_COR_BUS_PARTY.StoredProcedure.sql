USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_BUS_PARTY]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Proc_TRAC_Populate_COR_BUS_PARTY] AS              
DECLARE @JobID INT;              
DECLARE @TEMPTIME DATETIME;              
              
SET NOCOUNT ON              
SET XACT_ABORT ON              
              
SET @JobID = (SELECT ISNULL(MAX(JobID),0)              
FROM Core1.dbo.MC_JobID MJ              
INNER JOIN Core1.dbo.MC_SourceFile MS ON MJ.SourceFileID = MS.SourceFileID              
WHERE MS.logicalName = 'TracBusParty'              
AND MJ.SysProcessedLogID = 
(SELECT MAX(S.SysProcessedLogID) FROM Core1.dbo.MC_SysProcessedLog S  WHERE S.SystemID = 49));               
SET  @TEMPTIME = GETDATE();              
      
INSERT INTO  CoreETL.dbo.COR_BUS_PARTY(              
BUS_PARTY_ID,              
ACCSS_RSTRCT_ID,              
BUS_PARTY_TYPE_CODE,              
GNDR_CODE,              
MRTL_STAT_CODE,              
PRSN_NAME_PRFX_CODE,              
PRSN_NAME_SFX_CODE,              
PRCSSNG_CO_ID,              
TAXID_TYPE_CODE,              
JOB_ID,              
DATETIMESTAMP,              
BIRTH_DATE,              
DEATH_DATE,              
MTHR_MDN_NAME,              
ORG_NAME,              
OTHER_PARTY_NAME,              
PRSN_FIRST_NAME,              
PRSN_LAST_NAME,              
PRSN_MID_NAME,              
PRSN_PREV_LAST_NAME,              
TAXID_CNFRM_IND,              
TAXID_NUM,              
UNFRMTTD_PRSN_NAME,              
VIP_IND,              
MNTC_SYS_CODE,              
MNTC_SYS_ATTR_ID,              
MNTC_SYS_ATTR_KEY1_TEXT,              
MNTC_SYS_ATTR_KEY2_TEXT,              
MNTC_SYS_ATTR_KEY3_TEXT,              
MNTC_SYS_ATTR_KEY4_TEXT,           
--REC_INSRT_DATE,              
REC_INSRT_NAME,              
--REC_UPDT_DATE,              
--REC_UPDT_NAME,              
--REC_FROM_DATE,              
--REC_THRU_DATE,              
ADU)              
SELECT DISTINCT 
K.BusinessPartyID,              
C.ACCESS_RSTRCTN,              
C.BUS_PARTY_TYPE_CODE,              
CASE 
    WHEN C.GENDER_CODE IS NULL 
	THEN 'UNK'              
    ELSE C.GENDER_CODE  
END,              
CASE 
    WHEN ISNULL(C.MARITAL_STAT_CODE,'') = ''
	THEN 'UNK'              
    ELSE C.MARITAL_STAT_CODE              
END,    
CASE  
    WHEN ISNULL(C.PERSON_NAME_PREFIX_CODE,'') = '' 
	THEN 'UNK'    ---dcj 08/16/2016 added to match fast logic, causing error after upgrade rollback
    ELSE C.PERSON_NAME_PREFIX_CODE   
END,   
CASE 
    WHEN ISNULL(C.PERSON_NAME_SUFFIX_CODE,'') = '' 
	THEN 'UNK'  
    ELSE C.PERSON_NAME_SUFFIX_CODE   
END,            
GC.ProcessingCompanyID,              
C.TAXID_TYPE_CODE,              
@JobID AS JobID,              
@TEMPTIME AS DATETIMESTAMP,              
CAST(NULLIF(C.BIRTHDATE,'') AS DATE) as BIRTHDATE ,          
CAST(NULLIF(C.DEATH_DATE,'') AS DATE) as DEATH_DATE ,                
C.MOTHERS_MAIDEN_NAME,              
C.ORG_NAME,              
C.OTHER_PARTY_NAME,              
C.PERSON_FIRST_NAME,              
C.PERSON_LAST_NAME,              
C.PERSON_MIDDLE_NAME,              
C.PERSON_PREVIOUS_LAST_NAME,              
ISNULL(C.TAXID_CONFIRM_IND,0) as TAXID_CONFIRM_IND,              
C.TAXID,              
C.UNFORMATTED_PERSON_NAME,              
C.VIP_IND,              
C.MNTC_SYSTEM_CODE,              
GA.MaintenanceSYstemAttributeID,              
C.BUS_PARTY1_KEY AS MNTC_SYS_ATTR_KEY1_TEXT,              
C.BUS_PARTY2_KEY AS MNTC_SYS_ATTR_KEY2_TEXT,              
C.BUS_PARTY3_KEY AS MNTC_SYS_ATTR_KEY3_TEXT,              
CASE 
    WHEN C.BUS_PARTY5_KEY = '^' THEN 'N/A'
    ELSE C.BUS_PARTY5_KEY 
END AS MNTC_SYS_ATTR_KEY4_TEXT,              
'407' AS REC_INSRT_NAME,              
'U' AS ADU              
FROM Core1.dbo.COM_BUS_PARTY C         
INNER JOIN Core1.dbo.KeyTRACBusinessPartyID K ON 
               K.SourceSystemKey1 = C.BUS_PARTY1_KEY          
        AND    K.SourceSystemKey2 = C.BUS_PARTY2_KEY         
        AND    K.SourceSystemKey3 = C.BUS_PARTY3_KEY         
        AND    K.SourceSystemKey4 = C.BUS_PARTY4_KEY  
        ANd    K.SourceSystemKey5 = C.BUS_PARTY5_KEY       
        AND    K.SourceSystem  = C.MNTC_SYSTEM_CODE        
INNER JOIN Core1.dbo.GenIDSPMaintenanceSystemAttributeName GA  ON C.MNTC_SYS_ATTR_SRC_TEXT = GA.SourceSystem              
AND C.MNTC_SYS_ATTR1_KEY = GA.SourceSystemKey1              
AND C.MNTC_SYS_ATTR2_KEY = GA.SourceSystemKey2              
INNER JOIN Core1.dbo.GenIDCMProcessingCompany GC on GC.SourceSystem = C.MNTC_SYSTEM_CODE        
AND GC.SourceSystemKey4 = C.BUS_PARTY4_KEY                     
WHERE C.RECORD_TYPE_DESC = 'TRAC';             
              
SET NOCOUNT OFF              
SET XACT_ABORT OFF              
RETURN


GO
