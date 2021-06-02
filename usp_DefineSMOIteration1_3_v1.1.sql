use RegisterCases
go
if OBJECT_ID('usp_DefineSMOIteration1_3',N'P') is not null
	drop proc usp_DefineSMOIteration1_3	
go
create proc usp_DefineSMOIteration1_3
			@idRecordCase TVP_CasePatient READONLY,
			@iteration tinyint,
			@id int=null
as
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

begin transaction
begin try
--дабовляю в таблицу t_RefCaseIteration сведения с итерацией №1 
if @iteration=1
begin
	insert t_RefCasePatientDefine(rf_idCase,rf_idRegisterPatient,rf_idFiles)
		output inserted.id,inserted.rf_idCase, inserted.rf_idRegisterPatient into @idTable
	select c.rf_idCase as rf_idCase,c.ID_Patient as rf_idPatient,@id
	from @idRecordCase c 
end	
--при итерации №3 добавлять данные в таблицу t_RefCasePatientDefine не нужно т.к. они там уже лежать. 
--мы просто получаем необходимые данные
else 
begin
	insert @idTable
	select cd.id,t.rf_idCase,t.ID_Patient
	from @idRecordCase t inner join t_RefCasePatientDefine cd on
				t.rf_idCase=cd.rf_idCase
				and t.ID_Patient=cd.rf_idRegisterPatient
end

-- сначала определяю PID из РС ЕРЗ----------------------------------------------------------------------------------------
declare @tPeople as table
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd date
)
declare @t as TVP_Insurance

insert @t
select t.id,case when rc.rf_idF008=3 then rc.SeriaPolis else null end,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.SNILS,null,pd.NumberDocument,null,
		c.DateEnd
from @idTable t inner join t_Case c on
		t.rf_idCase=c.id 
				inner join t_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient

insert @tPeople 
select t.id,t.PID,t.DateEnd
from dbo.fn_GetPID(@t) t
-----------------------------------------------------------------------------------------------------------
--таблица с id случаями по которым определена страховая принадлежность
declare @tableCaseDefine as table (rf_idRefCaseIteration bigint) 

declare @tmpCaseDefine as table
(
	rf_idRefCaseIteration bigint,
	DateDefine datetime,
	PID int,
	UniqueNumberPolicy varchar(20),
	IsDefined bit,
	SMO varchar(5),
	SPolicy varchar(20) ,
	NPolcy varchar(20),
	RN varchar(11),
	rf_idF008 tinyint 
) 

if @iteration=1
begin
	-- заношу данные после первой итерации, для того что бы мог добавить данные во вторую итерацию	
	insert @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008)
	select TOP 1 WITH TIES t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP
	from vw_People p inner join @tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
							p.ID=pol.PID
	where t.pid is not null and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and pol.Q is not null--т.к. в базе есть люди у которых не определена СМО, хотя ОГРН СМО есть.
	ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idRefCaseIteration,pol.PID ORDER BY pol.DBEG desc)		
			
end
if @iteration=3
begin
	-- заношу данные после первой итерации, для того что бы мог добавить данные во вторую итерацию
	insert @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008)
	select t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP
	from vw_People p inner join @tPeople t on
							p.ID=t.pid
							inner join (
										SELECT TOP 1 WITH TIES *
										from vw_Polis t
										ORDER BY ROW_NUMBER() OVER(PARTITION BY t.PID ORDER BY t.DBeg desc)
										)pol on
							p.ID=pol.PID
	where t.pid is not null 
end
insert t_CaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008)	
		output inserted.rf_idRefCaseIteration into @tableCaseDefine
select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008 from @tmpCaseDefine

--сохраняю сведения с id случаем и номером итерации на котором данный случай был определен
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,@iteration from @tableCaseDefine
--

end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
	
--записи по тем пациентам по которым не определан страховая принадлежность, передаем в процедуру usp_DefineSMOIteration2_4
--для определения страховой принадлежности в ЦС ЕРЗ
--select c.rf_idCase, c.ID_Patient
--from t_RefCasePatientDefine rfc inner join t_CaseDefine cd on
--			rfc.id=cd.rf_idRefCaseIteration
--			right join @idRecordCase c on
--			rfc.rf_idCase=c.rf_idCase and 
--			rfc.rf_idRegisterPatient=c.ID_Patient						
--where rfc.id is null
--group by c.rf_idCase, c.ID_Patient

select c.rf_idCase, c.ID_Patient
from @idRecordCase c left join		(
										select rfc.id,rf_idCase,rfc.rf_idRegisterPatient
										from t_RefCasePatientDefine rfc inner join t_CaseDefine cd on
													rfc.id=cd.rf_idRefCaseIteration
									 ) rfc on
				rfc.rf_idCase=c.rf_idCase and 
			rfc.rf_idRegisterPatient=c.ID_Patient						 			
where rfc.id is null
group by c.rf_idCase, c.ID_Patient

/*
select t0.rf_idCase,t0.ID_Patient
from @idRecordCase t0 left join (
									select c.rf_idCase,c.ID_Patient
									from t_RefCasePatientDefine rfc inner join t_CaseDefine cd on
												rfc.id=cd.rf_idRefCaseIteration
												inner join @idRecordCase c on
												rfc.rf_idCase=c.rf_idCase and 
												rfc.rf_idRegisterPatient=c.ID_Patient						
									where rfc.id is null
									group by c.rf_idCase, c.ID_Patient
								) t1 on 
				t0.rf_idCase=t1.rf_idCase 
				and t0.ID_Patient=t1.ID_Patient
where t1.rf_idCase is null
*/
go
