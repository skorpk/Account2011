USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int,
		@CaseDefined1 TVP_CasePatient

select @idFile=rf_idFiles from vw_getFileBack where CodeM='611001' and NumberRegister=77 and PropertyNumberRegister=2 and ReportYear=2012

select distinct e.*,c.idRecordCase
from t_ErrorProcessControl e inner join t_Case c on
			e.rf_idCase=c.id
			and rf_idFile=@idFile
			and e.ErrorNumber=62
			
			
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
			

	insert @CaseDefined1(rf_idCase,ID_Patient)
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from (
				select rf.rf_idCase,rf.rf_idRegisterPatient
				from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
							rf.id=c.rf_idRefCaseIteration
							and c.OKATO ='18000'		
										inner join t_CasePatientDefineIteration i on
							rf.id=i.rf_idRefCaseIteration
							and i.rf_idIteration in (2,4)			  
				where rf.rf_idFiles=@idFile 
				union all
				select rf.rf_idCase,rf.rf_idRegisterPatient
				from t_RefCasePatientDefine rf inner join t_CasePatientDefineIteration i on
							rf.id=i.rf_idRefCaseIteration
							and i.rf_idIteration in (3)			  
				where rf.rf_idFiles=@idFile 
				group by rf.rf_idCase,rf.rf_idRegisterPatient
			 ) rf
select @@ROWCOUNT			 

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
	
declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest decimal(11,2))
		------------------------------------------------------

insert @t1(rf_idCase,Quantity,unitCode,idRecordCase)		 			
select id,Quantity,unitCode,idRecordCase 
from vw_dataPlanOrder c inner join @CaseDefined1 cd on
			c.id=cd.rf_idCase
where rf_idFiles=@idFile	order by idRecordCase asc


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

		select distinct rf_idCase,62 from @t1 where TotalRest<0
go