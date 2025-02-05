USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_ASSET_TRNSCTN_temp]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_ASSET_TRNSCTN_temp] AS                  
                                        
DECLARE @JobID INT;                                          
DECLARE @TempTime DateTime;                                          
                                          
SET @JobID = (SELECT MAX(JobID)                                        
              FROM MC_JobID                                        
              INNER JOIN MC_SourceFile                                        
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                                        
              WHERE logicalName = 'TracAssetTrnsctn'                                        
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                                        
                                       FROM MC_SysProcessedLog                                        
                                       WHERE SystemID = 49));                                        
SET @TempTime = GETDATE();                   
          
--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GROUP_TRACTransactionDetail]') AND type in (N'U'))            
--BEGIN            
--DROP TABLE [dbo].[GROUP_TRACTransactionDetail]            
--END            
    
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COR_ASSET_TRNSCTN_TAX_YR]') AND type in (N'U'))            
BEGIN            
DROP TABLE [dbo].[COR_ASSET_TRNSCTN_TAX_YR]    
END    
            
create TABLE Core1.dbo.[COR_ASSET_TRNSCTN_TAX_YR](    
 [AGREEMENT_ID] [numeric](12, 0) NOT NULL,    
 [ACCOUNTING_DATE] [datetime] NOT NULL,    
 [TRANSACTION_ID] [numeric](12, 0) NOT NULL,    
 [DATETIMESTAMP] [datetime] NULL,    
 [JOB_ID] [numeric](18, 0) NULL,    
 [RELATED_AGREEMENT_ID] [numeric](12, 0) NULL,    
 [TRANSACTION_STATUS_CODE] [varchar](12) NULL,    
 [TRANSACTION_TYPE_CODE] [varchar](12) NULL,    
 [SUBTYPE_CODE] [varchar](12) NULL,    
 [GAIN_OR_LOSS_REASON_CODE] [varchar](12) NULL,    
 [TRANSACTION_REASON_CODE] [varchar](12) NULL,    
 [AUTO_MAIL_CONFIRMATION] [char](1) NULL,    
 [WIRE_TRANSFER] [char](1) NULL,    
 [EFT] [char](1) NULL,    
 [AUTO_TRAN_TYPE_CODE] [varchar](12) NULL,    
 [MAINTENANCE_SYSTEM_KEY] [varchar](60) NULL,    
 [PRE_87_AMOUNT] [decimal](18, 6) NULL,    
 [POST_88_AMOUNT] [decimal](18, 6) NULL,    
 [THE_88_AMOUNT] [decimal](18, 6) NULL,    
 [PRE_82_AMOUNT] [decimal](18, 6) NULL,    
 [COST_BASIS_AMOUNT] [decimal](18, 6) NULL,    
 [ACCUMULATED_DIVIDENDS] [decimal](18, 6) NULL,    
 [TRANSACTION_DATE] [datetime] NULL,    
 [RECEIVED_DATE] [datetime] NULL,    
 [ENTRY_DATE] [datetime] NULL,    
 [REVERSAL_DATE] [datetime] NULL,    
 [TOTAL_AMOUNT] [decimal](18, 6) NULL,    
 [CURR_TAX_YEAR] [numeric](4, 0) NULL,    
 [TAXABLE_AMOUNT] [decimal](18, 6) NULL,    
 [COMMISSIONABLE_AMOUNT] [decimal](18, 6) NULL,    
 [DEST_COMPANY_FOR_DISB] [varchar](40) NULL,    
 [DEST_PRODUCT_FOR_DISB] [varchar](40) NULL,    
 [GAIN_OR_LOSS_AMOUNT] [decimal](18, 6) NULL,    
 [CHECK_NUMBER] [numeric](15, 0) NULL,    
 [DISCOUNT_CATEGORY] [varchar](40) NULL,    
 [NSCC_ORDER_NUMBER] [numeric](9, 0) NULL,    
 [FRAGMENTED_TRANSACTION] [char](1) NULL,    
 [SBG_OPERATOR_CODE] [varchar](10) NULL,    
 [CURR_CONTRIBUTION_AMT] [decimal](18, 6) NULL,    
 [PREV_TAX_YEAR] [numeric](4, 0) NULL,    
 [PREV_CONTRIBUTION_AMT] [decimal](18, 6) NULL,    
 [REC_INSRT_DATE] [datetime] NULL,    
 [REC_INSRT_NAME] [varchar](60) NULL,    
 [REC_UPDT_DATE] [datetime] NULL,    
 [REC_UPDT_NAME] [varchar](60) NULL,    
 [ORIGINAL_SOURCE_TRAN_TYPE] [varchar](30) NULL,    
 [ORIGINAL_SOURCE_SUBTYPE] [varchar](30) NULL,    
 [ORIGINAL_SOURCE_TRAN_REASON] [varchar](30) NULL,    
 [ACCSS_RSTRCT_ID] [numeric](12, 0) NULL,    
 [NET_RISK_AMT] [numeric](18, 6) NULL,    
 [SURR_CHG_WAIVE_IND] [numeric](1, 0) NULL,    
 [INCMNG_XFER_ID] [numeric](12, 0) NULL,    
 [MEC_DATE] [datetime] NULL,    
 [SPPRSS_COMM_IND] [numeric](1, 0) NULL,    
 [ORIGINAL_TRANSACTION_ID] [numeric](12, 0) NULL,    
 [CURR_TAX_YEAR_IND] BIT,      
 [PREV_TAX_YEAR_IND] BIT,      
 [ADU] [char](1) NULL)    
    
