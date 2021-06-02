use RegisterCases
go
select f.*,ab.NumberRegister,ab.PropertyNumberRegister,f1.FileNameHR,f1.CountSluch,f1.DateRegistration
from t_FileBack f inner join t_RegisterCaseBack ab on
		f.id=ab.rf_idFilesBack
				inner join t_File f1 on
		f.rf_idFiles=f1.id
where f.CodeM='165531'
order by f.DateCreate

go
declare @t table(id int,idBack int)
insert @t values(1253,3143),(1416,3532),(1536,3538),(1643,3555),(2210,3603)

delete from t_FileBack where id in (select idBack from @t)

update t_RefCasePatientDefine 
set IsUnloadIntoSP_TK=null
from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
		r.id=i.rf_idRefCaseIteration
							  inner join @t t on
		rf_idFiles=t.id
where i.rf_idIteration<>1

--declare @idFile int=1253
--declare @idFileBack int=3143
--exec usp_FillBackTablesAfterAllIteration @idFile
go
declare @codeLPU varchar(6)='165531'
select *,(p.Vdm+p.Vm)-p.Spred
from dbo.fn_PlanOrders(@codeLPU,12,2011) p inner join vw_sprUnit u on
		p.UnitCode=u.unitCode
go
select f.*,ab.NumberRegister,ab.PropertyNumberRegister,f1.FileNameHR,f1.CountSluch,f1.DateRegistration
from t_FileBack f inner join t_RegisterCaseBack ab on
		f.id=ab.rf_idFilesBack
				inner join t_File f1 on
		f.rf_idFiles=f1.id
where f.CodeM='165531'
order by f.DateCreate

