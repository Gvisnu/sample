USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Load_GenID_For_SRC_PRDCT_RIDER_PKG]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE     PROCEDURE [dbo].[Load_GenID_For_SRC_PRDCT_RIDER_PKG] @ISSUE INT
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
		INSERT INTO GenIDFASrcPrdctRiderPkg
		(
			SourceSystem,
			SourceSystemKey1,
			SourceSystemKey2,
			SourceSystemKey3,
			SourceSystemKey4,
			SrcPrdctRiderPkgID,
			JobID,
			DateTimeStamp
		)
		SELECT
			MSC,
			SSK1,
			SSK2,
			SSK3,
			SSK4,
			PRDCT_RIDER_PKG_ID,
			JOB_ID,
			SYSDATE
		FROM OPENQUERY(' + @SOURCEDB + ',''
			SELECT DISTINCT
			    A.MNTC_SYS_CODE AS MSC,
			    CASE WHEN A.MNTC_SYS_CODE = ''''LC'''' THEN MNTC_SYS_ATTR_KEY1_TEXT
			         ELSE NULL
			    END AS SSK1,
			    CASE WHEN A.MNTC_SYS_CODE = ''''LC'''' THEN MNTC_SYS_ATTR_KEY2_TEXT
			         ELSE NULL
			    END AS SSK2,
			    CASE WHEN A.MNTC_SYS_CODE = ''''LC'''' THEN MNTC_SYS_ATTR_KEY3_TEXT
			         ELSE NULL
			    END AS SSK3,
			    CASE WHEN A.MNTC_SYS_CODE = ''''LC'''' THEN MNTC_SYS_ATTR_KEY4_TEXT
			         ELSE NULL
			    END AS SSK4,
			    PRDCT_RIDER_PKG_ID,
			    JOB_ID,
			    SYSDATE
			FROM
			    COR_SRC_PRDCT_RIDER_PKG A
			WHERE A.REC_INSRT_NAME = ''''' + CAST(@ISSUE AS VARCHAR) + ''''''') Q
		LEFT OUTER JOIN GenIDFASrcPrdctRiderPkg
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
		INSERT INTO GenIDFASrcPrdctRiderPkg
		(
			SourceSystem,
			SourceSystemKey1,
			SourceSystemKey2,
			SourceSystemKey3,
			SourceSystemKey4,
			SrcPrdctRiderPkgID,
			JobID,
			DateTimeStamp
		)
		SELECT
			MSC,
			SSK1,
			SSK2,
			SSK3,
			SSK4,
			PRDCT_RIDER_PKG_ID,
			JOB_ID,
			SYSDATE
		FROM OPENQUERY(' + @SOURCEDB + ',''
			SELECT DISTINCT
			    A.MNTC_SYS_CODE AS MSC,
			    CASE WHEN A.MNTC_SYS_CODE = ''''LC'''' THEN MNTC_SYS_ATTR_KEY1_TEXT
			         ELSE NULL
			    END AS SSK1,
			    CASE WHEN A.MNTC_SYS_CODE = ''''LC'''' THEN MNTC_SYS_ATTR_KEY2_TEXT
			         ELSE NULL
			    END AS SSK2,
			    CASE WHEN A.MNTC_SYS_CODE = ''''LC'''' THEN MNTC_SYS_ATTR_KEY3_TEXT
			         ELSE NULL
			    END AS SSK3,
			    CASE WHEN A.MNTC_SYS_CODE = ''''LC'''' THEN MNTC_SYS_ATTR_KEY4_TEXT
			         ELSE NULL
			    END AS SSK4,
			    PRDCT_RIDER_PKG_ID,
			    JOB_ID,
			    SYSDATE
			FROM
			    COR_SRC_PRDCT_RIDER_PKG A) Q
		LEFT OUTER JOIN GenIDIVFund
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
