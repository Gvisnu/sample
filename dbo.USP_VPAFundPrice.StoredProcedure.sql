USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_VPAFundPrice]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_VPAFundPrice] AS
/*
CREATE DATETIME: Jun 18 2009 11:25AM
COMMENTS: MODIFIED JUNE 2008 TO NOT GENERATE PROCEDURE VARIABLES.
*/
SET NOCOUNT ON
SET LOCK_TIMEOUT -1
BEGIN

	IF OBJECT_ID('#temp') IS NOT NULL 
	  drop table #temp

	IF OBJECT_ID('#temp1') IS NOT NULL 
	  drop table #temp1

	IF OBJECT_ID('#Result1') IS NOT NULL 
	  drop table #Result1

	IF OBJECT_ID('#Result2') IS NOT NULL 
	  drop table #Result2

	-- get the latest vpa fund price record if we have more than one price record for the 
	-- fundcusip and pricedate combination
	select fundcusip,pricedate, max( id) as maxid 
	into #temp
	 from VpaFundPrice
	group by fundcusip,pricedate
	having count(*) > 1 

	select vpa.* 
	into #Result1
	from VpaFundPrice vpa
	inner join #temp temp
	on VPA.fundcusip = temp.fundcusip
	and VPA.pricedate = temp.pricedate
	and VPA.id = temp.maxid
	order by vpa.fundcusip 

	-- get the vpa fund price record if we have only one price record for the 
	-- fundcusip and pricedate combination
	select fundcusip,pricedate, max( id) as maxid 
	into #temp1
	 from VpaFundPrice
	group by fundcusip,pricedate
	having count(*) = 1 

	select vpa.* 
	into #Result2
	from VpaFundPrice vpa
	inner join #temp1 temp
	on VPA.fundcusip = temp.fundcusip
	and VPA.pricedate = temp.pricedate
	and VPA.id = temp.maxid
	order by vpa.fundcusip 

	INSERT INTO CORE1.dbo.COM_LEGAL_FUND_PRICE (
		[FundCusip],
		[PRICE_DATE],
		[LEGAL_PRICE_AMT],
		[DAILY_DIV_RATE],
		[JOB_ID])
	SELECT 
		Q.[fundCusip],
		CASE WHEN ISDATE(Q.[priceDate])=1 THEN Q.[priceDate] ELSE NULL END AS [priceDate], 
		CASE WHEN RTRIM(LTRIM(Q.[priceAmt])) =' ' THEN NULL WHEN RTRIM(LTRIM(Q.[priceAmt]))='-999' THEN NULL  else Q.[priceAmt] END AS [priceAmt], 
		CASE WHEN RTRIM(LTRIM(Q.[dailyDividendRate])) =' ' THEN NULL WHEN RTRIM(LTRIM(Q.[dailyDividendRate]))='-999' THEN NULL  else Q.[dailyDividendRate] END AS [dailyDividendRate],
		Q.[JobID]
	FROM	(
	select * from #Result1
	union 
	select * from #Result2
	) Q



	drop table #temp
	drop table #temp1

	drop table #Result1
	drop table #Result2
RETURN
END




GO
