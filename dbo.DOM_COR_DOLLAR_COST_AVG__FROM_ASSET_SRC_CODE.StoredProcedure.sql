USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[DOM_COR_DOLLAR_COST_AVG__FROM_ASSET_SRC_CODE]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DOM_COR_DOLLAR_COST_AVG__FROM_ASSET_SRC_CODE](@SYSPROCESSEDLOGID INT, @OUTPUTIND BIT = 1) AS
SET NOCOUNT ON
SET LOCK_TIMEOUT -1

DECLARE @ERRORSOURCE INT
DECLARE @ERRORCOUNT INT
DECLARE @XXXXCOUNT INT
DECLARE @REPERRORLOGID INT
DECLARE @CODES TABLE(DOMCODE VARCHAR(12))
DECLARE @AFFECTEDRECORDS INT
DECLARE @DOMS TABLE (SOURCEVALUE VARCHAR(255),DOMAINCODE VARCHAR(12))
DECLARE @RESULTS TABLE (SEQ INT, EVENT VARCHAR(178))
DECLARE @ALPHASYSTEM VARCHAR(4)

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 10, '000 SPID = ' + CAST (@@SPID AS VARCHAR(100))
INSERT INTO @RESULTS SELECT 20, '001 BEG-->CHECK SEGMENT STATUS  ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

--CHECK IF DOMAIN HAS ALREADY BEEN CONVERTED
IF EXISTS (SELECT 1 FROM CORE1.DBO.MC_SEGMENT WHERE COMPLETED = 'T' AND SEGMENT = 'DOMAIN' AND SEGMENTINSTANCE = 'DOM_COR_DOLLAR_COST_AVG__FROM_ASSET_SRC_CODE' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID)
BEGIN
        IF @OUTPUTIND = 1 SELECT 'ALREADY COMPLETE'
        RETURN
END 

-------------------------------------------------------------------------------------
--GET SYSTEM IDENTIFIER FOR REPERRORLOG
-------------------------------------------------------------------------------------

SET @ALPHASYSTEM = (SELECT LEFT(S.SYSTEMNAME,4) FROM MC_SYSPROCESSEDLOG L INNER JOIN MC_SOURCESYSTEM S ON L.SYSTEMID = S.SYSTEMID WHERE L.SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID)

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 30, '002 END-->CHECK SEGMENT STATUS  ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 40, '003 BEG-->SET SEGMENT STATUS    ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

--LOG THAT CONVERSION HAS STARTED
INSERT INTO CORE1.DBO.MC_SEGMENT (StartDateTimeStamp, EndDateTimeStamp, SegmentInstance, Completed, SourceFileID, Segment, RecordsProcessed, SysProcessedLogID)
SELECT GETDATE(),NULL,'DOM_COR_DOLLAR_COST_AVG__FROM_ASSET_SRC_CODE','F',0, 'DOMAIN',NULL,@SYSPROCESSEDLOGID
WHERE NOT EXISTS (SELECT 1 FROM CORE1.DBO.MC_SEGMENT WHERE SEGMENT = 'DOMAIN' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'DOM_COR_DOLLAR_COST_AVG__FROM_ASSET_SRC_CODE')

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 50, '004 END-->SET SEGMENT STATUS    ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 60, '005 BEG-->ADD INDEX IF NONE     ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

--IF EXISTS (SELECT NAME FROM COREETL.DBO.SYSINDEXES WHERE NAME = 'IDX_COR_DOLLAR_COST_AVG_FROM_ASSET_SRC_CODE_1')
--BEGIN
--CREATE  INDEX [IDX_COR_DOLLAR_COST_AVG_FROM_ASSET_SRC_CODE_1] ON [COREETL].[DBO].[COR_DOLLAR_COST_AVG]([FROM_ASSET_SRC_CODE])
--END

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 70, '006 END-->ADD INDEX IF NONE     ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 80, '007 BEG-->LOAD DOMAINS          ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

