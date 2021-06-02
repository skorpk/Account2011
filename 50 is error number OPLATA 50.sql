USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
		@codeLPU CHAR(6)='184512'

select @idFile=id from vw_getIdFileNumber where CodeM='184512' and NumberRegister=573 and ReportYear=2013

select * from vw_getIdFileNumber where id=@idFile
if NOT EXISTS (select * from sprLPUEnableCalendar where CodeM=@codeLPU and typePR_NOV=0)
begin 
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
declare @dateAdd tinyint,
		@dateNow date=getdate()
--вычисляем кол-во дней на исправление неправильных записей
select @dateAdd=spr.ControlDateDay
from t_RegistersCase a inner join sprCalendarPR_NOV1 spr on
		a.ReportYear=spr.ReportYear
		and a.rf_idFiles=@idFile
	
								
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
				
--	select c1.id,50
--	from(
--		select c.id,max(c1.id) as id2,cast(DATEADD(DAY,@dateAdd,MAX(fb.DateCreate)) as date) as DateRegSPTK
--		from t_RegistersCase a inner join t_RecordCase r on
--					a.id=r.rf_idRegistersCase
--					and a.rf_idFiles=@idFile
--					and r.IsNew=1
--								inner join t_Case c on
--					r.id=c.rf_idRecordCase
--								inner join t_Case c1 on
--				c.GUID_Case=c1.GUID_Case
--				and c.id<>c1.id
--								inner join t_RecordCaseBack rb on
--				c1.id=rb.rf_idCase
--								inner join t_CaseBack cb on
--				rb.id=cb.rf_idRecordCaseBack
--				and cb.TypePay=2
--								inner join t_RegisterCaseBack ab on
--				rb.rf_idRegisterCaseBack=ab.id
--								inner join t_FileBack fb on
--				ab.rf_idFilesBack=fb.id								
--		group by c.id		
--		 ) c1 left join (select top 1 with ties rf_idCase 
--						 from t_ErrorProcessControl e
--						 where ErrorNumber=57
--						 ORDER BY ROW_NUMBER() OVER(PARTITION BY e.rf_idCase ORDER BY e.DateRegistration desc)			
--										  ) e on
--				c1.id2=e.rf_idCase		
--where e.rf_idCase is null and @dateNow>c1.DateRegSPTK				

SELECT c1.id,50
FROM(
		SELECT TOP 1 WITH ties c.id,c1.id AS id2,cb.TypePay,fb.DateCreate
		from t_RegistersCase a inner join t_RecordCase r on
							a.id=r.rf_idRegistersCase
							and a.rf_idFiles=@idFile
							and r.IsNew=1
										inner join t_Case c on
							r.id=c.rf_idRecordCase
										inner join t_Case c1 on
						c.GUID_Case=c1.GUID_Case
						and c.id<>c1.id
										inner join t_RecordCaseBack rb on
						c1.id=rb.rf_idCase
										inner join t_CaseBack cb on
						rb.id=cb.rf_idRecordCaseBack
						--and cb.TypePay=2
										inner join t_RegisterCaseBack ab on
						rb.rf_idRegisterCaseBack=ab.id
										inner join t_FileBack fb on
						ab.rf_idFilesBack=fb.id								
		ORDER BY ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY fb.DateCreate desc)	
) c1 left join (select top 1 with ties rf_idCase 
						 from t_ErrorProcessControl e
						 where ErrorNumber=57
						 ORDER BY ROW_NUMBER() OVER(PARTITION BY e.rf_idCase ORDER BY e.DateRegistration desc)			
										  ) e on
				c1.id2=e.rf_idCase				
where e.rf_idCase is NULL AND @dateNow>cast(DATEADD(DAY,@dateAdd,c1.DateCreate) as date) AND c1.TypePay=2


/*
SELECT * FROM dbo.t_Case WHERE id=21716423
SELECT * 
FROM dbo.t_Case c inner join t_RecordCaseBack rb on
				c.id=rb.rf_idCase
								inner join t_CaseBack cb on
				rb.id=cb.rf_idRecordCaseBack
WHERE GUID_Case='BAFFD374-A95A-431F-A814-34CF3B02EEBA'


select c.id,max(c1.id) as id2,cast(DATEADD(DAY,@dateAdd,MAX(fb.DateCreate)) as date) as DateRegSPTK
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
					and r.IsNew=1
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join t_Case c1 on
				c.GUID_Case=c1.GUID_Case
				and c.id<>c1.id
								inner join t_RecordCaseBack rb on
				c1.id=rb.rf_idCase
								inner join t_CaseBack cb on
				rb.id=cb.rf_idRecordCaseBack
				and cb.TypePay=2
								inner join t_RegisterCaseBack ab on
				rb.rf_idRegisterCaseBack=ab.id
								inner join t_FileBack fb on
				ab.rf_idFilesBack=fb.id				
WHERE c.GUID_Case='BAFFD374-A95A-431F-A814-34CF3B02EEBA'				
group by c.id	
*/