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
insert into dbo.t_Diagnosis([DiagnosisCode],[rf_idCase],[TypeDiagnosis])
-----tmp_FileBack -------
SET IDENTITY_INSERT dbo.t_FileBack ON
------tmp_RegisterCaseBack----------
SET IDENTITY_INSERT dbo.t_RegisterCaseBack ON
--------tmp_RecordCaseBack --------
SET IDENTITY_INSERT dbo.t_RecordCaseBack ON
----------tmp_CaseBack-----------
insert dbo.t_CaseBack([rf_idRecordCaseBack],[TypePay])
insert dbo.t_PatientBack([rf_idRecordCaseBack],[rf_idF008],[SeriaPolis],[NumberPolis],[rf_idSMO],[OKATO])
------------------------------L----------------------
------tmp_RegisterPatient -------------
SET IDENTITY_INSERT dbo.t_RegisterPatient ON

-----tmp_RegisterPatientDocument-----------
insert dbo.t_RegisterPatientDocument([rf_idRegisterPatient],[rf_idDocumentType],[SeriaDocument],[NumberDocument],[SNILS],[OKATO],[OKATO_Place])
insert dbo.t_RegisterPatientAttendant([rf_idRegisterPatient],[Fam],[Im],[Ot],[rf_idV005],[BirthDay])