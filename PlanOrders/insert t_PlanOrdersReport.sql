use RegisterCases
go
select p.*,u.unitName
from dbo.fn_PlanOrders('104003',1,2012) p inner join vw_sprUnit u on
			p.UnitCode=u.unitCode
			
declare @idFile int=2355
		,@idFileBack int=4145
		,@month tinyint=1
		,@year smallint=2012
		,@codeLPU char(6)='104003'
		
insert t_PlanOrdersReport(rf_idFile,rf_idFileBack,CodeLPU,UnitCode,Vm,Vdm,Spred,MonthReport,YearReport)
select @idFile,@idFileBack,f.CodeLPU,f.UnitCode,f.Vm,f.Vdm,f.Spred,@month,@year
from dbo.fn_PlanOrders(@codeLPU,@month,@year) f


select *
from vw_getIdFileNumber
where CodeM='104003'

select * from t_FileBack where rf_idFiles=2355