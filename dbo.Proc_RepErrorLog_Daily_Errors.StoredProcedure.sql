USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_RepErrorLog_Daily_Errors]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_RepErrorLog_Daily_Errors]

AS
declare @sEnvironment as varchar(20)
declare @Count int
declare @DST int
declare @LC int
declare @LC2 int
declare @OMNI int
declare @EZP int
declare @MCS int
declare @TOTAL int
declare @Message varchar(200)
declare @subject varchar(40)


BEGIN	
	SET ANSI_NULLS  ON;
	SET ANSI_WARNINGS ON;
	SET NOCOUNT ON;

	--Extract the Errors and populate the Error log tables
	EXEC dbo.RepErrorLog_Extract;

	-- Get the error logs and create an excel sheet
	EXEC USP_EXPORT_DATA_TO_EXCEL 'Core1','SELECT * FROM Log_RepErrors','E:\Coretrans\PSRecon\Core_RepErrorLog_Errors.xls'


	-- send the email.
	IF @@SERVERNAME LIKE 'COREDEV%'
		set @sEnvironment='DEV'
	IF @@SERVERNAME LIKE 'COREQA%'
		set @sEnvironment='QA'
	IF @@SERVERNAME LIKE 'COREPROD%'
		set @sEnvironment='PROD'

	set @subject=@sEnvironment+' Rep Error Logs'
	
	SELECT @Count = COUNT(*)  FROM Core1.dbo.LOG_RepErrors
	SELECT @DST =   SUM(Error_Count) FROM Core1.dbo.LOG_RepErrors WHERE Error_Source = 'DST'
	SELECT @LC =    SUM(Error_Count) FROM Core1.dbo.LOG_RepErrors WHERE Error_Source = 'Navi'
	SELECT @LC2 =   SUM(Error_Count) FROM Core1.dbo.LOG_RepErrors WHERE Error_Source = 'LC2'
	SELECT @OMNI =  SUM(Error_Count) FROM Core1.dbo.LOG_RepErrors WHERE Error_Source = 'OMNI'
	SELECT @EZP =   SUM(Error_Count) FROM Core1.dbo.LOG_RepErrors WHERE Error_Source = 'EZP'
	SELECT @MCS =   SUM(Error_Count) FROM Core1.dbo.LOG_RepErrors WHERE Error_Source = 'MCS'
	SELECT @Total = SUM(Error_Count) FROM Core1.dbo.LOG_RepErrors

	set @Message='There were ' + cast(@Count as varchar) + ' errors involving ' + cast(@Total as varchar) + ' ERR table rows.'
	
	if(@DST>0)
	begin
		if(@DST=1)
			set @Message=@Message+' '+cast(@DST as varchar)+' is DST'
		else
			set @Message=@Message+' '+cast(@DST as varchar)+' are DST'
	end

	if(@LC>0)
	begin
		if(@LC=1)
			set @Message=@Message+' '+cast(@LC as varchar)+' is LifeCAD'
		else
			set @Message=@Message+' '+cast(@LC as varchar)+' are LifeCAD'
	end
	
	if(@LC2>0)
	begin
		if(@LC2=1)
			set @Message=@Message+' '+cast(@LC2 as varchar)+' is Traditional'
		else
			set @Message=@Message+' '+cast(@LC2 as varchar)+' are Traditional'
	end
	
	if(@OMNI>0)
	begin
		if(@OMNI=1)
			set @Message=@Message+' '+cast(@OMNI as varchar)+' is OMNI'
		else
			set @Message=@Message+' '+cast(@OMNI as varchar)+' are OMNI'
	end
	
	if(@EZP>0)
	begin
		if(@EZP=1)
			set @Message=@Message+' '+cast(@EZP as varchar)+' is EasyPay'
		else
			set @Message=@Message+' '+cast(@EZP as varchar)+' are EasyPay'
	end
	
	if(@MCS>0)
	begin
		if(@MCS=1)
			set @Message=@Message+' '+cast(@MCS as varchar)+' is MCS'
		else
			set @Message=@Message+' '+cast(@MCS as varchar)+' are MCS'
	end
	
	if(@Count>0)
	begin
		Exec USP_SQLEMAIL 'it-coreon-call@zinnia.com' ,'SP_Proc_RepErrorLog_Daily_Errors' , @subject,@Message, 'E:\Coretrans\PSRecon\Core_RepErrorLog_Errors.xls'
	end

END
GO
