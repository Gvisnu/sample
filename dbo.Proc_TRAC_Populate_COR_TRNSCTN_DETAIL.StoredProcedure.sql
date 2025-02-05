USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_TRNSCTN_DETAIL]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_TRAC_Populate_COR_TRNSCTN_DETAIL] AS



DECLARE @JobID INT;

DECLARE @TempDate DATETIME;



SET @TempDate = GETDATE();



SET @JobID = (SELECT MAX(JobID)

              FROM MC_JobID

              INNER JOIN MC_SourceFile

              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID

              WHERE logicalName = 'TracTransactionDetail'

              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)

                                       FROM MC_SysProcessedLog

                                       WHERE SystemID = 49));



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COR_TRNSCTN_DETAIL_Today]') AND type in (N'U'))

BEGIN

DROP TABLE [dbo].[COR_TRNSCTN_DETAIL_Today]

END



SELECT * INTO CORE1.DBO.[COR_TRNSCTN_DETAIL_Today] FROM COREETL.DBO.COR_TRNSCTN_DETAIL WHERE 1=2



update statistics dbo.TRACTransactionDetail

update statistics dbo.GenIDIATransaction



INSERT INTO CORE1.dbo.COR_TRNSCTN_DETAIL_Today

(

 AGREEMENT_ID,

 SRC_FUND_ID,

 TRANSACTION_ID,

 ACCOUNTING_DATE,

 DATETIMESTAMP,

 JOB_ID,

 TRAN_ASSET_SOURCE_CODE,

 DETAIL_TYPE_CODE,

 AMOUNT,

 REC_INSRT_NAME,

 ORIGINAL_SOURCE_DTL_TYPE,

 DETAIL_SEQ_ID,

 NUMBER_OF_UNITS,

 VALUE_PER_UNIT,

 ADU

)

SELECT

 G.AgreementID       AS AGREEMENT_ID,

 ISNULL(GENID.SRC_FUND_ID,'999999999')  AS SRC_FUND_ID,

 T.TransactionID      AS TRANSACTION_ID,

 ACCOUNTING_DATE      AS ACCOUNTING_DATE,

 @TempDate        AS DATETIMESTAMP,

 @JobID         AS JOB_ID,

 CASE CONTR_MONEY_TY_CDE WHEN  'UNK' THEN 'NANA'

 ELSE  CONTR_MONEY_TY_CDE+'+'+PLAN_TYPE_CDE   END AS TRAN_ASSET_SOURCE_CODE,

 DETAIL_TYPE_CODE      AS DETAIL_TYPE_CODE,

 AMOUNT         AS AMOUNT,

 CASE WHEN GENID.SRC_FUND_ID IS NULL THEN

 (RTRIM(F.SRC_SYS_ATTR_KEY1_TEXT)+'+'+RTRIM(F.SRC_SYS_ATTR_KEY2_TEXT)+'+'+RTRIM(F.SRC_SYS_ATTR_KEY3_TEXT)+'+'+RTRIM(F.SRC_SYS_ATTR_KEY4_TEXT))

 ELSE '419'

 END         AS REC_INSRT_NAME, -- Added on 01-30-2014 as per Santhosh feedback

 DETAIL_TYPE_CODE      As DETAIL_TYPE_CODE,

 SEQ_ID         AS SEQ_ID,

 NUMBER_OF_UNITS      AS NUMBER_OF_UNITS,

 --CASE WHEN NUMBER_OF_UNITS = 0 THEN 0

 --ELSE AMOUNT/NUMBER_OF_UNITS END  AS VALUE_PER_UNIT,

 UNIT_PRC	AS VALUE_PER_UNIT,

 'U'         AS ADU

FROM TRACTransactionDetail F

INNER JOIN GENIDFAAGREEMENT G   ON  F.Agreement_Sys_Attr_Key1_Text = G.SOURCESYSTEMKEY1

          AND F.Agreement_Sys_Attr_Key2_Text = G.SOURCESYSTEMKEY2

          AND F.Agreement_Sys_Attr_Key3_Text = G.SOURCESYSTEMKEY3

          AND F.Agreement_Sys_Attr_Key4_Text = G.SOURCESYSTEMKEY4

          AND F.MNTC_SYS_CODE = G.SOURCESYSTEM

