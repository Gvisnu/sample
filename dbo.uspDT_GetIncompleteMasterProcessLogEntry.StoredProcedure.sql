USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetIncompleteMasterProcessLogEntry]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE       PROCEDURE [dbo].[uspDT_GetIncompleteMasterProcessLogEntry] (
    @MasterProcessID int)
AS

SET NOCOUNT ON

--Get any MasterProcess instances for the supplied MasterProcessID
--  that are not complete
Select TOP 1 *
from DT_MasterProcessLog
Where ProcessStatusID NOT IN(4, 7) --(4)Complete,(7)VerificationFailed 
and MasterProcessID = @MasterProcessID
Order by StartDateTime

RETURN 0


GO
