USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_BUS_PARTY_PSTL_ADDR]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Proc_TRAC_Populate_COR_BUS_PARTY_PSTL_ADDR]                
AS                
DECLARE @JobID INT;                    
DECLARE @TEMPTIME DATETIME;                    
                    
SET NOCOUNT ON                    
SET XACT_ABORT ON                    
                    
SET @JobID = (SELECT isnull(MAX(JobID),0)                    
              FROM MC_JobID                    
              INNER JOIN MC_SourceFile                    
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                    
              WHERE logicalName = 'TracBusPartyPstlAddr'                    
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                    
                                       FROM MC_SysProcessedLog                    
                                       WHERE SystemID = 49));                    
SET  @TEMPTIME = GETDATE();                
                
Insert into COREETL.DBO.COR_BUS_PARTY_PSTL_ADDR(                
BUS_PARTY_PSTL_ADDR_ID,                
BUS_PARTY_ID,                
PSTL_ADDR_TYPE_CODE,                
STATE_CODE,                
CNTRY_CODE,                
JOB_ID,                
DATETIMESTAMP,                
CNTCT_RSTRCT_IND,                
ADDR_LINE1_TEXT,                
ADDR_LINE2_TEXT,                
ADDR_LINE3_TEXT,                
ADDR_LINE4_TEXT,                
CITY,                
PSTLCD_TEXT,                
PSTL_ADDR_FROM_DATE,                
PSTL_ADDR_THRU_DATE,                
MNTC_SYS_CODE,                
MNTC_SYS_ATTR_ID,                
MNTC_SYS_ATTR_KEY1_TEXT,                
MNTC_SYS_ATTR_KEY2_TEXT,                
MNTC_SYS_ATTR_KEY3_TEXT,                
MNTC_SYS_ATTR_KEY4_TEXT,                
REC_INSRT_DATE,                
REC_INSRT_NAME,                
REC_UPDT_DATE,                
REC_UPDT_NAME,                
ADU)                
Select                 
BusinessPartyPostalAddressID,                
BusinessPartyID,                
POSTAL_ADDR_TYPE_CODE,                
CASE WHEN ISNULL([STATE],'')  = '' THEN 'UNK' ELSE [STATE] End, 

--COMMENTED & MODIFIED to fix code issue - PBI000000071103 - 09-25-2018 - START
--CASE WHEN ISNULL([COUNTRYCODE],'USA') = '' THEN 'USA'   
CASE WHEN ISNULL([COUNTRYCODE],'USA') = 'USA' THEN 'USA' 
--COMMENTED & MODIFIED to fix code issue - PBI000000071103 - 09-25-2018 - END
        
WHEN LTRIM(RTRIM(COUNTRYCODE)) = 'UNKNOWN COUNTRIES' THEN 'UNK'  
ELSE  [COUNTRYCODE] END AS  CNTRY_CODE,         
--COUNTRYCODE,
@JobID,                
@TEMPTIME,                
CONTACT_RESTRICTED_IND,                
ADDR_LINE1,                
ADDR_LINE2,                
ADDR_LINE3,                
ADDR_LINE4,                
CITY,               
POSTALCODE,                
POSTAL_ADDR_FROM_DATE,                
POSTAL_ADDR_THRU_DATE,                
MNTC_SYS_ATTR_SRC_TEXT,                
MaintenanceSystemAttributeID,                
MNTC_SYS_ATTR1_KEY,                
MNTC_SYS_ATTR2_KEY,                
MNTC_SYS_ATTR3_KEY,                
MNTC_SYS_ATTR4_KEY,                
GETDATE(),                
'410',                
GETDATE(),                
'410',                
ADU                
FROM COM_POSTAL_ADDR                
Inner Join GenIDBPBusinessPartyPostalAddress GENIDPA ON                 
GENIDPA.SourceSystem = POSTAL_ADDR_SRC_TEXT                
AND GENIDPA.SourceSystemKey1  = POSTAL_ADDR1_KEY                
AND GENIDPA.SourceSystemKey2  = POSTAL_ADDR2_KEY                
AND GENIDPA.SourceSystemKey3  = POSTAL_ADDR3_KEY                
AND GENIDPA.SourceSystemKey4  = POSTAL_ADDR4_KEY                
Inner Join KeyTRACBusinessPartyID GENIDBP ON                 
GENIDBP.SourceSystem = PARTY_SRC_TEXT                
AND GENIDBP.SourceSystemKey1 = PARTY1_KEY                
AND GENIDBP.SourceSystemKey2 = PARTY2_KEY                
AND GENIDBP.SourceSystemKey3 = PARTY3_KEY                
AND GENIDBP.SourceSystemKey4 = PARTY4_KEY                
INNER JOIN dbo.GenIDSPMaintenanceSystemAttributeName                    
ON dbo.COM_POSTAL_ADDR.MNTC_SYS_ATTR_SRC_TEXT = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystem                    
 AND dbo.COM_POSTAL_ADDR.MNTC_SYS_ATTR1_KEY = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystemKey1                    
 AND dbo.COM_POSTAL_ADDR.MNTC_SYS_ATTR2_KEY = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystemKey2                    
WHERE dbo.COM_POSTAL_ADDR.RECORD_TYPE_DESC = 'TRAC';

GO
