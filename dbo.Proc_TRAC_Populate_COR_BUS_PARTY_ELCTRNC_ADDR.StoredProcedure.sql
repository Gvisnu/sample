USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_BUS_PARTY_ELCTRNC_ADDR]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_BUS_PARTY_ELCTRNC_ADDR] AS      
set nocount on      
set XACT_ABORT on      
DECLARE @JobID INT;      
-- Get the Job Id,      
      
SET @JobID = (SELECT isnull(MAX(JobID),0)      
              FROM MC_JobID      
              INNER JOIN MC_SourceFile      
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID      
              WHERE logicalName = 'TRACBusPartyElectronicAddress'      
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)      
                                       FROM MC_SysProcessedLog      
                                       WHERE SystemID = 49));      
      
INSERT INTO  CoreETL.dbo.COR_BUS_PARTY_ELCTRNC_ADDR(      
 BUS_PARTY_ELCTRNC_ADDR_ID,      
 BUS_PARTY_ID,      
 ELCTRNC_ADDR_TYPE_CODE,      
 JOB_ID,      
 DATETIMESTAMP,      
 ELCTRNC_ADDR,      
 ELCTRNC_ADDR_FROM_DATE,      
 ELCTRNC_ADDR_THRU_DATE,      
 CNTCT_RSTRCT_IND,      
 MNTC_SYS_CODE,      
 MNTC_SYS_ATTR_ID ,      
 MNTC_SYS_ATTR_KEY1_TEXT ,      
 MNTC_SYS_ATTR_KEY2_TEXT ,      
 MNTC_SYS_ATTR_KEY3_TEXT ,      
 MNTC_SYS_ATTR_KEY4_TEXT ,      
 REC_INSRT_NAME,      
 REC_FROM_DATE,      
 ADU      
 )      
SELECT dbo.KeyTRACBPElectronicAddressID.BusinessPartyElectronicAddressID,       
 --dbo.KeyTRACBusinessPartyID.BusinessPartyID,  
 NULL as BusinessPartyID,     
 dbo.COM_ELCTRNC_ADDR.ELCTRNC_ADDR_TYPE_CODE,      
 @JobID AS JobID,      
 GETDATE() AS DateTimeStamp,       
 dbo.COM_ELCTRNC_ADDR.ELCTRNC_ADDR,       
 dbo.COM_ELCTRNC_ADDR.ELCTRNC_ADDR_FROM_DATE,      
 dbo.COM_ELCTRNC_ADDR.ELCTRNC_ADDR_THRU_DATE,       
 dbo.COM_ELCTRNC_ADDR.CONTACT_RESTRICTED_IND,      
 dbo.COM_ELCTRNC_ADDR.ELCTRNC_ADDR_SRC_TEXT,       
 dbo.GenIDSPMaintenanceSystemAttributeName.MaintenanceSYstemAttributeID,      
 dbo.COM_ELCTRNC_ADDR.ELCTRNC_ADDR1_KEY,       
 'N/A' AS ELCTRNC_ADDR2_KEY,       
 'N/A' AS ELCTRNC_ADDR3_KEY,       
 'N/A' AS ELCTRNC_ADDR4_KEY,       
 '339' AS REC_INSRT_NAME,       
  GETDATE() AS REC_FROM_DATE,      
 dbo.COM_ELCTRNC_ADDR.ADU      
FROM dbo.KeyTRACBPElectronicAddressID 
INNER JOIN dbo.COM_ELCTRNC_ADDR ON dbo.KeyTRACBPElectronicAddressID.Payor_Key = dbo.COM_ELCTRNC_ADDR.PAYOR_KEY      
--INNER JOIN dbo.KeyTRACBusinessPartyID ON dbo.KeyTRACBusinessPartyID.Payor_Key = dbo.COM_ELCTRNC_ADDR.PAYOR_KEY      
 INNER JOIN dbo.GenIDSPMaintenanceSystemAttributeName      
 ON dbo.COM_ELCTRNC_ADDR.MNTC_SYS_ATTR_SRC_TEXT = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystem      
 AND dbo.COM_ELCTRNC_ADDR.MNTC_SYS_ATTR1_KEY = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystemKey1      
 AND dbo.COM_ELCTRNC_ADDR.MNTC_SYS_ATTR2_KEY = dbo.GenIDSPMaintenanceSystemAttributeName.SourceSystemKey2      
WHERE dbo.COM_ELCTRNC_ADDR.RECORD_TYPE_DESC = 'TRAC';      
set nocount off      
set XACT_ABORT off      
      
RETURN
GO