INNER JOIN GenIDIATransaction T   ON  F.Transaction_Sys_Attr_Key1_Text = T.SourceSystemKey1

          AND F.Transaction_Sys_Attr_Key2_Text = T.SourceSystemKey2

          AND F.Transaction_Sys_Attr_Key3_Text = T.SourceSystemKey3

          AND F.Transaction_Sys_Attr_Key4_Text = T.SourceSystemKey4

          AND F.Transaction_Sys_Attr_Key5_Text = T.SourceSystemKey5

          AND F.Transaction_Sys_Attr_Key6_Text = T.SourceSystemKey6

        AND F.Transaction_Sys_Attr_Key7_Text = T.SourceSystemKey7

          AND F.Transaction_Sys_Attr_Key8_Text = T.SourceSystemKey8

          AND F.Transaction_Sys_Attr_Key9_Text = T.SourceSystemKey9

        LEFT OUTER JOIN GENIDSRCFUND GENID  ON

         rtrim(GENID.SOURCESYSTEMKEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)
        --AND rtrim(GENID.SOURCESYSTEMKEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT) --INC000001869217 - Issue fix for TXN Duplicate 
        AND rtrim(GENID.SOURCESYSTEMKEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)
        AND rtrim(GENID.SOURCESYSTEMKEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)
    AND GENID.SOURCESYSTEM = F.MNTC_SYS_CODE
WHERE F.MNTC_SYS_CODE='TRAC'--and SRC_FUND_ID is not null
AND ( rtrim(SRC_SYS_ATTR_KEY2_TEXT)= '' OR rtrim(SRC_SYS_ATTR_KEY2_TEXT) IS NULL) --INC000001869217 - Change:1
and F.SRC_SYS_ATTR_KEY4_TEXT not in (SELECT FUND_CODE  FROM CORE1.DBO.TRAC_FUNDS_AF)

--INC000001869217 - Change:2 START

UNION

SELECT

 G.AgreementID       AS AGREEMENT_ID,

 ISNULL(GENID.SRC_FUND_ID,'999999999')  AS SRC_FUND_ID,

 T.TransactionID      AS TRANSACTION_ID,

 ACCOUNTING_DATE      AS ACCOUNTING_DATE,

 @TempDate        AS DATETIMESTAMP,

 @JobID         AS JOB_ID,

 CASE CONTR_MONEY_TY_CDE WHEN  'UNK' THEN 'NANA'

 ELSE  CONTR_MONEY_TY_CDE+'+'+PLAN_TYPE_CDE   END AS TRAN_ASSET_SOURCE_CODE,

 DETAIL_TYPE_CODE      AS DETAIL_TYPE_CODE,

 AMOUNT         AS AMOUNT,

 CASE WHEN GENID.SRC_FUND_ID IS NULL THEN

 (RTRIM(F.SRC_SYS_ATTR_KEY1_TEXT)+'+'+RTRIM(F.SRC_SYS_ATTR_KEY2_TEXT)+'+'+RTRIM(F.SRC_SYS_ATTR_KEY3_TEXT)+'+'+RTRIM(F.SRC_SYS_ATTR_KEY4_TEXT))

 ELSE '419'

 END         AS REC_INSRT_NAME, -- Added on 01-30-2014 as per Santhosh feedback

 DETAIL_TYPE_CODE      As DETAIL_TYPE_CODE,

 SEQ_ID         AS SEQ_ID,

 NUMBER_OF_UNITS      AS NUMBER_OF_UNITS,

 --CASE WHEN NUMBER_OF_UNITS = 0 THEN 0

 --ELSE AMOUNT/NUMBER_OF_UNITS END  AS VALUE_PER_UNIT,

 UNIT_PRC	AS VALUE_PER_UNIT,

 'U'         AS ADU

FROM TRACTransactionDetail F

INNER JOIN GENIDFAAGREEMENT G   ON  F.Agreement_Sys_Attr_Key1_Text = G.SOURCESYSTEMKEY1

          AND F.Agreement_Sys_Attr_Key2_Text = G.SOURCESYSTEMKEY2

          AND F.Agreement_Sys_Attr_Key3_Text = G.SOURCESYSTEMKEY3

          AND F.Agreement_Sys_Attr_Key4_Text = G.SOURCESYSTEMKEY4

          AND F.MNTC_SYS_CODE = G.SOURCESYSTEM

INNER JOIN GenIDIATransaction T   ON  F.Transaction_Sys_Attr_Key1_Text = T.SourceSystemKey1

          AND F.Transaction_Sys_Attr_Key2_Text = T.SourceSystemKey2

          AND F.Transaction_Sys_Attr_Key3_Text = T.SourceSystemKey3

          AND F.Transaction_Sys_Attr_Key4_Text = T.SourceSystemKey4

          AND F.Transaction_Sys_Attr_Key5_Text = T.SourceSystemKey5

          AND F.Transaction_Sys_Attr_Key6_Text = T.SourceSystemKey6

        AND F.Transaction_Sys_Attr_Key7_Text = T.SourceSystemKey7

          AND F.Transaction_Sys_Attr_Key8_Text = T.SourceSystemKey8

          AND F.Transaction_Sys_Attr_Key9_Text = T.SourceSystemKey9

        LEFT OUTER JOIN GENIDSRCFUND GENID  ON		
		
         rtrim(GENID.SOURCESYSTEMKEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)
        AND rtrim(GENID.SOURCESYSTEMKEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT) 
        AND rtrim(GENID.SOURCESYSTEMKEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)
        AND rtrim(GENID.SOURCESYSTEMKEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)
    AND GENID.SOURCESYSTEM = F.MNTC_SYS_CODE 
