USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_X_EXTRNL_ASSET_SRC_DETAIL_Error_Handling]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[Proc_TRAC_Populate_COR_X_EXTRNL_ASSET_SRC_DETAIL_Error_Handling]  
AS  
DECLARE @JobID INT;  
DECLARE @TEMPTIME DateTime;  
  
SET @JobID = (SELECT isnull(MAX(JobID),0)  
              FROM MC_JobID  
              INNER   
              JOIN MC_SourceFile  
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID  
     WHERE logicalName = 'TRACExternalAssetSourceDetail'  
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)  
                   FROM MC_SysProcessedLog  
                   WHERE SystemID = 49));  
SET @TEMPTIME = GETDATE();  
  
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COR_X_EXTRNL_ASSET_SRC_DETAIL_TODAY]') AND type in (N'U'))  
BEGIN  
DROP TABLE [dbo].[COR_X_EXTRNL_ASSET_SRC_DETAIL_TODAY]  
END  
  
SELECT * INTO CORE1.DBO.[COR_X_EXTRNL_ASSET_SRC_DETAIL_TODAY] FROM COREETL.DBO.COR_X_EXTRNL_ASSET_SRC_DETAIL WHERE 1=2  
  
/************************************************************************************************************************
** PR     Date            Author				Ticket			 TAS 							Description   
** --   --------         --------			---------------		-------    		------------------------------------------------
** 1    13.July.2020    Biswanath Panda		INC000004573688		 41579		  One condition has to be part of LEFT OUTER JOIN for dbo.TRACFunds table 
																			  but placed in WHERE clause . Now we placed correctly . 

*************************************************************************************************************************/
INSERT INTO CORE1.dbo.COR_X_EXTRNL_ASSET_SRC_DETAIL_TODAY  
(  
 AGREEMENT_ID,  
 SRC_FUND_ID,  
 ACCOUNTING_DATE,  
 ASSET_SOURCE_CODE,  
 DATETIMESTAMP,  
 JOB_ID,  
 DOLLAR_AMT,  
 REC_INSRT_DATE,  
 REC_INSRT_NAME,  
 REC_UPDT_DATE,  
 REC_UPDT_NAME,  
 VEST_PCT,  
 ADU  
 )  
Select  
 GenIDFAAgreement.AgreementID AS AGREEMENT_ID,  
 '999999999'     AS SRC_FUND_ID,  
 ASD.LoadDate     AS ACCOUNTING_DATE,  
 (CONVERT(nvarchar(20),ASD.CONTR_MONEY_TY_CDE)+'+'+CONVERT(nvarchar(20),ASD.PLAN_TYPE_CDE))  AS ASSET_SOURCE_CODE,  
 @TEMPTIME      AS DATETIMESTAMP,  
@JobID       AS JOB_ID,  
 CONVERT(DECIMAL(18,2),SUM(CONVERT(DECIMAL(18,6),CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES) * CONVERT(DECIMAL(18,6),ASD.UNIT_PRC)))) AS DOLLAR_AMT,  
@TEMPTIME      AS REC_INSRT_DATE,  
 (RTRIM(ASD.SRC_SYS_ATTR_KEY1_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY2_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY3_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY4_TEXT)) AS REC_INSRT_NAME,  
@TEMPTIME      AS REC_UPDT_DATE,  
 '449'       AS REC_UPDT_NAME,  
 ASD.MNY_TYPE_VESTED_PERCENT AS VEST_PCT,  
 MAX(ADU)      AS ADU  
FROM dbo.TRACAssetSourceDetailExternal ASD  
INNER JOIN dbo.GenIDFAAgreement  on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT  
        AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT  
        AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT  
        AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT  
        AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT  
        AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem  
LEFT OUTER JOIN dbo.TRACFunds B  
ON rtrim(ASD.SRC_SYS_ATTR_KEY1_TEXT) = rtrim(B.KEY1)  
ANd rtrim(ASD.SRC_SYS_ATTR_KEY3_TEXT) = rtrim(B.KEY3)  
and rtrim(ASD.SRC_SYS_ATTR_KEY4_TEXT) = rtrim(B.KEY4)  
and B.FUND_TYPE = 'EXT' 
-- INC# - Commenting & Below condition placed in JOIN condition  
and (
    (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(B.KEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT)) 
    OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = '')) 
  WHERE ASD.MNTC_SYS_CODE = 'TRAC'       
   /*and (
    (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(B.KEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT)) 
    OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = '')) */
    AND B.SRC_FUND_ID IS NULL 
