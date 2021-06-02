use RegisterCases
go
declare @id int,
		@idFileBack int
select @idFileBack=f.id,@id=f.rf_idFiles
from vw_getIdFileNumber v inner join t_FileBack f on
		v.id=f.rf_idFiles
where v.CodeM='371001' and ReportYear=2012 and NumberRegister=16 and f.UserName='VTFOMS\sysdba'


begin transaction
--записи по которым определена СМО
insert t_CaseDefine(rf_idRefCaseIteration,DateDefine,IsDefined,rf_idF008,SPolicy,NPolcy,SMO)
select distinct d.id,'20120328',1,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,smo.rf_idSMO		
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id								
							inner join t_Case c on		
			recb.rf_idCase=c.id
							inner join t_RefCasePatientDefine d on
			c.id=d.rf_idCase
							inner join t_CasePatientDefineIteration i on
			d.id=i.rf_idRefCaseIteration
			and i.rf_idIteration=3						
							inner join t_PatientSMO smo on
			rc.id=smo.ref_idRecordCase			
							left join t_PatientBack p on							
			recb.id=p.rf_idRecordCaseBack
where rf_idFilesBack=@idFileBack and p.rf_idRecordCaseBack is null

insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolcy,DateDefine)
select zp1.rf_idRefCaseIteration,max(zp.ID),ROKATO,RENP,ROPDOC,RQOGRN,RSPOL,RNPOL,GETDATE()
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id								
							inner join t_Case c on		
			recb.rf_idCase=c.id
							inner join t_RefCasePatientDefine d on
			c.id=d.rf_idCase
			and d.rf_idFiles=@id
							inner join t_CasePatientDefineIteration i on
			d.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)	
							inner join t_CaseDefineZP1 zp1 on
			d.id=zp1.rf_idRefCaseIteration			
							inner join PolicyRegister.dbo.ZP1 zp on
			zp1.rf_idZP1=zp.ID								
							left join t_PatientBack p on							
			recb.id=p.rf_idRecordCaseBack
where rf_idFilesBack=@idFileBack and p.rf_idRecordCaseBack is null and zp.RDBEG is not null
group by zp1.rf_idRefCaseIteration,ROKATO,RENP,ROPDOC,RQOGRN,RSPOL,RNPOL

--вставляем записи в таблицу о пациенте по которым не определили СМО
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,DateDefine)
select zp1.rf_idRefCaseIteration,max(zp.id),GETDATE()
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id								
							inner join t_Case c on		
			recb.rf_idCase=c.id
							inner join t_RefCasePatientDefine d on
			c.id=d.rf_idCase
			and d.rf_idFiles=@id
							inner join t_CasePatientDefineIteration i on
			d.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (4)	
							inner join t_CaseDefineZP1 zp1 on
			d.id=zp1.rf_idRefCaseIteration			
							inner join PolicyRegister.dbo.ZP1 zp on
			zp1.rf_idZP1=zp.ID																					
where rf_idFilesBack=@idFileBack and (zp.RDBEG is null)
group by zp1.rf_idRefCaseIteration


delete from t_FileBack where id=@idFileBack

update t_RefCasePatientDefine 
set IsUnloadIntoSP_TK=null
from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
		r.id=i.rf_idRefCaseIteration
where rf_idFiles=@id and i.rf_idIteration<>1

exec usp_FillBackTablesAfterAllIteration @id

select @idFileBack=f.id
from vw_getIdFileNumber v inner join t_FileBack f on
		v.id=f.rf_idFiles
where v.CodeM='371001' and ReportYear=2012 and NumberRegister=16 and f.UserName='VTFOMS\SKrainov'

--exec usp_RegisterSP_TK @idFileBack

rollback


