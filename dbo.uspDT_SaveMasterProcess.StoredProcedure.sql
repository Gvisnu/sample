USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_SaveMasterProcess]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspDT_SaveMasterProcess]
(@MasterProcessID int, @MasterProcessName varchar(75), @MasterProcessShortName varchar(10), 
	@ExportFileFolder varchar(255), @ImportFileFolder varchar(255), @SupportEmailFrom varchar(200), @SupportEmailTo varchar(200), 
	@MigrationFlag char(1), @MigrationIssue int,@FailureEmailTo varchar(255),@Timeout int,@System int) AS

SET NOCOUNT ON

If  @SupportEmailTo = ''
	SET @SupportEmailTo = NULL

If  @FailureEmailTo = ''
	SET @FailureEmailTo = NULL

--Issue 3259-Include Timeout option and SourceSystem in MasterProcess
If @System =''
	SET @System = NULL

If @Timeout ='' OR @Timeout=0
	SET @Timeout = NULL

If @MasterProcessID = 0
  Begin
    --Insert
    Insert Into DT_MasterProcess
      (MasterProcessName, MasterProcessShortName, ExportFileFolder, 
				ImportFileFolder, Timeout,SupportEmailFrom, SupportEmailTo, MigrationFlag, 
				MigrationIssue, CreateDateTime,FailureEmailTo,MCSourceSystemID)-- Added by Kamal
    values(@MasterProcessName, @MasterProcessShortName, @ExportFileFolder, 
				@ImportFileFolder,@Timeout,@SupportEmailFrom, @SupportEmailTo, @MigrationFlag, 
				@MigrationIssue, GetDate(),@FailureEmailTo,@System)

    Select @MasterProcessID = SCOPE_IDENTITY()
  End
Else
  Begin
    --Update
    Update DT_MasterProcess
    Set MasterProcessName = @MasterProcessName,
		MasterProcessShortName = @MasterProcessShortName,
		ExportFileFolder = @ExportFileFolder,
		ImportFileFolder = @ImportFileFolder,
		SupportEmailFrom = @SupportEmailFrom,
		SupportEmailTo = @SupportEmailTo,
		MigrationFlag = @MigrationFlag,
		MigrationIssue = @MigrationIssue,
		FailureEmailTo = @FailureEmailTo,   -- Added by Kamal
		Timeout=@Timeout,--Issue 3259
		MCSourceSystemID=@System --Issue 3259
    WHERE DT_MasterProcess.MasterProcessID = @MasterProcessID
  End

Select @MasterProcessID as MasterProcessID

RETURN 0

SET ANSI_NULLS OFF
GO
