USE RegisterCases
GO
/*
SELECT f.id,fb.id as rf_idBackFile,CountSluch
FROM dbo.t_File f JOIN dbo.t_FileBack fb ON
		fb.rf_idFiles = f.id
			join vw_sprT001 l on
		f.codeM=l.CodeM
WHERE DateRegistration>'20210601' and l.pfa<>1 and isnull(l.pfv,0)<>1
ORDER BY CountSluch DESC

--МО финансируемое по подушевому тарифу
SELECT f.id,fb.id as rf_idBackFile,CountSluch
FROM dbo.t_File f JOIN dbo.t_FileBack fb ON
		fb.rf_idFiles = f.id
			join vw_sprT001 l on
		f.codeM=l.CodeM
WHERE DateRegistration>'20210601' and (l.pfa=1 or isnull(l.pfv,0)=1)
ORDER BY CountSluch DESC
*/
/*
Проверяю на PFA/PFV
*/
DECLARE @idFile INT=208045

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)

DECLARE @CaseDefined AS TVP_CasePatient
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

--Проверка N: проверка плана-заказа. Всегда должна быть последней
--внес корректировки с тем что некоторые МО просят сдать данные за предыдущий отчетный год
INSERT @CaseDefined(rf_idCase,ID_Patient)
SELECT d.rf_idCase,rf_idRegisterPatient
FROM dbo.t_RefCasePatientDefine d JOIN dbo.t_RecordCaseBack r ON
					d.rf_idCase=r.rf_idCase
							JOIN dbo.t_CaseBack cb ON
					r.id=cb.rf_idRecordCaseBack	
WHERE rf_idFiles=@idFile AND IsUnloadIntoSP_TK=1 AND cb.TypePay=1

create table #tmpPlan
(
	CodeLPU varchar(6),
	UnitCode int,
	Vm DECIMAL(11,2),
	Vdm DECIMAL(11,2),
	Spred decimal(11,2),
	[month] tinyint
)
exec usp_PlanOrders @CodeLPU,@month,@year

if NOT EXISTS(select * from t_LPUPlanOrdersDisabled where CodeM=@codeLPU and ReportYear=@year and BeforeDate>=GETDATE())
begin
	CREATE table #t1(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest decimal(11,2))
		------------------------------------------------------

	insert #t1(rf_idCase,Quantity,unitCode,idRecordCase)
	select id,Quantity,unitCode,idRecordCase 
	from vw_dataPlanOrder c inner join @CaseDefined cd on
				c.id=cd.rf_idCase
	where rf_idFiles=@idFile AND NOT EXISTS(SELECT 1 FROM dbo.t_ErrorProcessControl e WHERE e.rf_idCase=cd.rf_idCase)
	order by idRecordCase asc
		
		declare cPlan cursor for
			select f.UnitCode,f.Vdm,f.Vm,f.Spred,f.Vdm+f.Vm-f.Spred from #tmpPlan f
			declare @unit int,@vdm decimal(11,2), @vm decimal(11,2), @spred decimal(11,2),@totalPlan decimal(11,2)
		open cPlan
		fetch next from cPlan into @unit,@vdm,@vm,@spred,@totalPlan
		while @@FETCH_STATUS = 0
		begin					
			update #t1 set @totalPlan=TotalRest=@totalPlan-Quantity where unitCode=@unit
			
			fetch next from cPlan into @unit,@vdm,@vm,@spred,@totalPlan
		end
		close cPlan
		deallocate cPlan
				
END
--вставка в таблицу ошибок
--insert @tError	select distinct rf_idCase,62 from #t1 where TotalRest<0
---------------------------контроль ФО---------------------------------------------------------------
---Добавляем колонки для последующего использования в рассчете ФО
ALTER TABLE #t1 ADD CodeFV SMALLINT
ALTER TABLE #t1 ADD DateEnd DATE
ALTER TABLE #t1 ADD DateBegin DATE
ALTER TABLE #t1 ADD IsGood TINYINT NOT NULL DEFAULT(1)-- 1 значит по такому случаю проводим контроль ФО, 2- по такому случаю не проводим т.к. он уходит с ошибкой 62
ALTER TABLE #t1 ADD TotalPriceFV DECIMAL(15,2)
ALTER TABLE #t1 ADD rf_idRecordCase INT
ALTER TABLE #t1 ADD AmountPayment DECIMAL(15,2)
ALTER TABLE #t1 ADD Profil SMALLINT

	EXEC dbo.usp_TestFV @idFile, @month,@year,@codeLPU	

GO
DROP TABLE #tmpPlan
go
DROP TABLE #t1
go
