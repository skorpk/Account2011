use RegisterCases
go
declare @t as TVP_Insurance_New
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

declare @idFile INT,
		@id int
select @idFile=id from vw_getIdFileNumber WHERE ReportYear=2020 AND CodeM='441001' AND NumberRegister=63

select * from vw_getIdFileNumber where id=@idFile

SELECT @id=@idFile



insert @idTable 
select DISTINCT c.id,c.id,rr.rf_idRegisterPatient
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
					INNER JOIN dbo.t_RefRegisterPatientRecordCase rr ON
			r.id=rr.rf_idRecordCase                  
WHERE a.rf_idFiles=@idFile AND c.idRecordCase IN(96,194)

SELECT @@ROWCOUNT

create table #t
(
	nrec bigint not null,		
	pid int null,			
	penp varchar(16) null,	
	sKey varchar(3) null,	
	sid	int null,			
	q varchar(5) null,		
	lid int null,			
	lpu varchar(6) null,	
	spol varchar(20) null,
	npol varchar(20) null,
	enp varchar(16) null,
	fam varchar(40) null,
	im varchar(40) null,
	ot varchar(40) null,
	dr datetime null,
	mr varchar(100) null,
	docn varchar(20) null,
	ss varchar(14) NULL,
	dd DATE NOT NULL,
	IsDelete TINYINT NULL,
	Step TINYINT  NOT NULL DEFAULT 9,
	DateBeg DATE,
	Sex TINYINT 
)

INSERT #t( nrec ,spol ,npol ,enp ,fam ,im ,ot ,dr , mr ,docn ,ss,dd,DateBeg, Sex)
select DISTINCT t.id,rc.SeriaPolis,rc.NumberPolis,ps.ENP,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.NumberDocument,pd.SNILS,cc.DateEnd,cc.DateBegin,p.rf_idV005
from @idTable t inner join t_Case c on
		t.rf_idCase=c.id 
				inner join vw_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
		AND c.rf_idRecordCase=rc.id
				INNER JOIN dbo.t_PatientSMO ps ON
		rc.id=ps.ref_idRecordCase              
				INNER JOIN dbo.t_CompletedCase cc ON
		rc.id=cc.rf_idRecordCase              
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient

SELECT * FROM #t

SELECT @@ROWCOUNT

exec Utility.dbo.sp_GetPid 
EXEC Utility.dbo.sp_GetIdPolisLPU_3

--------------------------------------------------------

--;WITH cte 
--AS(
--select row_number()over(partition by h.pid order by h.id desc) AS idRow, h.pid,h.id AS lid,h.lpu 
--from PolicyRegister.dbo.Histlpu h INNER join #t t on(h.pid=t.pid) 
--where cast(h.lpudt as date) <= t.DateBeg and cast(isnull(h.lpudx,t.DateBeg) as date) >= t.DateBeg
--)
--update t set t.lid=c.lid, t.lpu=c.lpu  
--from #t t INNER JOIN cte c ON
--             t.pid=c.pid
--WHERE c.idRow=1

--------------------------------------------------------
------------кроме скорой-------------------
UPDATE p SET IsDelete=1
FROM #t p INNER JOIN PolicyRegister.dbo.PEOPLE vp ON
		p.PID=vp.ID		
			INNER JOIN t_RefCasePatientDefine rr ON
		p.nrec=rr.id
			INNER JOIN dbo.t_Case c ON
		rr.rf_idCase=c.id	
WHERE vp.ENP IS NOT NULL AND p.dd>vp.DS AND c.rf_idV006<4
-------------для Скорой-------------------------
UPDATE p SET IsDelete=1
FROM #t p INNER JOIN PolicyRegister.dbo.PEOPLE vp ON
		p.PID=vp.ID		
			INNER JOIN t_RefCasePatientDefine rr ON
		p.nrec=rr.id
			INNER JOIN dbo.t_Case c ON
		rr.rf_idCase=c.id	
