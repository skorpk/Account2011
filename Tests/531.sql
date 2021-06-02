USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='101001' and NumberRegister=26 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile AND ErrorNumber=531
---------------------------------------------------------------------------------
SELECT DISTINCT cc.GUID_ZSL
INTO #t
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase								
						INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCase                      
where a.rf_idFiles=@idFile AND c.id IN(124147961,124147955,124147934,124147930)

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
select distinct c.id,531
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase								
where a.rf_idFiles=@idFile and r.IsNew>1
----------------------для записей с признаком 0-------------------------
select distinct c.id,531,cc.GUID_ZSL,cc.idRecordCase,c.NumberHistoryCase
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


--в каком реестре был представлен ранее случай
SELECT f.DateRegistration,cc.GUID_ZSL, c.rf_idMO,a.NumberRegister,a.ReportYear,c1.TypePay
FROM dbo.t_File f INNER join t_RegistersCase a ON
			f.id=a.rf_idFiles
				 inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase								
						INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCase  
						INNER JOIN dbo.t_RecordCaseBack rr ON
			c.id=rr.rf_idCase
			  INNER JOIN dbo.t_CaseBack c1 ON
			rr.id=c1.rf_idRecordCaseBack	                    
where cc.GUID_ZSL IN('98F112A9-0BF9-0C24-E053-CD9115AC4C69','98F11478-A6B9-0C20-E053-CD9115AC129D','98F112A9-01AD-0C24-E053-CD9115AC4C69','9D2E811E-7A70-5249-E053-CD9115AC9C2E')
ORDER BY cc.GUID_ZSL,c1.TypePay

----------------------для записей с признаком 1-------------------------
select distinct c.id,531,c.GUID_Case,p.*,cc.GUID_ZSL
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.vw_RegisterPatient p ON
			r.id=p.rf_idRecordCase
			AND p.rf_idFiles=@idFile															
where a.rf_idFiles=@idFile and r.IsNew=1 AND NOT EXISTS(SELECT * FROM dbo.#CaseTypePay WHERE GUID_Case=cc.GUID_ZSL AND TypePay=1)

GO
DROP TABLE #t
GO
DROP TABLE #CaseTypePay