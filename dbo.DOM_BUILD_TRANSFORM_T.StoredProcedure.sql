USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[DOM_BUILD_TRANSFORM_T]    Script Date: 12/31/2024 8:49:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create    PROCEDURE [dbo].[DOM_BUILD_TRANSFORM_T] (@MASTERPROCESSID INT) AS

-------------------------------------------------------------------------------------
--THIS PROCEDURE GENERATES INDIVIDUAL STORED PROCEDURES FOR EACH DOMAIN TABLE
-------------------------------------------------------------------------------------

DECLARE @DOMAINFIELDNAME VARCHAR(50)
DECLARE @DOMAINTABLENAME VARCHAR(50)
DECLARE @COREFIELDNAME VARCHAR(50)
DECLARE @CORETABLENAME VARCHAR(50)
DECLARE @PREV_CORETABLENAME VARCHAR(50)
DECLARE @ERRORCODE VARCHAR(12)
DECLARE @NSQL NVARCHAR(4000)
DECLARE @NSQL1 NVARCHAR(4000)
DECLARE @NSQL2 NVARCHAR(4000)
DECLARE @NSQL3 NVARCHAR(4000)
DECLARE @NSQL4 NVARCHAR(4000)
DECLARE @NSQL5 NVARCHAR(4000)
DECLARE @NSQL6 NVARCHAR(4000)

-------------------------------------------------------------------------------------
--BUILD A TEMP TABLE TO CONTAIN ALL DOMAINS
-------------------------------------------------------------------------------------
DECLARE @TRANSDATA TABLE(DOMAINFIELDNAME VARCHAR(50), DOMAINTABLENAME VARCHAR(50), COREFIELDNAME VARCHAR(50), CORETABLENAME VARCHAR(50), ERRORCODE VARCHAR(12) )


DECLARE @MAXDATAPROCESSID INT
DECLARE @PRECEDENCE INT
DECLARE @DPPRECEDENCE INT
DECLARE @MAXPRECEDENCE INT
DECLARE @MAXMASTERDATAPROCESSID INT

DECLARE @DOMCOUNT INT
DECLARE @TEMPTABLENAME VARCHAR(25)
DECLARE @SYSTEMID INT
DECLARE @SUBSYSTEMID INT

SET ANSI_NULLS  ON;
SET ANSI_WARNINGS ON;

-- Delete the DOM Procedures entry in the DataProcess table for this master process if there is any 
DELETE FROM DT_DATAPROCESS WHERE  MASTERPROCESSID = @MASTERPROCESSID AND DataProcessName LIKE 'EXEC DOM_COR%' 

-- Delete the NREP procedures from the Data process table for the given masterprocess
DELETE FROM DT_DATAPROCESS WHERE  MASTERPROCESSID = @MASTERPROCESSID AND DataProcessName LIKE 'EXEC NREP_%' 

--Get the SubSystem information ....
--Issue 3563
SET @SUBSYSTEMID=(SELECT  isnull(SUBSYSTEMID,-1) FROM DT_MASTERPROCESS 
     WHERE MASTERPROCESSID = @MASTERPROCESSID)
 
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
	[Precedence] [Float] NOT NULL ,
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
SELECT TOP 1	[DataProcessID],
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

