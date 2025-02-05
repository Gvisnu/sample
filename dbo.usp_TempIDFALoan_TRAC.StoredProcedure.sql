USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[usp_TempIDFALoan_TRAC]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_TempIDFALoan_TRAC] AS

DECLARE @JobID INT;      
      
SET @JobID = (SELECT MAX(JobID)      
              FROM MC_JobID      
              INNER JOIN MC_SourceFile      
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID      
              WHERE logicalName = 'TRACLoan'      
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)      
                                       FROM MC_SysProcessedLog      
                                       WHERE SystemID = 49));  
	

BEGIN
	
	SET NOCOUNT ON;
	insert into TempIDFALoan 
	(
	SOURCESYSTEM,
	SOURCESYSTEMKEY1,
	SOURCESYSTEMKEY2,
	SourceSystemKey3,
	SourceSystemKey4,
	JOBID
	)
SELECT 'TRAC' AS SourceSystem, 
LOAN_SYS_ATTR_KEY1_TEXT AS SourceSystemKey1, 
LOAN_SYS_ATTR_KEY2_TEXT AS SourceSystemKey2, 
LOAN_SYS_ATTR_KEY3_TEXT AS SourceSystemKey3, 
LOAN_SYS_ATTR_KEY4_TEXT AS SourceSystemKey4
,@JobID 
FROM  DBO.TRACLoan
END



GO
