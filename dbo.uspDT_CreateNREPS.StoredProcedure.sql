USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_CreateNREPS]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspDT_CreateNREPS]
(
	@MasterProcessID int	
)
AS
BEGIN
	Declare @MCSourceSystemID int
	Declare @NREPConnectionID int
	
	Select @MCSourceSystemID = MCSourceSystemID, @NREPConnectionID = NREPConnectionID 
		from DT_MasterProcess
			where MasterProcessID = @MasterProcessID

	if(@MCSourceSystemID is null)
	begin
		return 
	end

	if(@NREPConnectionID is null)
		Exec DPU_NREP_BUILD @MCSourceSystemID, @MasterProcessID
	else
		Exec DPU_NREP_BUILD @MCSourceSystemID, @MasterProcessID, @NREPConnectionID

END
GO
