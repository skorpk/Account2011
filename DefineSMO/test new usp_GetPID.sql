use RegisterCases
go
CREATE TABLE #t(
				id bigint NULL,
				ENP varchar(20) NULL,
				FAM varchar(40) NULL,
				IM varchar(40) NULL,
				OT varchar(40) NULL,
				DR datetime NULL,
				MR varchar(100) NULL,
				SS varchar(16) NULL,
				DOCS varchar(20) NULL,
				DOCN varchar(20) NULL,
				OKATO varchar(11) NULL,
				DateEnd date NULL
				)

DECLARE @iteration TINYINT=1

declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

declare @idFile INT
select @idFile=id from vw_getIdFileNumber where ReportYear=2017 AND CountSluch>5000 ORDER BY NEWID()

select * from vw_getIdFileNumber where id=@idFile

insert @idTable 
select rf.id,rf.rf_idCase,rf.rf_idRegisterPatient
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			inner join t_RefCasePatientDefine rf on
			c.id=rf.rf_idCase								                      
WHERE rf.rf_idFiles=@idFile	 
			   
insert #t
select t.id,case when rc.rf_idF008=3 then rc.NumberPolis else null end,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.SNILS,null,pd.NumberDocument,null,
		c.DateEnd
from @idTable t inner join t_Case c on
		t.rf_idCase=c.id 
				inner join vw_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient


SET STATISTICS TIME ON
create table #tPeople
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd DATE,
    IsDelete TINYINT,
    DateBegin DATE,
	Sex TINYINT,
	DR DATE,
	Step tinyint
)
exec usp_GetPID_Test 

