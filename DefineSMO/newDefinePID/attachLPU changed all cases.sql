use RegisterCases
go
declare @t as TVP_Insurance_New
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)


select f.DateRegistration,f.CodeM,a.NumberRegister,c.id, cc.rf_idRecordCasePatient
into #t3
from dbo.t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				 inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				inner join t_Case c on
			r.id=c.rf_idRecordCase	
				INNER JOIN AccountOMS.dbo.t_Case cc ON
			c.GUID_Case=cc.GUID_Case
			AND c.DateEnd=cc.DateEnd								
WHERE f.DateRegistration>'20171001' AND f.DateRegistration<'20171005'

insert @idTable 
select t.rf_idRecordCasePatient,rf.rf_idCase,rf.rf_idRegisterPatient
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			inner join t_RefCasePatientDefine rf on
			c.id=rf.rf_idCase		
					INNER JOIN #t3 t ON
			c.id=t.id                  
			
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
SELECT distinct t.id,rc.SeriaPolis,rc.NumberPolis,ps.ENP,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.NumberDocument,pd.SNILS,c.DateEnd,c.DateBegin,p.rf_idV005
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

create table #tPeople
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd DATE,
    IsDelete TINYINT,
    DateBegin DATE,
	Sex TINYINT,
	FAM VARCHAR(40),
	DR DATE,
	Step TINYINT,
	ENP VARCHAR(20),
	LPU VARCHAR(6),
	LPUid int,  -- id в таблице HISTLPU для определения МО прикрепления
	PolID INT -- id в таблице Polis
)

INSERT #tPeople(rf_idRefCaseIteration ,PID ,DateEnd ,IsDelete ,DateBegin ,Sex ,DR ,Step ,LPUid ,PolID,LPU,ENP, fam)
SELECT nrec,PID,DD,IsDelete,DateBeg,Sex,dr,step,lid,[sid],lpu, penp, fam FROM #t

--DROP TABLE tmpAttachLPUAccountOMS

SELECT p.*,r.AttachLPU
INTO tmpAttachLPUAccountOMS
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
		p.LPU=l.CodeM
				INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
		p.rf_idRefCaseIteration=r.id   
WHERE p.LPU<>r.AttachLPU		           

go	
DROP TABLE #tPeople
DROP TABLE #t
DROP TABLE #t3





