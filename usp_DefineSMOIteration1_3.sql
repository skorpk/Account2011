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
--при итерации №3 добавлять данные в таблицу t_RefCasePatientDefine не нужно т.к. они там уже лежат. 
--мы просто получаем необходимые данные
else 
begin
	insert @idTable
	select cd.id,t.rf_idCase,t.ID_Patient
	from @idRecordCase t inner join t_RefCasePatientDefine cd on
				t.rf_idCase=cd.rf_idCase
				and t.ID_Patient=cd.rf_idRegisterPatient
end
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
-- сначала определяю PID из РС ЕРЗ----------------------------------------------------------------------------------------

declare @t as TVP_Insurance

insert @t
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
--заменил функцию на хранимую процедуру и табличную переменную на временную таблицу
create table #tPeople
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd DATE,
    IsDelete TINYINT,
    DateBegin DATE
)
exec usp_GetPID @t
--фильтрация умершил людей.
UPDATE p SET IsDelete=1
FROM #tPeople p INNER JOIN dbo.vw_People vp ON
		p.PID=vp.ID			
WHERE p.DateEnd>vp.DS

		

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
	DateEnd date,
	LPU char(6)
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

if @iteration=1
begin
	-- заношу данные после первой итерации, для того что бы мог добавить данные во вторую итерацию		
	insert @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd)
	select TOP 1 WITH TIES t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
							p.ID=pol.PID
							 inner join vw_sprSMO smo on
							isnull(pol.Q,0)=smo.smocod
	where t.pid is not null and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and (pol.Q is not null) and pol.OKATO='18000'--т.к. в базе есть люди у которых не определена СМО, хотя ОГРН СМО есть.
	ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idRefCaseIteration,pol.PID ORDER BY pol.DBEG desc)		
	
	-- 28.02.2014 сохраняем данные по людям которые подходят под требования 3 итерации   
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
	-- заношу данные после первой итерации, для того что бы мог добавить данные во вторую итерацию
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
---Получаем  код МО приписки человека  на дату начала лечения пациента. Изменения от 03.10.2014
--Вступает в силу с 01.01.2013
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
-------------------------------
BEGIN TRANSACTION
BEGIN TRY			
--04.01.2014
--заносим в таблицу ошибок сведения по умершим людям
insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
SELECT 506,r.rf_idFiles,r.rf_idCase
FROM #tPeople p INNER JOIN dbo.t_RefCasePatientDefine r ON
		p.rf_idRefCaseIteration=r.id
WHERE IsDelete=1
--513 ошибка 
/*
Проводится проверка правомочности проведения диспансеризации определенных групп взрослого населения (R), 
профилактических осмотров определенных групп взрослого населения (O), профилактических(F) и предварительных (V) осмотров несовершеннолетних, 
диспансеризации детей-сирот (U), в том числе усыновленных. 
Указанные виды медицинской помощи должны быть оказаны медицинскими организациями, к которым прикреплены застрахованные лица
 */
insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
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

insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
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



--Изменение от 03.01.2012 года
insert t_CaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,AttachCodeM)	
		output inserted.rf_idRefCaseIteration into @tableCaseDefine
select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,LPU
from (
		select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, c.SMO,SPolicy,NPolcy,RN,rf_idF008,LPU
		from @tmpCaseDefine c left join vw_sprSMODisable s on
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
		SELECT p.rf_idRefCaseIteration,GETDATE(),p.PID,CASE WHEN r1.rf_idF008=3 THEN r1.NumberPolis ELSE NULL END,1,ps.rf_idSMO,r1.SeriaPolis,r1.NumberPolis
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

	
--сохраняю сведения с id случаем и номером итерации на котором данный случай был определен
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,@iteration from @tableCaseDefine

--28.02.2014
--сохраняю определение кода прикрепления МО для счетов с буквой O,R,F,V,U если человек застрахован в ВО
-- т.к. при 2 и 4 итерации код МО прикрепления не известен 
IF @iteration=1
BEGIN
--Изменения от 18.03.2014
	INSERT dbo.t_RefCaseAttachLPUItearion2( rf_idCase ,rf_idFiles ,rf_idRefCaseIteration ,AttachLPU,PID)	
	SELECT r.rf_idCase,r.rf_idFiles,t.rf_idRefCaseIteration,t.LPU,t.PID
	from @tmpCaseDefine3 t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
			AND ISNULL(t.LPU,'000000')!='000000'
						inner join t_Case c on
			r.rf_idCase=c.id			
	WHERE NOT EXISTS(SELECT * FROM @tableCaseDefine WHERE rf_idRefCaseIteration=r.id ) 

/*
	INSERT dbo.t_RefCaseAttachLPUItearion2( rf_idCase ,rf_idFiles ,rf_idRefCaseIteration ,AttachLPU,PID)	
	SELECT r.rf_idCase,r.rf_idFiles,t.rf_idRefCaseIteration,t.LPU,t.PID
	from @tmpCaseDefine3 t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
			AND ISNULL(t.LPU,'000000')!='000000'
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
	WHERE NOT EXISTS(SELECT * FROM @tableCaseDefine WHERE rf_idRefCaseIteration=r.id ) 
	
	INSERT dbo.t_RefCaseAttachLPUItearion2( rf_idCase ,rf_idFiles ,rf_idRefCaseIteration ,AttachLPU,PID)	
	SELECT r.rf_idCase,r.rf_idFiles,t.rf_idRefCaseIteration,t.LPU,t.PID
	from @tmpCaseDefine3 t inner join t_RefCasePatientDefine r on
			t.rf_idRefCaseIteration=r.id
			AND ISNULL(t.LPU,'000000')!='000000'
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
	WHERE NOT EXISTS(SELECT * FROM @tableCaseDefine WHERE rf_idRefCaseIteration=r.id ) 
	  */
END
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
select c.rf_idCase, c.ID_Patient
from @idRecordCase c left join		(
										select rfc.id,rf_idCase,rfc.rf_idRegisterPatient
										from t_RefCasePatientDefine rfc inner join t_CaseDefine cd on
													rfc.id=cd.rf_idRefCaseIteration										
									 ) rfc on
				c.rf_idCase=rfc.rf_idCase and 
			c.ID_Patient=rfc.rf_idRegisterPatient
where rfc.id is null
group by c.rf_idCase, c.ID_Patient

go