GROUP BY  
GenIDFAAgreement.AgreementID,  
 ASD.LoadDate,  
(RTRIM(ASD.SRC_SYS_ATTR_KEY1_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY2_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY3_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY4_TEXT)),  
 (CONVERT(nvarchar(20),ASD.CONTR_MONEY_TY_CDE)+'+'+CONVERT(nvarchar(20),ASD.PLAN_TYPE_CDE)),  
  ASD.MNY_TYPE_VESTED_PERCENT;  
  
INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM)  
SELECT GETDATE(),  
 'UNABLE TO LOAD '+CAST(CNT AS VARCHAR)+' RECORD(S) INTO COR_X_EXTRNL_ASSET_SRC_DETAIL DUE TO A SRC_FUND_ID OF 999999999',  
 'REFER TO ERR TABLE FOR DETAIL',  
 'REP',  
 'TRAC'  
FROM (SELECT COUNT(*) AS CNT FROM CORE1.dbo.COR_X_EXTRNL_ASSET_SRC_DETAIL_TODAY WHERE SRC_FUND_ID = 999999999) Q  
WHERE CNT > 0  
  
INSERT INTO COREERRLOG.DBO.ERR_X_EXTRNL_ASSET_SRC_DETAIL  
SELECT *,  
 (SELECT DISTINCT @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG)  
FROM CORE1.dbo.COR_X_EXTRNL_ASSET_SRC_DETAIL_TODAY  
WHERE SRC_FUND_ID = 999999999;  
  
DELETE CORE1.dbo.COR_X_EXTRNL_ASSET_SRC_DETAIL_TODAY  
WHERE SRC_FUND_ID =999999999;  
  
----- If a SRC_FUND_ID was 999999999 and has been corrected, move to COR table and delete ERR row  
  
INSERT INTO CORE1.dbo.COR_X_EXTRNL_ASSET_SRC_DETAIL_TODAY  
 (  
  AGREEMENT_ID,  
  SRC_FUND_ID,  
  ACCOUNTING_DATE,  
  ASSET_SOURCE_CODE,  
  DATETIMESTAMP,  
  JOB_ID,  
  DOLLAR_AMT,  
  REC_INSRT_DATE,  
  REC_INSRT_NAME,  
  REC_UPDT_DATE,  
  REC_UPDT_NAME,  
  VEST_PCT,  
  ADU  
 )  
SELECT  
     A.AGREEMENT_ID,  
  A.SRC_FUND_ID,  
  A.ACCOUNTING_DATE,  
  A.ASSET_SOURCE_CODE,  
  @TEMPTIME,      
  @JobID,      
  A.DOLLAR_AMT,  
  @TEMPTIME,      
  '449',                 
  @TEMPTIME,      
  A.REC_UPDT_NAME,  
  A.VEST_PCT,  
  A.ADU      
FROM COREERRLOG.DBO.ERR_X_EXTRNL_ASSET_SRC_DETAIL A      
INNER JOIN COREERRLOG.DBO.REPERRORLOG B      
ON  A.REPERRORID = B.ERRORID      
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'      
  AND A.SRC_FUND_ID <> 999999999;      
        
      
DELETE COREERRLOG.DBO.ERR_X_EXTRNL_ASSET_SRC_DETAIL      
FROM COREERRLOG.DBO.ERR_X_EXTRNL_ASSET_SRC_DETAIL A      
INNER JOIN COREERRLOG.DBO.REPERRORLOG B      
ON  A.REPERRORID = B.ERRORID      
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'      
  AND A.SRC_FUND_ID <> 999999999;      
        
--Update CoreETL.dbo.COR_X_EXTRNL_ASSET_SRC_DETAIL set REC_INSRT_NAME = '449';      
      
INSERT INTO COREETL.DBO.COR_X_EXTRNL_ASSET_SRC_DETAIL SELECT DISTINCT * FROM CORE1.DBO.[COR_X_EXTRNL_ASSET_SRC_DETAIL_TODAY]       
      
RETURN          
SET QUOTED_IDENTIFIER OFF
GO
