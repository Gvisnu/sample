USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[DPU_NREP_BUILD]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DPU_NREP_BUILD] (@SYSTEMID INT,@MASTERPROCESSID INT, @CONNECTIONID INT = NULL) AS  
-------------------------------------------------------------------------------------  
--THIS PROCEDURE GENERATES INDIVIDUAL STORED PROCEDURES FOR EACH REP TABLE  
-------------------------------------------------------------------------------------  
DECLARE @MAXDATAPROCESSID INT  
DECLARE @PRECEDENCE INT  
DECLARE @TEMPTABLENAME VARCHAR(25)  
DECLARE @SYSPROCESSEDLOGID INT  
  
DECLARE @STAGEOUTPUTFOLDER VARCHAR(100)  
DECLARE @STAGETABLENAME VARCHAR(100)  
DECLARE @REPLOADTABLEID INT  
DECLARE @LAUNCHPRECEDENCE INT  
DECLARE @ERRORMESSAGE NVARCHAR(255)  
DECLARE @SUBSYSTEMID INT  
DECLARE @CORECONNECTIONID INT --Added for issue 3825  
DECLARE @PROC_TYPE NVARCHAR(10)  
   
SET ANSI_NULLS  ON;  
SET ANSI_WARNINGS ON;  
SET NOCOUNT ON;  
  
--Get the SubSystem information ....  
--Issue 3563  
SET @SUBSYSTEMID=(SELECT  isnull(SUBSYSTEMID,-1) FROM DT_MASTERPROCESS   
     WHERE MASTERPROCESSID = @MASTERPROCESSID)  
  
-- Delete the DOM Procedures entry in the DataProcess table for this master process if there is any   
DELETE FROM DT_DATAPROCESS WHERE  MASTERPROCESSID = @MASTERPROCESSID AND DataProcessName LIKE 'EXEC NREP_%'   
  
  
UPDATE PRM_REPLOADTABLES SET PROCESSID = NULL, SPID_1 = NULL   
WHERE SOURCEFILEID IN (SELECT SOURCEFILEID FROM MC_SOURCEFILE WHERE   
SYSTEMID = @SYSTEMID AND isnull(SUBSYSTEMID,-1)=@SUBSYSTEMID )  
  
  
IF @CONNECTIONID IS NULL  
BEGIN  
 SET  @CONNECTIONID  = (SELECT ConnectionId FROM DT_Connection WHERE ConnectionName = 'CoreOracleDB')  
END  
  
  
IF @CONNECTIONID IS NULL  
BEGIN  
    SET @ERRORMESSAGE = N'DPU_NREP_BUILD FAILED.  @CONNECTIONID IS NULL.'  
    RAISERROR (@ERRORMESSAGE, 16, 1)  
 RETURN 1  
END  
  
--Added for issue 3825  
SET  @CORECONNECTIONID  = (SELECT ConnectionId FROM DT_Connection WHERE ConnectionName = 'CoreDB')  
  
IF @CORECONNECTIONID IS NULL  
BEGIN  
    SET @ERRORMESSAGE = N'DPU_NREP_BUILD FAILED.  @CORECONNECTIONID IS NULL.'  
    RAISERROR (@ERRORMESSAGE, 16, 1)  
 RETURN 1  
END  
  
  
if not object_id('tempdb..#TEMP_DATAPROCESS') is null  
     drop table #TEMP_DATAPROCESS  
  
-------------------------------------------------------------------------------------  
--BUILD A TEMP TABLE TO CONTAIN THE HIGHER PRECEDENCE DATAPROCESS TO USE THE VALUES TO INSERT THE RECORDS FOR DOM  
-------------------------------------------------------------------------------------  
CREATE TABLE #TEMP_DATAPROCESS (  
 [DataProcessID] [int]  NOT NULL ,  
 [DataProcessName] [varchar] (75) NOT NULL ,  
 [MasterProcessID] [int] NOT NULL ,  
 [DataProcessTypeID] [int] NOT NULL ,  
 [Precedence] [int] NOT NULL ,  
 [Priority] [int] NOT NULL ,  
 [BatchSize] [int] NOT NULL ,  
 [Timeout] [int] NOT NULL ,  
 [SourceObject] [varchar] (50)  NULL ,  
 [DestObject] [varchar] (50)  NULL ,  
 [MetaDataMappingName] [varchar] (50) NULL ,  
 [SourceConnectionID] [int] NOT NULL ,  
 [DestConnectionID] [int] NULL ,  
 [MetaDataConnectionID] [int] NULL ,  
 [ProcessScript] [text]  NULL ,  
 [ConditionalQuery] [text]  NULL ,  
 [FormatFileContents] [text]  NULL ,  
 [AbortMasterProcessOnError] [bit] NOT NULL ,  
 [BypassOnPriorError] [bit] NOT NULL ,  
 [IsActive] [bit] NOT NULL ,  
 [IsDeleted] [bit] NOT NULL ,  
 [CreateDateTime] [datetime] NOT NULL ,  
 [LastUpdateDateTime] [datetime] NOT NULL ,  
 [MigrationFlag] [char] (1) NULL ,  
 [MigrationIssue] [int] NULL   
 )  
  
SET @MAXDATAPROCESSID = (SELECT MAX(DataProcessID) FROM DT_DATAPROCESS)  
  
