USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[PROC_GL_FUND_FUND_CUSIP_CHANGES]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    --EXEC  [dbo].[PROC_GL_FUND_FUND_CUSIP_CHANGES]      
    
CREATE PROCEDURE  [dbo].[PROC_GL_FUND_FUND_CUSIP_CHANGES]      
       
AS      
BEGIN      
 -- SET NOCOUNT ON ADDED TO PREVENT EXTRA RESULT SETS FROM      
 -- INTERFERING WITH SELECT STATEMENTS.      
 SET NOCOUNT ON;      
      
DECLARE @COUNT AS INT       
DECLARE @MSG VARCHAR(8000)            
DECLARE @FROM VARCHAR(255)            
DECLARE @TO VARCHAR(255)            
DECLARE @SUBJ VARCHAR(255)         
DECLARE @ETLDIRECTORY VARCHAR(255)       
DECLARE @sql NVARCHAR(2000)          
DECLARE @sql1 NVARCHAR(2000)      
DECLARE @ENV VARCHAR(30)                      
        
 IF NOT OBJECT_ID('TEMPDB..#TEMPOMINISRCFUNDS') IS NULL            
    DROP TABLE #TEMPOMINISRCFUNDS       
          
SET @ENV = @@SERVERNAME   
SET @ETLDIRECTORY = (SELECT ETLDIRECTORY FROM CORE1.DBO.PRM_SYSTEMDIRECTORY WHERE SYSTEMID = 49)     
    
SELECT @COUNT=  COUNT (*) FROM CORE..SBGCORE.WK_GL_CSP_DESC_RPT      
      
IF @COUNT > 0       
BEGIN      
      
SELECT  *  FROM CORE..SBGCORE.WK_GL_CSP_DESC_RPT    
        
SELECT @SQL = 'EXEC USP_EXPORT_DATA_TO_EXCEL ''CORE1'',''SELECT * FROM #TEMPOMINISRCFUNDS '','''+@ETLDIRECTORY+'\GL_fund_CUSIP.XLS'''            
--- PRINT @SQL            
 EXEC SP_EXECUTESQL @SQL            
            
 SELECT @MSG = 'Attached the report of GL_FUND/CUSIP details for which GL_fund and CUSIP are not unique'            
 SET @SUBJ = @ENV + 'GL_fund and CUSIP'            
 SET @FROM = 'IT-COREON-CALL@SECURITYBENEFIT.COM'            
 SET @TO = 'SP_PROC_SRC_FUND_CHANGES'            
             
 SELECT @SQL1 ='EXEC USP_SQLEMAIL '''+@FROM+''','''+@TO+''','''+@SUBJ+''','''+@MSG+''','''+@ETLDIRECTORY+'\GL_fund_CUSIP.XLS'''            
 --PRINT @SQL1            
 EXEC SP_EXECUTESQL @SQL1         
      
END       
ELSE      
      
BEGIN       
        
 SELECT @MSG = 'GL_fund and CUSIP are unique'            
 SET @SUBJ = @ENV + ' - LIFECAD FIXED FUNDS CHANGES'            
 SET @FROM = 'IT-COREON-CALL@SECURITYBENEFIT.COM'            
 SET @TO = 'SP_PROC_SRC_FUND_CHANGES'            
             
 SELECT @SQL1 ='EXEC USP_SQLEMAIL '''+@FROM+''','''+@TO+''','''+@SUBJ+''','''+@MSG+''''            
 --PRINT @SQL1            
 EXEC SP_EXECUTESQL @SQL1        
      
END       
      
       
END 
GO
