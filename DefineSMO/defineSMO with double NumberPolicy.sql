USE RegisterCases
GO
DECLARE @idFile INT
declare @t as TVP_Insurance
DECLARE @iteration TINYINT=1
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)




select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='175405' AND ReportYear=2014 AND NumberRegister=15
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod=rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))
------------------------------------------------------------------------------------------------------
select c.id,d.*
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase					
					AND c.DateEnd>=@dateStart
					AND c.DateEnd<=@dateend
						INNER JOIN dbo.t_RefCasePatientDefine r1 ON
					c.id=r1.rf_idCase
					AND r1.rf_idFiles=@idFile
						INNER JOIN dbo.t_CasePatientDefineIteration i ON
					r1.id=i.rf_idRefCaseIteration
						INNER JOIN dbo.t_CaseDefine d ON
					r1.id=d.rf_idRefCaseIteration
WHERE c.GUID_Case IN('D4506300-3680-145E-157A-27781ACC8600','E5673467-1A7D-1259-3619-28893ABD8800','C7741755-2638-3186-11CD-30867BAA3270')


insert @idTable 
select rf.id,rf.rf_idCase,rf.rf_idRegisterPatient--,e.*
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			inner join t_RefCasePatientDefine rf on
			c.id=rf.rf_idCase			
WHERE c.GUID_Case IN('D4506300-3680-145E-157A-27781ACC8600','E5673467-1A7D-1259-3619-28893ABD8800','C7741755-2638-3186-11CD-30867BAA3270')
 
 select @@ROWCOUNT
 
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

select @@ROWCOUNT

create table #tPeople
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd DATE,
    IsDelete tinyint
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
										ORDER BY ROW_NUMBER() OVER(PARTITION BY p.ID ORDER BY p.LPUDT desc)
										) p on
			t.PID=p.ID


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
						
GO
DROP TABLE #tPeople