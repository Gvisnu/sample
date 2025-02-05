USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Delete_Dom_Dataprocess_Entries]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[Proc_Delete_Dom_Dataprocess_Entries]
 AS

SET NOCOUNT ON;

-- delete the DOM generated storeprocedure entries from the Data process table
DELETE FROM DT_DATAPROCESS 
WHERE  DataProcessName LIKE 'EXEC DOM_COR%';

-- Reset 
UPDATE PRM_DomainChildren SET ProcessID = NULL;


SET NOCOUNT ON;
GO
