use RegisterCases
go
--dbcc freeproccache()
--go
--SET STATISTICS IO ON
--SET STATISTICS TIME ON

declare @idFile int
select top 1 @idFile=v.id
from vw_getIdFileNumber v inner join t_File f on
		v.id=f.id
where v.id=3383
order by CountSluch desc


declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

--insert @idTable
--select ROW_NUMBER() OVER (ORDER BY c.id),c.id as rf_idCase,p.id as rf_idPatient 
--from t_RegistersCase a inner join t_RecordCase rc on
--			a.id=rc.rf_idRegistersCase
--			and a.rf_idFiles=@idFile
--					inner join t_Case c on
--					rc.id=c.rf_idRecordCase
--							  inner join (
--											select r.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient,p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,p.BirthPlace
--											from t_RegisterPatient p left join t_RefRegisterPatientRecordCase r on
--														p.id=r.rf_idRegisterPatient
--											where p.rf_idFiles=@idFile
--										) p on
--					rc.id=p.rf_idRecordCase and
--					rc.ID_Patient=p.ID_Patient
--					and p.rf_idFiles=@idFile

insert @idTable
select id,rf_idCase,rf_idRegisterPatient
from t_RefCasePatientDefine
where rf_idFiles=@idFile

create table #tPeople 
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
				inner join vw_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient

exec dbo.usp_GetPID @t

select pe.ID,pe.FAM,pe.IM,pe.OT
from #tPeople p inner join PolicyRegister.dbo.PEOPLE pe on
		p.PID=pe.ID

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
--insert @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd)
--select TOP 1 WITH TIES t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd
--from vw_People p inner join #tPeople t on
--							p.ID=t.pid
--							inner join vw_Polis pol on
--							p.ID=pol.PID
--							 inner join vw_sprSMO smo on
--							isnull(pol.Q,0)=smo.smocod
--where t.pid is not null and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and (pol.Q is not null) and pol.OKATO='18000000000'--т.к. в базе есть люди у которых не определена СМО, хотя ОГРН СМО есть.
--ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idRefCaseIteration,pol.PID ORDER BY pol.DBEG desc)	

select t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join (
										SELECT TOP 1 WITH TIES *
										from vw_Polis t
										ORDER BY ROW_NUMBER() OVER(PARTITION BY t.PID ORDER BY t.DBeg desc)
										)pol on
							p.ID=pol.PID
where t.pid is not null and (pol.Q is not null) and pol.OKATO='18000000000'
go
drop table #tPeople

--SET STATISTICS IO OFF
--SET STATISTICS TIME OFF