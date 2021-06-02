USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='141023' and NumberRegister=98 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile

DECLARE @CaseDefined TVP_CasePatient 

INSERT @CaseDefined 
SELECT r.rf_idCase,rf_idRegisterPatient
FROM dbo.t_RefCasePatientDefine r INNER JOIN dbo.t_ErrorProcessControl e ON
		r.rf_idCase=e.rf_idCase
WHERE r.rf_idFiles=@idFile AND e.ErrorNumber=62


SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile AND ErrorNumber=62
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

SELECT * FROM #tmpPlan WHERE Vdm+Vm>0

if NOT EXISTS(select * from t_LPUPlanOrdersDisabled where CodeM=@codeLPU and ReportYear=@year and BeforeDate>=GETDATE())
begin
	declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest decimal(11,2))
		------------------------------------------------------

	insert @t1(rf_idCase,Quantity,unitCode,idRecordCase)
	select id,Quantity,unitCode,idRecordCase 
	from dbo.vw_dataPlanOrder_Test c inner join @CaseDefined cd on
				c.id=cd.rf_idCase
	where rf_idFiles=@idFile	
	order by idRecordCase asc
		
		--использую курсор т.к. на данный момент это проще всего, но его потом следует заменить
		declare cPlan cursor for
			select f.UnitCode,f.Vdm,f.Vm,f.Spred,f.Vdm+f.Vm-f.Spred from #tmpPlan f
			declare @unit int,@vdm decimal(11,2), @vm decimal(11,2), @spred decimal(11,2),@totalPlan decimal(11,2)
		open cPlan
		fetch next from cPlan into @unit,@vdm,@vm,@spred,@totalPlan
		while @@FETCH_STATUS = 0
		begin					
			update @t1 set @totalPlan=TotalRest=@totalPlan-Quantity where unitCode=@unit
			fetch next from cPlan into @unit,@vdm,@vm,@spred,@totalPlan
		end
		close cPlan
		deallocate cPlan
		
		SELECT * FROM @t1
		select distinct *,62 from @t1 where TotalRest<0

		SELECT * FROM oms_nsi.dbo.tPlanUnit WHERE unitCode=259
END
GO
DROP TABLE #tmpPlan