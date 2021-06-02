use RegisterCases
go
create unique index QU_File on t_File(id) with IGNORE_DUP_KEY
--create unique index QU_RegistersCase on t_RegistersCase(id) with IGNORE_DUP_KEY
--create unique index QU_RecordCase on t_RecordCase(id) with IGNORE_DUP_KEY
--create unique index QU_PatientSMO on t_PatientSMO(ref_idRecordCase) with IGNORE_DUP_KEY
--create unique index QU_Case on t_Case(id) with IGNORE_DUP_KEY
--create unique index QU_Mes on t_Mes(rf_idCase,MES) with IGNORE_DUP_KEY
--create unique index QU_Diagnosis on t_Diagnosis(rf_idCase,DiagnosisCode,TypeDiagnosis) with IGNORE_DUP_KEY
--create unique index QU_Meduslugi on t_Meduslugi(rf_idCase,id) with IGNORE_DUP_KEY
create unique index QU_FileBack on t_FileBack(id) with IGNORE_DUP_KEY
create unique index QU_RegisterPatient on t_RegisterPatient(id) with IGNORE_DUP_KEY