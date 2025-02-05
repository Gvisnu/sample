USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_SRC_FUND_PRICE_OLD]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_SRC_FUND_PRICE_OLD] AS        
        
DECLARE @JobID INT;        
DECLARE @CurrDateTime DATETIME        
set nocount on        
        
SET @CurrDateTime = GETDATE()        
        
SET @JobID = (SELECT isnull(MAX(JobID),0)                    
              FROM MC_JobID                    
              INNER JOIN MC_SourceFile                    
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                    
              WHERE logicalName = 'TRACSrcFundPrice'                    
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                    
                                       FROM MC_SysProcessedLog                    
                                       WHERE SystemID = 49));       
----- Populate ETL table        
        
INSERT INTO CoreETL.dbo.COR_SRC_FUND_PRICE          
 (        
  SRC_FUND_ID,        
  JOB_ID,        
  DATETIMESTAMP,        
  PRICE_DATE,         
  UNIT_VAL_PRICE_AMT,        
  DAILY_DIV_AMT,        
  REC_INSRT_NAME,        
  REC_UPDT_NAME,        
  ADU        
 )        
SELECT DISTINCT
	IsNull(SRC_FUND_ID,999999999),        
	@JobID,        
	@CurrDateTime,        
	PRICE_DATE,        
	UNIT_VAL_PRICE_AMT,        
	DAILY_DIV_AMT,        
	'442',        
	--SRC_FUND1_KEY+'+'+SRC_FUND2_KEY+'+'+SRC_FUND3_KEY+'+'+SRC_FUND4_KEY 
	'' AS REC_UPDT_NAME,        
	'U'        
FROM dbo.COM_SRC_FUND_PRICE        
LEFT JOIN dbo.GenIDSrcFund    ON  SRC_FUND_PRICE_SRC_TEXT = dbo.GenIDSrcFund.SourceSystem        
								AND SRC_FUND1_KEY = dbo.GenIDSrcFund.SourceSystemKey1        
								--AND SRC_FUND2_KEY = dbo.GenIDSrcFund.SourceSystemKey2        
								--AND SRC_FUND3_KEY = dbo.GenIDSrcFund.SourceSystemKey3        
								--AND SRC_FUND4_KEY = dbo.GenIDSrcFund.SourceSystemKey4
GO
