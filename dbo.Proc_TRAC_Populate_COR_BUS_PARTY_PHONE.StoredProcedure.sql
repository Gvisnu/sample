USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_BUS_PARTY_PHONE]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_BUS_PARTY_PHONE] AS              
DECLARE @JobID INT;          
DECLARE @TEMPTIME DATETIME;              
              
set nocount on              
set XACT_ABORT on              
-- Get the Job Id,              
SET @JobID = (SELECT isnull(MAX(JobID),0)              
              FROM MC_JobID              
              INNER JOIN MC_SourceFile              
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID              
              WHERE logicalName = 'TracBusPartyPhone'              
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)              
                                       FROM MC_SysProcessedLog              
                                       WHERE SystemID = 49));              

SET  @TEMPTIME = GETDATE();         
              
INSERT INTO  CoreETL.dbo.COR_BUS_PARTY_PHONE(              
  BUS_PARTY_PHONE_ID ,              
 BUS_PARTY_ID,              
 PHONE_TYPE_CODE,              
 JOB_ID,              
 DATETIMESTAMP ,              
 CNTCT_RSTRCT_IND,              
 AREACD_NUM ,              
 EXT_NUM,              
 UNFRMTTD_PHONE_NUM,              
 PHONE_FROM_DATE,              
 PHONE_THRU_DATE ,              
 MNTC_SYS_CODE,              
 MNTC_SYS_ATTR_ID,              
 MNTC_SYS_ATTR_KEY1_TEXT,              
 MNTC_SYS_ATTR_KEY2_TEXT,              
 MNTC_SYS_ATTR_KEY3_TEXT,              
 MNTC_SYS_ATTR_KEY4_TEXT,              
 REC_INSRT_NAME,              
 ADU               
 )              
SELECT dbo.KeyTRACBPTelephoneNumberID.BusinessPartyTelephoneNumberID,               
 dbo.KeyTRACBusinessPartyID.BusinessPartyID,               
 dbo.COM_TELNUM.TELNUM_TYPE_CODE,               
 @JobID AS JobID,              
 GETDATE() AS datetimestamp,               
 dbo.COM_TELNUM.CONTACT_RESTRICTED_IND,              
 dbo.COM_TELNUM.AREACODE,               
 dbo.COM_TELNUM.EXTENSION,               
 dbo.COM_TELNUM.UNFORMATTED_TELNUM,               
 dbo.COM_TELNUM.TELNUM_FROM_DATE,              
 dbo.COM_TELNUM.TELNUM_THRU_DATE,              
 dbo.COM_TELNUM.TELNUM_SRC_TEXT,              
 dbo.GenIDSPMaintenanceSystemAttributeName.MaintenanceSYstemAttributeID,              
 dbo.COM_TELNUM.TELNUM1_KEY,              
 'N/A' AS TELNUM2_KEY,              
 'N/A' AS TELNUM3_KEY,              
 'N/A' AS TELNUM4_KEY,              
 '409' AS REC_INSRT_NAME,               
 dbo.COM_TELNUM.ADU              
FROM dbo.COM_TELNUM         
INNER JOIN KeyTRACBPTelephoneNumberID    
on KeyTRACBPTelephoneNumberID.Phone_Key1 = dbo.COM_TELNUM.TELNUM1_KEY     
AND KeyTRACBPTelephoneNumberID.Phone_Key2 = dbo.COM_TELNUM.TELNUM2_KEY     
AND KeyTRACBPTelephoneNumberID.Phone_Key3 = dbo.COM_TELNUM.TELNUM3_KEY     
AND KeyTRACBPTelephoneNumberID.Phone_Key4 = dbo.COM_TELNUM.TELNUM4_KEY     
AND KeyTRACBPTelephoneNumberID.Phone_Key5 = dbo.COM_TELNUM.TELNUM5_KEY     
INNER JOIN KeyTRACBusinessPartyID    
ON KeyTRACBusinessPartyID.SourceSystemKey1 = dbo.COM_TELNUM.PARTY1_KEY          
AND KeyTRACBusinessPartyID.SourceSystemKey2 = dbo.COM_TELNUM.PARTY2_KEY         
AND KeyTRACBusinessPartyID.SourceSystemKey3 = dbo.COM_TELNUM.PARTY3_KEY         
AND KeyTRACBusinessPartyID.SourceSystemKey4 = dbo.COM_TELNUM.PARTY4_KEY         
 INNER JOIN dbo.GenIDSPMaintenanceSystemAttributeName          
 ON dbo.COM_TELNUM.MNTC_SYS_ATTR_SRC_TEXT = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystem          
 AND dbo.COM_TELNUM.MNTC_SYS_ATTR1_KEY = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystemKey1          
 AND dbo.COM_TELNUM.MNTC_SYS_ATTR2_KEY = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystemKey2          
 AND dbo.COM_TELNUM.MNTC_SYS_ATTR3_KEY = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystemKey3    
 AND dbo.COM_TELNUM.MNTC_SYS_ATTR4_KEY = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystemKey4    
WHERE dbo.COM_TELNUM.RECORD_TYPE_DESC = 'TRAC';          
          
SET NOCOUNT OFF          
SET XACT_ABORT OFF          
RETURN
GO
