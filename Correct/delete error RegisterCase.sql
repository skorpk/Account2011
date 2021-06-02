use RegisterCases
go
declare @codeLPU char(56)='184512'

select * 
from (
select f.id,f.FileNameHR,CodeM,f.DateRegistration,r.NumberRegister,r.ReportMonth,f.CountSluch
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
where CodeM=@codeLPU
		) t left join (
						select f.id,f.FileNameHR,CodeM,r.NumberRegister,r.ReportMonth
						from AccountOMS.dbo.t_File f inner join AccountOMS.dbo.t_RegistersAccounts r on
								f.id=r.rf_idFiles
						where CodeM=@codeLPU
						) t2 on
		t.CodeM=t2.CodeM
		and t.NumberRegister=t2.NumberRegister
		and t.ReportMonth=t2.ReportMonth
where t2.id is null
/*
exec usp_RegisterCaseDelete 1035
exec usp_RegisterCaseDelete 1036
*/
--exec usp_RegisterCaseDelete 793

select CodeLPU,Vm,Vdm,Spred,unitName,u.unitCode
from dbo.fn_PlanOrders(@codeLPU,12,2011) p inner join vw_sprUnit u on
   	  p.UnitCode=u.unitCode

