use RegisterCases
go
select f.id,f.FileNameHR,f.CountSluch,f.DateRegistration,fb.id as idFileBack,fb.FileNameHRBack,fb.UserName,fb.DateCreate
from t_File f left join t_FileBack fb on
		f.id=fb.rf_idFiles
where f.CodeM='101001'
order by fb.DateCreate

--exec usp_RegisterCaseDelete 1726

declare @codeLPU varchar(6)='101001'
select *,(p.Vdm+p.Vm)-p.Spred as Diff
from dbo.fn_PlanOrders(@codeLPU,12,2011) p inner join vw_sprUnit u on
		p.UnitCode=u.unitCode
