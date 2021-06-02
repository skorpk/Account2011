use RegisterCases
go
if OBJECT_ID('vw_GlobalError',N'V') is not null
drop view vw_GlobalError
go
create view vw_GlobalError
as
select f.id,fn.id as id1,f.FileNameP, fn.[FileName],e.rf_idF012 as ErrorID, e.Comments as Error
from t_FileError f inner join t_FileTested ft on
			f.rf_idFileTested=ft.id
					inner join t_FileNameError fn on
			f.id=fn.rf_idFileError
					left join t_Error e on
			fn.id=e.rf_idFileNameError
go
------------------------------------------------------------------------------------ 
if OBJECT_ID('vw_sprF012',N'V') is not null
drop view vw_sprF012
go
create view vw_sprF012
as
	select * from oms_nsi.dbo.sprF012
go
------------------------------------------------------------------------------------ 
if OBJECT_ID('vw_XmlTag',N'V') is not null
drop view vw_XmlTag
go
create view vw_XmlTag
as
select el1.id,el1.NameElement,el2.NameElement as ParentElementName
from t_XmlElement el1 inner join t_XmlElement el2 on
			el1.Parent_id=el2.id
go
------------------------------------------------------------------------------------ 
if OBJECT_ID('vw_ErrorXSD',N'V') is not null
drop view vw_ErrorXSD
go
create view vw_ErrorXSD
as
select fe.rf_idFileError,e.rf_idFileNameError,e.rf_idF012,case when vw_xml.NameElement is null then e.ErrorTagAlter else vw_xml.NameElement end as NameElement,
		case when vw_xml.ParentElementName is null then e.ErrorParentTagAlter else vw_xml.ParentElementName  end as ParentElementName,
		case when e.rf_idGuidFieldError='' then null else e.rf_idGuidFieldError end as rf_idGuidFieldError,
		vw_error.AdditionalInfo
from t_FileNameError fe inner join t_Error e on
		fe.id=e.rf_idFileNameError
					left join vw_XmlTag vw_xml on
		e.rf_idXMLElement=vw_xml.id
					inner join vw_sprF012 vw_error on
		e.rf_idF012=vw_error.id
GO
----------------------------------------------Настроить синхронизацию из БД PolicyRerister в БД RegisterCase-------------------------------------- 
if OBJECT_ID('vw_Polis',N'V') is not null
drop view vw_Polis
go
create view vw_Polis
as
--select PID,DBEG,DEND,Q,SPOL,NPOL,POLTP			
--from dbo.POLIS
select PID,DBEG,CASE WHEN POLTP=1 THEN isnull(DSTOP,'20130101') ELSE isnull(DSTOP,isnull(DEND,'20150101')) END as DEND,Q,SPOL,NPOL,OKATO, POLTP			
from PolicyRegister.dbo.POLIS
GO
----------------------------------------------Настроить синхронизацию из БД PolicyRerister в БД RegisterCase-------------------------------------- 
if OBJECT_ID('vw_People',N'V') is not null
drop view vw_People
go
create view vw_People
as
--select ID, ENP, RN from dbo.PEOPLE--[srvsql1-st2].PolicyRegister.dbo.PEOPLE
select ID, ENP, RN from PolicyRegister.dbo.PEOPLE
go
if OBJECT_ID('vw_sprMUCompletedCase',N'V') is not null
drop view vw_sprMUCompletedCase
go
create view vw_sprMUCompletedCase
as
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName,
		Profile,AgeGroupShortName,cast(MUGroupCodeP as varchar(2))+'.'+cast(MUUnGroupCodeP as varchar(2))+'.'+cast(MUCodeP as varchar(3)) as MU_P
from oms_NSI.dbo.vw_sprMUAll
where MUGroupCodeP is not null
go
if OBJECT_ID('vw_sprMU',N'V') is not null
drop view vw_sprMU
go
create view vw_sprMU
as
select distinct cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName
from oms_NSI.dbo.vw_sprMUAll
--where MUGroupCodeP is null
go
if OBJECT_ID('vw_sprMUAll',N'V') is not null
drop view vw_sprMUAll
go
create view vw_sprMUAll
as
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName,
		Profile,AgeGroupShortName,cast(MUGroupCodeP as varchar(2))+'.'+cast(MUUnGroupCodeP as varchar(2))+'.'+cast(MUCodeP as varchar(3)) as MU_P
from oms_NSI.dbo.vw_sprMUAll
go

