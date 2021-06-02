use RegisterCases
go
if OBJECT_ID('usp_InsertFromTMPIntoTables',N'P') is not null
drop proc usp_InsertFromTMPIntoTables
go
create procedure usp_InsertFromTMPIntoTables
as
SET IDENTITY_INSERT dbo.t_File ON
--------tmp_File------------
insert t_File([GUID],[id],[DateRegistration],[FileVersion],[DateCreate],[FileNameHR],[FileNameLR],[FileZIP],[rf_idFileTested],[CountSluch])
select [GUID],[id],[DateRegistration],[FileVersion],[DateCreate],[FileNameHR],[FileNameLR],[FileZIP],[rf_idFileTested],[CountSluch]
from tmp_File 
SET IDENTITY_INSERT dbo.t_File OFF
--------tmp_RegistersCase-------
SET IDENTITY_INSERT dbo.t_RegistersCase ON
insert dbo.t_RegistersCase([rf_idFiles],[id],[rf_idMO],[ReportYear],[ReportMonth],[NumberRegister],[DateRegister],[rf_idSMO],[AmountPayment],[Comments],[AmountPaymentAccept],[AmountMEK],[AmountMEE],[AmountEKMP],[idRecord])
select [rf_idFiles],[id],[rf_idMO],[ReportYear],[ReportMonth],[NumberRegister],[DateRegister],[rf_idSMO],[AmountPayment],[Comments],
		[AmountPaymentAccept],[AmountMEK],[AmountMEE],[AmountEKMP],[idRecord]
from tmp_RegistersCase
SET IDENTITY_INSERT dbo.t_RegistersCase OFF
-------tmp_RecordCase-----------
SET IDENTITY_INSERT dbo.t_RecordCase ON
insert dbo.t_RecordCase([id],[rf_idRegistersCase],[idRecord],[IsNew],[ID_Patient],[rf_idF008],[SeriaPolis],[NumberPolis],[NewBorn])
select [id],[rf_idRegistersCase],[idRecord],[IsNew],[ID_Patient],[rf_idF008],[SeriaPolis],[NumberPolis],[NewBorn] from tmp_RecordCase
SET IDENTITY_INSERT dbo.t_RecordCase OFF
--------tmp_PatientSMO --------------
insert dbo.t_PatientSMO([ref_idRecordCase],[rf_idSMO],[OGRN],[OKATO],[Name])
select [ref_idRecordCase],[rf_idSMO],[OGRN],[OKATO],[Name] from tmp_PatientSMO 
---------tmp_Case-----------------
SET IDENTITY_INSERT dbo.t_Case ON
insert dbo.t_Case([id],[rf_idRecordCase],[idRecordCase],[GUID_Case],[rf_idV006],[rf_idV008],[rf_idDirectMO],[HopitalisationType],[rf_idMO],[rf_idSubMO]
				,[rf_idDepartmentMO],[rf_idV002],[IsChildTariff],[NumberHistoryCase],[DateBegin],[DateEnd],[rf_idV009],[rf_idV012],[rf_idV004],[rf_idDoctor]
				,[IsSpecialCase],[rf_idV010],[AmountPayment],[TypePay],[AmountPaymentAccept],[Age])
select [id],[rf_idRecordCase],[idRecordCase],[GUID_Case],[rf_idV006],[rf_idV008],[rf_idDirectMO],[HopitalisationType],[rf_idMO],[rf_idSubMO]
				,[rf_idDepartmentMO],[rf_idV002],[IsChildTariff],[NumberHistoryCase],[DateBegin],[DateEnd],[rf_idV009],[rf_idV012],[rf_idV004],[rf_idDoctor]
				,[IsSpecialCase],[rf_idV010],[AmountPayment],[TypePay],[AmountPaymentAccept],[Age]
from tmp_Case
SET IDENTITY_INSERT dbo.t_Case OFF
----------tmp_Meduslugi----------
insert dbo.t_Meduslugi([rf_idCase],[id],[GUID_MU],[rf_idMO],[rf_idSubMO],[rf_idDepartmentMO],[rf_idV002],[IsChildTariff],[DateHelpBegin],[DateHelpEnd],[DiagnosisCode]
						,[MUCode],[Quantity],[Price],[TotalPrice],[rf_idV004],[rf_idDoctor])
