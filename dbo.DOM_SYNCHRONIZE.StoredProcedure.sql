USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[DOM_SYNCHRONIZE]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





CREATE PROCEDURE [dbo].[DOM_SYNCHRONIZE] AS
        
        SET NOCOUNT ON
        ---------------------------------------------------------------------------------
        --GRAB SOURCE DATA
        ---------------------------------------------------------------------------------
        SELECT * INTO #PRM_DOMAIN FROM OPENQUERY(MASTERGENID,'SELECT * FROM COREMASTER.DBO.PRM_DOMAIN') A
        SELECT * INTO #PRM_DOMAINCHILDREN FROM OPENQUERY(MASTERGENID,'SELECT * FROM COREMASTER.DBO.PRM_DOMAINCHILDREN') A
        SELECT * INTO #PRM_DOMAINDESTINATION FROM OPENQUERY(MASTERGENID,'SELECT * FROM COREMASTER.DBO.PRM_DOMAINDESTINATION') A
        SELECT * INTO #PRM_DOMAINERRORCODE FROM OPENQUERY(MASTERGENID,'SELECT * FROM COREMASTER.DBO.PRM_DOMAINERRORCODE') A
        SELECT * INTO #PRM_DOMAINSOURCE FROM OPENQUERY(MASTERGENID,'SELECT * FROM COREMASTER.DBO.PRM_DOMAINSOURCE') A
        
        
        ---------------------------------------------------------------------------------
        --CONDUCT INSERTS
        ---------------------------------------------------------------------------------
        
        
        INSERT INTO PRM_DOMAINERRORCODE
        (ERRORCODE, DESCRIPTION, CATEGORY, MIGRATIONFLAG, MIGRATIONISSUE,PARAMETERSTARTDATE,PARAMETERENDDATE)
        SELECT 
        A.ERRORCODE, A.DESCRIPTION, A.CATEGORY, A.MIGRATIONFLAG, A.MIGRATIONISSUE, A.PARAMETERSTARTDATE, A.PARAMETERENDDATE
        FROM 
                #PRM_DOMAINERRORCODE A
                LEFT OUTER JOIN 
                PRM_DOMAINERRORCODE B
                ON A.ERRORCODE = B.ERRORCODE
        WHERE
                B.ERRORCODE IS NULL
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINERRORCODE RECORD(S) INSERTED'



        INSERT INTO PRM_DOMAIN
                (DOMAINTABLENAME, DOMAINFIELDNAME, MIGRATIONFLAG, MIGRATIONISSUE,PARAMETERSTARTDATE,PARAMETERENDDATE)
        SELECT 
                A.DOMAINTABLENAME, A.DOMAINFIELDNAME, A.MIGRATIONFLAG, A.MIGRATIONISSUE, A.PARAMETERSTARTDATE, A.PARAMETERENDDATE
        FROM 
                #PRM_DOMAIN A
                LEFT OUTER JOIN 
                PRM_DOMAIN B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
        WHERE
                B.DOMAINTABLENAME IS NULL
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAIN RECORD(S) INSERTED'


        
        INSERT INTO PRM_DOMAINCHILDREN
        (DOMAINCHILDRENID,DOMAINTABLENAME,CORETABLENAME, COREFIELDNAME, ERRORCODE, PROCESSID, MIGRATIONFLAG, MIGRATIONISSUE,PARAMETERSTARTDATE,PARAMETERENDDATE)
        SELECT 
        A.DOMAINCHILDRENID, A.DOMAINTABLENAME, A.CORETABLENAME, A.COREFIELDNAME, A.ERRORCODE, A.PROCESSID, A.MIGRATIONFLAG, A.MIGRATIONISSUE, A.PARAMETERSTARTDATE, A.PARAMETERENDDATE
        FROM 
                #PRM_DOMAINCHILDREN A
                LEFT OUTER JOIN 
                PRM_DOMAINCHILDREN B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
                AND A.CORETABLENAME = B.CORETABLENAME
                AND A.COREFIELDNAME = B.COREFIELDNAME
        WHERE
                B.DOMAINTABLENAME IS NULL
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINCHILDREN RECORD(S) INSERTED'

        
        

        
        INSERT INTO PRM_DOMAINDESTINATION
        (DOMAINTABLENAME, DOMAINCODE, DESCRIPTION, SHORTDESCRIPTION, FROMDATE, THROUGHDATE, MIGRATIONFLAG, MIGRATIONISSUE,PARAMETERSTARTDATE,PARAMETERENDDATE)
        SELECT 
        A.DOMAINTABLENAME, A.DOMAINCODE, A.DESCRIPTION, A.SHORTDESCRIPTION, A.FROMDATE, A.THROUGHDATE, A.MIGRATIONFLAG, A.MIGRATIONISSUE, A.PARAMETERSTARTDATE, A.PARAMETERENDDATE
        FROM 
                #PRM_DOMAINDESTINATION A
                LEFT OUTER JOIN 
                PRM_DOMAINDESTINATION B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
                AND A.DOMAINCODE = B.DOMAINCODE
        WHERE
                B.DOMAINTABLENAME IS NULL
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINDESTINATION RECORD(S) INSERTED'

        
        
        INSERT INTO PRM_DOMAINSOURCE
        (DOMAINTABLENAME, DOMAINCODE, SOURCEVALUE, SYSTEMID, COPYBOOKNAME, COPYBOOKFIELDNAME, COPYBOOKDESCRIPTION, MIGRATIONFLAG, MIGRATIONISSUE,PARAMETERSTARTDATE,PARAMETERENDDATE)
        SELECT 
        A.DOMAINTABLENAME, A.DOMAINCODE, A.SOURCEVALUE, A.SYSTEMID, A.COPYBOOKNAME, A.COPYBOOKFIELDNAME, A.COPYBOOKDESCRIPTION, A.MIGRATIONFLAG, A.MIGRATIONISSUE, A.PARAMETERSTARTDATE, A.PARAMETERENDDATE
        FROM 
                #PRM_DOMAINSOURCE A
                LEFT OUTER JOIN 
                PRM_DOMAINSOURCE B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
                AND A.DOMAINCODE = B.DOMAINCODE
                AND A.SOURCEVALUE = B.SOURCEVALUE
                AND A.SYSTEMID = B.SYSTEMID
        WHERE
                B.DOMAINTABLENAME IS NULL
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINSOURCE RECORD(S) INSERTED'
        

        


        ---------------------------------------------------------------------------------
        --CONDUCT DELETES
        ---------------------------------------------------------------------------------
        

        DELETE PRM_DOMAINERRORCODE
        FROM         
                PRM_DOMAINERRORCODE A
                LEFT OUTER JOIN
                #PRM_DOMAINERRORCODE B
                ON A.ERRORCODE = B.ERRORCODE
        WHERE
                B.ERRORCODE IS NULL
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINERRORCODE RECORD(S) DELETED'        



        DELETE PRM_DOMAINSOURCE
        FROM         
                PRM_DOMAINSOURCE A
                LEFT OUTER JOIN
                #PRM_DOMAINSOURCE B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
                AND A.DOMAINCODE = B.DOMAINCODE
                AND A.SOURCEVALUE = B.SOURCEVALUE
                AND A.SYSTEMID = B.SYSTEMID
        WHERE
                B.DOMAINTABLENAME IS NULL

        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINSOURCE RECORD(S) DELETED'



        DELETE PRM_DOMAINDESTINATION
        FROM         
                PRM_DOMAINDESTINATION A
                LEFT OUTER JOIN
                #PRM_DOMAINDESTINATION B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
                AND A.DOMAINCODE = B.DOMAINCODE
        WHERE
                B.DOMAINTABLENAME IS NULL
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINDESTINATION RECORD(S) DELETED'



        DELETE PRM_DOMAINCHILDREN
        FROM         
                PRM_DOMAINCHILDREN A
                LEFT OUTER JOIN
                #PRM_DOMAINCHILDREN B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
                AND A.CORETABLENAME = B.CORETABLENAME
                AND A.COREFIELDNAME = B.COREFIELDNAME
        WHERE
                B.DOMAINTABLENAME IS NULL
        
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINCHILDREN RECORD(S) DELETED'




        DELETE PRM_DOMAIN
        FROM         
                PRM_DOMAIN A
                LEFT OUTER JOIN
                #PRM_DOMAIN B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
        WHERE
                B.DOMAINTABLENAME IS NULL
        
        

        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAIN RECORD(S) DELETED'





        ---------------------------------------------------------------------------------
        --CONDUCT UPDATES
        ---------------------------------------------------------------------------------
        

        UPDATE PRM_DOMAIN
        SET
                DOMAINFIELDNAME = B.DOMAINFIELDNAME, 
                MIGRATIONFLAG = B.MIGRATIONFLAG, 
                MIGRATIONISSUE = B.MIGRATIONISSUE,
                PARAMETERSTARTDATE = B.PARAMETERSTARTDATE,
                PARAMETERENDDATE = B.PARAMETERENDDATE
        FROM 
                PRM_DOMAIN A
                INNER JOIN
                #PRM_DOMAIN B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
        

        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAIN RECORD(S) UPDATED'



        UPDATE PRM_DOMAINERRORCODE
        SET
                DESCRIPTION = B.DESCRIPTION, 
                CATEGORY = B.CATEGORY, 
                MIGRATIONFLAG = B.MIGRATIONFLAG, 
                MIGRATIONISSUE = B.MIGRATIONISSUE,
                PARAMETERSTARTDATE = B.PARAMETERSTARTDATE,
                PARAMETERENDDATE = B.PARAMETERENDDATE
        FROM 
                PRM_DOMAINERRORCODE A
                INNER JOIN
                #PRM_DOMAINERRORCODE B
                ON A.ERRORCODE = B.ERRORCODE
        
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINERRORCODE RECORD(S) UPDATED'



        UPDATE PRM_DOMAINDESTINATION
        SET
                DESCRIPTION = B.DESCRIPTION, 
                SHORTDESCRIPTION = B.SHORTDESCRIPTION, 
                FROMDATE = B.FROMDATE, 
                THROUGHDATE = B.THROUGHDATE,  
                MIGRATIONFLAG = B.MIGRATIONFLAG, 
                MIGRATIONISSUE = B.MIGRATIONISSUE,
                PARAMETERSTARTDATE = B.PARAMETERSTARTDATE,
                PARAMETERENDDATE = B.PARAMETERENDDATE
        FROM 
                PRM_DOMAINDESTINATION A
                INNER JOIN
                #PRM_DOMAINDESTINATION B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
                AND A.DOMAINCODE = B.DOMAINCODE
        

        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINDESTINATION RECORD(S) UPDATED'


        UPDATE PRM_DOMAINSOURCE
        SET
                COPYBOOKNAME = B.COPYBOOKNAME, 
                COPYBOOKFIELDNAME = B.COPYBOOKFIELDNAME, 
                COPYBOOKDESCRIPTION = B.COPYBOOKDESCRIPTION, 
                MIGRATIONFLAG = B.MIGRATIONFLAG, 
                MIGRATIONISSUE = B.MIGRATIONISSUE,
                PARAMETERSTARTDATE = B.PARAMETERSTARTDATE,
                PARAMETERENDDATE = B.PARAMETERENDDATE
        FROM 
                PRM_DOMAINSOURCE A
                INNER JOIN
                #PRM_DOMAINSOURCE B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
                AND A.DOMAINCODE = B.DOMAINCODE
                AND A.SOURCEVALUE = B.SOURCEVALUE
                AND A.SYSTEMID = B.SYSTEMID
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINSOURCE RECORD(S) UPDATED'
        

        UPDATE PRM_DOMAINCHILDREN
        SET
                DOMAINCHILDRENID = B.DOMAINCHILDRENID,
                ERRORCODE = B.ERRORCODE, 
                PROCESSID = B.PROCESSID,
                MIGRATIONFLAG = B.MIGRATIONFLAG, 
                MIGRATIONISSUE = B.MIGRATIONISSUE,
                PARAMETERSTARTDATE = B.PARAMETERSTARTDATE,
                PARAMETERENDDATE = B.PARAMETERENDDATE
        FROM 
                PRM_DOMAINCHILDREN A
                INNER JOIN
                #PRM_DOMAINCHILDREN B
                ON A.DOMAINTABLENAME = B.DOMAINTABLENAME
                AND A.CORETABLENAME = B.CORETABLENAME
                AND A.COREFIELDNAME = B.COREFIELDNAME
        
        PRINT CAST(@@ROWCOUNT  AS VARCHAR(100)) + ' PRM_DOMAINCHILDREN RECORD(S) UPDATED'

DROP TABLE #PRM_DOMAINERRORCODE 
DROP TABLE #PRM_DOMAIN
DROP TABLE #PRM_DOMAINCHILDREN
DROP TABLE #PRM_DOMAINDESTINATION
DROP TABLE #PRM_DOMAINSOURCE

RETURN
GO