WHERE vp.ENP IS NOT NULL AND p.dd>DATEADD(day,1,vp.DS) AND c.rf_idV006=4 AND c.rf_idV009 NOT IN(405,409,411)

--ставим все записям с PID=1 
UPDATE t SET Step=1 
from #t t WHERE PID IS NOT null--sKey IN('H10','H20','H30','H40','520','416','H21','H31','H41','521','410','411')

--заменил функцию на хранимую процедуру и табличную переменную на временную таблицу
create table #tPeople
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd DATE,
    IsDelete TINYINT,
    DateBegin DATE,
	Sex TINYINT,
	DR DATE,
	Step TINYINT,
	ENP VARCHAR(20),
	LPU VARCHAR(6),
	LPUid int,  -- id в таблице HISTLPU для определения МО прикрепления
	PolID INT -- id в таблице Polis
)

INSERT #tPeople(rf_idRefCaseIteration ,PID ,DateEnd ,IsDelete ,DateBegin ,Sex ,DR ,Step ,LPUid ,PolID,LPU,ENP)
SELECT nrec,PID,DD,IsDelete,DateBeg,Sex,dr,step,lid,[sid],lpu, penp FROM #t

SELECT nrec,PID,DD,IsDelete,DateBeg,Sex,dr,step,lid,[sid],lpu, penp FROM #t

CREATE NONCLUSTERED INDEX IX_PeopleTMP ON #tPeople(PID) INCLUDE(rf_idRefCaseIteration,PolID,LPUid,LPU,ENP,DateEnd, Step)

UPDATE p SET p.Sex=pp.W
FROM #tPeople p INNER JOIN PolicyRegister.dbo.PEOPLE pp ON
		p.pid=pp.id

DROP TABLE #t
-----------------------------------------------------------------------------------------------------------
--таблица с id случаями по которым определена страховая принадлежность
CREATE TABLE #tableCaseDefine (rf_idRefCaseIteration BIGINT,id INT) 

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
	LPU char(6)	,
	SNILS CHAR(11),
	Step TINYINT
) 
--вспомогательная таблица для PID у которых нет действ. полиса
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

SELECT '#tPeople', * FROM #tPeople

select t.rf_idRefCaseIteration, GETDATE(), t.PID,t.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd, t.Step,t.LPU,pol.OKATO
	,t.DateEnd,pol.DBEG,pol.DEND
from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
								pol.ID=t.PolID
								AND p.ID=pol.PID
where t.pid is not NULL /*and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND */and (pol.Q is not null) and pol.OKATO='18000'
	

select t.rf_idRefCaseIteration, GETDATE(), t.PID,t.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,t.DateEnd,t.LPU
from vw_People p inner join #tPeople t on
						p.ID=t.pid
						inner join vw_Polis pol on
							pol.ID=t.PolID
							AND p.ID=pol.PID
where t.pid is not null and (pol.Q is not null) and pol.OKATO='18000'	

	insert @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd,Step, LPU)
	select t.rf_idRefCaseIteration, GETDATE(), t.PID,t.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd, t.Step,t.LPU
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
								pol.ID=t.PolID
								AND p.ID=pol.PID
	where t.pid is not NULL /*and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND */and (pol.Q is not null) and pol.OKATO='18000'
	
	insert @tmpCaseDefine3(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd, LPU)	
	select t.rf_idRefCaseIteration, GETDATE(), t.PID,t.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,t.DateEnd,t.LPU
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
								pol.ID=t.PolID
								AND p.ID=pol.PID
	where t.pid is not null and (pol.Q is not null) and pol.OKATO='18000'	

---Получаем СНИЛС врача к которому прикреплен застрахованный.
	update @tmpCaseDefine
	set SNILS=isnull(p.SS_DOCTOR,'000000') 
	from @tmpCaseDefine t INNER JOIN #tPeople tt ON
				t.rf_idRefCaseIteration=tt.rf_idRefCaseIteration
						inner join PolicyRegister.dbo.HISTLPU p ON
			p.ID=tt.PolID
			AND p.kateg=1	
