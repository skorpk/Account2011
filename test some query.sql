USE RegisterCases
GO
DECLARE @idFile INT
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2017 AND CodeM='176001' AND NumberRegister=100017

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile

SELECT DISTINCT ErrorNumber FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile

declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=0)
begin 
--Это если запись подается впервые

	select c.id,50,r.IsNew,c.GUID_Case
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
				and r.IsNew=0
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join sprCalendarPR_NOV0 cal on
				a.ReportMonth=cal.ReportMonth
				and a.ReportYear=cal.ReportYear
	where GETDATE()>=(case when c.DateEnd>=isnull(cal.ReportDate1,'20221231') and c.DateEnd<=isnull(cal.ReportDate2,'20221231') 
								then isnull(cal.ControlDate2,'20221231') else isnull(cal.ControlDate1,'20221231') end)
			AND NOT EXISTS(SELECT * FROM dbo.vw_CaseTypePay WHERE GUID_Case=c.GUID_Case)

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
		where EXISTS(SELECT * FROM dbo.vw_CaseTypePay WHERE GUID_Case=c.GUID_Case)								
		ORDER BY ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY fb.DateCreate desc)	

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
		where EXISTS(SELECT * FROM dbo.vw_CaseTypePay WHERE GUID_Case=c.GUID_Case)								
		ORDER BY ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY fb.DateCreate desc)	
) c1
where NOT EXISTS(select * from t_ErrorProcessControl e where ErrorNumber IN (57,513) AND e.rf_idCase=c1.id2) 
		AND @dateNow>cast(DATEADD(DAY,@dateAdd,c1.DateCreate) as date) --AND c1.TypePay=2

end