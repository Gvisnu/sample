USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[DOM_COR_AGRMNT_PARTY_PSTL_ADDR__PSTL_ADDR_TYPE_CODE]    Script Date: 12/31/2024 8:49:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DOM_COR_AGRMNT_PARTY_PSTL_ADDR__PSTL_ADDR_TYPE_CODE] AS  
  
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
               WHERE Finished = 'F'  
               AND SystemID = 49 AND ISNULL(SUBSYSTEMID,-1) =-1  
            
IF @SYSPROCESSEDLOGID IS NULL  
BEGIN  
        SET @ERRORMESSAGE = '[dbo].DOM_COR_AGRMNT_PARTY_PSTL_ADDR__PSTL_ADDR_TYPE_CODE Failed. SYSPROCESSEDLOGID is null'   
        RAISERROR (@ERRORMESSAGE, 16, 1)  
  RETURN 1  
END  
   
SET @ETLDIRECTORY = (SELECT ETLDIRECTORY FROM CORE1.DBO.PRM_SYSTEMDIRECTORY WHERE SYSTEMID = @SYSTEMID)  
  
if not object_id('tempdb..##TEMP_DOM_122_20') is null  
     drop table ##TEMP_DOM_122_20  
  
CREATE TABLE ##TEMP_DOM_122_20(SEQ INT, EVENT VARCHAR(178))  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 10, '000 SPID = ' + CAST (@@SPID AS VARCHAR(100))  
INSERT INTO ##TEMP_DOM_122_20 SELECT 20, '001 BEG-->CHECK SEGMENT STATUS  ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
--CHECK IF DOMAIN HAS ALREADY BEEN CONVERTED  
-------------------------------------------------------------------------------------  
--GET SYSTEM IDENTIFIER FOR REPERRORLOG  
-------------------------------------------------------------------------------------  
  
  
SET @ALPHASYSTEM = (SELECT LEFT(S.SYSTEMNAME,4) FROM MC_SYSPROCESSEDLOG L INNER JOIN MC_SOURCESYSTEM S ON L.SYSTEMID = S.SYSTEMID WHERE L.SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID)  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 30, '002 END-->CHECK SEGMENT STATUS  ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 40, '003 BEG-->SET SEGMENT STATUS    ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 50, '004 END-->SET SEGMENT STATUS    ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 60, '005 BEG-->ADD INDEX IF NONE     ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 70, '006 END-->ADD INDEX IF NONE     ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 80, '007 BEG-->LOAD DOMAINS          ' + CONVERT(VARCHAR(100),GETDATE(),109)  
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
AND A.DOMAINTABLENAME = 'DOM_PSTL_ADDR_TYPE'  
AND ISNULL(A.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(A.PARAMETERENDDATE,'1/1/2999') > GETDATE()  
and ISNULL(B.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(B.PARAMETERENDDATE,'1/1/2999') > GETDATE()  
and ISNULL(C.PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(C.PARAMETERENDDATE,'1/1/2999') > GETDATE()  
  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 90, '008 END-->LOAD DOMAINS          ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 100, '009 BEG-->TRANSFORM DOMAINS     ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
UPDATE COREETL.DBO.COR_AGRMNT_PARTY_PSTL_ADDR WITH (ROWLOCK)  
SET PSTL_ADDR_TYPE_CODE = B.DOMAINCODE   
FROM COREETL.DBO.COR_AGRMNT_PARTY_PSTL_ADDR A   
INNER JOIN @DOMS B   
ON A.PSTL_ADDR_TYPE_CODE = B.SOURCEVALUE  
  
SET @AFFECTEDRECORDS = @@ROWCOUNT  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 110, '010 END-->TRANSFORM DOMAINS     ' + CONVERT(VARCHAR(100),GETDATE(),109)  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 120, '011 BEG-->LOG RECORD COUNT      ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
INSERT INTO ##TEMP_DOM_122_20 SELECT 130, '    ' + CAST(@AFFECTEDRECORDS AS VARCHAR(100)) + ' RECORDS TRANSFORMED'  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 140, '012 END-->LOG RECORD COUNT      ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 150, '013 BEG-->GET COUNT OF PRM_DomainSource INVALIDS ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
SELECT @ERRORSOURCE = COUNT(*)   
FROM COREETL.DBO.COR_AGRMNT_PARTY_PSTL_ADDR   
WHERE PSTL_ADDR_TYPE_CODE NOT IN (SELECT DOMAINCODE FROM @DOMS)  
AND PSTL_ADDR_TYPE_CODE IS NOT NULL  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 160, '014 END-->GET COUNT OF PRM_DomainSource ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
IF @ERRORSOURCE > 0   
BEGIN  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 170, '015 BEG-->LOG ROWS IN ERRORLOG  ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
  
        INSERT INTO COREERRLOG.DBO.REPERRORLOG   
        (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM)   
        VALUES   
        (GETDATE(), CAST(@ERRORSOURCE AS VARCHAR(100)) + ' INVALID PRM_DomainSource VALUE(S) DETECTED FOR COR_AGRMNT_PARTY_PSTL_ADDR.PSTL_ADDR_TYPE_CODE.','REFER TO ERR TABLES FOR DETAILS','DOM', @ALPHASYSTEM)  
          
        SELECT @REPERRORLOGID = @@IDENTITY  
  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 180, '016 END-->LOG ROWS IN ERRORLOG  ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 190, '017 BEG-->LOAD ROWS IN ERR      ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
  
        INSERT INTO   
        COREERRLOG.DBO.ERR_AGRMNT_PARTY_PSTL_ADDR   
        SELECT *,@REPERRORLOGID   
        FROM COREETL.DBO.COR_AGRMNT_PARTY_PSTL_ADDR  
        WHERE PSTL_ADDR_TYPE_CODE NOT IN (SELECT DOMAINCODE FROM @DOMS)  
        AND PSTL_ADDR_TYPE_CODE IS NOT NULL  
  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 200, '018 END-->LOAD ROWS INTO ERR    ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 210, '019 BEG-->CONVERT INVALIDS TO X ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
  
        UPDATE   
        COREETL.DBO.COR_AGRMNT_PARTY_PSTL_ADDR WITH (ROWLOCK)  
        SET PSTL_ADDR_TYPE_CODE = 'XXXX'   
        WHERE PSTL_ADDR_TYPE_CODE NOT IN (SELECT DOMAINCODE FROM @DOMS)  
        AND PSTL_ADDR_TYPE_CODE IS NOT NULL  
  
  
        SELECT @XXXXCOUNT = @@ROWCOUNT  
  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 220, '    ' + CAST(@XXXXCOUNT AS VARCHAR(100)) + ' RECORDS CONVERTED TO ERROR CODES'  
  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 230, '020 END-->CONVERT INVALIDS TO X ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
END  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 240, '021 BEG-->GRAB VALID ORACLE DOMS   ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
INSERT INTO @CODES   
SELECT PSTL_ADDR_TYPE_CODE   
FROM OPENQUERY(CORE,'SELECT PSTL_ADDR_TYPE_CODE FROM DOM_PSTL_ADDR_TYPE WHERE PSTL_ADDR_TYPE_CODE IS NOT NULL AND REC_THRU_DATE > SYSDATE')  
  
INSERT INTO @CODES (DOMCODE) VALUES ('^')  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 250, '022 END-->GET VALID ORACLE DOMS ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 260, '023 BEG-->GET COUNT OF ORACLE INVALIDS ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
SELECT @ERRORCOUNT = COUNT(*)   
FROM COREETL.DBO.COR_AGRMNT_PARTY_PSTL_ADDR   
WHERE PSTL_ADDR_TYPE_CODE NOT IN (SELECT DOMCODE FROM @CODES)  
AND PSTL_ADDR_TYPE_CODE IS NOT NULL  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 270, '024 END-->GET COUNT OF ORACLE INVALIDS ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
IF @ERRORCOUNT > 0   
BEGIN  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 280, '025 BEG-->LOG ROWS IN ERRORLOG  ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
  
        INSERT INTO COREERRLOG.DBO.REPERRORLOG   
        (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM)   
        VALUES   
        (GETDATE(), CAST(@ERRORCOUNT AS VARCHAR(100)) + ' INVALID ORACLE SOURCE DOMAIN VALUE(S) DETECTED FOR COR_AGRMNT_PARTY_PSTL_ADDR.PSTL_ADDR_TYPE_CODE.','REFER TO ERR TABLES FOR DETAILS','DOM', @ALPHASYSTEM)  
          
       SELECT @REPERRORLOGID = @@IDENTITY  
  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 290, '026 END-->LOG ROWS IN ERRORLOG  ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 300, '027 BEG-->LOAD ROWS IN ERR      ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
  
        INSERT INTO   
        COREERRLOG.DBO.ERR_AGRMNT_PARTY_PSTL_ADDR   
        SELECT *,@REPERRORLOGID   
        FROM COREETL.DBO.COR_AGRMNT_PARTY_PSTL_ADDR  
        WHERE PSTL_ADDR_TYPE_CODE NOT IN (SELECT DOMCODE FROM @CODES)  
        AND PSTL_ADDR_TYPE_CODE IS NOT NULL  
  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 310, '028 END-->LOAD ROWS INTO ERR    ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 320, '029 BEG-->CONVERT INVALIDS TO X ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
  
        UPDATE   
        COREETL.DBO.COR_AGRMNT_PARTY_PSTL_ADDR WITH (ROWLOCK)  
        SET PSTL_ADDR_TYPE_CODE = 'XXXX'   
        WHERE PSTL_ADDR_TYPE_CODE NOT IN (SELECT DOMCODE FROM @CODES)  
        AND PSTL_ADDR_TYPE_CODE IS NOT NULL  
  
        SELECT @XXXXCOUNT = @@ROWCOUNT  
  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 330, '    ' + CAST(@XXXXCOUNT AS VARCHAR(100)) + ' RECORDS CONVERTED TO ERROR CODES'  
  
        -------------------------------------------------------------------------------------------  
        INSERT INTO ##TEMP_DOM_122_20 SELECT 340, '030 END-->CONVERT INVALIDS TO X ' + CONVERT(VARCHAR(100),GETDATE(),109)  
        -------------------------------------------------------------------------------------------  
END  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 350, '031 BEG-->UPDATE SEGMENT LOG    ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
--UPDATE CORE1.DBO.MC_SEGMENT  
--SET ENDDATETIMESTAMP = GETDATE(),COMPLETED = 'T', RECORDSPROCESSED = @AFFECTEDRECORDS  
--WHERE SEGMENT = 'DOMAIN' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'DOM_COR_AGRMNT_PARTY_PSTL_ADDR__PSTL_ADDR_TYPE_CODE'  
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 360, '032 END-->UPDATE SEGMENT LOG    ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 370, '033 BEG-->RESET THE PROCESSID   ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
UPDATE PRM_DOMAINCHILDREN SET PROCESSID = NULL WHERE DOMAINTABLENAME = 'DOM_PSTL_ADDR_TYPE' AND CORETABLENAME = 'COR_AGRMNT_PARTY_PSTL_ADDR' AND COREFIELDNAME = 'PSTL_ADDR_TYPE_CODE'   
  
-------------------------------------------------------------------------------------------  
INSERT INTO ##TEMP_DOM_122_20 SELECT 380, '034 END-->RESET THE PROCESSID   ' + CONVERT(VARCHAR(100),GETDATE(),109)  
-------------------------------------------------------------------------------------------  
  
--IF @OUTPUTIND = 1 SELECT EVENT FROM ##TEMP_DOM_122_20 ORDER BY SEQ ASC  
-- build full BCP query  
    
  SELECT    @sql = 'bcp "select EVENT FROM ##TEMP_DOM_122_20 ORDER BY SEQ ASC" queryout ' + @ETLDIRECTORY + '\DomainResults\DOM_COR_AGRMNT_PARTY_PSTL_ADDR__PSTL_ADDR_TYPE_CODE.TXT -SSBGETL -T -c'  
  -- execute BCP  
  Exec master..xp_cmdshell @sql  
  
  DROP TABLE ##TEMP_DOM_122_20  
  
RETURN
GO
