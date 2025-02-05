USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_InsertErrorLog]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[uspDT_InsertErrorLog]
(@ProcessDescription varchar(250),
@MasterProcessLogID int,
@DataProcessLogID int,
@ErrorDateTime datetime,
@ErrorText text) AS

SET NOCOUNT ON

INSERT INTO DT_ErrorLog
  (ProcessDescription, MasterProcessLogID, DataProcessLogID, ErrorDateTime, ErrorText)
Values
  (@ProcessDescription, @MasterProcessLogID, @DataProcessLogID, @ErrorDateTime, @ErrorText)

GO
