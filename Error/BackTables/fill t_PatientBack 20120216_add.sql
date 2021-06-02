use RegisterCases
declare @t as table(rf_idCase bigint,id bigint)
begin transaction
insert @t
select recb.rf_idCase,recb.id
from t_FileBack f inner join t_RegisterCaseBack rcb on
			f.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
							inner join t_CaseBack cb on
			recb.id=cb.rf_idRecordCaseBack
where f.DateCreate>'20120217 02:00:00' and f.DateCreate<'20120217 08:00:00' and p.OKATO is null --and p.rf_idSMO!='34'

--простовляем окато для тех записей у которых определена СМО(иногородний)
update p
set p.OKATO=t.ROKATO
from t_PatientBack p inner join (
									select t.id,z.ROKATO
									from t_RefCasePatientDefine r inner join t_CaseDefineZP1 i on
													r.id=i.rf_idRefCaseIteration
																	inner join @t t on
													r.rf_idCase=t.rf_idCase
																	inner join PolicyRegister.dbo.ZP1 z on
													i.rf_idZP1=z.ID
									where z.RDBEG is not null 
								) t on p.rf_idRecordCaseBack=t.id
								
--простовляем в тип оплаты =2 и код СМО =00 у которых не определена СМО
update cb
set cb.TypePay=2
from t_FileBack f inner join t_RegisterCaseBack rcb on
			f.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
							inner join t_CaseBack cb on
			recb.id=cb.rf_idRecordCaseBack
where f.DateCreate>'20120217 02:00:00' and f.DateCreate<'20120217 08:00:00' and p.OKATO is null 

update p
set p.rf_idSMO='00', p.OKATO='00000'
from t_FileBack f inner join t_RegisterCaseBack rcb on
			f.id=rcb.rf_idFilesBack
					inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
							inner join t_CaseBack cb on
			recb.id=cb.rf_idRecordCaseBack
where f.DateCreate>'20120217 02:00:00' and f.DateCreate<'20120217 08:00:00' and p.OKATO is null 

commit