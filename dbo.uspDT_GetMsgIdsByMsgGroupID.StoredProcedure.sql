USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetMsgIdsByMsgGroupID]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspDT_GetMsgIdsByMsgGroupID]
(@MsgGroupID varchar(255))
 AS

  SET NOCOUNT ON

    SELECT PhoneNumber+'@'+Carrier as MsgTo 
    FROM dbo.DT_TxtMsgGroups (NOLOCK)
    Where TxtMsgGroupID = @MsgGroupID

   
GO