-------------------------------
		
--04.01.2014
--заносим в таблицу ошибок сведения по умершим людям
--insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 506,r.rf_idFiles,r.rf_idCase
FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
		p.rf_idRefCaseIteration=r.id
WHERE IsDelete=1

--заносим в таблицу ошибок сведения по людям без енп
--insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 57,r.rf_idFiles,r.rf_idCase
FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
		p.rf_idRefCaseIteration=r.id
WHERE ISNULL(p.ENP,'')='' AND PolID IS NOT null

--599 ошибка. Проводится проверка на соответствие даты рождения или пола от МО и даты рождения или пола в  РСЗ
--03.12.2015 Отключил проверку т.к. МО подает большое количество не корректных данных
--18.01.2016 Enable this test for sex

-----------------checking column sex----------------------
--insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 599,r.rf_idFiles,r.rf_idCase
FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
		p.rf_idRefCaseIteration=r.id
				INNER JOIN dbo.t_RegisterPatient rp ON
		r.rf_idRegisterPatient=rp.id
		AND r.rf_idFiles=rp.rf_idFiles
				INNER JOIN dbo.t_Case c ON
		r.rf_idCase=c.id
				INNER JOIN dbo.t_RecordCase r1 ON
		c.rf_idRecordCase=r1.id
		AND r1.IsChild=0
WHERE p.sex<>rp.rf_idV005  AND p.PID IS NOT NULL AND p.PolID IS NOT NULL						

--insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 599,r.rf_idFiles,r.rf_idCase
FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
		p.rf_idRefCaseIteration=r.id
				INNER JOIN dbo.t_RegisterPatient rp ON
		r.rf_idRegisterPatient=rp.id
		AND r.rf_idFiles=rp.rf_idFiles
				INNER JOIN dbo.t_RegisterPatientAttendant att ON
		rp.id=att.rf_idRegisterPatient              
				INNER JOIN dbo.t_Case c ON
		r.rf_idCase=c.id
				INNER JOIN dbo.t_RecordCase r1 ON
		c.rf_idRecordCase=r1.id
		AND r1.IsChild=1
WHERE p.sex<>ISNULL(att.rf_idV005,3) AND p.PID IS NOT NULL AND p.PolID IS NOT NULL

--513 ошибка 
/*
Проводится проверка правомочности проведения диспансеризации определенных групп взрослого населения (R), 
профилактических осмотров определенных групп взрослого населения (O), профилактических(F) и предварительных (V) осмотров несовершеннолетних, 
диспансеризации детей-сирот (U), в том числе усыновленных. 
Указанные виды медицинской помощи должны быть оказаны медицинскими организациями, к которым прикреплены застрахованные лица
 */
--insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 513,r.rf_idFiles,r.rf_idCase
from @tmpCaseDefine t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
						inner join t_Case c on
			r.rf_idCase=c.id
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
						INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
			m.MUCode=l.MU
WHERE m.Price>0 AND c.rf_idMO<>isnull(t.LPU,'000000')

--insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 513,r.rf_idFiles,r.rf_idCase
from @tmpCaseDefine t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
						inner join t_Case c on
			r.rf_idCase=c.id
						INNER JOIN dbo.t_Mes m ON
			c.id=m.rf_idCase
						INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
									UNION ALL
									SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
			m.MES=l.MU
WHERE c.rf_idMO<>isnull(t.LPU,'000000')

SELECT * FROM @tmpCaseDefine
--Изменение от 20.12.2016 добавлено полу IdStep
--1- это значит что человек нашелся по ФИО+ДР. В usp_FillBackTables идет обработка этих данных т.к. могут быть ошибки при подсчете МТР
--insert t_CaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,AttachCodeM,IDStep)	
--		output inserted.rf_idRefCaseIteration, INSERTED.id into #tableCaseDefine
select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,LPU,
		CASE WHEN step=1 THEN 1 ELSE 9 END AS step -- когда определили на 1 шаге, то ставим 1 а иначе ставим 9(для того что бы ставить OPLATA=2)
