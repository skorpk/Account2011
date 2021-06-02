USE RegisterCases
GO
declare @id INT
SELECT @id=idFileBack FROM dbo.vw_getFileBack WHERE ReportYear=2013 AND CodeM='102604' AND NumberRegister=400010

select recb.id,pb.*
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack											
							inner join dbo.t_PatientBack pb on
			recb.id=pb.rf_idRecordCaseBack
WHERE rcb.rf_idFilesBack=@id AND OKATO NOT IN ('00000','18000') AND RTRIM(ISNULL(rf_idSMO,'0'))<>'34'

BEGIN TRANSACTION
UPDATE pb SET pb.rf_idSMO='34'
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack											
							inner join dbo.t_PatientBack pb on
			recb.id=pb.rf_idRecordCaseBack
WHERE rcb.rf_idFilesBack=@id AND OKATO NOT IN ('00000','18000') AND RTRIM(ISNULL(rf_idSMO,'0'))<>'34'

select recb.id,pb.*
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack											
							inner join dbo.t_PatientBack pb on
			recb.id=pb.rf_idRecordCaseBack
WHERE rcb.rf_idFilesBack=@id AND OKATO NOT IN ('00000','18000') AND RTRIM(ISNULL(rf_idSMO,'0'))<>'34'

--COMMIT