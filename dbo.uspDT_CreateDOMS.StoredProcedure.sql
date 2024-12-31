USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_CreateDOMS]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspDT_CreateDOMS]
(
	@MasterProcessID int	
)
AS
BEGIN
	Declare @MCSourceSystemID int
	
	Select @MCSourceSystemID = MCSourceSystemID 
		from DT_MasterProcess
			where MasterProcessID = @MasterProcessID

	if(@MCSourceSystemID is null)
	begin
		return 
	end

	Exec DOM_BUILD_TRANSFORM @MasterProcessID

END
GO
