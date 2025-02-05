USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Truncates_Stage_Tables]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Proc_TRAC_Truncates_Stage_Tables]                          
as                          
----------------------------------------------------------------             
          
-- Below block is specially added for Omni_To_TRAC_Funds table          
--Truncate table dbo.Omni_To_TRAC_Funds           
--Truncate table dbo.COM_Omni_To_TRAC_Funds           
--Truncate table COREETL.dbo.Omni_To_TRAC_Funds           
          
----------------------------------------------------------------           
--Truncate table Jana                  
Truncate table TRACAgreement   --01                        
Truncate table TRACAgreementParty  --02                        
Truncate table TRACAssetTransaction  --03                        
Truncate table TRACAutoTransaction  --04                        
Truncate table TRACBusParty    --05                        
Truncate table TRACBusPartyElecAddr  --06                        
Truncate table TRACBusPartyPstlAddr  --07                        
Truncate table TRACBusPartyPhone  --08             
          
                        
Truncate table TRACLoan     --10                        
Truncate table TRACPlan     --11                        
Truncate table TRACPlanAlloctn   --12                        
Truncate table TRACPlanSrc    --13                        
Truncate table TRACTransactionDetail --14                        
Truncate table TRACLoanFundDetail  --15                      
Truncate Table TRACLoanAssetRecord  --16                  
Truncate table TRAC_Core_Extract_Range --17                 
Truncate table TRACFundDetail  --18                
--Truncate table TRACAssetSourceDetail --19               
Truncate table TRACAssetSourceDetailVariable            
Truncate table TRACAssetSourceDetailFixed            
Truncate table TRACAssetSourceDetailExternal
Truncate table TRACAssetSourceDetailVariable_Plan
Truncate table TRACAssetSourceDetailFixed_Plan          
          
TRUNCATE TABLE TRACIntRatePlan          
TRUNCATE TABLe TRACPlanAuthorization          
             
--Truncate table TRACContributionDetail --20                
--TRUNCATE TABLE TRACPlanNote                
Truncate Table TRACAgreementAuthorization              
Truncate table TRACFUNDS              
Truncate table TRACSrcFundPrice            
Truncate Table TRACAgreementPartyPhone            
Truncate Table TRACAgreementPartyPostalAddress            
Truncate Table TRACAgrmntPartyElectronicAddress           
Truncate Table TRACInvstrAssetDrvdValue        
Truncate Table TRACAgreementPartyAuthorization        
TRUNCATE TABLE Core1.dbo.TRACInvstrAssetDrvdValue_DeathBenefit         
      
TRUNCATE TABLE Core1.dbo.TRACEFT        
               
Truncate table dbo.TempIDIATransaction                      
Truncate table dbo.TempIDFAAgreement                      
Truncate table dbo.TempIDFALoan                      
Truncate table TempIDBPAgreementParty            
Truncate table TempIDFAAgreementAuthorization            
Truncate table TempIDBPBusinessParty            
Truncate table TempIDFAAutoTran        
TRUNCATE TABLE TempIDFAEFT    
                      
DELETE FROM COM_BUS_PARTY WHERE MNTC_SYSTEM_CODE = 'TRAC'                        
DELETE FROM COM_POSTAL_ADDR WHERE MNTC_SYSTEM_CODE = 'TRAC'                        
DELETE FROM COM_TELNUM WHERE MNTC_SYSTEM_CODE = 'TRAC'                        
DELETE FROM COM_ELCTRNC_ADDR WHERE MNTC_SYSTEM_CODE = 'TRAC'                   
DELETE FROM COM_X_AGRMNT_PARTY WHERE MNTC_SYSTEM_CODE = 'TRAC'             
DELETE FROM COM_SRC_FUND_PRICE WHERE MNTC_SYSTEM_CODE = 'TRAC'        
DELETE FROM COM_AGRMNT_PARTY_ATHRZTN WHERE MNTC_SYSTEM_CODE = 'TRAC'  
  
  
Truncate Table Core1.dbo.TRACAgreementAuthorization_Delete  
Truncate Table Core1.dbo.TRACAgreementDelete  
Truncate Table Core1.dbo.TRACPlanDelete  
Truncate Table Core1.dbo.TRACLoanDelete

Truncate Table Core1.dbo.TRACAGREEMENTPARTY_PURGE


           
----------------------------------------------------------------            
-- Below block is specially added for Future Allocation table             
               
/*TRUNCATE TABLE TRACFutureAlloctn_Yesterday            
INSERT INTO TRACFutureAlloctn_Yesterday            
Select * from TRACFutureAlloctn            
TRUNCATE Table TRACFutureAlloctn_Delete            
TRUNCATE Table TRACFutureAlloctn_Delta                  
Truncate table TRACFutureAlloctn  --09    
*/

      
--The below set of changes has been implemented on 05-20-2015 as per instruction from Francis. Please refer mail for more information


DROP TABLE CORE1.DBO.TRACFUTUREALLOCTN_YESTERDAY

EXEC sp_rename 'TRACFutureAlloctn', 'TRACFutureAlloctn_Yesterday'

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TRACFutureAlloctn]') AND type in (N'U'))
BEGIN
DROP TABLE [dbo].[TRACFutureAlloctn]
END

SELECT * INTO CORE1.DBO.TRACFutureAlloctn FROM Core1.DBO.TRACFutureAlloctn_Yesterday WHERE 1=2

TRUNCATE Table TRACFutureAlloctn_Delete            
TRUNCATE Table TRACFutureAlloctn_Delta                  

---------------------End of the block---------------------------   







GO