--SELECT Agreement_Sys_Attr_Key1_Text,              
--Agreement_Sys_Attr_Key2_Text,              
--Agreement_Sys_Attr_Key3_Text,              
--Agreement_Sys_Attr_Key4_Text,              
--Transaction_Sys_Attr_Key1_Text,              
--Transaction_Sys_Attr_Key2_Text,              
--Transaction_Sys_Attr_Key3_Text,              
--Transaction_Sys_Attr_Key4_Text,              
--Transaction_Sys_Attr_Key5_Text,              
--Transaction_Sys_Attr_Key6_Text,              
--Transaction_Sys_Attr_Key7_Text,              
--Transaction_Sys_Attr_Key8_Text,              
--Transaction_Sys_Attr_Key9_Text,              
--ACCOUNTING_DATE,              
--SUM(TEMP.AMOUNT) TOTAL_AMOUNT              
--INTO              
--DBO.GROUP_TRACTransactionDetail          
--FROM TRACTransactionDetail TEMP              
--GROUP BY Agreement_Sys_Attr_Key1_Text,              
--Agreement_Sys_Attr_Key2_Text,              
--Agreement_Sys_Attr_Key3_Text,              
--Agreement_Sys_Attr_Key4_Text,              
--Transaction_Sys_Attr_Key1_Text,              
--Transaction_Sys_Attr_Key2_Text,              
--Transaction_Sys_Attr_Key3_Text,              
--Transaction_Sys_Attr_Key4_Text,              
--Transaction_Sys_Attr_Key5_Text,              
--Transaction_Sys_Attr_Key6_Text,              
--Transaction_Sys_Attr_Key7_Text,              
--Transaction_Sys_Attr_Key8_Text,              
--Transaction_Sys_Attr_Key9_Text,              
--ACCOUNTING_DATE              
    
