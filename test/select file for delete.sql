select f.id,f.FileNameHR,f.DateRegistration,r.NumberRegister,r.DateRegister
from t_File f inner join t_RegistersCase r on
			f.id=r.rf_idFiles
where f.CodeM='105001' and r.NumberRegister=500001

exec usp_RegisterCaseDelete 1481