-- Get the max Predence and max dataprocessid
SET @MAXPRECEDENCE = (SELECT [Precedence] FROM #TEMP_DATAPROCESS  )
SET @MAXMASTERDATAPROCESSID = (SELECT [DataprocessId] FROM #TEMP_DATAPROCESS  )

--get the 2nd max precedence number
SET @PRECEDENCE = (SELECT MAX(PRECEDENCE)  FROM DT_DATAPROCESS
WHERE MASTERPROCESSID = @MASTERPROCESSID AND PRECEDENCE < @MAXPRECEDENCE)

--increment the max precedence by 2nd max + 100 to give precedence for DOM procs
IF (@MAXPRECEDENCE <> (@PRECEDENCE + 100))
BEGIN
	SET @MAXPRECEDENCE = @PRECEDENCE + 100

	PRINT @MAXPRECEDENCE
	--Set the max dataprocessid precedence with the new predence
	UPDATE DT_DATAPROCESS
	SET PRECEDENCE = @MAXPRECEDENCE,
		LASTUPDATEDATETIME = GETDATE(),
		MIGRATIONFLAG = 'U',
		MIGRATIONISSUE = 3286
	WHERE DATAPROCESSID = @MAXMASTERDATAPROCESSID AND MASTERPROCESSID = @MASTERPROCESSID
END

-- Subtract one and use that precedence for all the DOM Procedures
SELECT @PRECEDENCE = @PRECEDENCE + 1

-- Get the Source System id
SET @SYSTEMID =(SELECT MCSourceSystemID FROM DT_MASTERPROCESS WHERE MASTERPROCESSID = @MASTERPROCESSID)

IF @SYSTEMID IS NULL
BEGIN
        RAISERROR ('DOM_BUILD_TRANSFORM Procedure Failed. MCSourceSystemID id is null in DT_masterprocess', 16, 1)
		RETURN 1
END

INSERT INTO @TRANSDATA
SELECT DOMAINFIELDNAME, B.DOMAINTABLENAME, B.COREFIELDNAME, B.CORETABLENAME, ISNULL(ERRORCODE,'XXXX1')
FROM    PRM_DOMAIN A INNER JOIN PRM_DOMAINCHILDREN B 
        ON A.DOMAINTABLENAME = B.DOMAINTABLENAME  
	INNER JOIN PRM_REPCORETABLES Z ON B.CORETABLENAME = Z.CORETABLENAME
WHERE
        ISNULL(A.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() 
        AND ISNULL(A.PARAMETERENDDATE,'1/1/2999')  > GETDATE()
        and ISNULL(B.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() 
        AND ISNULL(B.PARAMETERENDDATE,'1/1/2999')  > GETDATE()
	AND EXISTS (SELECT 1 FROM PRM_REPLOADTABLES Y WHERE Z.REPCORETABLEID = Y.REPCORETABLEID 
	AND SYSTEMID = @SYSTEMID AND ISNULL(SubSystemID,-1)=@SubSystemID AND CHARINDEX(B.COREFIELDNAME,STAGECOLUMNS) <> 0)
	Order by B.CORETABLENAME, B.DOMAINTABLENAME
-------------------------------------------------------------------------------------
--BUILD A CURSOR TO LOOP THROUGH EACH DOMAIN AND BUILD THE ASSOCIATED CONVERSION
--STORED PROCEDURE
-------------------------------------------------------------------------------------

DECLARE CRSR_CONSTS CURSOR FOR
        SELECT DOMAINFIELDNAME, DOMAINTABLENAME, COREFIELDNAME, CORETABLENAME, ERRORCODE FROM @TRANSDATA

SELECT @DOMCOUNT = 1

OPEN CRSR_CONSTS
FETCH Next FROM CRSR_CONSTS INTO @DOMAINFIELDNAME, @DOMAINTABLENAME,@COREFIELDNAME,@CORETABLENAME,@ERRORCODE

SET @PREV_CORETABLENAME = ''
SET @DPPRECEDENCE = 0

WHILE @@FETCH_STATUS=0
BEGIN

SELECT @TEMPTABLENAME = '##TEMP_DOM_' + CAST(@MASTERPROCESSID AS VARCHAR) + '_'+ CAST(@DOMCOUNT AS VARCHAR)

SELECT @NSQL = N'if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[DOM_' + @CORETABLENAME + '__' + @COREFIELDNAME + ']'') and OBJECTPROPERTY(id, N''IsProcedure'') = 1)
drop procedure [dbo].[DOM_' + @CORETABLENAME + '__' + @COREFIELDNAME + ']'

EXECUTE SP_EXECUTESQL @NSQL

SELECT @NSQL = N'CREATE PROCEDURE [dbo].[DOM_' + @CORETABLENAME + '__' + @COREFIELDNAME + '] AS

DECLARE @ERRORSOURCE INT
DECLARE @ERRORCOUNT INT
DECLARE @XXXXCOUNT INT
DECLARE @REPERRORLOGID INT
DECLARE @CODES TABLE(DOMCODE VARCHAR(12))
DECLARE @AFFECTEDRECORDS INT
DECLARE @DOMS TABLE (SOURCEVALUE VARCHAR(255),DOMAINCODE VARCHAR(12))
DECLARE @ALPHASYSTEM VARCHAR(4)
DECLARE @SYSPROCESSEDLOGID INT
DECLARE @SYSTEMID INT
DECLARE @OUTPUTIND BIT 
DECLARE @ETLDIRECTORY VARCHAR(255)
DECLARE @sql varchar(5000) 
DECLARE @ERRORMESSAGE NVARCHAR(255)

SET ANSI_NULLS  ON;
SET ANSI_WARNINGS ON;  
SET NOCOUNT ON
SET LOCK_TIMEOUT -1

SELECT @OUTPUTIND = 1

SELECT @SYSPROCESSEDLOGID = SysProcessedLogID, @SYSTEMID = SystemID FROM MC_SysProcessedLog
               WHERE Finished = ''F''
               AND SystemID = '+CAST(@SYSTEMID AS VARCHAR(8))+ ' AND ISNULL(SUBSYSTEMID,-1) =' + CAST(@SUBSYSTEMID AS VARCHAR(100))+ '
          
IF @SYSPROCESSEDLOGID IS NULL
BEGIN
        SET @ERRORMESSAGE = ''[dbo].DOM_'+ @CORETABLENAME + '__' + @COREFIELDNAME + ' Failed. SYSPROCESSEDLOGID is null'' 
        RAISERROR (@ERRORMESSAGE, 16, 1)
		RETURN 1
END
	
SET @ETLDIRECTORY = (SELECT ETLDIRECTORY FROM CORE1.DBO.PRM_SYSTEMDIRECTORY WHERE SYSTEMID = @SYSTEMID)

if not object_id(''tempdb..'+ @TEMPTABLENAME + ''') is null
	    drop table '+ @TEMPTABLENAME + '

CREATE TABLE '+ @TEMPTABLENAME + '(SEQ INT, EVENT VARCHAR(178))

-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 10, ''000 SPID = '' + CAST (@@SPID AS VARCHAR(100))
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 20, ''001 BEG-->CHECK SEGMENT STATUS  '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

--CHECK IF DOMAIN HAS ALREADY BEEN CONVERTED
-------------------------------------------------------------------------------------
--GET SYSTEM IDENTIFIER FOR REPERRORLOG
-------------------------------------------------------------------------------------
SET @ALPHASYSTEM = (SELECT LEFT(S.SYSTEMNAME,4) FROM MC_SYSPROCESSEDLOG L INNER JOIN MC_SOURCESYSTEM S ON L.SYSTEMID = S.SYSTEMID WHERE L.SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID)

-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 30, ''002 END-->CHECK SEGMENT STATUS  '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 40, ''003 BEG-->SET SEGMENT STATUS    '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 50, ''004 END-->SET SEGMENT STATUS    '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 60, ''005 BEG-->ADD INDEX IF NONE     '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
'
SELECT @NSQL1 = N'
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 70, ''006 END-->ADD INDEX IF NONE     '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 80, ''007 BEG-->LOAD DOMAINS          '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

INSERT INTO @DOMS
SELECT A.SOURCEVALUE, A.DOMAINCODE
FROM PRM_DOMAINSOURCE A 
INNER JOIN PRM_DOMAINDESTINATION B
ON A.DOMAINCODE = B.DOMAINCODE
AND A.DOMAINTABLENAME=B.DOMAINTABLENAME
INNER JOIN PRM_DOMAIN C
ON A.DOMAINTABLENAME = C.DOMAINTABLENAME
WHERE A.SYSTEMID IN (SELECT SYSTEMID FROM MC_SYSPROCESSEDLOG WHERE SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID)
AND A.DOMAINTABLENAME = ''' + @DOMAINTABLENAME + '''
AND ISNULL(A.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(A.PARAMETERENDDATE,''1/1/2999'') > GETDATE()
and ISNULL(B.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(B.PARAMETERENDDATE,''1/1/2999'') > GETDATE()
and ISNULL(C.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(C.PARAMETERENDDATE,''1/1/2999'') > GETDATE()


-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 90, ''008 END-->LOAD DOMAINS          '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 100, ''009 BEG-->TRANSFORM DOMAINS     '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

UPDATE COREETL.DBO.' + @CORETABLENAME + ' WITH (ROWLOCK)
SET ' + @COREFIELDNAME + ' = B.DOMAINCODE 
FROM COREETL.DBO.' + @CORETABLENAME + ' A 
INNER JOIN @DOMS B 
ON A.' + @COREFIELDNAME + ' = B.SOURCEVALUE

SET @AFFECTEDRECORDS = @@ROWCOUNT
'
SELECT @NSQL2 = N'
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 110, ''010 END-->TRANSFORM DOMAINS     '' + CONVERT(VARCHAR(100),GETDATE(),109)-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 120, ''011 BEG-->LOG RECORD COUNT      '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

INSERT INTO '+ @TEMPTABLENAME + ' SELECT 130, ''    '' + CAST(@AFFECTEDRECORDS AS VARCHAR(100)) + '' RECORDS TRANSFORMED''

-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 140, ''012 END-->LOG RECORD COUNT      '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 150, ''013 BEG-->GET COUNT OF PRM_DomainSource INVALIDS '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

SELECT @ERRORSOURCE = COUNT(*) 
FROM COREETL.DBO.' + @CORETABLENAME + ' 
WHERE ' + @COREFIELDNAME + ' NOT IN (SELECT DOMAINCODE FROM @DOMS)
AND ' + @COREFIELDNAME + ' IS NOT NULL

-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 160, ''014 END-->GET COUNT OF PRM_DomainSource '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

IF @ERRORSOURCE > 0 
BEGIN
        -------------------------------------------------------------------------------------------
        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 170, ''015 BEG-->LOG ROWS IN ERRORLOG  '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        INSERT INTO COREERRLOG.DBO.REPERRORLOG 
        (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM) 
        VALUES 
        (GETDATE(), CAST(@ERRORSOURCE AS VARCHAR(100)) + '' INVALID PRM_DomainSource VALUE(S) DETECTED FOR ' + @CORETABLENAME + '.' + @COREFIELDNAME + '.'',''REFER TO ERR TABLES FOR DETAILS'',''DOM'', @ALPHASYSTEM)
        
        SELECT @REPERRORLOGID = @@IDENTITY

        -------------------------------------------------------------------------------------------
        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 180, ''016 END-->LOG ROWS IN ERRORLOG  '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------'
SELECT @NSQL3 = N'
        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 190, ''017 BEG-->LOAD ROWS IN ERR      '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        INSERT INTO 
        COREERRLOG.DBO.ERR_' + RIGHT(@CORETABLENAME,LEN(@CORETABLENAME)-4) + ' 
        SELECT *,@REPERRORLOGID 
        FROM COREETL.DBO.' + @CORETABLENAME + '
        WHERE ' + @COREFIELDNAME + ' NOT IN (SELECT DOMAINCODE FROM @DOMS)
        AND ' + @COREFIELDNAME + ' IS NOT NULL

        -------------------------------------------------------------------------------------------        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 200, ''018 END-->LOAD ROWS INTO ERR    '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------
        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 210, ''019 BEG-->CONVERT INVALIDS TO X '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        UPDATE 
        COREETL.DBO.' + @CORETABLENAME + ' WITH (ROWLOCK)
        SET ' + @COREFIELDNAME + ' = ''' + @ERRORCODE + ''' 
        WHERE ' + @COREFIELDNAME + ' NOT IN (SELECT DOMAINCODE FROM @DOMS)
        AND ' + @COREFIELDNAME + ' IS NOT NULL
        SELECT @XXXXCOUNT = @@ROWCOUNT

        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 220, ''    '' + CAST(@XXXXCOUNT AS VARCHAR(100)) + '' RECORDS CONVERTED TO ERROR CODES''

        -------------------------------------------------------------------------------------------
        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 230, ''020 END-->CONVERT INVALIDS TO X '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------
END

-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 240, ''021 BEG-->GRAB VALID ORACLE DOMS   '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
'
SELECT @NSQL4 = N'
INSERT INTO @CODES 
SELECT ' + @DOMAINFIELDNAME + ' 
FROM OPENQUERY(CORE,''SELECT ' + @DOMAINFIELDNAME + ' FROM ' + @DOMAINTABLENAME + ' WHERE ' + @DOMAINFIELDNAME + ' IS NOT NULL AND REC_THRU_DATE > SYSDATE'')

INSERT INTO @CODES (DOMCODE) VALUES (''^'')

-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 250, ''022 END-->GET VALID ORACLE DOMS '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 260, ''023 BEG-->GET COUNT OF ORACLE INVALIDS '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

SELECT @ERRORCOUNT = COUNT(*) 
FROM COREETL.DBO.' + @CORETABLENAME + ' 
WHERE ' + @COREFIELDNAME + ' NOT IN (SELECT DOMCODE FROM @CODES)
AND ' + @COREFIELDNAME + ' IS NOT NULL

-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 270, ''024 END-->GET COUNT OF ORACLE INVALIDS '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

IF @ERRORCOUNT > 0 
BEGIN
        -------------------------------------------------------------------------------------------
        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 280, ''025 BEG-->LOG ROWS IN ERRORLOG  '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        INSERT INTO COREERRLOG.DBO.REPERRORLOG 
        (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM) 
        VALUES 
        (GETDATE(), CAST(@ERRORCOUNT AS VARCHAR(100)) + '' INVALID ORACLE SOURCE DOMAIN VALUE(S) DETECTED FOR ' + @CORETABLENAME + '.' + @COREFIELDNAME + '.'',''REFER TO ERR TABLES FOR DETAILS'',''DOM'', @ALPHASYSTEM)
        
        SELECT @REPERRORLOGID = @@IDENTITY

        -------------------------------------------------------------------------------------------
        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 290, ''026 END-->LOG ROWS IN ERRORLOG  '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------'
SELECT @NSQL5 = N'
        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 300, ''027 BEG-->LOAD ROWS IN ERR      '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        INSERT INTO 
        COREERRLOG.DBO.ERR_' + RIGHT(@CORETABLENAME,LEN(@CORETABLENAME)-4) + ' 
        SELECT *,@REPERRORLOGID 
        FROM COREETL.DBO.' + @CORETABLENAME + '
        WHERE ' + @COREFIELDNAME + ' NOT IN (SELECT DOMCODE FROM @CODES)
        AND ' + @COREFIELDNAME + ' IS NOT NULL

        -------------------------------------------------------------------------------------------        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 310, ''028 END-->LOAD ROWS INTO ERR    '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------
        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 320, ''029 BEG-->CONVERT INVALIDS TO X '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        UPDATE 
        COREETL.DBO.' + @CORETABLENAME + ' WITH (ROWLOCK)
        SET ' + @COREFIELDNAME + ' = ''' + @ERRORCODE + ''' 
        WHERE ' + @COREFIELDNAME + ' NOT IN (SELECT DOMCODE FROM @CODES)
        AND ' + @COREFIELDNAME + ' IS NOT NULL

        SELECT @XXXXCOUNT = @@ROWCOUNT

        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 330, ''    '' + CAST(@XXXXCOUNT AS VARCHAR(100)) + '' RECORDS CONVERTED TO ERROR CODES''

        -------------------------------------------------------------------------------------------
        INSERT INTO '+ @TEMPTABLENAME + ' SELECT 340, ''030 END-->CONVERT INVALIDS TO X '' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------
END
'
SELECT @NSQL6 = N'
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 350, ''031 BEG-->UPDATE SEGMENT LOG    '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

--UPDATE CORE1.DBO.MC_SEGMENT
--SET ENDDATETIMESTAMP = GETDATE(),COMPLETED = ''T'', RECORDSPROCESSED = @AFFECTEDRECORDS
--WHERE SEGMENT = ''DOMAIN'' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = ''DOM_' + @CORETABLENAME + '__' + @COREFIELDNAME + '''

-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 360, ''032 END-->UPDATE SEGMENT LOG    '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 370, ''033 BEG-->RESET THE PROCESSID   '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

UPDATE PRM_DOMAINCHILDREN SET PROCESSID = NULL WHERE DOMAINTABLENAME = ''' + @DOMAINTABLENAME + ''' AND CORETABLENAME = ''' + @CORETABLENAME + ''' AND COREFIELDNAME = ''' + @COREFIELDNAME + ''' 

-------------------------------------------------------------------------------------------
INSERT INTO '+ @TEMPTABLENAME + ' SELECT 380, ''034 END-->RESET THE PROCESSID   '' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

--IF @OUTPUTIND = 1 SELECT EVENT FROM '+ @TEMPTABLENAME + ' ORDER BY SEQ ASC
-- build full BCP query

--comented for issue 7074  
--  SELECT  @sql = ''bcp "select EVENT FROM '+ @TEMPTABLENAME + ' ORDER BY SEQ ASC" queryout '' + @ETLDIRECTORY + ''\DomainResults\DOM_' + @CORETABLENAME + '__' + @COREFIELDNAME + '.TXT -SSBGETL -T -c''
  SELECT    @sql = ''bcp "select EVENT FROM '+ @TEMPTABLENAME + ' ORDER BY SEQ ASC" queryout '' + @ETLDIRECTORY + ''\DomainResults\DOM_' + @CORETABLENAME + '__' + @COREFIELDNAME + '.TXT -S' + @@SERVERNAME + ' -T -c''
  -- execute BCP
  Exec master..xp_cmdshell @sql

  DROP TABLE '+ @TEMPTABLENAME + '

RETURN'


-------------------------------------------------------------------------------------
--INITIALIZE STORED PROC CONTENT FOR DYNAMIC EXECUTION
-------------------------------------------------------------------------------------
SELECT @NSQL =  REPLACE(@NSQL,'''','''''')
SELECT @NSQL1 =  REPLACE(@NSQL1,'''','''''')  
SELECT @NSQL2 =  REPLACE(@NSQL2,'''','''''') 
SELECT @NSQL3 =  REPLACE(@NSQL3,'''','''''') 
SELECT @NSQL4 =  REPLACE(@NSQL4,'''','''''') 
SELECT @NSQL5 =  REPLACE(@NSQL5,'''','''''') 
SELECT @NSQL6 =  REPLACE(@NSQL6,'''','''''') 

IF @COREFIELDNAME = 'INVSTMNT_ASSET_SRC_TYPE_CODE'
BEGIN
PRINT @NSQL
PRINT @NSQL1
PRINT @NSQL2
PRINT @NSQL3
PRINT @NSQL4
PRINT @NSQL5
PRINT @NSQL6
END
-------------------------------------------------------------------------------------
--DYNAMICLY BUILD THE STORED PROC
-------------------------------------------------------------------------------------

EXEC (N'EXEC SP_EXECUTESQL N''' + @NSQL + @NSQL1 + @NSQL2 + @NSQL3 + @NSQL4 + @NSQL5 + @NSQL6 + '''')

-- Create an entry into the DT_DataProcess table for this new DOM Stored Procedure
SELECT @MAXDATAPROCESSID = @MAXDATAPROCESSID + 1

IF (@PREV_CORETABLENAME = @CORETABLENAME )
	SET @DPPRECEDENCE = @DPPRECEDENCE + 1
ELSE
	SET @DPPRECEDENCE = @PRECEDENCE

print 'jayan'

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
	'EXEC DOM_' + @CORETABLENAME + '__' + @COREFIELDNAME  AS  DataProcessName,
	TD.MasterProcessID,
	TD.DataProcessTypeID,
	@DPPRECEDENCE AS Precedence,
	TD.Priority,
	TD.BatchSize,
	TD.Timeout,
	TD.SourceObject,
	TD.DestObject,
	TD.MetaDataMappingName,
	TD.SourceConnectionID,
	TD.DestConnectionID,
	TD.MetaDataConnectionID,
	'EXEC DOM_' + @CORETABLENAME + '__' + @COREFIELDNAME  AS ProcessScript,
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
	
SELECT @DOMCOUNT = @DOMCOUNT + 1

SET @PREV_CORETABLENAME = @CORETABLENAME 

FETCH Next FROM CRSR_CONSTS INTO @DOMAINFIELDNAME, @DOMAINTABLENAME,@COREFIELDNAME,@CORETABLENAME,@ERRORCODE

END
CLOSE CRSR_CONSTS
DEALLOCATE CRSR_CONSTS

DROP TABLE #TEMP_DATAPROCESS

RETURN

GO