WHERE F.MNTC_SYS_CODE='TRAC' 
and (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '') 
and F.SRC_SYS_ATTR_KEY4_TEXT not in (SELECT FUND_CODE  FROM CORE1.DBO.TRAC_FUNDS_AF)

--INC000001869217 - Change:2 END

UNION

SELECT

 G.AgreementID       AS AGREEMENT_ID,

 ISNULL(GENID.SRC_FUND_ID,'999999999')  AS SRC_FUND_ID,

 T.TransactionID      AS TRANSACTION_ID,

 ACCOUNTING_DATE      AS ACCOUNTING_DATE,

 @TempDate        AS DATETIMESTAMP,

 @JobID         AS JOB_ID,

 CASE CONTR_MONEY_TY_CDE WHEN  'UNK' THEN 'NANA'

 ELSE  CONTR_MONEY_TY_CDE+'+'+PLAN_TYPE_CDE   END AS TRAN_ASSET_SOURCE_CODE,

 DETAIL_TYPE_CODE      AS DETAIL_TYPE_CODE,

 AMOUNT         AS AMOUNT,

 CASE WHEN GENID.SRC_FUND_ID IS NULL THEN

 (RTRIM(F.SRC_SYS_ATTR_KEY1_TEXT)+'+'+RTRIM(F.SRC_SYS_ATTR_KEY2_TEXT)+'+'+RTRIM(F.SRC_SYS_ATTR_KEY3_TEXT)+'+'+RTRIM(F.SRC_SYS_ATTR_KEY4_TEXT))

 ELSE '419'

 END         AS REC_INSRT_NAME, -- Added on 01-30-2014 as per Santhosh feedback

 DETAIL_TYPE_CODE      As DETAIL_TYPE_CODE,

 SEQ_ID         AS SEQ_ID,

 NUMBER_OF_UNITS      AS NUMBER_OF_UNITS,

 --CASE WHEN NUMBER_OF_UNITS = 0 THEN 0

 --ELSE AMOUNT/NUMBER_OF_UNITS END  AS VALUE_PER_UNIT,

 UNIT_PRC	AS VALUE_PER_UNIT,

 'U'         AS ADU       FROM TRACTransactionDetail F

INNER JOIN GENIDFAAGREEMENT G   ON  F.Agreement_Sys_Attr_Key1_Text = G.SOURCESYSTEMKEY1

          AND F.Agreement_Sys_Attr_Key2_Text = G.SOURCESYSTEMKEY2

          AND F.Agreement_Sys_Attr_Key3_Text = G.SOURCESYSTEMKEY3

          AND F.Agreement_Sys_Attr_Key4_Text = G.SOURCESYSTEMKEY4

          AND F.MNTC_SYS_CODE = G.SOURCESYSTEM

INNER JOIN GenIDIATransaction T   ON  F.Transaction_Sys_Attr_Key1_Text = T.SourceSystemKey1

          AND F.Transaction_Sys_Attr_Key2_Text = T.SourceSystemKey2

          AND F.Transaction_Sys_Attr_Key3_Text = T.SourceSystemKey3

          AND F.Transaction_Sys_Attr_Key4_Text = T.SourceSystemKey4

          AND F.Transaction_Sys_Attr_Key5_Text = T.SourceSystemKey5

          AND F.Transaction_Sys_Attr_Key6_Text = T.SourceSystemKey6

        AND F.Transaction_Sys_Attr_Key7_Text = T.SourceSystemKey7

          AND F.Transaction_Sys_Attr_Key8_Text = T.SourceSystemKey8

          AND F.Transaction_Sys_Attr_Key9_Text = T.SourceSystemKey9

        LEFT OUTER JOIN GENIDSRCFUND GENID  ON

         rtrim(GENID.SOURCESYSTEMKEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)

         AND rtrim(GENID.SOURCESYSTEMKEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT)

               AND rtrim(GENID.SOURCESYSTEMKEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)

        AND rtrim(GENID.SOURCESYSTEMKEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)

    AND GENID.SOURCESYSTEM = F.MNTC_SYS_CODE

WHERE F.MNTC_SYS_CODE='TRAC'

  --AND rtrim(GENID.SOURCESYSTEMKEY2) <> rtrim(SRC_SYS_ATTR_KEY2_TEXT)

 -- and SRC_FUND_ID is not null