INSERT INTO Core1.dbo.[COR_ASSET_TRNSCTN_TAX_YR]    
(                                        
AGREEMENT_ID,  
ACCOUNTING_DATE,  
TRANSACTION_ID,  
DATETIMESTAMP,  
JOB_ID,  
TRANSACTION_STATUS_CODE,  
TRANSACTION_TYPE_CODE,  
SUBTYPE_CODE,  
TRANSACTION_REASON_CODE,  
AUTO_MAIL_CONFIRMATION,  
MAINTENANCE_SYSTEM_KEY,  
PRE_87_AMOUNT,  
POST_88_AMOUNT,  
THE_88_AMOUNT,  
COST_BASIS_AMOUNT,  
ACCUMULATED_DIVIDENDS,  
TRANSACTION_DATE,  
RECEIVED_DATE,  
ENTRY_DATE,  
REVERSAL_DATE,  
TOTAL_AMOUNT,  
CURR_TAX_YEAR,  
PREV_TAX_YEAR,  
CURR_CONTRIBUTION_AMT,  
PREV_CONTRIBUTION_AMT,  
TAXABLE_AMOUNT,  
GAIN_OR_LOSS_AMOUNT,  
FRAGMENTED_TRANSACTION,  
SBG_OPERATOR_CODE,  
ORIGINAL_SOURCE_TRAN_TYPE,  
ORIGINAL_SOURCE_SUBTYPE,  
ORIGINAL_SOURCE_TRAN_REASON,  
ACCSS_RSTRCT_ID,  
REC_INSRT_DATE,  
REC_INSRT_NAME,  
REC_UPDT_DATE,            
AUTO_TRAN_TYPE_CODE,     
CURR_TAX_YEAR_IND,    
PREV_TAX_YEAR_IND,    
ADU                       
)                                        
SELECT   GenIDFAAgreement.AgreementID     AS AGREEMENT_ID,  
TRACTransactionDetail.ACCOUNTING_DATE           AS ACCOUNTING_DATE,   
GenIDIATransaction.TransactionID    AS TRANSACTION_ID,    
@TempTime          AS DATETIMESTAMP,    
@JobID           AS JOB_ID,    
TRACTransactionDetail.TRANSACTION_STATUS_CODE   As TRANSACTION_STATUS_CODE,                          
TRACTransactionDetail.DETAIL_TYPE_CODE   AS TRANSACTION_TYPE_CODE,                        
TRACTransactionDetail.DETAIL_TYPE_CODE   AS SUBTYPE_CODE,                        
TRACTransactionDetail.DETAIL_TYPE_CODE   As TRANSACTION_REASON_CODE,   
''            AS AUTO_MAIL_CONFIRMATION,  
TRACTransactionDetail.Transaction_Sys_Attr_Key1_Text  +      '+' +        
TRACTransactionDetail.Transaction_Sys_Attr_Key2_Text  +      '+' +             
TRACTransactionDetail.Transaction_Sys_Attr_Key3_Text  +     '+' +              
TRACTransactionDetail.Transaction_Sys_Attr_Key4_Text  +      '+' +             
TRACTransactionDetail.Transaction_Sys_Attr_Key5_Text  +      '+' +             
TRACTransactionDetail.Transaction_Sys_Attr_Key6_Text  AS MAINTENANCE_SYSTEM_KEY,  
0            AS PRE_87_AMOUNT,  
0            AS POST_88_AMOUNT,              
0            AS THE_88_AMOUNT,  
0            AS COST_BASIS_AMOUNT,  
0            AS ACCUMULATED_DIVIDENDS,  
TRACTransactionDetail.TRANSACTION_DATE          AS TRANSACTION_DATE,    
TRACTransactionDetail.ACCOUNTING_DATE   AS RECEIVED_DATE,  
TRACTransactionDetail.ENTRY_DATE    AS ENTRY_DATE,   
TRACTransactionDetail.REVERSAL_DATE    AS REVERSAL_DATE,  
--TA.TOTAL_AMOUNT         AS TOTAL_AMOUNT,    
AMOUNT   AS TOTAL_AMOUNT,    
NULL           AS CURR_TAX_YEAR,  
NULL           AS PREV_TAX_YEAR,      
NULL            AS CURR_CONTRIBUTION_AMT,  
NULL           AS PREV_CONTRIBUTION_AMT,  
0            AS TAXABLE_AMOUNT,  
0            AS GAIN_OR_LOSS_AMOUNT,  
'Y'            AS FRAGMENTED_TRANSACTION,   
''            AS SBG_OPERATOR_CODE,  
TRACTransactionDetail.TRANSACTION_STATUS_CODE   As ORIGINAL_SOURCE_TRAN_TYPE,                        
'^'            AS ORIGINAL_SOURCE_SUBTYPE,                        
--isnull(convert(varchar(12),TRACTransactionDetail.DETAIL_TYPE_CODE),'N/A')As ORIGINAL_SOURCE_TRAN_REASON,  
TRACTransactionDetail.DETAIL_TYPE_CODE   As ORIGINAL_SOURCE_TRAN_REASON,  
DBO.TRAC_ACCESS_RESTRICTION(Accss_rstrct_id)    AS ACCSS_RSTRCT_ID,  
@TempTime          AS REC_INSRT_DATE,  
'417'           AS REC_INSRT_NAME,  
@TempTime          AS REC_UPDT_DATE,            
'N/A'           AS AUTO_TRAN_TYPE_CODE,    
CASE WHEN YEAR(ROSTER_PAYROLL_DTE) = YEAR(TRACTransactionDetail.ACCOUNTING_DATE) THEN 1     
WHEN YEAR(ROSTER_PAYROLL_DTE) = '0000' THEN 1    
ELSE 0 END AS CURR_TAX_YEAR_IND,    
CASE WHEN YEAR(ROSTER_PAYROLL_DTE) <> YEAR(TRACTransactionDetail.ACCOUNTING_DATE) AND YEAR(ROSTER_PAYROLL_DTE) <> '0000' THEN 1    
ELSE 0 END AS PREV_TAX_YEAR_IND,    
'A'            AS ADU                 
FROM TRACTransactionDetail_Temp TRACTransactionDetail    
INNER JOIN GenIDIATransaction                                      
 ON  TRACTransactionDetail.MNTC_SYS_CODE = GenIDIATransaction.SourceSystem                  
 AND TRACTransactionDetail.Transaction_Sys_Attr_Key1_Text = GenIDIATransaction.SourceSystemKey1                                        
 AND TRACTransactionDetail.Transaction_Sys_Attr_Key2_Text = GenIDIATransaction.SourceSystemKey2                                        
 AND TRACTransactionDetail.Transaction_Sys_Attr_Key3_Text = GenIDIATransaction.SourceSystemKey3                                        
 AND TRACTransactionDetail.Transaction_Sys_Attr_Key4_Text = GenIDIATransaction.SourceSystemKey4                                        
 AND TRACTransactionDetail.Transaction_Sys_Attr_Key5_Text = GenIDIATransaction.SourceSystemKey5                           
 AND TRACTransactionDetail.Transaction_Sys_Attr_Key6_Text = GenIDIATransaction.SourceSystemKey6                                        
 AND TRACTransactionDetail.Transaction_Sys_Attr_Key7_Text = GenIDIATransaction.SourceSystemKey7                                        
 AND TRACTransactionDetail.Transaction_Sys_Attr_Key8_Text = GenIDIATransaction.SourceSystemKey8                              
 AND TRACTransactionDetail.Transaction_Sys_Attr_Key9_Text = GenIDIATransaction.SourceSystemKey9                              
