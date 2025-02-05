USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_SRC_FUND_ID_Correction]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_TRAC_Populate_SRC_FUND_ID_Correction] AS    

Declare @SRC_FUND_ID int
Declare @SRC_FUND_ID_Max int

SelecT @SRC_FUND_ID = MAX(SRC_FUND_ID) FROM GenIDSRCFund WHERE SourceSystem = 'TRAC' 
SelecT @SRC_FUND_ID_Max = SRC_FUND_ID FROM GENIDSRCFund_Max

If @SRC_FUND_ID > @SRC_FUND_ID_Max 
BEGIN 

DELETE FROM DBO.GENIDSRCFund_Max

INSERT INTO DBO.GENIDSRCFund_Max 
SelecT MAX(SRC_FUND_ID)  SRC_FUND_ID FROM GenIDSRCFund WHERE SourceSystem = 'TRAC' 
    
-----------------------------------------------------------------------    
-- Correct fund ID in ERR table where possible    
-----------------------------------------------------------------------    
    
UPDATE CoreErrLog.dbo.ERR_SRC_FUND_PRICE    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_SRC_FUND_PRICE A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey2 = REC_INSRT_NAME    
WHERE A.SRC_FUND_ID = '999999999';    
    
UPDATE CoreErrLog.dbo.ERR_TRNSCTN_DETAIL     
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_TRNSCTN_DETAIL A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
AND SourceSystemKey2 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)  
AND SourceSystemKey3 = dbo.DelimInString(REC_INSRT_NAME,'+', 3)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 4)    
WHERE A.SRC_FUND_ID = '999999999';    
    
UPDATE CoreErrLog.dbo.ERR_INT_RATE_PLAN    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_INT_RATE_PLAN A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)    
WHERE A.SRC_FUND_ID = '999999999';    
    
UPDATE CoreErrLog.dbo.ERR_PLN_ALLOCTN    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_PLN_ALLOCTN A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
AND SourceSystemKey2 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)  
AND SourceSystemKey3 = dbo.DelimInString(REC_INSRT_NAME,'+', 3)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 4)    
WHERE A.SRC_FUND_ID = 999999999;   

-- Added the below block on 03-30-2015
UPDATE CoreErrLog.dbo.ERR_PLN_ALLOCTN    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_PLN_ALLOCTN A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
--AND SourceSystemKey2 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)  
AND SourceSystemKey3 = dbo.DelimInString(REC_INSRT_NAME,'+', 3)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 4)    
WHERE A.SRC_FUND_ID = 999999999
and (
    (rtrim(dbo.DelimInString(REC_INSRT_NAME,'+', 2) ) <> '' 
    AND rtrim(B.SOURCESYSTEMKEY2) = rtrim(dbo.DelimInString(REC_INSRT_NAME,'+', 2) )) 
    OR (rtrim(dbo.DelimInString(REC_INSRT_NAME,'+', 2) ) = '')) ; 
-- End of the below block
    
UPDATE CoreErrLog.dbo.ERR_ASSET_SOURCE_DETAIL    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_ASSET_SOURCE_DETAIL A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
AND SourceSystemKey2 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)  
AND SourceSystemKey3 = dbo.DelimInString(REC_INSRT_NAME,'+', 3)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 4)    
WHERE A.SRC_FUND_ID = 999999999;    
    
UPDATE CoreErrLog.dbo.ERR_FIXED_ASSET_SRC_DTL    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_FIXED_ASSET_SRC_DTL A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
AND SourceSystemKey2 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)  
AND SourceSystemKey3 = dbo.DelimInString(REC_INSRT_NAME,'+', 3)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 4)    
WHERE A.SRC_FUND_ID = 999999999;    
    
UPDATE CoreErrLog.dbo.ERR_X_CONTRIB_DETAIL    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_X_CONTRIB_DETAIL A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
AND SourceSystemKey2 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)  
AND SourceSystemKey3 = dbo.DelimInString(REC_INSRT_NAME,'+', 3)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 4)    
WHERE A.SRC_FUND_ID = 999999999;    
    
UPDATE CoreErrLog.dbo.ERR_X_FUND_DETAIL    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_X_FUND_DETAIL A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
AND SourceSystemKey2 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)  
AND SourceSystemKey3 = dbo.DelimInString(REC_INSRT_NAME,'+', 3)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 4)    
WHERE A.SRC_FUND_ID = 999999999;    
    
UPDATE CoreErrLog.dbo.ERR_X_LOAN_FUND_DTL    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_X_LOAN_FUND_DTL A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
AND SourceSystemKey2 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)  
AND SourceSystemKey3 = dbo.DelimInString(REC_INSRT_NAME,'+', 3)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 4)  
WHERE A.SRC_FUND_ID = 999999999;    
    
UPDATE CoreErrLog.dbo.ERR_X_EXTRNL_ASSET_SRC_DETAIL    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_X_EXTRNL_ASSET_SRC_DETAIL A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
AND SourceSystemKey2 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)  
AND SourceSystemKey3 = dbo.DelimInString(REC_INSRT_NAME,'+', 3)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 4)  
WHERE A.SRC_FUND_ID = 999999999;    
    
UPDATE CoreErrLog.dbo.ERR_X_EXTRNL_FUND_DETAIL    
SET SRC_FUND_ID = B.SRC_FUND_ID    
FROM CoreErrLog.dbo.ERR_X_EXTRNL_FUND_DETAIL A    
INNER JOIN GenIDSRCFund B    
ON  SourceSystem = 'TRAC'    
AND SourceSystemKey1 = dbo.DelimInString(REC_INSRT_NAME,'+', 1)    
AND SourceSystemKey2 = dbo.DelimInString(REC_INSRT_NAME,'+', 2)  
AND SourceSystemKey3 = dbo.DelimInString(REC_INSRT_NAME,'+', 3)    
AND SourceSystemKey4 = dbo.DelimInString(REC_INSRT_NAME,'+', 4)  
WHERE A.SRC_FUND_ID = 999999999;    
END 

RETURN
GO