-- Get the Max Precedence record for this Masterprocess and use the values to insert the records for DOM SP's into the DataProcess table  
INSERT INTO #TEMP_DATAPROCESS  
SELECT TOP 1 [DataProcessID],  
 [DataProcessName],  
 [MasterProcessID],  
 [DataProcessTypeID],  
 [Precedence],  
 [Priority],  
 [BatchSize],  
 [Timeout],  
 [SourceObject],  
 [DestObject],  
 [MetaDataMappingName],  
 [SourceConnectionID],  
 [DestConnectionID],  
 [MetaDataConnectionID],  
 [ProcessScript],  
 [ConditionalQuery],  
 [FormatFileContents],  
 [AbortMasterProcessOnError],  
 [BypassOnPriorError],  
 [IsActive],  
 [IsDeleted],  
 [CreateDateTime],  
 [LastUpdateDateTime],  
 [MigrationFlag],  
 [MigrationIssue]  
FROM DT_DATAPROCESS  
WHERE MASTERPROCESSID = @MASTERPROCESSID  
AND PRECEDENCE = ( SELECT MAX(PRECEDENCE) FROM DT_DATAPROCESS  
WHERE MASTERPROCESSID = @MASTERPROCESSID )  
  
-- Get the max Predence  
SET @PRECEDENCE = (SELECT [Precedence] FROM #TEMP_DATAPROCESS  )  
  
  
  
  
-------------------------------------------------------------------------------------  
--BUILD A CURSOR TO LOOP THROUGH EACH REP TABLE AND BUILD THE ASSOCIATED CONVERSION  
--STORED PROCEDURE  
-------------------------------------------------------------------------------------  
  
DECLARE CRSR_REPTABLE CURSOR FOR  
 select STAGEOUTPUTFOLDER ,   
 DBO.REP_STAGENAME(B.CORETABLENAME,A.REPLOADTABLEID) as stagetablename,   
 A.REPLOADTABLEID,  
 launchprecedence,  
 CASE WHEN INSERTIND = 1 AND UPDATEIND = 0 THEN 'SPI_' WHEN UPDATEIND = 1 THEN 'SPM_' END  
from prm_reploadtables a with(nolock)   
inner join prm_repcoretables b with(nolock) on a.repcoretableid = b.repcoretableid   
and a.systemid = @SYSTEMID  
AND isnull(SUBSYSTEMID,-1)=@SUBSYSTEMID  
 order by launchprecedence  
  
  
OPEN CRSR_REPTABLE  
FETCH Next FROM CRSR_REPTABLE INTO @STAGEOUTPUTFOLDER,@STAGETABLENAME,@REPLOADTABLEID, @LAUNCHPRECEDENCE,@PROC_TYPE  
  
WHILE @@FETCH_STATUS=0  
BEGIN  

 EXEC DPU_NREP_BUILD_ETL_OBJECTS @SYSTEMID ,@REPLOADTABLEID , @CONNECTIONID,@SUBSYSTEMID  
  
 -- Create an entry into the DT_DataProcess table for this new DOM Stored Procedure  
 SELECT @MAXDATAPROCESSID = @MAXDATAPROCESSID + 1  
  
 INSERT INTO DT_DATAPROCESS   
 (  
  [DataProcessID],  
  [DataProcessName],  
  [MasterProcessID],  
  [DataProcessTypeID],  
  [Precedence],  
  [Priority],  
  [BatchSize],  
  [Timeout],  
  [SourceObject],  
  [DestObject],  
  [MetaDataMappingName],  
  [SourceConnectionID],  
  [DestConnectionID],  
  [MetaDataConnectionID],  
  [ProcessScript],  
  [ConditionalQuery],  
  [FormatFileContents],  
  [AbortMasterProcessOnError],  
  [BypassOnPriorError],  
  [IsActive],  
  [IsDeleted],  
  [CreateDateTime],  
  [LastUpdateDateTime],  
  [MigrationFlag],  
  [MigrationIssue]  
 )SELECT @MAXDATAPROCESSID AS DataProcessID,  
  'EXEC NREP_' + @STAGETABLENAME  AS  DataProcessName,  
  TD.MasterProcessID,  
  2,--TD.DataProcessTypeID,--updated for issue 3825  
  @PRECEDENCE + @LAUNCHPRECEDENCE AS Precedence, -- Add the launchingprecedence with the maximum precedence  
  TD.Priority,  
  TD.BatchSize,  
  TD.Timeout,  
  'dbo.REP_' + @STAGETABLENAME, --TD.SourceObject,--updated for issue 3825  
  'SBGSTAGE.' + @STAGETABLENAME As DestObject,--TD.DestObject,--updated for issue 3825  
  TD.MetaDataMappingName,  
  TD.SourceConnectionID,  
  @CORECONNECTIONID,--updated for issue 3825  
  TD.MetaDataConnectionID,  
  'EXEC NREP_' + @STAGETABLENAME + ' ' + CAST(@SYSTEMID AS VARCHAR) + ','+ CAST(@CONNECTIONID AS VARCHAR) AS ProcessScript,  
  TD.ConditionalQuery,  
  TD.FormatFileContents,  
  TD.AbortMasterProcessOnError,  
  TD.BypassOnPriorError,  
  TD.IsActive,  
  TD.IsDeleted,  
  GETDATE() AS CreateDateTime,  
  GETDATE() AS LastUpdateDateTime,  
  TD.MigrationFlag,  
  TD.MigrationIssue  
  FROM #TEMP_DATAPROCESS TD  
   
 FETCH Next FROM CRSR_REPTABLE INTO @STAGEOUTPUTFOLDER,@STAGETABLENAME,@REPLOADTABLEID,@LAUNCHPRECEDENCE,@PROC_TYPE  
END  
  
CLOSE CRSR_REPTABLE  
DEALLOCATE CRSR_REPTABLE  
  
DROP TABLE #TEMP_DATAPROCESS  
  
  
RETURN  
GO
