USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Z_SBG_SP_Migrate_MC_Data]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Z_SBG_SP_Migrate_MC_Data]

/*************************************************************************/
/*                                                                       */
/*  This stored procedure copies data from specific MC_.. tables in the  */
/*  Core1 database on CORESQLQA\CORESQLDEV1, to corresponding MC_..      */
/*  tables in the Core1 database on CORESQLPROD\CORESQLPROD1.            */
/*                                                                       */
/*  The specific tables are:                                             */
/*    MC_CycleDateLocation                                               */
/*    MC_DeltaParams                                                     */
/*    MC_DTSParams                                                       */
/*    MC_EARMultiFiles                                                   */
/*    MC_EARMultiParams                                                  */
/*    MC_EARParams                                                       */
/*    MC_HeaderMerger                                                    */
/*    MC_HeaderMergerFields                                              */
/*    MC_HeaderMergerIDSplit                                             */
/*    MC_Module                                                          */
/*    MC_PkgData                                                         */
/*    MC_PostDTSTruncate                                                 */
/*    MC_RelativePaths                                                   */
/*    MC_SequenceAdder                                                   */
/*    MC_ServerName                                                      */
/*    MC_SourceFile                                                      */
/*    MC_SourceFileModule                                                */
/*    MC_SourceSystem                                                    */
/*    MC_SyncSortParams                                                  */
/*    MC_TelleMergerParams                                               */
/*    UDP_Domain                                                         */
/*                                                                       */
/*  Written by Cal Wrightsman, Nov. 2001.                                */
/*                                                                       */
/*  Last Updated: Friday, Nov. 16, 2001 at 2:20 PM.                      */
/*                                                                       */
/*************************************************************************/

	@issueno	int	      /* input parameter - issue number. */

AS

/*************************************************************************/
/*  Create a temporary table and load the issue number.                  */
/*************************************************************************/
CREATE TABLE dbo.Temp_Issue_No_Table
       (Issue_Nbr		int)

INSERT INTO Temp_Issue_No_Table VALUES(@issueno)

/*************************************************************************/
/*  Migrate rows in the MC_CycleDateLocation table.                      */
/*************************************************************************/
DELETE MC_CycleDateLocation
FROM CORESQLDEV1.Core1.dbo.MC_CycleDateLocation dev,
     MC_CycleDateLocation prod,
     Temp_Issue_No_Table
WHERE prod.SystemID = dev.SystemID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_CycleDateLocation
      (SystemID, SourceFileID, DateStartByte, DateByteLength,
       DateFormat, MigrationFlag, MigrationIssue)
SELECT SystemID, SourceFileID, DateStartByte, DateByteLength,
       DateFormat, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_CycleDateLocation dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_DeltaParams table.                            */
/*************************************************************************/
DELETE MC_DeltaParams
FROM CORESQLDEV1.Core1.dbo.MC_DeltaParams dev,
     MC_DeltaParams prod,
     Temp_Issue_No_Table
WHERE prod.DeltaParamID = dev.DeltaParamID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_DeltaParams
      (DeltaParamID, startdate, enddate, TodayFileName, YesterFileName,
       SaveToFileName, KeyStart, KeyLength, RecLength, SourceFileID,
       TodayPath, YesterPath, SaveToPath, DeltaYesNo,
       MigrationFlag, MigrationIssue)
SELECT DeltaParamID, startdate, enddate, TodayFileName, YesterFileName,
       SaveToFileName, KeyStart, KeyLength, RecLength, SourceFileID,
       TodayPath, YesterPath, SaveToPath, DeltaYesNo,
       MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_DeltaParams dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_DTSParams table.                              */
/*************************************************************************/
DELETE MC_DTSParams
FROM CORESQLDEV1.Core1.dbo.MC_DTSParams dev,
     MC_DTSParams prod,
     Temp_Issue_No_Table
WHERE prod.DTSParamID = dev.DTSParamID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_DTSParams
      (DTSParamID, StartDate, EndDate, FileName, SourceFileID,
       Priority, DestinationTable, MigrationFlag, MigrationIssue)
SELECT DTSParamID, StartDate, EndDate, FileName, SourceFileID,
       Priority, DestinationTable, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_DTSParams dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_EARMultiFiles table.                          */
/*************************************************************************/
DELETE MC_EARMultiFiles
FROM CORESQLDEV1.Core1.dbo.MC_EARMultiFiles dev,
     MC_EARMultiFiles prod,
     Temp_Issue_No_Table
