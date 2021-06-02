USE RegisterCases 
go

declare @CaseDefined TVP_CasePatient,		
		@idFile int
	
select top 1 @idFile=id from vw_getIdFileNumber where DateRegistration>'20121225' --order by CountSluch desc

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile


------------------------------------------------------------------
--Проверка N: проверка плана-заказа. Всегда должна быть последней
--внес корректировки с тем что некоторые МО просят сдать данные за предыдущий отчетный год
if NOT EXISTS(select * from t_LPUPlanOrdersDisabled where CodeM=@codeLPU and ReportYear=@year and BeforeDate>=GETDATE())
begin
	declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest decimal(11,2))
		------------------------------------------------------

	insert @t1(rf_idCase,Quantity,unitCode,idRecordCase)
	select id,Quantity,unitCode,idRecordCase from vw_dataPlanOrder where rf_idFiles=@idFile	order by idRecordCase asc
		
		--использую курсор т.к. на данный момент это проще всего, но его потом следует заменить
		declare cPlan cursor for
			select f.UnitCode,f.Vdm,f.Vm,f.Spred,f.Vdm+f.Vm-f.Spred from dbo.fn_PlanOrders(@codeLPU,@month,@year) f
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

		--SET STATISTICS IO OFF
		SET STATISTICS TIME OFF

		select distinct rf_idCase,Quantity,TotalRest from @t1 --where TotalRest<0
end
go
