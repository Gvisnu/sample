USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_ETL_MC_JobID]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_ETL_MC_JobID] AS

DECLARE	@FILEID INT,
	@SPLID INT

---
-- Build a cursor of files that need Job ID.
---

Declare ExecCursor Cursor Local Fast_Forward For
	SELECT	F.SourceFileID,
		P.SysProcessedLogID
	FROM MC_SourceSystem S
	INNER JOIN MC_SysProcessedLog P
	ON P.SystemID = S.SystemID
	INNER JOIN MC_SourceFile F
	ON F.SystemID = P.SystemID
	LEFT OUTER JOIN MC_JobID J
	ON  J.SysProcessedLogID = P.SysProcessedLogID
	AND J.SourceFileID = F.SourceFileID
	WHERE S.EndDate IS NULL
	  AND P.Finished = 'F'
	  AND F.EndDate IS NULL
	  AND J.JobID IS NULL

Open ExecCursor
Fetch Next From ExecCursor Into @FILEID, @SPLID

While (@@Fetch_Status <> -1)
Begin

	INSERT INTO MC_JobID
	(JobID,DateStarted,DateEnded,SourceFileID,ReplicatedToETL,SysProcessedLogID)
	SELECT	(SELECT JOB_ID FROM OPENQUERY(CORE,'SELECT SEQ_COR_JOB_ID.NextVal AS JOB_ID FROM DUAL')),
		GETDATE(),
		NULL,
		@FILEID,
		'N',
		@SPLID
	
	Fetch Next From ExecCursor Into @FILEID, @SPLID

End

Close ExecCursor
Deallocate ExecCursor

Return

GO
