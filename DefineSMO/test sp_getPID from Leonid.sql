use RegisterCases
go
declare @t as TVP_Insurance_New
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

declare @idFile INT
select @idFile=id from vw_getIdFileNumber where ReportYear=2017 AND CountSluch>1000 ORDER BY NEWID()

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


--SELECT * FROM @t
--select @@ROWCOUNT
SET STATISTICS TIME ON
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
select t.id,rc.SeriaPolis,rc.NumberPolis,ps.ENP,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.NumberDocument,pd.SNILS,c.DateEnd,c.DateBegin,p.rf_idV005
from @idTable t inner join t_Case c on
		t.rf_idCase=c.id 
				inner join vw_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
				INNER JOIN dbo.t_PatientSMO ps ON
		rc.id=ps.ref_idRecordCase              
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient

exec Utility.dbo.sp_GetPid 
EXEC Utility.dbo.sp_GetIdPolisLPU

UPDATE p SET IsDelete=1
FROM #t p INNER JOIN PolicyRegister.dbo.PEOPLE vp ON
		p.PID=vp.ID			
WHERE vp.ENP IS NOT NULL AND p.dd>vp.DS

UPDATE t SET Step=1 
from #t t WHERE sKey IN('H10','H20','H30','H40','520','416','H21','H31','H41','521','411')


SELECT * FROM #t

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
	LPU VARCHAR(6),
	LPUid int,  -- id в таблице HISTLPU для определения МО прикрепления
	PolID INT -- id в таблице Polis
)

INSERT #tPeople(rf_idRefCaseIteration ,PID ,DateEnd ,IsDelete ,DateBegin ,Sex ,DR ,Step ,LPUid ,PolID,LPU)
SELECT nrec,PID,DD,IsDelete,DateBeg,Sex,dr,step,lid,[sid],lpu FROM #t

		

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
	insert @tmpCaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd,Step, LPU)
	select t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd, t.Step,LPU
	from vw_People p inner join #tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
								pol.ID=t.PolID
								AND p.ID=pol.PID
	where t.pid is not NULL and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and (pol.Q is not null) and pol.OKATO='18000'
	
	insert @tmpCaseDefine3(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008,DateEnd, LPU)	
	select t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP,DateEnd,LPU
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
SELECT * FROM @tmpCaseDefine
SELECT * FROM @tmpCaseDefine3

go	
DROP TABLE #tPeople
DROP TABLE #tableCaseDefine
DROP TABLE #t





