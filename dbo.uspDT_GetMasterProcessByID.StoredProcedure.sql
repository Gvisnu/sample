USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetMasterProcessByID]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspDT_GetMasterProcessByID](@MasterProcessID int)
 AS

	SET NOCOUNT ON

    SELECT * 
    FROM dbo.DT_MasterProcess (NOLOCK)
    Where MasterProcessID = @MasterProcessID

RETURN 0

GO