SELECT * FROM #tPeople
/*
SET STATISTICS TIME ON
UPDATE p SET IsDelete=1
FROM #tPeople p INNER JOIN dbo.vw_People vp ON
		p.PID=vp.ID			
WHERE p.DateEnd>vp.DS


-----------------------------------------------------------------------------------------------------------
--таблица с id случа€ми по которым определена страхова€ принадлежность
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
	DateEnd date,
	LPU char(6)
) 
--вспомогательна€ таблица дл€ PID у которых нет действ. полиса
declare @tmpCaseDefine3 as table
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
	DateEnd date,
	LPU char(6)
) 

if @iteration=1
begin
	-- заношу данные после первой итерации, дл€ того что бы мог добавить данные во вторую итерацию		
	insert @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd)
	select TOP 1 WITH TIES t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
							p.ID=pol.PID
							 inner join vw_sprSMO smo on
							isnull(pol.Q,0)=smo.smocod
	where t.pid is not null and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and (pol.Q is not null) and pol.OKATO='18000'--т.к. в базе есть люди у которых не определена —ћќ, хот€ ќ√–Ќ —ћќ есть.
	ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idRefCaseIteration,pol.PID ORDER BY pol.DBEG desc)		
	
	-- 28.02.2014 сохран€ем данные по люд€м которые подход€т под требовани€ 3 итерации   
    insert @tmpCaseDefine3(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd)	
	select t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join (
										SELECT TOP 1 WITH TIES t.*
										from vw_Polis t inner join #tPeople t1 on
													t.PID=t1.PID
													and t1.DateEnd>=t.DBEG						
										where t.pid is not null  
										ORDER BY ROW_NUMBER() OVER(PARTITION BY t.PID ORDER BY t.DBeg desc)
										)pol on
							p.ID=pol.PID
	where t.pid is not null and (pol.Q is not null) and pol.OKATO='18000'			
end
if @iteration=3
begin
	-- заношу данные после первой итерации, дл€ того что бы мог добавить данные во вторую итерацию
	insert @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd)
	select t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join (
										SELECT TOP 1 WITH TIES t.*
										from vw_Polis t inner join #tPeople t1 on
													t.PID=t1.PID
													and t1.DateEnd>=t.DBEG						
										where t.pid is not null  
										ORDER BY ROW_NUMBER() OVER(PARTITION BY t.PID ORDER BY t.DBeg desc)
										)pol on
							p.ID=pol.PID
	where t.pid is not null and (pol.Q is not null) and pol.OKATO='18000'
end

SELECT 1,* FROM @tmpCaseDefine

---ѕолучаем  код ћќ приписки человека  на дату начала лечени€ пациента. »зменени€ от 03.10.2014
--¬ступает в силу с 01.01.2013
update @tmpCaseDefine
	set LPU=p.LPU
	from @tmpCaseDefine t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
						inner join t_Case c on
			r.rf_idCase=c.id
						inner join t_RecordCase rc on
			c.rf_idRecordCase=rc.id
			and rc.IsChild=0
						inner join (
										select  TOP 1 WITH TIES ID, isnull(LPU,'000000') as LPU
										from vw_PeopleDefineLPU p INNER JOIN #tPeople t ON
													p.id=t.PID	
										WHERE t.DateBegin>=p.LPUDT																											
										ORDER BY ROW_NUMBER() OVER(PARTITION BY p.ID ORDER BY p.LPUDT desc)
										) p on
			--t.rf_idRefCaseIteration=p.rf_idRefCaseIteration
			t.PID=p.ID

update @tmpCaseDefine3
	set LPU=p.LPU
	from @tmpCaseDefine3 t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
						inner join t_Case c on
			r.rf_idCase=c.id
						inner join t_RecordCase rc on
			c.rf_idRecordCase=rc.id
			and rc.IsChild=0
						inner join (
										select  TOP 1 WITH TIES ID, isnull(LPU,'000000') as LPU
										from vw_PeopleDefineLPU p INNER JOIN #tPeople t ON
													p.id=t.PID	
										WHERE t.DateBegin>=p.LPUDT																
										ORDER BY ROW_NUMBER() OVER(PARTITION BY p.ID ORDER BY p.LPUDT desc)
										) p on
			t.PID=p.ID		
SELECT 506,r.rf_idFiles,r.rf_idCase
FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
		p.rf_idRefCaseIteration=r.id
WHERE IsDelete=1

select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,LPU
from (
		select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined,CASE WHEN c.SMO='34001' THEN '34007' ELSE c.SMO END AS SMO
				,SPolicy,NPolcy,RN,rf_idF008,LPU
		from @tmpCaseDefine c INNER JOIN dbo.t_RefCasePatientDefine r ON
				c.rf_idRefCaseIteration=r.id
						INNER JOIN t_Case c1 ON
				r.rf_idCase=c1.id
						 left join vw_sprSMODisable s on
					c.SMO=s.SMO
		where s.id is null
		union all
		select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, c.SMO,SPolicy,NPolcy,RN,rf_idF008,LPU
		from @tmpCaseDefine  c inner join vw_sprSMODisable s on
					c.SMO=s.SMO
		where c.DateEnd<s.DateEnd
		union all
		select rf_idRefCaseIteration,DateDefine,c.PID,UniqueNumberPolicy,IsDefined, lp.Q as SMO,lp.SPOL as SPolicy,lp.NPOL as NPolcy
				,lp.RN,rf_idF008,LPU
		from @tmpCaseDefine c inner join vw_sprSMODisable s on
					c.SMO=s.SMO
							 inner join dbo.ListPeopleFromPlotnikov lp on
				c.PID=lp.ID
		where c.DateEnd>=s.DateEnd
		UNION ALL--все записи по умершим которые не определились на первом этапе и что бы они дальше не пошли отсортировываем их
		---если застрахованный определилс€ на нашем регистре как  апиталовский переопредел€ем его в –√—
		SELECT p.rf_idRefCaseIteration,GETDATE(),p.PID,CASE WHEN r1.rf_idF008=3 THEN r1.NumberPolis ELSE NULL END,1
				,CASE WHEN ps.rf_idSMO='34001' THEN '34007' ELSE ISNULL(ps.rf_idSMO,'34') END,r1.SeriaPolis,r1.NumberPolis
				,pe.RN,r1.rf_idF008,'000000'
		FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
				p.rf_idRefCaseIteration=r.id
						INNER JOIN t_Case c ON
				r.rf_idCase=c.id
						INNER JOIN dbo.t_RecordCase r1 ON
				c.rf_idRecordCase=r1.id
						INNER JOIN dbo.t_PatientSMO ps ON
				r1.id=ps.ref_idRecordCase
						INNER JOIN dbo.vw_People pe ON
				p.PID=pe.ID
		WHERE NOT EXISTS(SELECT * FROM @tmpCaseDefine WHERE rf_idRefCaseIteration=p.rf_idRefCaseIteration) and p.IsDelete=1 					
	) t

SELECT r1.id, p.rf_idRefCaseIteration,GETDATE(),p.PID,CASE WHEN r1.rf_idF008=3 THEN r1.NumberPolis ELSE NULL END,1
				,CASE WHEN ps.rf_idSMO='34001' THEN '34007' ELSE ISNULL(ps.rf_idSMO,'34') END,r1.SeriaPolis,r1.NumberPolis
				,pe.RN,r1.rf_idF008,'000000'
		FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
				p.rf_idRefCaseIteration=r.id
						INNER JOIN t_Case c ON
				r.rf_idCase=c.id
						INNER JOIN dbo.t_RecordCase r1 ON
				c.rf_idRecordCase=r1.id
						INNER JOIN dbo.t_PatientSMO ps ON
				r1.id=ps.ref_idRecordCase
						INNER JOIN dbo.vw_People pe ON
				p.PID=pe.ID
		WHERE NOT EXISTS(SELECT * FROM @tmpCaseDefine WHERE rf_idRefCaseIteration=p.rf_idRefCaseIteration) and p.IsDelete=1 					
*/
go
drop table #tPeople
drop table #t

--------------------------------------------------------------
/*
DECLARE @pid INT=2155435,
		@id INT=53769185

SELECT * FROM PolicyRegister.dbo.PEOPLE WHERE id=@pid
SELECT *
FROM  dbo.t_RegisterPatient p 	
WHERE p.id=@id		        
*/