WHERE prod.EARParamID = dev.EARParamID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_EARMultiFiles
      (EARParamID, StartDate, EndDate, SourceFileID, SourceFilePath,
       SourceFileName,DestFilePath1, DestFilePath2, DestFilePath3,
       DestFileName1, DestFileName2, DestFileName3, FirstArray,
       SecondArray, ThirdArray, RecordLength, HeaderLength,
       MigrationFlag, MigrationIssue)
SELECT EARParamID, StartDate, EndDate, SourceFileID, SourceFilePath,
       SourceFileName, DestFilePath1, DestFilePath2, DestFilePath3,
       DestFileName1, DestFileName2, DestFileName3, FirstArray,
       SecondArray, ThirdArray, RecordLength, HeaderLength,
       MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_EARMultiFiles dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_EARMultiParams table.                         */
/*************************************************************************/
DELETE MC_EARMultiParams
FROM CORESQLDEV1.Core1.dbo.MC_EARMultiParams dev,
     MC_EARMultiParams prod,
     Temp_Issue_No_Table
WHERE prod.EARParamID = dev.EARParamID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_EARMultiParams
      (EARParamID, StartDate, EndDate, SourceFileID, SourceFilePath,
       SourceFileName, DestFilePath, DestFileName, RecordLength,
       StartFromCharNum, CharsToCut, MoveTo, MigrationFlag, MigrationIssue)
SELECT EARParamID, StartDate, EndDate, SourceFileID, SourceFilePath,
       SourceFileName, DestFilePath, DestFileName, RecordLength,
       StartFromCharNum, CharsToCut, MoveTo, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_EARMultiParams dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_EARParams table.                              */
/*************************************************************************/
DELETE MC_EARParams
FROM CORESQLDEV1.Core1.dbo.MC_EARParams dev,
     MC_EARParams prod,
     Temp_Issue_No_Table
WHERE prod.EARParamID = dev.EARParamID
  AND dev.MigrationIssue = Issue_Nbr

SET IDENTITY_INSERT MC_EARParams ON

INSERT INTO MC_EARParams
      (EARParamID, Precedence, StartDate, EndDate, SourceFileID,
       SourceFilePath, SourceFileName, DestFilePath, DestFileName,
       RecordLength, HeaderLength, ArrayCompLength, ArrayCompQuantity,
       ElementCount, RunSyncSort, SyncSortSourcePath,
       SyncSortSourceFileName, MigrationFlag, MigrationIssue)
SELECT EARParamID, Precedence, StartDate, EndDate, SourceFileID,
       SourceFilePath, SourceFileName, DestFilePath, DestFileName,
       RecordLength, HeaderLength, ArrayCompLength, ArrayCompQuantity,
       ElementCount, RunSyncSort, SyncSortSourcePath,
       SyncSortSourceFileName, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_EARParams dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

SET IDENTITY_INSERT MC_EARParams OFF

/*************************************************************************/
/*  Migrate rows in the MC_HeaderMerger table.                           */
/*************************************************************************/
DELETE MC_HeaderMerger
FROM CORESQLDEV1.Core1.dbo.MC_HeaderMerger dev,
     MC_HeaderMerger prod,
     Temp_Issue_No_Table 
WHERE prod.HeaderMergerID = dev.HeaderMergerID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_HeaderMerger
      (HeaderMergerID, SplitFileName, HeaderIndicator, SourceFileID,
       LoadPath, SavePath, HeaderRecordLength, DetailRecordLength,
       HeaderMergerIdSplitID, MigrationFlag, MigrationIssue)
SELECT HeaderMergerID, SplitFileName, HeaderIndicator, SourceFileID,
       LoadPath, SavePath, HeaderRecordLength, DetailRecordLength,
       HeaderMergerIdSplitID, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_HeaderMerger dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_HeaderMergerFields table.                     */
/*************************************************************************/
DELETE MC_HeaderMergerFields
FROM CORESQLDEV1.Core1.dbo.MC_HeaderMergerFields dev,
     MC_HeaderMergerFields prod,
     Temp_Issue_No_Table
WHERE prod.HeaderMergerFieldID = dev.HeaderMergerFieldID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_HeaderMergerFields
      (HeaderMergerFieldID, HeaderMergerID, HeaderFieldStart,
       HeaderFieldLength, DetailStartPosition,
       MigrationFlag, MigrationIssue)
SELECT HeaderMergerFieldID, HeaderMergerID, HeaderFieldStart,
       HeaderFieldLength, DetailStartPosition,
       MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_HeaderMergerFields dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_HeaderMergerIDSplit table.                    */
