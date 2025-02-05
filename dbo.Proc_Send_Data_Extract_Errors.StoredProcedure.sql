USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Send_Data_Extract_Errors]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Proc_Send_Data_Extract_Errors]
(
@System_Name CHAR(4),
@Err_zip_file_path VARCHAR(500) 
)
AS
DECLARE @MSG VARCHAR(8000)

DECLARE @ENV VARCHAR(4)
DECLARE @FROM VARCHAR(255)
DECLARE @TO VARCHAR(255)
DECLARE @SUBJ VARCHAR(255)
DECLARE @REC_COUNT numeric(10)
DECLARE @file_exists INT

BEGIN

	-- Check the file exist or not

	EXEC master..xp_fileexist @Err_zip_file_path, @file_exists  out

	--send the email only if the file exists
	If @file_exists = 1 
	BEGIN
		SET @SUBJ = @@ServerName+ ' ' + @System_Name + ' CYCLE - BULK INSERT Error - Invalid SourceSystem Data when loading tables.'

		INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM)
		SELECT	GETDATE(),
			@SUBJ,
			'REFER TO THE ZIP FILE - ' + @Err_zip_file_path,
			'BULK INSERT',
			@System_Name
		


		SET @FROM = 'it-coreon-call@securitybenefit.com'
		SET @TO =   'Proc_Send_Data_Extract_Errors'

		SELECT @MSG =
			   'Bulk Insert has failed with some error records.'  + CHAR(13) + CHAR(10) +
			   'Error file(s) available in the ' +  @Err_zip_file_path + CHAR(13) + CHAR(10) +
			   'Please investigate these record(s). ' + CHAR(13) + CHAR(10) +
			   'Thank you.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

		-- Get the error logs and create an excel sheet
		EXEC USP_SQLEmail @FROM, @TO, @SUBJ,@MSG, @Err_zip_file_path
	END

END



GO
