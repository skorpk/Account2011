use RegisterCases
go
declare @RecordCase as TVP_CasePatient,
			@idRecordCaseNext as TVP_CasePatient,
			@CaseDefined as TVP_CasePatient
			
declare @tempID as table(id int, ID_PAC nvarchar(36),N_ZAP int)

declare @idFile int=3491


insert @tempID
select c.id,r.ID_Patient,r.idRecord
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
where a.rf_idFiles=@idFile
			
insert @RecordCase	
select c.id as rf_idCase,p.id as rf_idPatient 
from @tempID rc inner join t_Case c on
		rc.id=c.rf_idRecordCase
				  inner join (
								select r.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient,p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,p.BirthPlace
								from t_RegisterPatient p left join t_RefRegisterPatientRecordCase r on
												p.id=r.rf_idRegisterPatient
								where p.rf_idFiles=@idFile
							) p on
		rc.id=p.rf_idRecordCase and
		rc.ID_PAC=p.ID_Patient
-----изменения от 22.01.2012-------------------------------------------------------------------			
	
--определение сстраховой принадлежности в РС ЕРЗ на 1-ой итерации.
--возвращает id ненайденых пациентов(по которым не определена страховая принадлежность)
--данные необходимо для того что бы определить страховую принадлежность на ЦС ЕРЗ на 2-ой итерации
--добавил в качестве параметра передачу id файла входящего
	
	--insert @idRecordCaseNext
	--exec usp_DefineSMOIteration1_3 @RecordCase,@iteration=1,@id=@idFile
	