---------------------------------delete from RegisterCase----------------------------
delete from t_Diagnosis
delete from t_MES
delete from t_FinancialSanctions
delete from t_ReasonPaymentCancelled
delete from t_Meduslugi

delete from t_Case
DBCC CHECKIDENT ('dbo.t_Case', RESEED, 0);

delete from t_PatientSMO

delete from t_RecordCase
DBCC CHECKIDENT ('dbo.t_RecordCase', RESEED, 0);

delete from t_RegistersCase
DBCC CHECKIDENT ('dbo.t_RegistersCase', RESEED, 0);

delete from t_RegisterPatientDocument
delete from t_RegisterPatientAttendant

delete from t_RegisterPatient
DBCC CHECKIDENT ('dbo.t_RegisterPatient', RESEED, 0);

delete from t_File
DBCC CHECKIDENT ('dbo.t_File', RESEED, 0);
--------------------------------delete from back files---------------------------------
delete from t_PatientBack
delete from t_CaseBack

delete from t_RecordCaseBack
DBCC CHECKIDENT ('dbo.t_RecordCaseBack', RESEED, 0);

delete from t_RegisterCaseBack
DBCC CHECKIDENT ('dbo.t_RegisterCaseBack', RESEED, 0);

delete from t_FileBack
DBCC CHECKIDENT ('dbo.t_FileBack', RESEED, 0);
-------------------------------------delete from iteration tables-----------------------------------------------
delete from t_CaseDefineZP1
delete from t_CaseDefine
delete from t_CasePatientDefineIteration
delete from t_RefCasePatientDefine
DBCC CHECKIDENT ('dbo.t_RefCasePatientDefine', RESEED, 0);
-----------------------------delete from error tables------------------------------

delete from t_FileNameError
DBCC CHECKIDENT ('dbo.t_FileNameError', RESEED, 0);
delete from t_Error
delete from t_FileError
delete from t_FileTested


delete from t_ErrorProcessControl