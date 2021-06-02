use RegisterCases
go
select COUNT(distinct c.id),SUM(c.AmountPayment),c.rf_idV006,v006.Name
from t_FileBack f inner join t_RegisterCaseBack r on
			f.id=r.rf_idFilesBack
			and CodeM='101001'
				  inner join t_RecordCaseBack r1 on
		r.id=r1.rf_idRegisterCaseBack					
					inner join t_Case c on
		r1.rf_idCase=c.id
					inner join t_ErrorProcessControl e on
		c.id=e.rf_idCase
		and e.ErrorNumber=57
					inner join oms_nsi.dbo.sprV006 v006 on
		c.rf_idV006=v006.Id
group by c.rf_idV006,v006.Name
order by 3

select rp.Fam,rp.Im,rp.Ot,rp.BirthDay,r1.SeriaPolis,r1.NumberPolis,d.SNILS,d.SeriaDocument,d.NumberDocument,c.id
from t_File f inner join t_RegistersCase r on
			f.id=r.rf_idFiles
			and CodeM='101001'
				  inner join t_RecordCase r1 on
		f.id=r1.rf_idRegistersCase
				  inner join t_Case c on
		r1.id=c.rf_idRecordCase
					inner join t_ErrorProcessControl e on
		c.id=e.rf_idCase
		and e.ErrorNumber=57	
					inner join t_RegisterPatient rp on
		r1.id=rp.rf_idRecordCase		
					inner join t_RegisterPatientDocument d on
		rp.id=d.rf_idRegisterPatient		
group by rp.Fam,rp.Im,rp.Ot,rp.BirthDay,r1.SeriaPolis,r1.NumberPolis,d.SNILS,d.SeriaDocument,d.NumberDocument,c.id
--select rp.*
--from t_File f inner join t_RefCase
--			inner join t_RegisterPatient rp on
--		f.id=rp.rf_idFiles
--where CodeM='101001'