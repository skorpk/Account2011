use RegisterCases
go
select pb.rf_idRecordCaseBack,fb.DateCreate,fb.UserName
from  t_FileBack fb inner join t_RegisterCaseBack ab on
				    fb.id=ab.rf_idFilesBack
									inner join	t_RecordCaseBack rcb on
				    ab.id=rcb.rf_idRegisterCaseBack
								inner join (		
											select rf_idRecordCaseBack 
											from t_PatientBack p 
											group by rf_idRecordCaseBack having COUNT(*)>1
										   ) t on
					rcb.id=t.rf_idRecordCaseBack
									inner join t_PatientBack pb on
					rcb.id=pb.rf_idRecordCaseBack
where fb.DateCreate>'20120701'
order by DateCreate desc
									