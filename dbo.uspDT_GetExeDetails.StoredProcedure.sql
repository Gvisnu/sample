USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetExeDetails]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspDT_GetExeDetails]
(
	@PrgID INT
)
 AS

 SET NOCOUNT ON

SELECT 
       [Name]
      ,[Description]
      ,[WorkingDirectory]
      ,[Arguments]
FROM [Core1].[dbo].[DT_ExternalProgram]
Where [ExternalProgramID]=@PrgID

    
GO
