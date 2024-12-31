USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[TEST_NREPBUILD]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[TEST_NREPBUILD] as
         
        CREATE TABLE #LLOADCOUNT (RESULT VARCHAR(255))
        
        DECLARE @CMD NVARCHAR(255);
         --SELECT @CMD = N'SELECT CNT FROM OPENQUERY(CORE,''SELECT COUNT(*) AS CNT FROM SBGSTAGE.X_FUND_DETAIL_468'')'
         SELECT @CMD = N'SELECT CNT FROM OPENQUERY(CORE,''SELECT 1000000 AS CNT FROM DUAL'')'
         
         EXEC SP_EXECUTESQL @CMD 
                        --SELECT @CMD = N'SELECT CNT FROM OPENROWSET(''OraOLEDB.Oracle'',' + @CONNSTRING + ',''SELECT COUNT(*) AS CNT FROM SBGSTAGE.X_FUND_DETAIL_468'')'
    -- Modified by Senthilkumar Sekaran as on 02-18-2013 for issue no: 7074
                INSERT INTO #LLOADCOUNT EXEC SP_EXECUTESQL @CMD             
                 
                 
                 DECLARE @JJJ NVARCHAR(255);
                 
                 SET @JJJ = (select result from #LLOADCOUNT);
                 
                 print @JJJ
                 
                 RETURN
GO
