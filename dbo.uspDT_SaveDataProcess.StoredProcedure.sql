USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_SaveDataProcess]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE                    PROCEDURE [dbo].[uspDT_SaveDataProcess]
(@DataProcessXML as text,
  @ProcessScript text,
  @FormatFileContents text,
  @ConditionalQuery text) AS

SET NOCOUNT ON

DECLARE @xmlHandle int
DECLARE @DataProcessID int

SET @DataProcessID = 0

DECLARE @DataProcessXMLTable TABLE(DataProcessID int,
                MasterProcessID int,  
                DataProcessName varchar(75),
                DataProcessTypeID int,
                IsActive bit,
                AbortMasterProcessOnError bit,
				BypassOnPriorError bit,
                SourceObject varchar(50),
                DestObject varchar(50), 
                MetaDataMappingName varchar(50),
                Timeout int,
                BatchSize int,
                Priority int,
                Precedence int,
                SourceConnectionID int,
                DestConnectionID int,
                MetaDataConnectionID int,
				MigrationIssue int,
				MigrationFlag varchar(1),
				CTLTransactionID int)

EXEC sp_xml_preparedocument @xmlHandle OUT, @DataProcessXML

--Microsoft Workaround for OpenXML
INSERT INTO @DataProcessXMLTable
Select *
    From OPENXML (@xmlHandle, '/DataProcess',8)
      WITH (DataProcessID int,
                MasterProcessID int,  
                DataProcessName varchar(75),
                DataProcessTypeID int,
                IsActive bit,
                AbortMasterProcessOnError bit,
				BypassOnPriorError bit,
                SourceObject varchar(50),
                DestObject varchar(50), 
                MetaDataMappingName varchar(50),
                Timeout int,
                BatchSize int,
                Priority int,
                Precedence int,
                SourceConnectionID int,
                DestConnectionID int,
                MetaDataConnectionID int,
				MigrationIssue int,
				MigrationFlag varchar(1),
				CTLTransactionID int)


Select @DataProcessID = DataProcessID
FROM @DataProcessXMLTable

If @DataProcessID = 0
  Begin
    --Insert
    Insert Into DT_DataProcess
    (MasterProcessID, DataProcessName,IsActive,AbortMasterProcessOnError,BypassOnPriorError,
      SourceObject,DestObject,MetaDataMappingName,Timeout,BatchSize,Priority,Precedence,
      SourceConnectionID, DestConnectionID, MetaDataConnectionID, DataProcessTypeID,
      ProcessScript,FormatFileContents, ConditionalQuery, LastUpdateDateTime, MigrationIssue, MigrationFlag,CTLTransactionID)
    Select MasterProcessID, DataProcessName,IsActive,AbortMasterProcessOnError,BypassOnPriorError,
      SourceObject,DestObject,MetaDataMappingName,Timeout,BatchSize,Priority,Precedence,
      SourceConnectionID, DestConnectionID, MetaDataConnectionID, DataProcessTypeID,
      @ProcessScript,@FormatFileContents, @ConditionalQuery, GetDate(), MigrationIssue, MigrationFlag,CTLTransactionID
    From @DataProcessXMLTable

    Select @DataProcessID = SCOPE_IDENTITY()

  End
Else
  Begin
    --Update
    Update DT_DataProcess
    Set MasterProcessID = XMLData.MasterProcessID, 
        DataProcessName = XMLData.DataProcessName,
        IsActive = XMLData.IsActive,
        AbortMasterProcessOnError = XMLData.AbortMasterProcessOnError,
	BypassOnPriorError = XMLData.BypassOnPriorError,
        SourceObject = XMLData.SourceObject,
        DestObject = XMLData.DestObject,
        MetaDataMappingName = XMLData.MetaDataMappingName,
        Timeout = XMLData.Timeout,
        BatchSize = XMLData.BatchSize,
        Priority = XMLData.Priority,
        Precedence = XMLData.Precedence,
        SourceConnectionID = XMLData.SourceConnectionID, 
        DestConnectionID = XMLData.DestConnectionID,
        MetaDataConnectionID = XMLData.MetaDataConnectionID,
        DataProcessTypeID = XMLData.DataProcessTypeID,
        ProcessScript = @ProcessScript,
        FormatFileContents = @FormatFileContents,
        ConditionalQuery = @ConditionalQuery,
        LastUpdateDateTime = GetDate(),
	MigrationIssue = XMLData.MigrationIssue,  
	MigrationFlag = XMLData.MigrationFlag,
	CTLTransactionID = XMLDATA.CTLTransactionID
    From @DataProcessXMLTable as XMLData
      WHERE DT_DataProcess.DataProcessID = XMLData.DataProcessID
  End

EXEC sp_xml_removedocument @xmlHandle

Select @DataProcessID as DataProcessID

RETURN 0
GO