from (
		select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined,CASE WHEN c.SMO='34001' THEN '34007' ELSE c.SMO END AS SMO
				,SPolicy,NPolcy,RN,rf_idF008,LPU,c.step
		from @tmpCaseDefine c INNER JOIN dbo.t_RefCasePatientDefine r ON
				c.rf_idRefCaseIteration=r.id
						INNER JOIN t_Case c1 ON
				r.rf_idCase=c1.id
						 left join vw_sprSMODisable s on
					c.SMO=s.SMO
		where s.id is null
		union all
		select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, c.SMO,SPolicy,NPolcy,RN,rf_idF008,LPU, c.step
		from @tmpCaseDefine  c inner join vw_sprSMODisable s on
					c.SMO=s.SMO
		where c.DateEnd<s.DateEnd
		union all
		select rf_idRefCaseIteration,DateDefine,c.PID,UniqueNumberPolicy,IsDefined, lp.Q as SMO,lp.SPOL as SPolicy,lp.NPOL as NPolcy
				,lp.RN,rf_idF008,LPU, c.step
		from @tmpCaseDefine c inner join vw_sprSMODisable s on
					c.SMO=s.SMO
							 inner join dbo.ListPeopleFromPlotnikov lp on
				c.PID=lp.ID
		where c.DateEnd>=s.DateEnd
		UNION ALL--все записи по умершим которые не определились на первом этапе и что бы они дальше не пошли отсортировываем их
		---если застрахованный определился на нашем регистре как Капиталовский переопределяем его в РГС
		SELECT p.rf_idRefCaseIteration,GETDATE(),p.PID,CASE WHEN r1.rf_idF008=3 THEN r1.NumberPolis ELSE NULL END,1
				,CASE WHEN ps.rf_idSMO='34001' THEN '34007' ELSE ISNULL(ps.rf_idSMO,'34') END,r1.SeriaPolis,r1.NumberPolis
				,pe.RN,r1.rf_idF008,'000000',p.Step
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
	---вставка данных найденных и определенных, но имеющих неточности в ФИО+ДР, кроме умерших
--ускорил вставку
/*
SELECT  id ,rf_idFiles ,FAM ,Im ,Ot ,rf_idV005 , BirthDay 
INTO #t1 FROM dbo.vw_RegisterPatient WHERE rf_idFiles=@id

INSERT dbo.t_Correction( rf_idCaseDefine ,pid ,FAM ,IM ,OT ,BirthDay,TypeEquale)
SELECT t2.id,t.PID,p.FAM,p.im,p.ot,p.DR,
	 CASE WHEN ISNULL(p.FAM,'bla')!=ISNULL(pp.FAM,'bla') THEN 1 WHEN ISNULL(p.IM,'bla')!=ISNULL(pp.IM,'bla') THEN 2 
		  WHEN ISNULL(p.OT,'bla')!=ISNULL(pp.OT,'bla') THEN 3 WHEN ISNULL(p.DR,'bla')!=ISNULL(pp.BirthDay,'bla') THEN 4 end												
FROM dbo.t_CaseDefine t INNER JOIN #tableCaseDefine t2 ON
			t.id=t2.id
					INNER JOIN dbo.vw_People p ON
			t.pid=p.id 
					INNER JOIN dbo.t_RefCasePatientDefine rp ON
			t.rf_idRefCaseIteration=rp.id
					INNER JOIN #t1 pp ON
			rp.rf_idFiles=pp.rf_idFiles
			AND rp.rf_idRegisterPatient=pp.id                
WHERE (CASE WHEN ISNULL(p.FAM,'bla')!=ISNULL(pp.FAM,'bla') THEN 1 WHEN ISNULL(p.IM,'bla')!=ISNULL(pp.IM,'bla') THEN 2 
		  WHEN ISNULL(p.OT,'bla')!=ISNULL(pp.OT,'bla') THEN 3 WHEN ISNULL(p.DR,'bla')!=ISNULL(pp.BirthDay,'bla') THEN 4 END) IS NOT null												

------------вставка 57 ошибки-------------
--Если запись присутствует в таблицы t_Correction то PID мы нашли и есть несоответствия в персональных данных 
--для двойных случаев при 57 ошибки выкидываем весь законченный случай
SELECT DISTINCT 57,rf.rf_idFiles,c1.id--rf.rf_idCase
FROM dbo.t_CaseDefine cd INNER JOIN #tableCaseDefine t2 ON
			cd.id=t2.id
						INNER JOIN t_RefCasePatientDefine rf ON
			rf.id=cd.rf_idRefCaseIteration
						INNER JOIN dbo.t_Correction cc ON
			cd.id=cc.rf_idCaseDefine  
						INNER JOIN t_Case c ON
			rf.rf_idCase=c.id				
						INNER JOIN dbo.t_Case c1 ON
			c.rf_idRecordCase=c1.rf_idRecordCase
--WHERE cd.idStep>1

---Information about Doctor's SNILS saves into table t_CaseSNILSDefine
INSERT dbo.t_CaseSNILSDefine(rf_idRefCaseIteration ,SNILS)
SELECT t.rf_idRefCaseIteration,ISNULL(t.SNILS,'0')
FROM @tmpCaseDefine t INNER JOIN #tableCaseDefine t2 ON
			t.rf_idRefCaseIteration=t2.rf_idRefCaseIteration
			 
--сохраняю сведения с id случаем и номером итерации на котором данный случай был определен
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,@iteration from #tableCaseDefine

--28.02.2014
--сохраняю определение кода прикрепления МО для счетов с буквой O,R,F,V,U если человек застрахован в ВО
-- т.к. при 2 и 4 итерации код МО прикрепления не известен 
IF @iteration=1
BEGIN
--Изменения от 18.03.2014
	--INSERT dbo.t_RefCaseAttachLPUItearion2( rf_idCase ,rf_idFiles ,rf_idRefCaseIteration ,AttachLPU,PID)	
	SELECT r.rf_idCase,r.rf_idFiles,t.rf_idRefCaseIteration,t.LPU,t.PID
	from @tmpCaseDefine3 t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
			AND ISNULL(t.LPU,'000000')!='000000'
						inner join t_Case c on
			r.rf_idCase=c.id			
	WHERE NOT EXISTS(SELECT * FROM #tableCaseDefine WHERE rf_idRefCaseIteration=r.id ) 


END
--
*/
--end try
--begin catch
--if @@TRANCOUNT>0
--	select ERROR_MESSAGE()
--	rollback transaction
--end catch
--if @@TRANCOUNT>0
--	ROLLBACK transaction	
----записи по тем пациентам по которым не определан страховая принадлежность, передаем в процедуру usp_DefineSMOIteration2_4
----для определения страховой принадлежности в ЦС ЕРЗ
--select c.rf_idCase, c.ID_Patient
--from @idRecordCase c left join		(
--										select rfc.id,rf_idCase,rfc.rf_idRegisterPatient
--										from t_RefCasePatientDefine rfc inner join t_CaseDefine cd on
--													rfc.id=cd.rf_idRefCaseIteration										
--									 ) rfc on
--				c.rf_idCase=rfc.rf_idCase and 
--			c.ID_Patient=rfc.rf_idRegisterPatient
--where rfc.id is null
--group by c.rf_idCase, c.ID_Patient


go	
DROP TABLE #tPeople
go
DROP TABLE #tableCaseDefine
go
--DROP TABLE #t
--DROP TABLE #t1





