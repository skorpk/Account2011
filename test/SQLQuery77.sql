select *
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
where CodeM='102508'

select * from t_FileBack where rf_idFiles=945

--exec usp_RegisterCaseDelete 949
--exec usp_RegisterCaseDelete 934

--exec usp_RegisterCaseDelete 918
--exec usp_RegisterCaseDelete 919
--exec usp_RegisterCaseDelete 920
--exec usp_RegisterCaseDelete 921
--exec usp_RegisterCaseDelete 922

select *
from dbo.fn_PlanOrders('102508',5,2011)

--declare @CaseDefined as TVP_CasePatient
--declare @tError as table(rf_idCase bigint,ErrorNumber smallint)

 
--insert @CaseDefined
--select c.id,1
--from t_RegistersCase r inner join t_RecordCase rc on
--	r.id=rc.rf_idRegistersCase
--					inner join t_Case c on
--	rc.id=c.rf_idRecordCase
--where r.rf_idFiles=944
--group by c.id

--declare @t1 as table(rf_idCase bigint,Quantity bigint,unitCode int,TotalRest int)

--insert @t1(rf_idCase,Quantity,unitCode)
--select rf_idCase,SUM(Quantity),unitCode
--from (
--		select top 1000000 m.rf_idCase,m.id,m.Quantity,t1.unitCode
--		from (
--			  select c1.rf_idCase 
--			  from @CaseDefined  c1 left join @tError e on
--							c1.rf_idCase=e.rf_idCase
--			  where e.rf_idCase is null
--		     ) c1
--					inner join t_Meduslugi m on
--			c1.rf_idCase=m.rf_idCase							
--					inner join dbo.vw_sprMU t1 on
--					m.MUCode=t1.MU	
--		order by m.id	
--		) t
--group by rf_idCase,unitCode

--declare cPlan cursor for
--	select f.UnitCode,f.Vdm,f.Vm,f.Spred
--	from dbo.fn_PlanOrders('102508',12,2011) f
--	declare @unit int,@vdm int, @vm int, @spred int
--open cPlan
--fetch next from cPlan into @unit,@vdm,@vm,@spred
--while @@FETCH_STATUS = 0
--begin		
--	--select @unit,@vdm,@vm
--	--update @t1 set @vm= Totalrest=@vm+@vdm-@spred-ISNULL(Quantity, 0) where unitCode=@unit
--	declare cCase cursor for
--		select t.rf_idCase,t.Quantity from @t1 t where unitCode=@unit
--		declare @idCase bigint, @Quantity int
--	open cCase
--	fetch next from cCase into @idCase,@Quantity
--	while @@FETCH_STATUS=0
--	begin	
		
--		--select @idCase,@vm+@vdm-@Quantity-@spred
--		update @t1 set TotalRest=@vm+@vdm-@Quantity-@spred where rf_idCase=@idCase
--		set @spred=@spred+@Quantity
		
--		fetch next from cCase into @idCase,@Quantity
--	end
--	close cCase
--	deallocate cCase
--	fetch next from cPlan into @unit,@vdm,@vm,@spred
--end
--close cPlan
--deallocate cPlan

--insert @tError
--select rf_idCase,62 from @t1 where TotalRest<0

--select ErrorNumber,rf_idCase from @tError