INNER JOIN GenIDFAAgreement                  
 ON  TRACTransactionDetail.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                  
 AND TRACTransactionDetail.Agreement_Sys_Attr_Key1_Text = GenIDFAAgreement.SourceSystemKey1                  
 AND TRACTransactionDetail.Agreement_Sys_Attr_Key2_Text = GenIDFAAgreement.SourceSystemKey2                  
 AND TRACTransactionDetail.Agreement_Sys_Attr_Key3_Text = GenIDFAAgreement.SourceSystemKey3                  
--Inner join GROUP_TRACTransactionDetail TA              
-- ON  TRACTransactionDetail.MNTC_SYS_CODE = GenIDIATransaction.SourceSystem                  
-- AND TRACTransactionDetail.Transaction_Sys_Attr_Key1_Text = TA.Transaction_Sys_Attr_Key1_Text                                        
-- AND TRACTransactionDetail.Transaction_Sys_Attr_Key2_Text = TA.Transaction_Sys_Attr_Key2_Text                                        
-- AND TRACTransactionDetail.Transaction_Sys_Attr_Key3_Text = TA.Transaction_Sys_Attr_Key3_Text                                        
-- AND TRACTransactionDetail.Transaction_Sys_Attr_Key4_Text = TA.Transaction_Sys_Attr_Key4_Text                                        
-- AND TRACTransactionDetail.Transaction_Sys_Attr_Key5_Text = TA.Transaction_Sys_Attr_Key5_Text                           
-- AND TRACTransactionDetail.Transaction_Sys_Attr_Key6_Text = TA.Transaction_Sys_Attr_Key6_Text                                        
-- AND TRACTransactionDetail.Transaction_Sys_Attr_Key7_Text = TA.Transaction_Sys_Attr_Key7_Text                                        
-- AND TRACTransactionDetail.Transaction_Sys_Attr_Key8_Text = TA.Transaction_Sys_Attr_Key8_Text                              
-- AND TRACTransactionDetail.Transaction_Sys_Attr_Key9_Text = TA.Transaction_Sys_Attr_Key9_Text                              
-- AND TRACTransactionDetail.Agreement_Sys_Attr_Key1_Text = TA.Agreement_Sys_Attr_Key1_Text                  
-- AND TRACTransactionDetail.Agreement_Sys_Attr_Key2_Text = TA.Agreement_Sys_Attr_Key2_Text                  
-- AND TRACTransactionDetail.Agreement_Sys_Attr_Key3_Text = TA.Agreement_Sys_Attr_Key3_Text               
-- AND TRACTransactionDetail.ACCOUNTING_DATE = TA.ACCOUNTING_DATE               
WHERE  GenIDIATransaction.SourceSystem = 'TRAC'        
AND  TRACTransactionDetail.DETAIL_TYPE_CODE = TRACTransactionDetail.ParentReasonCode       
    
