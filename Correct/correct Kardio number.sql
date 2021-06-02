use RegisterCases
go
--select * from oms_NSI.dbo.vw_sprT001 where CodeM='104401'

select * from t_RegistersCase where rf_idMO='340023' and id in(44,167)

select f.rf_idFiles,r.* 
from t_FileBack f inner join t_RegisterCaseBack r on
			f.id=r.rf_idFilesBack 
where ref_idF003='340023' and f.rf_idFiles in(44,167)

update t_RegistersCase set NumberRegister=2 where id=44
update t_RegistersCase set NumberRegister=4 where id=167
update t_RegisterCaseBack set NumberRegister=2 where id in(20,323)
update t_RegisterCaseBack set NumberRegister=4 where id=130

select * from t_RegistersCase where rf_idMO='340023' and id in(44,167)

select f.rf_idFiles,r.* 
from t_FileBack f inner join t_RegisterCaseBack r on
			f.id=r.rf_idFilesBack 
where ref_idF003='340023' and f.rf_idFiles in(44,167)