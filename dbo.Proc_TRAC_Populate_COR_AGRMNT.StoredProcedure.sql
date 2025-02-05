USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_AGRMNT]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Proc_TRAC_Populate_COR_AGRMNT]              
AS              
DECLARE @JobID INT;              
DECLARE @TempTime DateTime;              
              
SET @JobID = (SELECT MAX(JobID)              
FROM MC_JobID              
INNER JOIN MC_SourceFile              
ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID              
WHERE logicalName = 'TracAgreement'              
AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)              
 FROM MC_SysProcessedLog              
 WHERE SystemID = 49));              
SET @TempTime = GETDATE(); 

INSERT INTO CoreETL.dbo.COR_AGRMNT              
(              
 AGREEMENT_ID,              
 DATETIMESTAMP,              
 JOB_ID,              
 AGREEMENT_TYPE_CODE,              
 STATUS_CODE,              
 TAX_CATEGORY_CODE,              
 EMPLOYEE_AGREEMENT,              
 MARKET_SEGMENT_CODE,              
 STATE_ID,              
 EFFECTIVE_DATE,              
 TERMINATION_DATE,              
 ALLOCATED,              
 ANNUITY_COMMENCEMENT_DATE,              
 LIMITED_POWER_OF_ATTORNEY,              
-- STIPULATED_AMOUNT,          Commented on 12/05/2013 as the data is loading from Billing    
 PLAN_NUMBER,              
 ACCOUNT_NUMBER,              
 MNTC_SYSTEM_ENTRY_DATE,              
 REC_INSRT_NAME,              
 COMMISSION_OPTION_CODE,              
 SOURCE_PRODUCT_ID,              
 ISSUE_DATE,              
 FIRST_FUNDING_DATE,              
 QUALIFICATION_CODE,              
 ACCSS_RSTRCT_ID,              
 PLAN_ENTRY_DATE,        
 MNTC_SYS_CODE,        
 DST_SOCCD_NUM,    
 PLAN_ID, 
 TAX_CATEGORY_DESC,
 ADU)              
Select              
 AgreementID,              
 @TempTime,            
 @JobID,              
 CASE WHEN ISNULL(Agreement_Type,'')  = '' THEN 'UNK' ELSE Agreement_Type End,  
 Status   AS STATUS_CODE,              
 Tax_Category AS TAX_CATEGORY_CODE,              
 --EMPLOYEE_AGREEMENT = CASE Accss_rstrct_id WHEN'HO' THEN 'Y'     
 --          ELSE 'N'     
 --          END,      
EMPLOYEE_AGREEMENT = CASE WHEN DBO.TRAC_ACCESS_RESTRICTION(Accss_rstrct_id) = 1 THEN 'Y'     
           ELSE 'N'     
           END,        
 CASE WHEN Tax_Category <> 'NON-QUAL' THEN Tax_Category        
  ELSE Tax_Category + ' ' + SUBSTRING(product,1,2)              
  END AS MARKET_SEGMENT_CODE,                  
 CASE WHEN ISNULL(Stateid,'') = '' THEN 'UNK'      
   ELSE StateID     
   END AS STATE_ID,               
 CASE WHEN Effective_Date = '01-01-1900' THEN NULL              
  WHEN Effective_Date = '12-31-2999' THEN NULL              
  WHEN LTRIM(RTRIM(Effective_Date)) = '' THEN NULL              
  ELSE Effective_Date     
  END AS Effective_Date,               
 CASE WHEN Termination_Date = '01-01-1900' THEN NULL              
  WHEN Termination_Date = '12-31-2999' THEN NULL              
  WHEN LTRIM(RTRIM(TERMINATION_DATE)) = '' THEN NULL              
  ELSE Termination_Date     
  END AS TERMINATION_DATE,              
 CASE WHEN(SUBSTRING(stag.Agrmnt_sys_attr_key2_text,1, 1) IN ('G', ''))THEN 'N'              
  WHEN (SUBSTRING(stag.Agrmnt_sys_attr_key2_text,1, 1) = 'I') THEN 'Y'              
  ELSE 'N'     
  END AS ALLOCATED,              
 CASE WHEN Annuity_Commencement_Date = '00000000' THEN NULL    
  WHEN LTRIM(RTRIM(Annuity_Commencement_Date)) = '' THEN NULL     
  WHEN Annuity_Commencement_Date = '01-01-1900' THEN NULL              
  WHEN Annuity_Commencement_Date = '12-31-2999' THEN NULL     
  ELSE Annuity_Commencement_Date     
  End as Annuity_Commencement_Date ,              
 Limited_Power_of_Attorney,              
 --Stipulated_Amount,          Commented on 12/05/2013 as the data is loading from Billing    
 Agrmnt_sys_attr_key2_text AS PLAN_NUMBER,              
 --ACCOUNT_NUMBER,              
 -- added based on comments from francis on 09/19/2013      
 STUFF(ACCOUNT_NUMBER , 1, 0, REPLICATE('0', 9 - LEN(ACCOUNT_NUMBER))) as ACCOUNT_NUMBER,     
