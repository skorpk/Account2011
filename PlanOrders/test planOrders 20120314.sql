use RegisterCases
go
declare @idFile int=4634,
		@codeLPU char(5)='106002',
		@month tinyint=3,
		@year smallint=2012

declare @CaseDefined TVP_CasePatient
declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest int)

select id from t_Case where GUID_Case='DDC77DA1-A3A6-2373-E2BE-2967121A47BA'

insert @CaseDefined(rf_idCase,ID_Patient)
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

--select * from @CaseDefined where rf_idCase=3595404

-exec usp_RunProcessControl @CaseDefined, @idFile

------------------------------------------------------
/*
insert @t1(rf_idCase,Quantity,unitCode,idRecordCase)
select rf_idCase,cast(SUM(Quantity) as decimal(11,2)),unitCode,idRecordCase
from (
		select top 1000000 m.rf_idCase,c1.idRecordCase
							,cast((case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as decimal(11,2)) as Quantity
							,t1.unitCode
		from (
			  select c1.rf_idCase,c.idRecordCase 
			  from @CaseDefined  c1 inner join t_Case c on
							c1.rf_idCase=c.id									
		     ) c1
					inner join vw_MeduslugiMes m on
			c1.rf_idCase=m.rf_idCase							
					inner join dbo.vw_sprMU t1 on
					m.MUCode=t1.MU	
					and t1.unitCode is not null
		--order by c1.idRecordCase	
		) t
group by rf_idCase,unitCode,idRecordCase
order by idRecordCase asc
--использую курсор т.к. на данный момент это проще всего, но его потом следует заменить
declare cPlan cursor for
	select f.UnitCode,f.Vdm,f.Vm,f.Spred
	from dbo.fn_PlanOrders(@codeLPU,@month,@year) f
	declare @unit int,@vdm decimal(11,2), @vm decimal(11,2), @spred decimal(11,2)
open cPlan
fetch next from cPlan into @unit,@vdm,@vm,@spred
while @@FETCH_STATUS = 0
begin		
	--select @unit,@vdm,@vm
	--update @t1 set @vm= Totalrest=@vm+@vdm-@spred-ISNULL(Quantity, 0) where unitCode=@unit
	declare cCase cursor for
		select t.rf_idCase,t.Quantity from @t1 t where unitCode=@unit
		declare @idCase bigint, @Quantity decimal(11,2)
	open cCase
	fetch next from cCase into @idCase,@Quantity
	while @@FETCH_STATUS=0
	begin			
		--select @idCase,@vm+@vdm-@Quantity-@spred
		update @t1 set TotalRest=@vm+@vdm-@Quantity-@spred where rf_idCase=@idCase
		set @spred=@spred+@Quantity
		
		fetch next from cCase into @idCase,@Quantity
	end
	close cCase
	deallocate cCase
	fetch next from cPlan into @unit,@vdm,@vm,@spred
end
close cPlan
deallocate cPlan

select distinct rf_idCase from @t1 --where TotalRest<0

select distinct rf_idCase,62 from @t1 where TotalRest<0
*/