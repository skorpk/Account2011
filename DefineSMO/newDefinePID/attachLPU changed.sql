use RegisterCases
go
declare @t as TVP_Insurance_New
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

SELECT c.GUID_Case,c.DateEnd,c.rf_idRecordCasePatient
INTO #t1 
FROM AccountOMS.dbo.t_Case c 
					INNER JOIN (VALUES (76067281,43000),(76067733,42999),(76067771,43004),(76151059,43007),(76151084,43007),(76101026,43007),(76162295,42999),(76162436,43005),(76162477,43007),
										(76163128,43003),(76163129,43005),(76163270,42998),(76075512,43003),(76075513,43005),(76075514,43008),(76080289,43007),(76106931,43008),(76107105,43000),
										(76107842,42980),(76107943,43007),(76108055,42999),(76108317,43007),(76108385,42997),(76109133,42998),(76109489,43007),(76110267,43003),(76110382,43004),
										(76115900,42989),(76116455,43003),(76116507,42997),(76117000,43006),(76117001,43000),(76117223,42993),(76072636,43004),(76072713,43003),(76072781,43007),
										(76078053,43004),(76078054,43007),(76078090,43003),(76078165,43000),(76078166,43004),(76078220,43003),(76078427,42997),(76079097,42984),(76079098,43003),
										(76079552,42997),(76079683,42986),(76079684,43005),(76124497,43006),(76165467,42992),(76165524,43003),(76165613,42996),(76165636,42996),(76067083,42997),
										(76099293,43004),(76226587,43000),(76227026,42996),(76126419,43006),(76227991,43003),(76228356,43006),(76076355,42999),(76076356,42997),(76077394,42999),
										(76077578,43003),(76094035,43008),(76094192,43007),(76094602,43006),(76071106,43004),(76071107,43006),(76076691,43000),(76076870,43005),(76077117,43003),
										(76097526,43007),(76100307,43000),(76100369,43007),(76100422,43007),(76100692,43005),(76150956,43007),(76160606,42999),(76160607,43000),(76163427,43000),
										(76167999,43003),(76168000,43005),(76123719,43007),(76123841,43005),(76162348,42992),(76162349,42997),(76162350,43004),(76163094,43006),(76096039,43006),
										(76096149,43005),(76208589,42998),(76107227,43006),(76107398,43005),(76107439,43005),(76109306,42986),(76115823,42999),(76117139,42996),(76072841,43007),
										(76078291,42999),(76078850,43007),(76164996,43004),(76166061,43003),(76166757,43003),(76166925,42999),(76166926,43003),(76167142,42999),(76099396,43004),
										(76227410,42985),(76227629,42989),(76126544,43006),(76228298,43005),(76071793,43000),(76100233,43003),(76100255,43000),(76100604,43005),(76067533,43007),
										(76094851,43004),(76123838,43007),(76162741,43006),(76080257,43007),(76125717,43005),(76125744,43005),(76208432,42996),(76106941,42998),(76107269,43006),
										(76107867,43003),(76108300,42979),(76109147,43005),(76110051,42998),(76115733,42996),(76115734,42999),(76115761,42996),(76115762,42992),(76116320,43003),
										(76117157,42999),(76117281,43000),(76078955,43007),(76079393,43000),(76079405,43007),(76079525,43007),(76079862,43003),(76166195,43003),(76166262,43004),
										(76229492,42994),(76099932,43006),(76226819,43000),(76093109,43007),(76093256,43007),(76126673,43004),(76227870,43005),(76227919,42988),(76076336,42991),
										(76094077,42998),(76094477,42985),(76076977,42979),(76076978,42986),(76077233,43000),(76077234,43003),(76077235,43005),(76077353,43005),(76124959,43007),
										(76160883,42992),(76160884,42998),(76163665,43000),(76101896,43004),(76077454,43005),(76093515,43003),(76106775,42991),(76110499,43003),(76110515,43000),
										(76077722,43006),(76078696,43007),(76075462,42996),(76226501,42993),(76226910,42997),(76227822,42999),(76227949,42991),(76077535,43004),(76077536,43004),
										(76093926,42995),(76229557,42993),(76071553,43007),(76071734,43007),(76071748,43004),(76071816,43000),(76071817,43006),(76072018,42996),(76076639,43000),
										(76076940,42979),(76076941,42986),(76076956,43005),(76107319,42993),(76107476,43005),(76107477,43000),(76150833,43007),(76166663,43007),(76067094,43006),
										(76067188,43004),(76072003,42996),(76072004,43000),(76076964,43005),(76160840,42993),(76163252,42996),(76080066,43007),(76107772,42999),(76108150,42990),
										(76108930,43000),(76110340,43000),(76078262,43000),(76078749,43003),(76078765,43005),(76078967,42998),(76165211,42998),(76229511,43005),(76100468,43007),
										(76101424,43004),(76160593,43004),(76095950,42992),(76093539,43003),(76123608,43007),(76125678,43004),(76125699,42998),(76151229,42999),(76108057,42991),
										(76108058,42990),(76108059,43003),(76079190,43007),(76166299,42998),(76067057,42996),(76101814,43007),(76075496,43003),(76093225,43004),(76093226,43006),
										(76093376,43006),(76126736,43005),(76126843,43005),(76126859,43006),(76076725,43004),(76095128,42999),(76160838,43003),(76123531,42991),(76123770,42999),
										(76123867,42996),(76162146,43007),(76162660,42996),(76162661,42997),(76162878,42996),(76113763,43000),(76080288,43006),(76208422,42990),(76107561,42993),
										(76107562,42999),(76107563,42997),(76107564,43006),(76107573,42980),(76107574,42993),(76108462,43005),(76108580,43000),(76108705,43003),(76109047,42990),
										(76109528,42998),(76110343,43006),(76110383,43000),(76110384,43004),(76150837,43007),(76117086,43004),(76117124,42989),(76117150,42997),(76072632,43000),
										(76072858,43003),(76077650,43000),(76078513,42991),(76078514,43004),(76078515,43005),(76078600,42998),(76079057,42992),(76079058,43006),(76079165,43003),
										(76079765,43006),(76079904,43003),(76110593,43007),(76124469,43006),(76165050,43006),(76165066,43005),(76165403,43003),(76165415,42996),(76165589,42984),
										(76165590,42998),(76165842,42993),(76166168,42996),(76166169,43007),(76166459,43006),(76166463,42999),(76166595,42998),(76166652,43004),(76166871,43000),
										(76166968,42998),(76084079,43006),(76099378,43007),(76226707,42998),(76227448,42982),(76227478,43007),(76093205,42996),(76093214,43005),(76126762,43003),
										(76126827,43003),(76228001,43003),(76076317,43005),(76094443,43000),(76093030,43006),(76095114,42999),(76099164,43007),(76099209,43003),(76160997,42997),
										(76161273,43005)) v(rf_idCase,DateEnd) ON
				c.id=v.rf_idCase
				AND c.DateEnd=DATEADD(DAY,-2,CAST(cast(v.DateEnd AS datetime) AS DATE)) 