/*************************************************************************/
DELETE MC_HeaderMergerIDSplit
FROM CORESQLDEV1.Core1.dbo.MC_HeaderMergerIDSplit dev,
     MC_HeaderMergerIDSplit prod,
     Temp_Issue_No_Table
WHERE prod.HeaderMergerIdSplitID = dev.HeaderMergerIdSplitID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_HeaderMergerIDSplit
      (HeaderMergerIdSplitID, SplitFileName, SavePath, KeyLength,
       KeyStart, MigrationFlag, MigrationIssue)
SELECT HeaderMergerIdSplitID, SplitFileName, SavePath, KeyLength,
       KeyStart, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_HeaderMergerIDSplit dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_Module table.                                 */
/*************************************************************************/
DELETE MC_Module
FROM CORESQLDEV1.Core1.dbo.MC_Module dev,
     MC_Module prod,
     Temp_Issue_No_Table
WHERE prod.ModuleID = dev.ModuleID
  AND dev.MigrationIssue = Issue_Nbr
 
INSERT INTO MC_Module
      (ModuleID, Description, MigrationFlag, MigrationIssue)
SELECT ModuleID, Description, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_Module dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_PkgData table.                                */
/*************************************************************************/
DELETE MC_PkgData
FROM CORESQLDEV1.Core1.dbo.MC_PkgData dev,
     MC_PkgData prod,
     Temp_Issue_No_Table
WHERE prod.ID = dev.ID
  AND dev.MigrationIssue = Issue_Nbr

SET IDENTITY_INSERT MC_PkgData ON

INSERT INTO MC_PkgData
      (ID, PackageName, PackageDescription, PackageID, PackageVersion,
       PackageExecutionLineage, ExecutedOn, ExecutedBy, ExecutionStarted,
       ExecutionCompleted, PumpStatus, MigrationFlag, MigrationIssue)
SELECT ID, PackageName, PackageDescription, PackageID, PackageVersion,
       PackageExecutionLineage, ExecutedOn, ExecutedBy, ExecutionStarted,
       ExecutionCompleted, PumpStatus, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_PkgData dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

SET IDENTITY_INSERT MC_PkgData OFF

/*************************************************************************/
/*  Migrate rows in the MC_PostDTSTruncate table.                        */
/*************************************************************************/
DELETE MC_PostDTSTruncate
FROM CORESQLDEV1.Core1.dbo.MC_PostDTSTruncate dev,
     MC_PostDTSTruncate prod,
     Temp_Issue_No_Table 
WHERE prod.PackageName = dev.PackageName 
  AND prod.TableName = dev.TableName 
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_PostDTSTruncate
      (PackageName, TableName, MigrationFlag,
       MigrationIssue, ReadyToTruncate)
SELECT PackageName, TableName, MigrationFlag,
       MigrationIssue, ReadyToTruncate
FROM CORESQLDEV1.Core1.dbo.MC_PostDTSTruncate dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_RelativePaths table.                          */
/*************************************************************************/
DELETE MC_RelativePaths
FROM CORESQLDEV1.Core1.dbo.MC_RelativePaths dev,
     MC_RelativePaths prod,
     Temp_Issue_No_Table
WHERE prod.PathID = dev.PathID
AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_RelativePaths
      (PathID, ReferenceName, CompletePath, StartDate, EndDate,
       SystemID, MigrationFlag, MigrationIssue)
SELECT PathID, ReferenceName, CompletePath, StartDate, EndDate,
       SystemID, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_RelativePaths dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_SequenceAdder table.                          */
/*************************************************************************/
DELETE MC_SequenceAdder
FROM CORESQLDEV1.Core1.dbo.MC_SequenceAdder dev,
     MC_SequenceAdder prod,
     Temp_Issue_No_Table
WHERE prod.SeqID = dev.SeqID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_SequenceAdder
      (SeqID, SplitFileName, SourceFileID, LoadPath, SavePath,
       RecordLen, MigrationFlag, MigrationIssue)
SELECT SeqID, SplitFileName, SourceFileID, LoadPath, SavePath,
       RecordLen, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_SequenceAdder dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_ServerName table.                             */
/*************************************************************************/
DELETE MC_ServerName
FROM CORESQLDEV1.Core1.dbo.MC_ServerName dev,
     MC_ServerName prod,
     Temp_Issue_No_Table
