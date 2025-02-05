USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Check_Data_Availability]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Proc_TRAC_Check_Data_Availability]
As
set nocount on

DECLARE	@VariableCount INT
DECLARE	@FixedCount INT
DECLARE @TransactionCount INT
DECLARE @ErrorMessage VARCHAR(100)

SET @VariableCount = (select count(*) from Core1.dbo.TRACAssetSourceDetailVariable)
SET @FixedCount = (select count(*) from Core1.dbo.TRACAssetSourceDetailFixed)
SET @TransactionCount = (select count(*) from  TRACTransactionDetail)


IF (@VariableCount = 0 OR @FixedCount = 0 or @TransactionCount = 0)
BEGIN
	
	SET @ErrorMessage = 'Please contact CORE on-call support person. Data from CORE.v_AssetSourceDetailVariable or CORE.v_AssetSourceDetailFixed or v_TransactionDetail not loaded properly may due to transaction extract date is set ahead.'
	RAISERROR (@ErrorMessage, 16, 1)
END

GO