select f.DateRegistration,f.CodeM,a.NumberRegister, c.id, t.rf_idRecordCasePatient
into #t2
from dbo.t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
				 inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				inner join t_Case c on
			r.id=c.rf_idRecordCase	
				INNER JOIN #t1 t ON
			c.GUID_Case=t.guid_case
			AND c.DateEnd=t.DateEnd                      

insert @idTable 
select t.rf_idRecordCasePatient,rf.rf_idCase,rf.rf_idRegisterPatient
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			inner join t_RefCasePatientDefine rf on
			c.id=rf.rf_idCase		
					INNER JOIN #t2 t ON
			c.id=t.id                  
			



--SELECT * FROM @t
--select @@ROWCOUNT

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

UPDATE p SET IsDelete=1
FROM #t p INNER JOIN PolicyRegister.dbo.PEOPLE vp ON
		p.PID=vp.ID			
WHERE vp.ENP IS NOT NULL AND p.dd>vp.DS

UPDATE t SET Step=1 
from #t t WHERE PID IS NOT null--sKey IN('H10','H20','H30','H40','520','416','H21','H31','H41','521','411','410')
--������� ������� �� �������� ��������� � ��������� ���������� �� ��������� �������
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
	LPUid int,  -- id � ������� HISTLPU ��� ����������� �� ������������
	PolID INT -- id � ������� Polis
)

INSERT #tPeople(rf_idRefCaseIteration ,PID ,DateEnd ,IsDelete ,DateBegin ,Sex ,DR ,Step ,LPUid ,PolID,LPU,ENP, fam)
SELECT nrec,PID,DD,IsDelete,DateBeg,Sex,dr,step,lid,[sid],lpu, penp, fam FROM #t

DROP TABLE tmpAttachLPUAccountOMS

SELECT p.*,r.AttachLPU
INTO tmpAttachLPUAccountOMS
FROM #tPeople p INNER JOIN dbo.vw_sprT001 l ON
		p.LPU=l.CodeM
				INNER JOIN AccountOMS.dbo.t_RecordCasePatient r ON
		p.rf_idRefCaseIteration=r.id              

UPDATE p SET p.Sex=pp.W
FROM #tPeople p INNER JOIN PolicyRegister.dbo.PEOPLE pp ON
		p.pid=pp.id


--SELECT * FROM #tPeople 
CREATE NONCLUSTERED INDEX IX_PeopleTMP ON #tPeople(PID) INCLUDE(rf_idRefCaseIteration,PolID,LPUid,LPU,ENP,DateEnd, Step)

go	
DROP TABLE #tPeople
--DROP TABLE #tableCaseDefine
DROP TABLE #t
--DROP TABLE #t1
--DROP TABLE #t2