CASE WHEN System_Entry_Date = '01-01-1900' THEN NULL              
  WHEN System_Entry_Date = '12-31-2999' THEN NULL              
  WHEN LTRIM(RTRIM(System_Entry_Date)) = '' THEN NULL              
  ELSE System_Entry_Date     
  END AS System_Entry_Date,              
 '404' AS REC_INSRT_NAME,              
 Commission_Option AS COMMISSION_OPTION_CODE,              
 SrcPrdct.SourceProductID AS SOURCE_PRODUCT_ID,                      
CASE WHEN Issue_Date = '01-01-1900' THEN NULL              
  WHEN Issue_Date = '12-31-2999' THEN NULL 
  WHEN Issue_date = '0001-01-01' THEN NULL  --Included manually as per PROD - 06222015            
  WHEN LTRIM(RTRIM(Issue_Date)) = '' THEN NULL              
  ELSE Issue_Date     
  END AS Issue_Date,     
CASE WHEN First_Funding_Date = '01-01-1900' THEN NULL              
  WHEN First_Funding_Date = '12-31-2999' THEN NULL              
  WHEN LTRIM(RTRIM(First_Funding_Date)) = '' THEN NULL              
  ELSE First_Funding_Date     
  END AS First_Funding_Date,         
CASE WHEN Tax_Category = 'NON-QUAL'     
  THEN 'N'     
  ELSE 'Y' END AS QUALIFICATION_CODE,              
 DBO.TRAC_ACCESS_RESTRICTION(Accss_rstrct_id),              
 CASE WHEN PLAN_ENTRY_DATE = '01-01-1900' THEN NULL              
  WHEN PLAN_ENTRY_DATE = '12-31-2999' THEN NULL              
  WHEN LTRIM(RTRIM(PLAN_ENTRY_DATE)) = '' THEN NULL              
  ELSE PLAN_ENTRY_DATE     
  END AS PLAN_ENTRY_DATE,              
 Mntc_Sys_Code,        
 '000' AS DST_SOCCD_NUM,    
 PlanID AS PLAN_ID,    
 Tax_Category_Desc,
 'U'              
 FROM DBO.TRACAgreement stag              
 INNER JOIN GenIDFAAgreement Genid ON GenId.SourceSystem = stag.MNTC_SYS_CODE              
       AND GenId.SourceSystemKey1 = stag.Agrmnt_sys_attr_key1_text              
       AND GenId.SourceSystemKey2 = stag.Agrmnt_sys_attr_key2_text              
       AND GenId.SourceSystemKey3 = stag.Agrmnt_sys_attr_key3_text              
 INNER JOIN GenIDPRSourceProduct SrcPrdct ON SrcPrdct.SourceSystem = stag.MNTC_SYS_CODE              
           AND SrcPrdct.SourceSystemKey1 = stag.Product    
 INNER JOIN GenIDPLPlan ON stag.Agrmnt_sys_attr_key2_text = GenIDPLPlan.SourceSystemKey1       
      AND stag.Agrmnt_sys_attr_key1_text = GenIDPLPlan.SourceSystemKey2       
      AND stag.MNTC_SYS_CODE =GenIDPLPlan.SourceSystem  
GO
