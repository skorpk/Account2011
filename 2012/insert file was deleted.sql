use RegisterCases
go
--select * from vw_getIdFileNumber where CodeM='331001' and NumberRegister in (1) and ReportYear=2012
--------tmp_File------------
select * 
into tmp_File 
from t_File where id in (1988,2125,1869)
--------tmp_RegistersCase-------
select * 
into tmp_RegistersCase
from t_RegistersCase where rf_idFiles in (1988,2125,1869)
-------tmp_RecordCase-----------
select r.*
into tmp_RecordCase
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
where a.rf_idFiles in (1988,2125,1869)
--------tmp_PatientSMO --------------
select p.*
into tmp_PatientSMO 
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
						inner join t_PatientSMO p on
				r.id=p.ref_idRecordCase
where a.rf_idFiles in (1988,2125,1869)
---------tmp_Case-----------------
select c.*
into tmp_Case
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
						inner join t_Case c on
				r.id=c.rf_idRecordCase
where a.rf_idFiles in (1988,2125,1869)
----------tmp_Meduslugi----------
select m.*
into tmp_Meduslugi
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
						inner join t_Case c on
				r.id=c.rf_idRecordCase
						inner join t_Meduslugi m on
				c.id=m.rf_idCase
where a.rf_idFiles in (1988,2125,1869)
-------tmp_MES -----------
select m.*
into tmp_MES 
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
						inner join t_Case c on
				r.id=c.rf_idRecordCase
						inner join t_MES m on
				c.id=m.rf_idCase
where a.rf_idFiles in (1988,2125,1869)
----------tmp_Diagnosis-------------
select m.*
into tmp_Diagnosis
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
						inner join t_Case c on
				r.id=c.rf_idRecordCase
						inner join t_Diagnosis m on
				c.id=m.rf_idCase
where a.rf_idFiles in (1988,2125,1869)


---------------------------------FileBack------------------------
-----tmp_FileBack -------
select * 
into tmp_FileBack 
from t_FileBack where id in (3284,3408,3299,3048)
------tmp_RegisterCaseBack----------
select * 
into tmp_RegisterCaseBack
from t_RegisterCaseBack rb where rf_idFilesBack in (3284,3408,3299,3048)
--------tmp_RecordCaseBack --------
select rcb.* 
into tmp_RecordCaseBack 
from t_RegisterCaseBack rb inner join t_RecordCaseBack rcb on
				rb.id=rcb.rf_idRegisterCaseBack
where rf_idFilesBack in (3284,3408,3299,3048)
----------tmp_CaseBack-----------
select cb.*
into tmp_CaseBack
from t_RegisterCaseBack rb inner join t_RecordCaseBack rcb on
				rb.id=rcb.rf_idRegisterCaseBack
							inner join t_CaseBack cb on
				rcb.id=cb.rf_idRecordCaseBack
where rf_idFilesBack in (3284,3408,3299,3048)
-------tmp_PatientBack-----------
select cb.*
into tmp_PatientBack
from t_RegisterCaseBack rb inner join t_RecordCaseBack rcb on
				rb.id=rcb.rf_idRegisterCaseBack
							inner join t_PatientBack cb on
				rcb.id=cb.rf_idRecordCaseBack
where rf_idFilesBack in (3284,3408,3299,3048)

------------------------------L----------------------
------tmp_RegisterPatient -------------
select * 
into tmp_RegisterPatient 
from t_RegisterPatient where rf_idFiles in (1988,2125,1869)
-----tmp_RegisterPatientDocument-----------
select rpd.* 
into tmp_RegisterPatientDocument
from t_RegisterPatient rp inner join t_RegisterPatientDocument rpd on
			rp.id=rpd.rf_idRegisterPatient
where rf_idFiles in (1988,2125,1869)
----tmp_RegisterPatientAttendant--------------
select rpd.* 
into tmp_RegisterPatientAttendant
from t_RegisterPatient rp inner join t_RegisterPatientAttendant rpd on
			rp.id=rpd.rf_idRegisterPatient
where rf_idFiles in (1988,2125,1869)
go
-------------tmp_PlanOrdersReport -------
--select *
--into tmp_PlanOrdersReport 
--from t_PlanOrdersReport where rf_idFile in (1988,2125,1869)
alter table tmp_File drop column CodeM
alter table tmp_RecordCase drop column NPolisLen
alter table tmp_RecordCase drop column IsChild
alter table tmp_FileBack drop column CodeM
alter table tmp_FileBack drop column PackID
alter table tmp_FileBack drop column MM

