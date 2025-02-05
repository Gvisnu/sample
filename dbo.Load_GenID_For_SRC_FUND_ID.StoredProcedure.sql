USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Load_GenID_For_SRC_FUND_ID]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE      PROCEDURE [dbo].[Load_GenID_For_SRC_FUND_ID] @ISSUE INT
AS

DECLARE @PROCSQL NVARCHAR(4000)
DECLARE @SOURCEDB VARCHAR(100)

SELECT @SOURCEDB = CASE WHEN @@SERVERNAME LIKE '%DEV%' THEN 'COREDEV'
                        WHEN @@SERVERNAME LIKE 'COREQA%' THEN 'COREQA'
                        ELSE 'COREPRD'
                   END

IF @ISSUE <> 999999999

	BEGIN
		
		SELECT @PROCSQL = '
		INSERT INTO GenIDSrcFund
		(
			SourceSystem,
			SourceSystemKey1,
			SourceSystemKey2,
			SourceSystemKey3,
			SourceSystemKey4,
			SRC_FUND_ID,
			JobID,
			DateTimeStamp
		)
		SELECT
			MSC,
		    CASE WHEN MSC = ''DST'' THEN ''00''
		         ELSE SSK1
		    END AS SSK1,
		    CASE WHEN MSC = ''DST'' THEN SSK1
			     WHEN LTRIM(RTRIM(SSK2))=''N/A'' THEN ''^''
		         ELSE SSK2
		    END AS SSK2,
			CASE WHEN LTRIM(RTRIM(SSK3))=''N/A''THEN ''^'' ELSE SSK3 END,
			CASE WHEN LTRIM(RTRIM(SSK4))=''N/A''THEN ''^'' ELSE SSK4 END,
			Q.src_FUND_ID,
			Q.JOBID,
			SYSDATE
		FROM OPENQUERY(' + @SOURCEDB + ',''
			SELECT DISTINCT
                   A.MNTC_SYS_CODE AS MSC,
                   A.MNTC_SYS_ATTR_KEY1_TEXT SSK1,
                   A.MNTC_SYS_ATTR_KEY2_TEXT SSK2,
                   A.MNTC_SYS_ATTR_KEY3_TEXT SSK3,
                   A.MNTC_SYS_ATTR_KEY4_TEXT SSK4,
                   A.SRC_FUND_ID AS SRC_FUND_ID,
                   A.JOB_ID AS JOBID,
                   SYSDATE
			FROM
			    COR_SRC_FUND A
			WHERE A.REC_INSRT_NAME = ''''' + CAST(@ISSUE AS VARCHAR) + ''''' OR A.REC_UPDT_NAME = ''''' + CAST(@ISSUE AS VARCHAR) + ''''' '') Q
		LEFT OUTER JOIN GenIDSrcFund
		    ON  MSC  = SourceSystem
		    AND SSK1 = SourceSystemKey1
		    AND SSK2 = SourceSystemKey2
		    AND SSK3 = SourceSystemKey3
		    AND SSK4 = SourceSystemKey4
		    WHERE SourceSystem IS NULL'

	END

ELSE

	BEGIN
		
		SELECT @PROCSQL = '
		INSERT INTO GenIDSrcFund
		(
			SourceSystem,
			SourceSystemKey1,
			SourceSystemKey2,
			SourceSystemKey3,
			SourceSystemKey4,
			SRC_FUND_ID,
			JobID,
			DateTimeStamp
		)
		SELECT
			MSC,
			SSK1,
			SSK2,
			SSK3,
			SSK4,
			Q.src_FUND_ID,
			Q.JOBID,
			SYSDATE
		FROM OPENQUERY(' + @SOURCEDB + ',''
			SELECT DISTINCT
                   A.MNTC_SYS_CODE AS MSC,
				   CASE A.MNTC_SYS_CODE WHEN ''''DST'''' THEN ''''00''''
						ELSE A.MNTC_SYS_ATTR_KEY1_TEXT END AS SSK1,
				   CASE WHEN A.MNTC_SYS_CODE = ''''DST'''' THEN A.MNTC_SYS_ATTR_KEY1_TEXT 
						WHEN TRIM(A.MNTC_SYS_ATTR_KEY2_TEXT)= ''''N/A'''' THEN ''''^''''
						ELSE A.MNTC_SYS_ATTR_KEY2_TEXT END AS SSK2,
                   CASE WHEN TRIM(A.MNTC_SYS_ATTR_KEY3_TEXT ) = ''''N/A'''' THEN ''''^'''' 
						ELSE A.MNTC_SYS_ATTR_KEY3_TEXT  END AS SSK3,
                   CASE WHEN TRIM(A.MNTC_SYS_ATTR_KEY4_TEXT) = ''''N/A'''' THEN ''''^'''' 
						ELSE A.MNTC_SYS_ATTR_KEY4_TEXT  END AS SSK4,
			       A.SRC_FUND_ID AS SRC_FUND_ID,
			       A.JOB_ID AS JOBID,
			       SYSDATE
			FROM
			    COR_SRC_FUND A '') Q
		LEFT OUTER JOIN GenIDSrcFund
		    ON  MSC  = SourceSystem
		    AND SSK1 = SourceSystemKey1
		    AND SSK2 = SourceSystemKey2
		    AND SSK3 = SourceSystemKey3
		    AND SSK4 = SourceSystemKey4
		   WHERE SourceSystem IS NULL'

	END


--PRINT @PROCSQL

EXEC SP_EXECUTESQL @PROCSQL

RETURN 

GO
