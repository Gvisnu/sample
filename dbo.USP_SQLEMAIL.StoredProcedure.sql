USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_SQLEMAIL]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_SQLEMAIL] 
   @From varchar(100) ,
   @To varchar(255) ,
   @PrmSubject varchar(255),
   @BodyMessage varchar(8000) ,
   @Attachment varchar(200)= " "

AS

Declare @output varchar(1000)
DECLARE @TOEMAILIDS varchar(8000)
DECLARE @profilename varchar(100)	
DECLARE @RETURNCODE INT
	--added for issue 7094
	SET @profilename = (SELECT Appsettingvalue from Core1.dbo.DT_AppSetting WHERE Appsetting = 'SQLEmailProfileName')

	--get the email addresses for the particular email group id
	SELECT @TOEMAILIDS = core1.dbo.fn_getEmailIdsbyEmailGroupID(@To)

	IF LEN(@TOEMAILIDS) <= 0 
	BEGIN
		SET @TOEMAILIDS	= 'it-coreon-call@zinnia.com'
	END
	

	if @Attachment <> ' ' 
	BEGIN
		EXEC  @RETURNCODE = msdb.dbo.sp_send_dbmail @profile_name=@profilename,
		@from_address=@from,  
		@recipients= @TOEMAILIDS,
		@subject=@PrmSubject,
		@body=@BodyMessage,
		@file_attachments = @Attachment
	End 
	ELSE
	BEGIN
		EXEC @RETURNCODE = msdb.dbo.sp_send_dbmail @profile_name=@profilename,
		@from_address=@from,
		@recipients= @TOEMAILIDS,
		@subject=@PrmSubject,
		@body=@BodyMessage

	END


	---- if there is no email ids found for the specific emailgroup id then send a email to it-core on-call group
	IF LEN(@TOEMAILIDS) <= 0 
	BEGIN
		SET @PrmSubject = 'EMAILGROUPID ' + @To + ' NOT FOUND IN DT_EMAILGROUPS TABLE.'

		EXEC @RETURNCODE = msdb.dbo.sp_send_dbmail @profile_name=@profilename,
		@from_address=@from,  
		@recipients= @TOEMAILIDS,
		@subject=@PrmSubject,
		@body=@PrmSubject
	END

RETURN


GO
