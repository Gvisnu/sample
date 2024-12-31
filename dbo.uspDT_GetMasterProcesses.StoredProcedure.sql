USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetMasterProcesses]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE                            PROCEDURE [dbo].[uspDT_GetMasterProcesses] 
 AS

  SET NOCOUNT ON

    SELECT * 
    FROM dbo.DT_MasterProcess (NOLOCK)
    Where IsDeleted = 0
    ORDER BY MasterProcessName

GO
