USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_SRC_FUND_ADDITION]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Proc_TRAC_SRC_FUND_ADDITION] as      
      
DECLARE @MSG VARCHAR(8000)      
DECLARE @FROM VARCHAR(255)      
DECLARE @TO VARCHAR(255)      
DECLARE @SUBJ VARCHAR(255)      
DECLARE @ROWCNT INT      
DECLARE @ETLDIRECTORY VARCHAR(255)      
DECLARE @sql NVARCHAR(2000)      
DECLARE @sql1 NVARCHAR(2000)          
DECLARE @sql3 NVARCHAR(2000)     
DECLARE @ENV VARCHAR(30)  
  
         
if not object_id('tempdb..#TEMPSRCFUNDS') is null      
    drop table #TEMPSRCFUNDS      
      
SELECT Q.* INTO #TEMPSRCFUNDS FROM  (SELECT DISTINCT REC_INSRT_NAME FROM CoreErrLog.dbo.ERR_PLN_ALLOCTN WHERE SRC_FUND_ID = '999999999')Q  
      
set @ROWCNT = (select count(*) from #TEMPSRCFUNDS)      
SET @ETLDirectory = (Select ETLDirectory from Core1.dbo.PRM_SystemDirectory Where SystemID = 49)      
SET @ENV = Core1.dbo.fn_GetServerName();   
SET @FROM = 'it-coreon-call@securitybenefit.com'      
SET @To = 'SP_Proc_TRAC_Src_Fund_Changes'      
--SET @To = 'Janarthanan.subramanian@se2.com'      
     
if(@ROWCNT > 0)      
begin      
      
 SELECT @sql = 'EXEC USP_EXPORT_DATA_TO_EXCEL ''Core1'',''SELECT * FROM #TEMPSRCFUNDS'','''+@ETLDirectory+'\TRAC_SRC_FUND_ADDITION.xls'''      
 --PRINT @SQL      
 EXEC sp_executesql @sql      
      
 SELECT @MSG = 'The attached spreadsheet has list of TRAC Src funds which has to be added in COR_SRC_FUND and GenIDSRCfund table'      
 SET @SUBJ = @ENV + ' - TRAC SRC FUNDS ADDITION'      
 SELECT @sql1 ='EXEC USP_SQLEMAIL '''+@FROM+''','''+@TO+''','''+@SUBJ+''','''+@MSG+''','''+@ETLDIRECTORY+'\TRAC_SRC_FUND_ADDITION.xls'''      
 --print @SQL1      
 EXEC sp_executesql @sql1      
      
       
end      
    
else      
begin      
 SELECT @MSG = 'No TRAC Src Funds have to be Added'      
 SET @SUBJ = @ENV + ' - TRAC SRC FUNDS ADDITION'      
 SELECT @sql3 ='EXEC USP_SQLEMAIL '''+@FROM+''','''+@TO+''','''+@SUBJ+''','''+@MSG+''''        
 EXEC sp_executesql @sql3       
 --EXEC USP_SQLEMAIL @FROM,@TO,@SUBJ, @MSG,NULL    Commented this block as it was generating balnk mails on 08-21-2013  
      
end
GO
