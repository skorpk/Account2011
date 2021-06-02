declare @tempID as table(id int, ID_PAC nvarchar(36))

--insert @tempID
--select id,ID_Patient
--from t_RecordCase
----where rf_idRegistersCase=5		

--declare @RecordCase as TVP_CasePatient,
--		@idRecordCaseNext as TVP_CasePatient

--insert @RecordCase	
--select c.id as rf_idCase,p.id as rf_idPatient 
--from @tempID rc inner join t_Case c on
--		rc.id=c.rf_idRecordCase
--			  inner join t_RegisterPatient p on
--		rc.id=p.rf_idRecordCase and
--		rc.ID_PAC=p.ID_Patient

--select * from @RecordCase

--exec usp_DefineSMOIteration1_3 @RecordCase,@iteration=1
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)
insert @idTable
select ROW_NUMBER() OVER(order by rf_idCase),rf_idCase,rf_idRegisterPatient 
from t_RefCasePatientDefine group by rf_idCase,rf_idRegisterPatient

--дабовляю в таблицу t_RefCaseIteration сведения с итерацией №1 или №3
			
-- сначала определяю PID из РС ЕРЗ
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
		
select COUNT(*) as PID_Finded from @tPeople where PID is not null
select COUNT(*) as PID_NotFinded from @tPeople where PID is null

select * from @tPeople where PID=2553895

select TOP 1 WITH TIES t.rf_idRefCaseIteration,GETDATE(),1,t.PID,p.ENP,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DBEG
from vw_People p inner join vw_Polis pol on
			p.ID=pol.PID
				inner join @tPeople t on
			p.ID=t.pid
			and t.pid is not null 
where t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and pol.Q is not null
ORDER BY ROW_NUMBER() OVER(PARTITION BY rf_idRefCaseIteration,pol.PID ORDER BY DBEG desc)	




--select *
--from (select * from @tPeople where PID is not null) p left join (
--							select pol.PID,pol.DEND,pol.DBEG 
--							from vw_People p inner join vw_Polis pol on
--											p.ID=pol.PID
--											inner join @tPeople t on
--														p.ID=t.pid
--														and t.PID is not null
--							where t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and pol.Q is not null
--							group by pol.PID,pol.DEND,pol.DBEG 
--							) t on p.PID=t.PID
--where t.PID is null
--order by p.PID
--where t.PID is null