WHERE prod.Core1Server = dev.Core1Server 
  AND prod.CoreETLServer = dev.CoreETLServer
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_ServerName
      (Core1Server, CoreETLServer, MigrationFlag, MigrationIssue)
SELECT Core1Server, CoreETLServer, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_ServerName dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_SourceFile table.                             */
/*************************************************************************/
DELETE MC_SourceFile
FROM CORESQLDEV1.Core1.dbo.MC_SourceFile dev,
     MC_SourceFile prod,
     Temp_Issue_No_Table
WHERE prod.SourceFileID = dev.SourceFileID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_SourceFile
      (SourceFileID, startdate, enddate, path, filename, logicalName,
       Priority, SystemID, MigrationFlag, MigrationIssue)
SELECT SourceFileID, startdate, enddate, path, filename, logicalName,
       Priority, SystemID, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_SourceFile dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_SourceFileModule table.                       */
/*************************************************************************/
DELETE MC_SourceFileModule
FROM CORESQLDEV1.Core1.dbo.MC_SourceFileModule dev,
     MC_SourceFileModule prod,
     Temp_Issue_No_Table
WHERE prod.SourceSystemID = dev.SourceSystemID
  AND prod.ModuleID = dev.ModuleID
  AND prod.ProcessOrder = dev.ProcessOrder
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_SourceFileModule
      (SourceSystemID, ModuleID, ProcessOrder, StartDate,
       EndDate, MigrationFlag, MigrationIssue)
SELECT SourceSystemID, ModuleID, ProcessOrder, StartDate,
       EndDate, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_SourceFileModule dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_SourceSystem table.                           */
/*************************************************************************/
DELETE MC_SourceSystem
FROM CORESQLDEV1.Core1.dbo.MC_SourceSystem dev,
     MC_SourceSystem prod,
     Temp_Issue_No_Table
WHERE prod.SystemID = dev.SystemID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_SourceSystem
      (SystemID, SystemName, Priority, StartDate,
       EndDate, MigrationFlag, MigrationIssue)
SELECT SystemID, SystemName, Priority, StartDate,
       EndDate, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_SourceSystem dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_SyncSortParams table.                         */
/*************************************************************************/
DELETE MC_SyncSortParams
FROM CORESQLDEV1.Core1.dbo.MC_SyncSortParams dev,
     MC_SyncSortParams prod,
     Temp_Issue_No_Table
WHERE prod.SSID = dev.SSID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_SyncSortParams
      (StartDate, EndDate, SourceFileID, ScriptPath,
       ScriptFile, SSID, MigrationFlag, MigrationIssue)
SELECT StartDate, EndDate, SourceFileID, ScriptPath,
       ScriptFile, SSID, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_SyncSortParams dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the MC_TelleMergerParams table.                      */
/*************************************************************************/
DELETE MC_TelleMergerParams
FROM CORESQLDEV1.Core1.dbo.MC_TelleMergerParams dev,
     MC_TelleMergerParams prod,
     Temp_Issue_No_Table
WHERE prod.TelleMergerID = dev.TelleMergerID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO MC_TelleMergerParams
      (TelleMergerID, StartDate, EndDate, SourceFileID, ScriptPath,
       ScriptFile, MigrationFlag, MigrationIssue)
SELECT TelleMergerID, StartDate, EndDate, SourceFileID, ScriptPath,
       ScriptFile, MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.MC_TelleMergerParams dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  Migrate rows in the UDP_Domain table.                                */
/*************************************************************************/
DELETE UDP_Domain
FROM CORESQLDEV1.Core1.dbo.UDP_Domain dev,
     UDP_Domain prod,
     Temp_Issue_No_Table
WHERE prod.DomainID = dev.DomainID
  AND dev.MigrationIssue = Issue_Nbr

INSERT INTO UDP_Domain
      (DomainID, SourceFileID, CoreETLTable, CoreETLField, SourceSystem,
       SourceCopyBook, SourceField, CoreTable, CoreField, Description,
       MigrationFlag, MigrationIssue)
SELECT DomainID, SourceFileID, CoreETLTable, CoreETLField, SourceSystem,
       SourceCopyBook, SourceField, CoreTable, CoreField, Description,
       MigrationFlag, MigrationIssue
FROM CORESQLDEV1.Core1.dbo.UDP_Domain dev,
     Temp_Issue_No_Table
WHERE dev.MigrationIssue = Issue_Nbr

/*************************************************************************/
/*  We are done, so drop the temporary table and return.                 */
/*************************************************************************/
DROP TABLE dbo.Temp_Issue_No_Table
RETURN
GO