INSERT INTO @DOMS
SELECT A.SOURCEVALUE, A.DOMAINCODE
FROM PRM_DOMAINSOURCE A 
INNER JOIN PRM_DOMAINDESTINATION B
ON A.DOMAINCODE = B.DOMAINCODE
INNER JOIN PRM_DOMAIN C
ON A.DOMAINTABLENAME = C.DOMAINTABLENAME
WHERE A.SYSTEMID IN (SELECT SYSTEMID FROM MC_SYSPROCESSEDLOG WHERE SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID)
AND A.DOMAINTABLENAME = 'DOM_ASSET_SRC'
AND ISNULL(A.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(A.PARAMETERENDDATE,'1/1/2999') > GETDATE()
and ISNULL(B.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(B.PARAMETERENDDATE,'1/1/2999') > GETDATE()
and ISNULL(C.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(C.PARAMETERENDDATE,'1/1/2999') > GETDATE()

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 90, '008 END-->LOAD DOMAINS          ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 100, '009 BEG-->TRANSFORM DOMAINS     ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

UPDATE COREETL.DBO.COR_DOLLAR_COST_AVG 
SET FROM_ASSET_SRC_CODE = B.DOMAINCODE 
FROM COREETL.DBO.COR_DOLLAR_COST_AVG A 
INNER JOIN @DOMS B 
ON A.FROM_ASSET_SRC_CODE = B.SOURCEVALUE

SET @AFFECTEDRECORDS = @@ROWCOUNT

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 110, '010 END-->TRANSFORM DOMAINS     ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 120, '011 BEG-->LOG RECORD COUNT      ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

INSERT INTO @RESULTS SELECT 130, '    ' + CAST(@AFFECTEDRECORDS AS VARCHAR(100)) + ' RECORDS TRANSFORMED'

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 140, '012 END-->LOG RECORD COUNT      ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 150, '013 BEG-->GET COUNT OF PRM_DomainSource INVALIDS ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

SELECT @ERRORSOURCE = COUNT(*) 
FROM COREETL.DBO.COR_DOLLAR_COST_AVG 
WHERE FROM_ASSET_SRC_CODE NOT IN (SELECT DOMAINCODE FROM @DOMS)
AND FROM_ASSET_SRC_CODE IS NOT NULL

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 160, '014 END-->GET COUNT OF PRM_DomainSource ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

IF @ERRORSOURCE > 0 
BEGIN
        -------------------------------------------------------------------------------------------
        INSERT INTO @RESULTS SELECT 170, '015 BEG-->LOG ROWS IN ERRORLOG  ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        INSERT INTO COREERRLOG.DBO.REPERRORLOG 
        (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM) 
        VALUES 
        (GETDATE(), CAST(@ERRORSOURCE AS VARCHAR(100)) + ' INVALID PRM_DomainSource VALUE(S) DETECTED FOR COR_DOLLAR_COST_AVG.FROM_ASSET_SRC_CODE.','REFER TO ERR TABLES FOR DETAILS','DOM', @ALPHASYSTEM)
        
        SELECT @REPERRORLOGID = @@IDENTITY

        -------------------------------------------------------------------------------------------
        INSERT INTO @RESULTS SELECT 180, '016 END-->LOG ROWS IN ERRORLOG  ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------
        INSERT INTO @RESULTS SELECT 190, '017 BEG-->LOAD ROWS IN ERR      ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        INSERT INTO 
        COREERRLOG.DBO.ERR_DOLLAR_COST_AVG 
        SELECT *,@REPERRORLOGID 
        FROM COREETL.DBO.COR_DOLLAR_COST_AVG
        WHERE FROM_ASSET_SRC_CODE NOT IN (SELECT DOMAINCODE FROM @DOMS)
        AND FROM_ASSET_SRC_CODE IS NOT NULL

        -------------------------------------------------------------------------------------------        INSERT INTO @RESULTS SELECT 200, '018 END-->LOAD ROWS INTO ERR    ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------
        INSERT INTO @RESULTS SELECT 210, '019 BEG-->CONVERT INVALIDS TO X ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        UPDATE 
        COREETL.DBO.COR_DOLLAR_COST_AVG 
        SET FROM_ASSET_SRC_CODE = 'XXXX' 
        WHERE FROM_ASSET_SRC_CODE NOT IN (SELECT DOMAINCODE FROM @DOMS)
        AND FROM_ASSET_SRC_CODE IS NOT NULL

        SELECT @XXXXCOUNT = @@ROWCOUNT

        INSERT INTO @RESULTS SELECT 220, '    ' + CAST(@XXXXCOUNT AS VARCHAR(100)) + ' RECORDS CONVERTED TO ERROR CODES'

        -------------------------------------------------------------------------------------------
        INSERT INTO @RESULTS SELECT 230, '020 END-->CONVERT INVALIDS TO X ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------
END

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 240, '021 BEG-->GRAB VALID ORACLE DOMS   ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

INSERT INTO @CODES 
SELECT ASSET_SOURCE_CODE 
FROM OPENQUERY(CORE,'SELECT ASSET_SOURCE_CODE FROM DOM_ASSET_SRC WHERE ASSET_SOURCE_CODE IS NOT NULL AND REC_THRU_DATE > SYSDATE')

INSERT INTO @CODES (DOMCODE) VALUES ('^')

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 250, '022 END-->GET VALID ORACLE DOMS ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 260, '023 BEG-->GET COUNT OF ORACLE INVALIDS ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

SELECT @ERRORCOUNT = COUNT(*) 
FROM COREETL.DBO.COR_DOLLAR_COST_AVG 
WHERE FROM_ASSET_SRC_CODE NOT IN (SELECT DOMCODE FROM @CODES)
AND FROM_ASSET_SRC_CODE IS NOT NULL

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 270, '024 END-->GET COUNT OF ORACLE INVALIDS ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

IF @ERRORCOUNT > 0 
BEGIN
        -------------------------------------------------------------------------------------------
        INSERT INTO @RESULTS SELECT 280, '025 BEG-->LOG ROWS IN ERRORLOG  ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        INSERT INTO COREERRLOG.DBO.REPERRORLOG 
        (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM) 
        VALUES 
        (GETDATE(), CAST(@ERRORCOUNT AS VARCHAR(100)) + ' INVALID ORACLE SOURCE DOMAIN VALUE(S) DETECTED FOR COR_DOLLAR_COST_AVG.FROM_ASSET_SRC_CODE.','REFER TO ERR TABLES FOR DETAILS','DOM', @ALPHASYSTEM)
        
        SELECT @REPERRORLOGID = @@IDENTITY

        -------------------------------------------------------------------------------------------
        INSERT INTO @RESULTS SELECT 290, '026 END-->LOG ROWS IN ERRORLOG  ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------
        INSERT INTO @RESULTS SELECT 300, '027 BEG-->LOAD ROWS IN ERR      ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        INSERT INTO 
        COREERRLOG.DBO.ERR_DOLLAR_COST_AVG 
        SELECT *,@REPERRORLOGID 
        FROM COREETL.DBO.COR_DOLLAR_COST_AVG
        WHERE FROM_ASSET_SRC_CODE NOT IN (SELECT DOMCODE FROM @CODES)
        AND FROM_ASSET_SRC_CODE IS NOT NULL

        -------------------------------------------------------------------------------------------        INSERT INTO @RESULTS SELECT 310, '028 END-->LOAD ROWS INTO ERR    ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------
        INSERT INTO @RESULTS SELECT 320, '029 BEG-->CONVERT INVALIDS TO X ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------

        UPDATE 
        COREETL.DBO.COR_DOLLAR_COST_AVG 
        SET FROM_ASSET_SRC_CODE = 'XXXX' 
        WHERE FROM_ASSET_SRC_CODE NOT IN (SELECT DOMCODE FROM @CODES)
        AND FROM_ASSET_SRC_CODE IS NOT NULL

        SELECT @XXXXCOUNT = @@ROWCOUNT

        INSERT INTO @RESULTS SELECT 330, '    ' + CAST(@XXXXCOUNT AS VARCHAR(100)) + ' RECORDS CONVERTED TO ERROR CODES'

        -------------------------------------------------------------------------------------------
        INSERT INTO @RESULTS SELECT 340, '030 END-->CONVERT INVALIDS TO X ' + CONVERT(VARCHAR(100),GETDATE(),109)
        -------------------------------------------------------------------------------------------
END

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 350, '031 BEG-->UPDATE SEGMENT LOG    ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

UPDATE CORE1.DBO.MC_SEGMENT
SET ENDDATETIMESTAMP = GETDATE(),COMPLETED = 'T', RECORDSPROCESSED = @AFFECTEDRECORDS
WHERE SEGMENT = 'DOMAIN' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'DOM_COR_DOLLAR_COST_AVG__FROM_ASSET_SRC_CODE'

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 360, '032 END-->UPDATE SEGMENT LOG    ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 370, '033 BEG-->RESET THE PROCESSID   ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

UPDATE PRM_DOMAINCHILDREN SET PROCESSID = NULL WHERE DOMAINTABLENAME = 'DOM_ASSET_SRC' AND CORETABLENAME = 'COR_DOLLAR_COST_AVG' AND COREFIELDNAME = 'FROM_ASSET_SRC_CODE' 

-------------------------------------------------------------------------------------------
INSERT INTO @RESULTS SELECT 380, '034 END-->RESET THE PROCESSID   ' + CONVERT(VARCHAR(100),GETDATE(),109)
-------------------------------------------------------------------------------------------

IF @OUTPUTIND = 1 SELECT EVENT FROM @RESULTS ORDER BY SEQ ASC

RETURN
GO