SELECT  TRANSACTION_ID, TOTALAMOUNT = SUM(TOTAL_AMOUNT)      
INTO  #SUMAMOUNT    
FROM  [COR_ASSET_TRNSCTN_TAX_YR]      
--WHERE   TRANSACTION_TYPE_CODE NOT IN (SelecT Sourcevalue from PRM_DomainSource where SystemID = 49 and Domaintablename  = 'DOM_DTL_TYPE'  
--AND Domaincode  IN ('FED WTHLD','ST WTHLD'))     
GROUP BY  TRANSACTION_ID      
    
SELECT  TRANSACTION_ID, CURR_CONTRIBUTION_AMT = SUM(TOTAL_AMOUNT)      
INTO  #SUMCURRAMOUNT      
FROM  [COR_ASSET_TRNSCTN_TAX_YR]      
WHERE 
--  TRANSACTION_TYPE_CODE NOT IN (SelecT Sourcevalue from PRM_DomainSource where SystemID = 49 and Domaintablename  = 'DOM_DTL_TYPE'  
--AND Domaincode  IN ('FED WTHLD','ST WTHLD'))              AND 
CURR_TAX_YEAR_IND = 1      
GROUP BY  TRANSACTION_ID       
    
SELECT  TRANSACTION_ID, PREV_CONTRIBUTION_AMT = SUM(TOTAL_AMOUNT)      
INTO  #SUMPREVAMOUNT    
FROM  [COR_ASSET_TRNSCTN_TAX_YR]      
WHERE 
--  TRANSACTION_TYPE_CODE NOT IN (SelecT Sourcevalue from PRM_DomainSource where SystemID = 49 and Domaintablename  = 'DOM_DTL_TYPE'  
--AND Domaincode  IN ('FED WTHLD','ST WTHLD'))              AND 
PREV_TAX_YEAR_IND = 1      
GROUP BY  TRANSACTION_ID       
    
UPDATE  A      
SET  TOTAL_AMOUNT = B.TOTALAMOUNT,      
        CURR_CONTRIBUTION_AMT = C.CURR_CONTRIBUTION_AMT,      
        PREV_CONTRIBUTION_AMT = D.PREV_CONTRIBUTION_AMT,      
        CURR_TAX_YEAR = CASE WHEN C.CURR_CONTRIBUTION_AMT IS NOT NULL THEN YEAR(A.TRANSACTION_DATE) ELSE NULL END,      
        PREV_TAX_YEAR = CASE WHEN D.PREV_CONTRIBUTION_AMT IS NOT NULL THEN YEAR(A.TRANSACTION_DATE)-1 ELSE NULL END      
