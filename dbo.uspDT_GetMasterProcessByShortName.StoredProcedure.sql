USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetMasterProcessByShortName]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[uspDT_GetMasterProcessByShortName]
(@MasterProcessShortName varchar(20))
 AS

  SET NOCOUNT ON

    SELECT * 
    FROM dbo.DT_MasterProcess (NOLOCK)
    Where IsDeleted = 0
	and MasterProcessShortName = @MasterProcessShortName

GO
