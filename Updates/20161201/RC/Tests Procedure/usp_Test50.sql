USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test50]    Script Date: 26.01.2017 11:49:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test50]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=0)
begin 
--Это если запись подается впервые
	insert #tError
	select c.id,50
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
end 
if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=1)
begin
--Если запись пришла как исправленная
--если в прошлый раз она подовалась не в срок, то отдаем с ошибкой 50
--Включил проверку 09.12.2015 в связи повышением тарифов на ноябрь
	insert #tError
	select c1.id,50
	from(
		select c.id,max(c1.id) as MaxID
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
					and r.IsNew=1
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join t_Case c1 on
				c.GUID_Case=c1.GUID_Case
				and c.id<>c1.id
		group by c.id
		 ) c1 inner join t_ErrorProcessControl e on
				c1.MaxID=e.rf_idCase
				and e.ErrorNumber=50
	
				
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
INSERT #tError
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
		ORDER BY ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY fb.DateCreate desc)	
) c1
where NOT EXISTS(select * from t_ErrorProcessControl e where ErrorNumber IN (57,513) AND e.rf_idCase=c1.id2) 
		AND @dateNow>cast(DATEADD(DAY,@dateAdd,c1.DateCreate) as date) --AND c1.TypePay=2

end
