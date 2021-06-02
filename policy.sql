use RegisterCases
go
declare @idRecordCase TVP_CasePatient

insert @idRecordCase values(5,'4896AD88-5E4F-462C-B1B0-E10F69C34138'),
						    (6,'AD6547EB-6570-4D0B-BD9A-4FBB3C377C3F'),
						    (7,'EEC4691C-154B-4301-927F-BC48FDA03696'),
							(8,'3AB1EB23-3978-4D1B-9D97-70DCD39FD306')

declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)
declare @iteration tinyint=1

--select * from @idRecordCase
delete from t_RefCaseIteration

insert t_RefCaseIteration(rf_idCase,rf_idIteration,rf_idRegisterPatient)
	output inserted.id,inserted.rf_idCase, inserted.rf_idRegisterPatient into @idTable
select c.id as rf_idCase,@iteration,p.id as rf_idPatient
from @idRecordCase rc inner join t_Case c on
			rc.rf_idCase=c.rf_idRecordCase
					  inner join t_RegisterPatient p on
			rc.rf_idCase=p.rf_idRecordCase and
			rc.ID_Patient=p.ID_Patient
			

declare @tPeople as table
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd date
)
insert @tPeople
select t.id,dbo.getPID(null,case when rc.rf_idF008=3 then rc.SeriaPolis else null end,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.SNILS,null,pd.NumberDocument,null),
		c.DateEnd
from @idTable t inner join t_Case c on
		t.rf_idCase=c.id 
				inner join t_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient

delete from t_CaseDefine

insert t_CaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN)
select t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN
from [srvsql1-st2].PolicyRegister.dbo.PEOPLE p inner join @tPeople t on
						p.ID=t.pid
						inner join [srvsql1-st2].PolicyRegister.dbo.POLIS pol on
						p.ID=pol.PID
where t.pid is not null and t.DateEnd>=pol.DBEG and t.DateEnd<=isnull(pol.DSTOP,pol.DEND)
				