and F.SRC_SYS_ATTR_KEY4_TEXT in (SELECT FUND_CODE FROM CORE1.DBO.TRAC_FUNDS_AF)

/*

Update A

Set AMOUNT = CASE WHEN  AMOUNT < 0 THEN AMOUNT*-1   ELSE AMOUNT END

FROM CORE1.dbo.COR_TRNSCTN_DETAIL_Today A INNER JOIN PRM_DomainSource B

ON A.DETAIL_TYPE_CODE = B.Sourcevalue

where SystemID = 49 and Domaintablename  = 'DOM_DTL_TYPE'

AND Domaincode  IN ('FED WTHLD','ST WTHLD')

*/



INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM)

SELECT GETDATE(),

 'UNABLE TO LOAD '+CAST(CNT AS VARCHAR)+' RECORD(S) INTO COR_TRNSCTN_DETAIL DUE TO A SRC_FUND_ID OF 999999999',

 'REFER TO ERR TABLE FOR DETAIL',

 'REP',

 'TRAC'

FROM (SELECT COUNT(*) AS CNT FROM CORE1.dbo.COR_TRNSCTN_DETAIL_Today WHERE SRC_FUND_ID = 999999999) Q

WHERE CNT > 0



INSERT INTO COREERRLOG.DBO.ERR_TRNSCTN_DETAIL

SELECT *,

 (SELECT DISTINCT @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG)

FROM CORE1.dbo.COR_TRNSCTN_DETAIL_Today

WHERE SRC_FUND_ID = 999999999;



DELETE CORE1.dbo.COR_TRNSCTN_DETAIL_Today

WHERE SRC_FUND_ID =999999999;



----- If a SRC_FUND_ID was 999999999 and has been corrected, move to COR table and delete ERR row



INSERT INTO CORE1.dbo.COR_TRNSCTN_DETAIL_Today

 (

   [TRANSACTION_ID]

           ,[DETAIL_SEQ_ID]

           ,[ACCOUNTING_DATE]

           ,[AGREEMENT_ID]

           ,[DATETIMESTAMP]

           ,[JOB_ID]

           ,[SRC_FUND_ID]

           ,[TRAN_ASSET_SOURCE_CODE]

           ,[DETAIL_TYPE_CODE]

           ,[AMOUNT]

           ,[NUMBER_OF_UNITS]

           ,[VALUE_PER_UNIT]

           ,[INTEREST_RATE]

           ,[REC_INSRT_NAME]

           ,[REC_UPDT_NAME]

           ,[ORIGINAL_SOURCE_DTL_TYPE]

           ,[DETAIL_GAIN_LOSS_AMT]

           ,[LOAN_ID]

           ,[ADU]

 )

SELECT

    A.[TRANSACTION_ID]

      ,A.[DETAIL_SEQ_ID]

      ,A.[ACCOUNTING_DATE]

      ,A.[AGREEMENT_ID]

   ,@TempDate

   ,@JobID

      ,A.[SRC_FUND_ID]

      ,A.[TRAN_ASSET_SOURCE_CODE]

      ,A.[DETAIL_TYPE_CODE]

      ,A.[AMOUNT]

      ,A.[NUMBER_OF_UNITS]

      ,A.[VALUE_PER_UNIT]

      ,A.[INTEREST_RATE]

      --,A.[REC_INSRT_NAME]

      ,'419'

      ,A.[REC_UPDT_NAME]

      ,A.[ORIGINAL_SOURCE_DTL_TYPE]

      ,A.[DETAIL_GAIN_LOSS_AMT]

      ,A.[LOAN_ID]

      ,A.[ADU]

FROM COREERRLOG.DBO.ERR_TRNSCTN_DETAIL A

INNER JOIN COREERRLOG.DBO.REPERRORLOG B

ON  A.REPERRORID = B.ERRORID 

WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'

  AND A.SRC_FUND_ID <> 999999999;



DELETE COREERRLOG.DBO.ERR_TRNSCTN_DETAIL

FROM COREERRLOG.DBO.ERR_TRNSCTN_DETAIL A

INNER JOIN COREERRLOG.DBO.REPERRORLOG B

ON  A.REPERRORID = B.ERRORID

WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'

  AND A.SRC_FUND_ID <> 999999999;



--Update CORE1.dbo.COR_TRNSCTN_DETAIL_Today set REC_INSRT_NAME = '419';



INSERT INTO COREETL.DBO.COR_TRNSCTN_DETAIL SELECT DISTINCT * FROM CORE1.DBO.[COR_TRNSCTN_DETAIL_TODAY]



RETURN
GO
