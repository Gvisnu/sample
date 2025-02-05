USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_GenIDAgrmnt_Delete]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Proc_TRAC_GenIDAgrmnt_Delete]                          
AS  

IF object_id('tempdb.dbo.#AgrmntDlt') IS NOT NULL        
DROP TABLE #AgrmntDlt  
                        
SELECT DISTINCT
GenID.AgreementID,
INV_CO_UNIT_TAX_ID AS Agrmnt_sys_attr_key1_text,      
EXTERNAL_PLAN_ID AS Agrmnt_sys_attr_key2_text,      
PARTICIPANT_ID AS Agrmnt_sys_attr_key3_text,      
'^' As Agrmnt_sys_attr_key4_text,      
'^' As Agrmnt_sys_attr_key5_text,      
History_Action AS STATUS_CODE,      
Date_Deleted
INTO #AgrmntDlt
FROM TRACMASTER.TracMasterHistory.dbo.ParticipantPlanLevel_History PARTPL      
CROSS JOIN (SELECT CYCLESTARTDATE,CYCLEENDDATE FROM TRACMASTER.TracMaster.CORE.CYCLE_DATE D JOIN (SELECT MAX(CYCLEENDDATE) AS MAXENDDATE FROM TRACMASTER.TracMAster.CORE.CYCLE_DATE WHERE CYCLEENDDATE IS NOT NULL) M ON D.CYCLEENDDATE = M.MAXENDDATE) DT
INNER JOIN Core1.dbo.GenIDFAAgreement GenID ON GenID.SourceSystem = 'TRAC' 
AND INV_CO_UNIT_TAX_ID = GenID.SourceSystemKey1
AND EXTERNAL_PLAN_ID = GenID.SourceSystemKey2
AND PARTICIPANT_ID = GenID.SourceSystemKey3    
WHERE (PARTPL.Date_Deleted BETWEEN DT.CYCLESTARTDATE AND DT.CYCLEENDDATE)      
AND History_Action = 'DELETE'

INSERT INTO Core1.dbo.TMP_AGRMNT_DLT_LOG
SELECT 
SourceSystem,
SourceSystemKey1,
SourceSystemKey2,
SourceSystemKey3,
SourceSystemKey4,
SourceSystemKey5,
GenID,
LineageIDInd,
AgreementID,
JobID,
DateTimeStamp,
GETDATE()
FROM Core1.dbo.GenIDFAAgreement
WHERE AgreementID IN (SELECT AgreementID FROM #AgrmntDlt)

DELETE FROM Core1.dbo.GenIDFAAgreement
WHERE AgreementID IN (SELECT AgreementID FROM #AgrmntDlt)

DROP TABLE #AgrmntDlt

GO