FROM Core1.dbo.[COR_ASSET_TRNSCTN_TAX_YR] A      
 INNER JOIN  #SUMAMOUNT B ON  A.TRANSACTION_ID = B.TRANSACTION_ID      
    LEFT OUTER JOIN #SUMCURRAMOUNT C ON  A.TRANSACTION_ID = C.TRANSACTION_ID      
    LEFT OUTER JOIN #SUMPREVAMOUNT D ON  A.TRANSACTION_ID = D.TRANSACTION_ID      
             
Insert into COREETL.dbo.[COR_ASSET_TRNSCTN](AGREEMENT_ID,ACCOUNTING_DATE,TRANSACTION_ID,DATETIMESTAMP,JOB_ID,TRANSACTION_STATUS_CODE,TRANSACTION_TYPE_CODE,SUBTYPE_CODE,  
TRANSACTION_REASON_CODE,AUTO_MAIL_CONFIRMATION,MAINTENANCE_SYSTEM_KEY,PRE_87_AMOUNT,POST_88_AMOUNT,THE_88_AMOUNT,COST_BASIS_AMOUNT,ACCUMULATED_DIVIDENDS,TRANSACTION_DATE,  
RECEIVED_DATE,ENTRY_DATE,REVERSAL_DATE,TOTAL_AMOUNT,CURR_TAX_YEAR,PREV_TAX_YEAR,CURR_CONTRIBUTION_AMT,PREV_CONTRIBUTION_AMT,TAXABLE_AMOUNT,GAIN_OR_LOSS_AMOUNT,  
FRAGMENTED_TRANSACTION,SBG_OPERATOR_CODE,ORIGINAL_SOURCE_TRAN_TYPE,ORIGINAL_SOURCE_SUBTYPE,ORIGINAL_SOURCE_TRAN_REASON,ACCSS_RSTRCT_ID,REC_INSRT_DATE,REC_INSRT_NAME,  
REC_UPDT_DATE,AUTO_TRAN_TYPE_CODE,ADU)  
Select Distinct AGREEMENT_ID,  
ACCOUNTING_DATE,  
TRANSACTION_ID,  
DATETIMESTAMP,  
JOB_ID,  
TRANSACTION_STATUS_CODE,  
TRANSACTION_TYPE_CODE,  
SUBTYPE_CODE,  
TRANSACTION_REASON_CODE,  
AUTO_MAIL_CONFIRMATION,  
MAINTENANCE_SYSTEM_KEY,  
PRE_87_AMOUNT,  
POST_88_AMOUNT,  
THE_88_AMOUNT,  
COST_BASIS_AMOUNT,  
ACCUMULATED_DIVIDENDS,  
TRANSACTION_DATE,  
RECEIVED_DATE,  
ENTRY_DATE,  
REVERSAL_DATE,  
TOTAL_AMOUNT,  
CURR_TAX_YEAR,  
PREV_TAX_YEAR,  
CURR_CONTRIBUTION_AMT,  
PREV_CONTRIBUTION_AMT,  
TAXABLE_AMOUNT,  
GAIN_OR_LOSS_AMOUNT,  
FRAGMENTED_TRANSACTION,  
SBG_OPERATOR_CODE,  
ORIGINAL_SOURCE_TRAN_TYPE,  
ORIGINAL_SOURCE_SUBTYPE,  
ORIGINAL_SOURCE_TRAN_REASON,  
ACCSS_RSTRCT_ID,  
REC_INSRT_DATE,  
REC_INSRT_NAME,  
REC_UPDT_DATE,            
AUTO_TRAN_TYPE_CODE,  
ADU      
from Core1.dbo.[COR_ASSET_TRNSCTN_TAX_YR]  
  
--DROP TABLE DBO.GROUP_TRACTransactionDetail              
SET QUOTED_IDENTIFIER OFF
GO
