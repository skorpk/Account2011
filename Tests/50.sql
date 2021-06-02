USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='801933' and NumberRegister=41 and ReportYear=2020

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

SELECT cc.GUID_ZSL
FROM dbo.t_ErrorProcessControl e INNER JOIN dbo.t_Case c ON
			e.rf_idCase=c.id
					INNER JOIN dbo.t_CompletedCase cc ON
            c.rf_idRecordCase=cc.rf_idRecordCase
WHERE rf_idFile=@idFile AND ErrorNumber=50

SELECT DISTINCT cc.GUID_ZSL,c.id
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase								
						INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCase                      
where cc.GUID_ZSL='80D71EE8-32F9-981B-8D12-FDFA5134B384'
---------------------------------------------------------------------------------
	SELECT DISTINCT cc.GUID_ZSL,c.id
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


if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=0)
begin 
--Это если запись подается впервые
	select c.id,50,a.NumberRegister
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				and r.IsNew=0
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join sprCalendarPR_NOV0 cal on
				a.ReportMonth=cal.ReportMonth
				and a.ReportYear=cal.ReportYear
							INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase
	where GETDATE()>=(case when c.DateEnd>=isnull(cal.ReportDate1,'20221231') and c.DateEnd<=isnull(cal.ReportDate2,'20221231') 
								then isnull(cal.ControlDate2,'20221231') else isnull(cal.ControlDate1,'20221231') end)
			AND NOT EXISTS(SELECT * FROM dbo.#CaseTypePay WHERE GUID_Case=cc.GUID_ZSL)

end 
if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=1)
begin
--если ошибка была 57 то на данный случай не накладываем услоивия контроля дат
--все остальные повторно выставленные случаи проверяем повторно на график выставления случаев
declare @dateAdd tinyint,
		@dateNow date=getdate()
--вычисляем кол-во дней на исправление неправильных записей
select @dateAdd=spr.ControlDateDay
from t_RegistersCase a inner join sprCalendarPR_NOV1 spr on
		a.ReportYear=spr.ReportYear
		and a.rf_idFiles=@idFile

--изменил 28.04.2014
SELECT c1.id,50
FROM(
		SELECT TOP 1 WITH ties c.id,c1.id AS id2,cb.TypePay,fb.DateCreate
		from t_RegistersCase a inner join t_RecordCase r on
							a.id=r.rf_idRegistersCase
							and a.rf_idFiles=@idFile
							and r.IsNew=0
										inner join t_Case c on
							r.id=c.rf_idRecordCase
										inner join t_Case c1 on
						c.GUID_Case=c1.GUID_Case
						and c.id<>c1.id
										inner join t_RecordCaseBack rb on
						c1.id=rb.rf_idCase
										inner join t_CaseBack cb on
						rb.id=cb.rf_idRecordCaseBack   						
										inner join t_RegisterCaseBack ab on
						rb.rf_idRegisterCaseBack=ab.id
										inner join t_FileBack fb on
						ab.rf_idFilesBack=fb.id	
							INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase
		where EXISTS(SELECT * FROM dbo.#CaseTypePay WHERE GUID_Case=cc.GUID_ZSL)							
		ORDER BY ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY fb.DateCreate desc)	
) c1
where NOT EXISTS(select * from t_ErrorProcessControl e where ErrorNumber IN (57,513) AND e.rf_idCase=c1.id2) 
		AND @dateNow>cast(DATEADD(DAY,@dateAdd,c1.DateCreate) as date) 

END
go
DROP TABLE #CaseTypePay
go
DROP TABLE #t