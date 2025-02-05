USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_GENIDTRACPLAN]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_GENIDTRACPLAN] AS      
      
      
 SET NOCOUNT ON      
 SET LOCK_TIMEOUT -1      
      
 INSERT INTO dbo.GenIDPLPlan      
 (      
 SourceSystem,      
 SourceSystemKey1,      
 SourceSystemKey2,      
 SourceSystemKey3,      
 SourceSystemKey4,      
 JobID      
 )      
 SELECT DISTINCT A.MNTC_SYSTEM_CODE,      
  ISNULL(A.PLAN_SYS_ATTR_KEY1_TEXT,'^'),      
   ISNULL(A.PLAN_SYS_ATTR_KEY2_TEXT,'^'),      
  '^',      
  '^',      
  1      
 FROM TRACPlan A LEFT OUTER JOIN GenIDPLPlan B      
 ON A.MNTC_SYSTEM_CODE = B.SOURCESYSTEM       
 AND ISNULL(A.PLAN_SYS_ATTR_KEY1_TEXT,'^') = B.SOURCESYSTEMKEY1 
 and ISNULL(A.PLAN_SYS_ATTR_KEY2_TEXT,'^') = B.SOURCESYSTEMKEY2    
 WHERE B.SOURCESYSTEM IS NULL       
        --AND A.ADU IN ('A','U')      
      
RETURN 



GO
