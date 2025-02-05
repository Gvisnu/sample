USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetEmailIdsByEmailGroupID]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspDT_GetEmailIdsByEmailGroupID]
(@EmailGroupID varchar(255))
 AS

  SET NOCOUNT ON

    SELECT EmailAddress 
    FROM dbo.DT_EmailGroups (NOLOCK)
    Where EmailGroupID = @EmailGroupID

   IF @@ROWCOUNT = 0
	RAISERROR ('EMAILGROUPID NOT FOUND IN DT_EMAILGROUPS TABLE.', 16, 1)

GO
