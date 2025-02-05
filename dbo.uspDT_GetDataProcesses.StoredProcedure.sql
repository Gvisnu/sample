USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetDataProcesses]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE    PROCEDURE [dbo].[uspDT_GetDataProcesses] 
(@MasterProcessID int,
  @RetreiveForEdit bit,
  @IsNightlyCycle bit = 1)
 AS

  SET NOCOUNT ON
If @RetreiveForEdit = 1
  Begin
    SELECT *
    FROM dbo.DT_DataProcess (NOLOCK)
    Where MasterProcessID = @MasterProcessID
    And IsDeleted = 0
    ORDER BY DataProcessName
  End
Else
  Begin
   If @IsNightlyCycle = 1
   Begin
		SELECT DP.*, 
			CASE WHEN DATALENGTH(ISNULL(DP.FormatFileContents, '')) = 0 Then 0 Else 1 End as UsesFormatFile,
			CASE WHEN DATALENGTH(ISNULL(DP.ConditionalQuery, '')) = 0 Then 0 Else 1 End as ISConditional,
			CASE WHEN DP.DestConnectionID IS NULL Then 0 Else 1 End as PerformDataImport,
			SourceConn.ConnectionString AS SourceConnectionString,
			SourceConn.DatabaseTypeID as SourceDatabaseTypeID,
			DestConn.ConnectionString AS DestConnectionString,
			DestConn.DatabaseTypeID as DestDatabaseTypeID,
			MetaConn.ConnectionString AS MetaDataConnectionString,
			MetaConn.DatabaseTypeID as MetaDataDatabaseTypeID
		FROM dbo.DT_DataProcess DP (NOLOCK)
		LEFT OUTER  JOIN dbo.DT_Connection SourceConn (NOLOCK)  -- Kamal 08/15/2008
				  ON DP.SourceConnectionID = SourceConn.ConnectionID
		LEFT OUTER JOIN dbo.DT_Connection DestConn  (NOLOCK)
				  ON DP.DestConnectionID = DestConn.ConnectionID
		LEFT OUTER JOIN dbo.DT_Connection MetaConn  (NOLOCK)
			  ON DP.MetaDataConnectionID = MetaConn.ConnectionID
		Where DP.MasterProcessID = @MasterProcessID
		  AND DP.IsDeleted = 0
		  AND DP.ISActive = 1
		ORDER BY DP.Precedence, DP.Priority, DP.DataProcessID
   End		
   Else
   Begin
		SELECT DP.*, 
			CASE WHEN DATALENGTH(ISNULL(DP.FormatFileContents, '')) = 0 Then 0 Else 1 End as UsesFormatFile,
			CASE WHEN DATALENGTH(ISNULL(DP.ConditionalQuery, '')) = 0 Then 0 Else 1 End as ISConditional,
			CASE WHEN DP.DestConnectionID IS NULL Then 0 Else 1 End as PerformDataImport,
			SourceConn.RealtimeConnectionString AS SourceConnectionString, --Added for issue 3552
			SourceConn.DatabaseTypeID as SourceDatabaseTypeID,
			DestConn.ConnectionString AS DestConnectionString,
			DestConn.DatabaseTypeID as DestDatabaseTypeID,
			MetaConn.ConnectionString AS MetaDataConnectionString,
			MetaConn.DatabaseTypeID as MetaDataDatabaseTypeID
		FROM dbo.DT_DataProcess DP (NOLOCK)
		LEFT OUTER  JOIN dbo.DT_Connection SourceConn (NOLOCK)  -- Kamal 08/15/2008
				  ON DP.SourceConnectionID = SourceConn.ConnectionID
		LEFT OUTER JOIN dbo.DT_Connection DestConn  (NOLOCK)
				  ON DP.DestConnectionID = DestConn.ConnectionID
		LEFT OUTER JOIN dbo.DT_Connection MetaConn  (NOLOCK)
			  ON DP.MetaDataConnectionID = MetaConn.ConnectionID
		Where DP.MasterProcessID = @MasterProcessID
		  AND DP.IsDeleted = 0
		  AND DP.ISActive = 1
		ORDER BY DP.Precedence, DP.Priority, DP.DataProcessID
   End
  End

RETURN 0


GO
