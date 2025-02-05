USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_AGRMNT_PARTY_ELCTRNC_ADDR]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
            
            
CREATE  PROCEDURE [dbo].[Proc_TRAC_Populate_COR_AGRMNT_PARTY_ELCTRNC_ADDR] AS                  
set nocount on                  
set XACT_ABORT on                  
DECLARE @JobID INT;                  
-- Get the Job Id,                  
                  
SET @JobID = (SELECT isnull(MAX(JobID),0)                  
              FROM MC_JobID                  
              INNER JOIN MC_SourceFile                  
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                  
              WHERE logicalName = 'TRACAgrmntPartyElectronicAddress'    -- Logical name and Stage table name is different               
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                  
                                       FROM MC_SysProcessedLog                  
                                       WHERE SystemID = 49));                  
                  
INSERT INTO  CoreETL.dbo.COR_AGRMNT_PARTY_ELCTRNC_ADDR             
 (                  
  AGRMNT_PARTY_ELCTRNC_ADDR_ID,                  
  AGRMNT_PARTY_ID,                  
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
                  
SELECT DISTINCT B.AgreementPartyElectronicAddressID,                
c.AgreementPartyID,                 
 a.ELCTRNC_ADDR_TYPE_CODE,                  
 @JobID AS JobID,                  
 GETDATE() AS DateTimeStamp,                   
a.ELCTRNC_ADDR,                   
a.ELCTRNC_ADDR_FROM_DATE,                  
--a.ELCTRNC_ADDR_THRU_DATE,                   
'12-31-2999' ELCTRNC_ADDR_THRU_DATE,                   
a.CONTACT_RESTRICTED_IND,                  
a.ELCTRNC_ADDR_SRC_TEXT,                   
d.MaintenanceSystemAttributeID,                  
a.ELCTRNC_ADDR1_KEY,                   
A.ELCTRNC_ADDR2_KEY,                   
A.ELCTRNC_ADDR3_KEY,                   
A.ELCTRNC_ADDR6_KEY,                   
'433' AS REC_INSRT_NAME,                    
 GETDATE() AS REC_FROM_DATE,                  
'A' ADU                 
FROM COM_ELCTRNC_ADDR a              
INNER JOIN GenIDBPAgreementPartyElectronicAddress B            
ON A.ELCTRNC_ADDR_SRC_TEXT = B.SOURCESYSTEM            
AND ISNULL(A.ELCTRNC_ADDR1_KEY,'^') = B.SOURCESYSTEMKEY1            
AND ISNULL(A.ELCTRNC_ADDR2_KEY,'^') = B.SOURCESYSTEMKEY2            
AND ISNULL(A.ELCTRNC_ADDR3_KEY,'^') = B.SOURCESYSTEMKEY3            
AND ISNULL(A.ELCTRNC_ADDR4_KEY,'^') = B.SOURCESYSTEMKEY4      
INNER JOIN GENIDBPAGREEMENTPARTY C            
ON ISNULL(b.SourceSystem,'TRAC') = C.SOURCESYSTEM            
AND B.SourceSystemKey1 = C.SOURCESYSTEMKEY1            
AND B.SourceSystemKey2 = C.SOURCESYSTEMKEY2            
AND B.SourceSystemKey3 = C.SOURCESYSTEMKEY3       
AND B.SourceSystemKey5 = C.SOURCESYSTEMKEY5       
INNER JOIN GENIDSPMAINTENANCESYSTEMATTRIBUTENAME D            
ON A.MNTC_SYS_ATTR_SRC_TEXT = D.SOURCESYSTEM            
AND ISNULL(A.MNTC_SYS_ATTR1_KEY,'^') = D.SOURCESYSTEMKEY1            
AND ISNULL(A.MNTC_SYS_ATTR2_KEY,'^') = D.SOURCESYSTEMKEY2            
AND ISNULL(A.MNTC_SYS_ATTR3_KEY,'^') = D.SOURCESYSTEMKEY3            
AND ISNULL(A.MNTC_SYS_ATTR4_KEY,'^') = D.SOURCESYSTEMKEY4            
WHERE A.ELCTRNC_ADDR_ASSOC_TYPE_CODE = 'AGRMNT'            
AND A.MNTC_SYSTEM_CODE = 'TRAC'          
                  
set nocount off                  
set XACT_ABORT off                  
                  
RETURN
GO
