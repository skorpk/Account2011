USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test531]    Script Date: 01.10.2019 9:21:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test531]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

	---------------------------------------------------------------------------------
	SELECT DISTINCT cc.GUID_ZSL
	INTO #t
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
							inner join t_Case c on
				r.id=c.rf_idRecordCase								
							INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase                      
	where a.rf_idFiles=@idFile

	;WITH cte
	AS
	(
	SELECT ROW_NUMBER() OVER(PARTITION BY cc.rf_idRecordCase ORDER BY c1.TypePay desc) AS idRow,cc.GUID_ZSL AS GUID_CASE,c1.TypePay, cc.rf_idRecordCase
	FROM #t t INNER JOIN  dbo.t_CompletedCase cc ON
			 t.GUID_ZSL=cc.GUID_ZSL
						INNER JOIN t_Case c ON
			cc.rf_idRecordCase=c.rf_idRecordCase
						INNER JOIN dbo.t_RecordCaseBack r ON
			c.id=r.rf_idCase
				  INNER JOIN dbo.t_CaseBack c1 ON
				r.id=c1.rf_idRecordCaseBack					                  
	WHERE c.DateEnd>='20190101' 
	)
	SELECT DISTINCT GUID_CASE ,TypePay into #CaseTypePay FROM cte WHERE idRow=1
	---------------------------------------------------------------------------------

	insert #tError
	select distinct c.id,531
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
							inner join t_Case c on
				r.id=c.rf_idRecordCase								
	where a.rf_idFiles=@idFile and r.IsNew>1
	----------------------для записей с признаком 0-------------------------
	insert #tError
	select distinct c.id,531
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
							INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase  
							inner join t_Case c on
				r.id=c.rf_idRecordCase																
							INNER JOIN #CaseTypePay vp ON
				cc.GUID_ZSL=vp.GUID_Case
				AND vp.TypePay=1                      
	where a.rf_idFiles=@idFile and r.IsNew=0 


	--insert #tError
	--select distinct c.id,531
	--from t_RegistersCase a inner join t_RecordCase r on
	--			a.id=r.rf_idRegistersCase
	--						INNER JOIN dbo.t_CompletedCase cc ON
	--			r.id=cc.rf_idRecordCase  
	--						inner join t_Case c on
	--			r.id=c.rf_idRecordCase																
	--where a.rf_idFiles=@idFile and r.IsNew=0 AND EXISTS(SELECT * FROM dbo.t_RecordCaseBack WHERE rf_idCase=c.id)

	----------------------для записей с признаком 1-------------------------
	insert #tError
	select distinct c.id,531
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
							INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase  
							inner join t_Case c on
				r.id=c.rf_idRecordCase																
	where a.rf_idFiles=@idFile and r.IsNew=1 AND NOT EXISTS(SELECT * FROM dbo.#CaseTypePay WHERE GUID_Case=cc.GUID_ZSL AND TypePay=1)

DROP TABLE #CaseTypePay
DROP TABLE #t
go