select [rf_idCase],[id],[GUID_MU],[rf_idMO],[rf_idSubMO],[rf_idDepartmentMO],[rf_idV002],[IsChildTariff],[DateHelpBegin],[DateHelpEnd],[DiagnosisCode],[MUCode]
		,[Quantity],[Price],[TotalPrice],[rf_idV004],[rf_idDoctor]
from tmp_Meduslugi

-------tmp_MES -----------
insert dbo.t_Mes([MES],[rf_idCase],[TypeMES],[Quantity],[Tariff])
select [MES],[rf_idCase],[TypeMES],[Quantity],[Tariff] from tmp_MES 

----------tmp_Diagnosis-------------
insert into dbo.t_Diagnosis([DiagnosisCode],[rf_idCase],[TypeDiagnosis])select [DiagnosisCode],[rf_idCase],[TypeDiagnosis] from tmp_Diagnosis---------------------------------FileBack------------------------
-----tmp_FileBack -------
SET IDENTITY_INSERT dbo.t_FileBack ONinsert dbo.t_FileBack([id],[rf_idFiles],[DateCreate],[FileVersion],[FileNameHRBack],[UserName],[IsUnload])select [id],[rf_idFiles],[DateCreate],[FileVersion],[FileNameHRBack],[UserName],[IsUnload]from tmp_FileBackSET IDENTITY_INSERT dbo.t_FileBack OFF
------tmp_RegisterCaseBack----------
SET IDENTITY_INSERT dbo.t_RegisterCaseBack ONinsert dbo.t_RegisterCaseBack([id],[rf_idFilesBack],[ref_idF003],[ReportYear],[ReportMonth],[DateCreate],[NumberRegister],[PropertyNumberRegister])select [id],[rf_idFilesBack],[ref_idF003],[ReportYear],[ReportMonth],[DateCreate],[NumberRegister],[PropertyNumberRegister]from tmp_RegisterCaseBackSET IDENTITY_INSERT dbo.t_RegisterCaseBack OFF
--------tmp_RecordCaseBack --------
SET IDENTITY_INSERT dbo.t_RecordCaseBack ONinsert dbo.t_RecordCaseBack([id],[rf_idRegisterCaseBack],[rf_idRecordCase],[rf_idCase])select [id],[rf_idRegisterCaseBack],[rf_idRecordCase],[rf_idCase]from tmp_RecordCaseBackSET IDENTITY_INSERT dbo.t_RecordCaseBack OFF
----------tmp_CaseBack-----------
insert dbo.t_CaseBack([rf_idRecordCaseBack],[TypePay])select [rf_idRecordCaseBack],[TypePay]from tmp_CaseBack-------tmp_PatientBack-----------
insert dbo.t_PatientBack([rf_idRecordCaseBack],[rf_idF008],[SeriaPolis],[NumberPolis],[rf_idSMO],[OKATO])select [rf_idRecordCaseBack],[rf_idF008],[SeriaPolis],[NumberPolis],[rf_idSMO],[OKATO]from tmp_PatientBack
------------------------------L----------------------
------tmp_RegisterPatient -------------
SET IDENTITY_INSERT dbo.t_RegisterPatient ONinsert dbo.t_RegisterPatient([id],[rf_idFiles],[ID_Patient],[Fam],[Im],[Ot],[rf_idV005],[BirthDay],[BirthPlace],[rf_idRecordCase])select [id],[rf_idFiles],[ID_Patient],[Fam],[Im],[Ot],[rf_idV005],[BirthDay],[BirthPlace],[rf_idRecordCase]from tmp_RegisterPatientSET IDENTITY_INSERT dbo.t_RegisterPatient OFF

-----tmp_RegisterPatientDocument-----------
insert dbo.t_RegisterPatientDocument([rf_idRegisterPatient],[rf_idDocumentType],[SeriaDocument],[NumberDocument],[SNILS],[OKATO],[OKATO_Place])select [rf_idRegisterPatient],[rf_idDocumentType],[SeriaDocument],[NumberDocument],[SNILS],[OKATO],[OKATO_Place]from tmp_RegisterPatientDocument----tmp_RegisterPatientAttendant--------------
insert dbo.t_RegisterPatientAttendant([rf_idRegisterPatient],[Fam],[Im],[Ot],[rf_idV005],[BirthDay])select [rf_idRegisterPatient],[Fam],[Im],[Ot],[rf_idV005],[BirthDay]from tmp_RegisterPatientAttendantgo