USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Load_GenID_For_SOURCE_PRODUCT]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[Load_GenID_For_SOURCE_PRODUCT] @ISSUE INT
AS

DECLARE @PROCSQL NVARCHAR(4000)
DECLARE @SOURCEDB VARCHAR(100)

SELECT @SOURCEDB = CASE WHEN @@SERVERNAME LIKE '%DEV%' THEN 'COREDEV'
                        WHEN @@SERVERNAME LIKE '%COREQA%' THEN 'COREQA'
                        ELSE 'COREPRD'
                   END

IF @ISSUE <> 999999999

	BEGIN
		
		SELECT @PROCSQL = '
		INSERT INTO GenIDPRSourceProduct
		(
			SourceSystem,
			SourceSystemKey1,
			SourceSystemKey2,
			SourceSystemKey3,
			SourceSystemKey4,
			SourceSystemKey5,
			JobID,
			DateTimeStamp,
			SourceProductID
		)
		SELECT
			MSC,
			SSK1,
			SSK2,
			SSK3,
			SSK4,
			SSK5,
			JOB_ID,
			GETDATE(),
			SRC_PRDCT_ID
		FROM OPENQUERY(' + @SOURCEDB + ',''
			SELECT	MNTC_SYS_CODE AS MSC,
				PRDCT_MNTC_SYS_KEY_TEXT AS SSK1,
				''''^'''' AS SSK2,
				''''^'''' AS SSK3,
				''''^'''' AS SSK4,
				''''^'''' AS SSK5,
				JOB_ID,
				SRC_PRDCT_ID
			FROM
				COR_SRC_PRDCT
			WHERE
				REC_INSRT_NAME = ''''' + CAST(@ISSUE AS VARCHAR) + ''''''')
		LEFT OUTER JOIN GenIDPRSourceProduct
		    ON  MSC  = SourceSystem
		    AND SSK1 = SourceSystemKey1
		    AND SSK2 = SourceSystemKey2
		    AND SSK3 = SourceSystemKey3
		    AND SSK4 = SourceSystemKey4
		    AND SSK5 = SourceSystemKey5
		WHERE SourceSystem IS NULL'

	END

ELSE

	BEGIN
		
		SELECT @PROCSQL = '
		INSERT INTO GenIDPRSourceProduct
		(
			SourceSystem,
			SourceSystemKey1,
			SourceSystemKey2,
			SourceSystemKey3,
			SourceSystemKey4,
			SourceSystemKey5,
			JobID,
			DateTimeStamp,
			SourceProductID
		)
		SELECT
			MSC,
			SSK1,
			SSK2,
			SSK3,
			SSK4,
			SSK5,
			JOB_ID,
			GETDATE(),
			SRC_PRDCT_ID
		FROM OPENQUERY(' + @SOURCEDB + ',''
			SELECT	MNTC_SYS_CODE AS MSC,
				PRDCT_MNTC_SYS_KEY_TEXT AS SSK1,
				''''^'''' AS SSK2,
				''''^'''' AS SSK3,
				''''^'''' AS SSK4,
				''''^'''' AS SSK5,
				JOB_ID,
				SRC_PRDCT_ID
			FROM
				COR_SRC_PRDCT'')
		LEFT OUTER JOIN GenIDPRSourceProduct
		    ON  MSC  = SourceSystem
		    AND SSK1 = SourceSystemKey1
		    AND SSK2 = SourceSystemKey2
		    AND SSK3 = SourceSystemKey3
		    AND SSK4 = SourceSystemKey4
		    AND SSK5 = SourceSystemKey5
		WHERE SourceSystem IS NULL'

	END

PRINT @PROCSQL

EXEC SP_EXECUTESQL @PROCSQL

RETURN 

GO
