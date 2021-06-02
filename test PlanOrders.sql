USE RegisterCases
GO
DECLARE @idFile INT
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2013 AND CodeM='145516' AND NumberRegister=503

DECLARE @CaseDefined TVP_CasePatient 
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

INSERT @CaseDefined
select c.id as rf_idCase, p.id as ID_Patient
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join vw_RegisterPatient p on
				r.id=p.rf_idRecordCase
				and p.rf_idFiles=@idFile
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							LEFT JOIN (SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile AND ErrorNumber<>62) e ON
				c.id=e.rf_idCase
WHERE e.rf_idCase IS null
				
				
				
create table #tmpPlan
(
	CodeLPU varchar(6),
	UnitCode int,
	Vm int,
	Vdm int,
	Spred decimal(11,2),
	[month] tinyint
)
exec usp_PlanOrders @CodeLPU,@month,@year

if NOT EXISTS(select * from t_LPUPlanOrdersDisabled where CodeM=@codeLPU and ReportYear=@year and BeforeDate>=GETDATE())
begin
	declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest decimal(11,2))
		------------------------------------------------------

	insert @t1(rf_idCase,Quantity,unitCode,idRecordCase)
	select id,Quantity,unitCode,idRecordCase 
	from vw_dataPlanOrder c inner join @CaseDefined cd on
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

		select distinct * from @t1 where TotalRest<0
END
GO
DROP TABLE #tmpPlan