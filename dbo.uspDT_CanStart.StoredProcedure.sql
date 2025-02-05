USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_CanStart]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspDT_CanStart]
AS
BEGIN
	Declare @QueueCount Int	
	Select @QueueCount=Count(*) 
	from EventManagement.dbo.Queue Q
	join EventManagement.dbo.ExternalProgram EP
	on Q.EventID = EP.ExternalProgramID
    where CharIndex('DataProcessUtility.exe',StartPath) > 0
	if(@QueueCount > 0)
	begin
		RAISERROR ('ITEMS FOR THE DATAPROCESSUTILITY EXIST IN THE QUEUE', 16, 1) 
	end
END




	
GO
