USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_LOAN]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_LOAN]          
AS          
DECLARE @JobID INT;          
DECLARE @TEMPTIME DateTime;          
      
SET @JobID = (SELECT isnull(MAX(JobID),0)      
              FROM MC_JobID      
              INNER JOIN MC_SourceFile      
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID      
              WHERE logicalName = 'TRACLoan'      
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)      
                                       FROM MC_SysProcessedLog      
                                       WHERE SystemID = 49));          
SET @TEMPTIME = GETDATE();          

INSERT INTO COREETL.dbo.COR_LOAN(     
 LOAN_ID,         
 AGREEMENT_ID,    
 LOAN_REPAYMENT_FREQUENCY_CODE,    
 LOAN_REASON_CODE,    
 LOAN_STATUS_CODE,    
 STATUS_AS_OF_DATE,    
 ORIGINAL_LOAN_AMOUNT,    
 LOAN_PERIOD,    
 SCHEDULED_REPAYMENT_AMOUNT,    
 NEXT_PAYMENT_DATE,    
 CREDIT_INTEREST_RATE,    
 DEBIT_INTEREST_RATE,    
 MAINTENANCE_SYSTEM_KEY,     
 DATETIMESTAMP,    
 JOB_ID,    
 REC_INSRT_DATE,    
 REC_INSRT_NAME,    
 LOAN_ISSUE_DATE,    
 LOAN_EST_PAYOFF_DATE,    
 ADU    
    )          
 SELECT      
 GenIDFALoan.LoanID       AS LOAN_ID,    
 GenIDFAAgreement.AgreementID    AS AGREEMNET_ID,    
 --IsNULL(LOAN_REPAYMENT_FREQUENCY_CODE,'UNK')AS LOAN_REPAYMENT_FREQUENCY_CODE,    
 CASE WHEN ISNULL(LOAN_REPAYMENT_FREQUENCY_CODE,'') = '' THEN 'UNK'    
   ELSE LOAN_REPAYMENT_FREQUENCY_CODE   
   END AS LOAN_REPAYMENT_FREQUENCY_CODE,   
 LOAN_REASON_CODE       AS LOAN_REASON_CODE,    
 --IsNULL(LOAN_STATUS_CODE,'UNK')    AS LOAN_STATUS_CODE,    
 CASE WHEN ISNULL(LOAN_STATUS_CODE,'') = '' THEN 'UNK'    
   ELSE LOAN_STATUS_CODE   
   END AS LOAN_STATUS_CODE,   
 @TEMPTIME         AS STATUS_AS_OF_DATE,    
 ORIGINAL_LOAN_AMT       AS ORIGINAL_LOAN_AMOUNT,     
 CASE WHEN Isnull(LTRIM(RTRIM(LOAN_PERIOD)),'')    = '' THEN 0 ELSE LTRIM(RTRIM(LOAN_PERIOD)) END   AS LOAN_PERIOD,
 SKED_LN_RPYMNT_AMT       AS SCHEDULED_REPAYMENT_AMOUNT,    
 NEXT_PAYMENT_DATE       AS NEXT_PAYMENT_DATE,    
 LOAN_ANNL_INT_RTE       AS CREDIT_INTEREST_RATE,    
 LOAN_ANNL_INT_RTE       AS DEBIT_INTEREST_RATE,    
 LOAN_SYS_ATTR_KEY1_TEXT+'+'+LOAN_SYS_ATTR_KEY2_TEXT+'+'+LOAN_SYS_ATTR_KEY3_TEXT+'+'+LOAN_SYS_ATTR_KEY4_TEXT AS MAINTENANCE_SYSTEM_KEY,    
 @TEMPTIME         AS DATETIMESTAMP,    
 @JobID          AS JOB_ID,    
 @TEMPTIME         AS REC_INSRT_DATE,    
 '413'          AS REC_INSRT_NAME,    
 LOAN_START_DATE       AS LOAN_ISSUE_DATE,    
 LOAN_EST_PAYOFF_DATE      AS LOAN_EST_PAYOFF_DATE,    
 ADU    
 FROM TRACLoan TL    
 INNER JOIN GenIDFALoan on GenIDFALoan.SourceSystemKey1 = TL.LOAN_SYS_ATTR_KEY1_TEXT    
      AND GenIDFALoan.SourceSystemKey2 = TL.LOAN_SYS_ATTR_KEY2_TEXT    
      AND GenIDFALoan.SourceSystemKey3 = TL.LOAN_SYS_ATTR_KEY3_TEXT    
      AND GenIDFALoan.SourceSystemKey4 = TL.LOAN_SYS_ATTR_KEY4_TEXT    
      AND GenIDFALoan.SourceSystem = TL.MNTC_SYS_CODE    
 INNER JOIN GenIDFAAgreement on GenIDFAAgreement.SourceSystemKey1 = TL.AGRMNT_SYS_ATTR_KEY1_TEXT    
       AND GenIDFAAgreement.SourceSystemKey2 = TL.AGRMNT_SYS_ATTR_KEY2_TEXT    
       AND GenIDFAAgreement.SourceSystemKey3 = TL.AGRMNT_SYS_ATTR_KEY3_TEXT    
       AND GenIDFAAgreement.SourceSystem = TL.MNTC_SYS_CODE              
 WHERE TL.MNTC_SYS_CODE = 'TRAC'    
            
RETURN  
GO
