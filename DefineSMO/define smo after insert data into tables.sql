use RegisterCases
go
declare @idFile int=39869
declare @tempID as table(id int, ID_PAC nvarchar(36),N_ZAP int)
declare	@idRecordCase as TVP_CasePatient

insert @tempID
select r.id,r.ID_Patient,r.idRecord
from t_RegistersCase a inner join t_RecordCase r on
		 a.id=r.rf_idRegistersCase
		 and a.rf_idFiles=@idFile
		 
insert @idRecordCase
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
										and e.ErrorNumber<>57
where e.rf_idCase is null

declare @iteration tinyint=1,
		@id int=@idFile
		
---------------------------------------------------TEST---------------------------------------------------------
--begin transaction

	declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

	--дабовляю в таблицу t_RefCaseIteration сведения с итерацией №1 
	--if @iteration=1
	--begin
	--	insert t_RefCasePatientDefine(rf_idCase,rf_idRegisterPatient,rf_idFiles)
	--		output inserted.id,inserted.rf_idCase, inserted.rf_idRegisterPatient into @idTable
	--	select c.rf_idCase as rf_idCase,c.ID_Patient as rf_idPatient,@id
	--	from @idRecordCase c 
	--end	
	--при итерации №3 добавлять данные в таблицу t_RefCasePatientDefine не нужно т.к. они там уже лежать. 
	--мы просто получаем необходимые данные
	--else 
	--begin
		insert @idTable
		select cd.id,t.rf_idCase,t.ID_Patient
		from @idRecordCase t inner join t_RefCasePatientDefine cd on
					t.rf_idCase=cd.rf_idCase
					and t.ID_Patient=cd.rf_idRegisterPatient
	--end

	-- сначала определяю PID из РС ЕРЗ----------------------------------------------------------------------------------------

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
	--заменил функцию на хранимую процедуру и табличную переменную на временную таблицу
	create table #tPeople
	(
		rf_idRefCaseIteration bigint,
		PID int,
		DateEnd date
	)
	exec usp_GetPID @t

SELECT * FROM #tPeople
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

	if @iteration=1
	begin
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
		where t.pid is not null and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and (pol.Q is not null) and pol.OKATO='18000'--т.к. в базе есть люди у которых не определена СМО, хотя ОГРН СМО есть.
		ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idRefCaseIteration,pol.PID ORDER BY pol.DBEG desc)		
				
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

	--Изменение от 03.01.2012 года
	--insert t_CaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008)	
	--		output inserted.rf_idRefCaseIteration into @tableCaseDefine
	select rf_idCase,rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008
	from (
			select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, c.SMO,SPolicy,NPolcy,RN,rf_idF008
			from @tmpCaseDefine c left join vw_sprSMODisable s on
						c.SMO=s.SMO
			where s.id is null
			union all
			select rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, c.SMO,SPolicy,NPolcy,RN,rf_idF008
			from @tmpCaseDefine  c inner join vw_sprSMODisable s on
						c.SMO=s.SMO
			where c.DateEnd<s.DateEnd
			union all
			select rf_idRefCaseIteration,DateDefine,c.PID,UniqueNumberPolicy,IsDefined, lp.Q as SMO,lp.SPOL as SPolicy,lp.NPOL as NPolcy
					,lp.RN,rf_idF008
			from @tmpCaseDefine c inner join vw_sprSMODisable s on
						c.SMO=s.SMO
								 inner join dbo.ListPeopleFromPlotnikov lp on
					c.PID=lp.ID
			where c.DateEnd>=s.DateEnd
		) t inner join t_RefCasePatientDefine rd on
			t.rf_idRefCaseIteration=rd.id
	order by rf_idCase
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


--rollback
go
drop table #tPeople