if OBJECT_ID('vw_sprT001',N'V') is not null
drop view vw_sprT001
go
create view vw_sprT001
as
select * from oms_nsi.dbo.vw_sprT001 
go
if OBJECT_ID('vw_sprSMO',N'V') is not null
drop view vw_sprSMO
go
create view vw_sprSMO
as
select smocod,sNameF,sNameS
from oms_nsi.dbo.tSMO where smocod is not null
go
--вьюха которая показывает случай по которым не определена страховая принадлежность
if OBJECT_ID('vw_CaseNotDefineYet',N'V') is not null
drop view vw_CaseNotDefineYet
go
create view vw_CaseNotDefineYet
as
select czp1.rf_idRefCaseIteration,czp1.rf_idZP1
from t_RefCasePatientDefine rf inner join t_CaseDefineZP1 czp1 on
					rf.id=czp1.rf_idRefCaseIteration
					and rf.IsUnloadIntoSP_TK is null
							left join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration>1
where i.rf_idRefCaseIteration is null
group by czp1.rf_idRefCaseIteration,czp1.rf_idZP1
go
if OBJECT_ID('vw_sprSMOGlobal',N'V') is not null
drop view vw_sprSMOGlobal
go
create view vw_sprSMOGlobal
as
select TF_OKATO as OKATO,SMOKOD,NAM_SMOK as SMO, OGRN
from oms_nsi.dbo.sprSMO 
go
if OBJECT_ID('vw_sprUnit',N'V') is not null
drop view vw_sprUnit
go
create view vw_sprUnit
as
select unitCode,unitName
from oms_nsi.dbo.tPlanUnit
go
if OBJECT_ID('vw_sprSMODisable',N'V') is not null
drop view vw_sprSMODisable
go
create view vw_sprSMODisable
as
select *
from oms_NSI.dbo.sprSMODisable
go
if OBJECT_ID('vw_RegisterPatient',N'V') is not null
drop view vw_RegisterPatient
go
create view vw_RegisterPatient
as
	--select p.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient,p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,p.BirthPlace
	--from t_RegisterPatient p where p.rf_idRecordCase is not null
	--union all
	--select r.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient,p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,p.BirthPlace
	--from t_RegisterPatient p inner join t_RefRegisterPatientRecordCase r on
	--			p.id=r.rf_idRegisterPatient
	select p.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient
			,case when UPPER(p.Fam)='НЕТ' then pa.Fam else p.Fam end as FAM
			,case when UPPER(p.Im)='НЕТ' then pa.Im else p.Im end as Im
			,case when UPPER(p.Fam)='НЕТ' then pa.Ot else p.Ot end Ot
			,case when UPPER(p.Fam)='НЕТ' then pa.rf_idV005 else p.rf_idV005 end as rf_idV005
			,case when UPPER(p.Fam)='НЕТ' then pa.BirthDay else p.BirthDay end as BirthDay
			,p.BirthPlace
	from t_RegisterPatient p left join t_RegisterPatientAttendant pa on
			p.id=pa.rf_idRegisterPatient
	where p.rf_idRecordCase is not null
	union all
	select r.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient
			,case when UPPER(p.Fam)='НЕТ' then pa.Fam else p.Fam end as FAM
			,case when UPPER(p.Im)='НЕТ' then pa.Im else p.Im end as Im
			,case when UPPER(p.Fam)='НЕТ' then pa.Ot else p.Ot end Ot
			,case when UPPER(p.Fam)='НЕТ' then pa.rf_idV005 else p.rf_idV005 end as rf_idV005
			,case when UPPER(p.Fam)='НЕТ' then pa.BirthDay else p.BirthDay end as BirthDay
			,p.BirthPlace
	from t_RegisterPatient p inner join t_RefRegisterPatientRecordCase r on
					p.id=r.rf_idRegisterPatient
							left join t_RegisterPatientAttendant pa on
			p.id=pa.rf_idRegisterPatient

GO
if OBJECT_ID('vw_Diagnosis',N'V') is not null
drop view vw_Diagnosis
go
create view vw_Diagnosis
as
select rf_idCase,max(case when TypeDiagnosis=1 then DiagnosisCode else null end) DS1,
		max(case when TypeDiagnosis=2 then DiagnosisCode else null end) DS0,
		max(case when TypeDiagnosis=3 then DiagnosisCode else null end) DS2		
from t_Diagnosis
group by rf_idCase
go