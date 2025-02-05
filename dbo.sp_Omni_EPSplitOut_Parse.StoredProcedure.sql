USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[sp_Omni_EPSplitOut_Parse]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[sp_Omni_EPSplitOut_Parse]

AS

--Parse the Records into the ExtendedPDF table

Set NOCOUNT ON


--Declare input variables
DECLARE @Plan_Num VarChar(6)
DECLARE @PLAN_Seq VarChar(3)
DECLARE @Part_ID VarChar (9)
DECLARE @Fund_ID VarChar(3)
DECLARE @Entry SmallInt
DECLARE @Var_Data VarChar(15)
DECLARE @Var_Data_2 VarChar(15)
DECLARE @Part_Num VarChar(9)
DECLARE @Sub_Plan VarChar(6)
DECLARE @Part_Ext VarChar (2)
DECLARE @Usage VarChar (2)
DECLARE @Key_Data VarChar(12)
DECLARE @Rec_Type VarChar (2)
DECLARE @Base Int
DECLARE @Base_Count Int
DECLARE @Col001 VarChar (1000)
DECLARE @JobID Int

DECLARE crsr_EP CURSOR FOR 
	SELECT * FROM OmniEPSplitOut
	
OPEN crsr_EP

Set @Base_Count = 1
Set @Base = 121 --Base Column for Variable Length Data
SET @JobId = (SELECT MAX(JobID) AS JobID FROM MC_JobID GROUP BY SourceFileID HAVING (SourceFileID = 41))

FETCH Next FROM crsr_EP INTO @Col001

WHILE @@FETCH_STATUS = 0
BEGIN
	Set @Plan_Num = Substring(@Col001, 41,6)
	Set @Plan_Seq = SubString(@Col001,47,3)
	Set @Part_ID =  SubString(@Col001,40,3)
	Set @Part_ID = SubString(@Col001, 54,9)
	Set @Sub_Plan = SubString(@Col001, 63,6)
	Set @Part_Ext = SubString(@Col001, 69,2)
	Set @Usage = SubString(@Col001, 71,2)
	Set @Key_Data = SubString(@Col001, 73,12)
	Set @Fund_ID = (CASE 
				WHEN Substring(@Col001, 87,1) = '*'
					THEN Substring(@Col001, 85,2)
				ELSE Substring(@Col001, 85,3)
				END
			)
	Set @Rec_Type = SubString(@Col001, 93,2)
	
	Set @Entry = CAST(SubString(@Col001, 95,6)AS SMALLINT)

	WHILE @Base_Count <= @Entry
	BEGIN

          Set @Var_Data = (Substring(@Col001, (@Base + ((@Base_Count * 15)-15)),15))
          Set @Base_Count = @Base_Count + 1
          Set @Var_Data_2 = (Substring(@Col001,(@Base + ((@Base_Count * 15)-15)),15))

          INSERT INTO OmniEPIAContributionDetail
		(EP_Plan_Num, EP_Plan_Seq, EP_Part_ID, EP_Part_Num,
		 EP_Sub_Plan, EP_Part_Ext, EP_Usage, EP_Key_Data,
		 EP_Fund_ID, EP_Rec_Type, 
		 EP_Contract, EP_Units, JobId)
	  Values(@Plan_Num, @Plan_Seq, @Part_ID, @Part_Num,
		 @Sub_Plan, @Part_Ext, @Usage, @Key_Data,
		 @Fund_ID, @Rec_Type, 
		 @Var_Data, @Var_Data_2, @JobId)

          Set @Base_Count = @Base_Count + 1

	END
	Set @Base_Count = 1
	FETCH NEXT FROM crsr_EP INTO @Col001
	
END

CLOSE crsr_EP
DEALLOCATE crsr_EP

RETURN
GO
