USE RegisterCases
go
--select * from vw_getIdFileNumber where CodeM='124528' and NumberRegister=51
declare @idFile int
select @idFile=id from vw_getIdFileNumber where CodeM='124528' and NumberRegister=51

select distinct rf_idCase from t_ErrorProcessControl where rf_idFile=@idFile
select @idFile
declare @tempID as table(id int, ID_PAC nvarchar(36),N_ZAP int)
declare @RecordCase as TVP_CasePatient
declare @t as TVP_Insurance
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

insert @tempID
select r.id,r.ID_Patient,r.idRecord
from t_RegistersCase a inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		and a.rf_idFiles=@idFile

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
								left join t_ErrorProcessControl e on
					c.id=e.rf_idCase
					and e.rf_idFile=@idFile
			where e.rf_idCase is null
			

begin transaction
	exec usp_DefineSMOIteration1_3 @RecordCase,@iteration=1,@id=@idFile
	/*
	insert t_RefCasePatientDefine(rf_idCase,rf_idRegisterPatient,rf_idFiles)
		output inserted.id,inserted.rf_idCase, inserted.rf_idRegisterPatient into @idTable
	select c.rf_idCase as rf_idCase,c.ID_Patient as rf_idPatient,@idFile
	from @RecordCase c 


insert @t
select t.id,case when rc.rf_idF008=3 then rc.SeriaPolis else null end,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.SNILS,null,pd.NumberDocument,null,
		c.DateEnd
from @idTable t inner join t_Case c on
		t.rf_idCase=c.id 
				inner join vw_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient
--заменил функцию на хранимую процедуру и табличную переменную на временную таблицу
create table #tPeople
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd date
)
exec usp_GetPID @t

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
	rf_idF008 tinyint,
	DateEnd date
) 


	-- заношу данные после первой итерации, для того что бы мог добавить данные во вторую итерацию	
	-- 19.12.2011 изменил алгоритм определения страховй принадлежности.
	insert @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd)
	select TOP 1 WITH TIES t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
							p.ID=pol.PID
							 inner join vw_sprSMO smo on
							isnull(pol.Q,0)=smo.smocod
	where t.pid is not null and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and (pol.Q is not null) and pol.OKATO='18000000000'--т.к. в базе есть люди у которых не определена СМО, хотя ОГРН СМО есть.
	ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idRefCaseIteration,pol.PID ORDER BY pol.DBEG desc)		
*/
go
--drop table #tPeople
	
rollback