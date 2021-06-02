USE RegisterCases
go
SET NOCOUNT ON
DECLARE @idFile INT
DECLARE @t AS TABLE(idNumber INT)
DECLARE @tCase AS TABLE(id BIGINT, guid_Case UNIQUEIDENTIFIER)
INSERT @t(idNumber) VALUES(4705),(5035),(5050)

INSERT @t(idNumber) VALUES(69),(90),(183),(343),(480),(507),(790),(969),(1241),(1470),(1780),(2285),(2454),(2459),(2466)
		,(2887),(3026),(3307),(3376),(3980),(4096),(4161),(4222),(4280),(4323),(4460),(4552),(4564),(4565),(4920),(5041),(5047)
		,(5274),(5278),(5473),(5479),(5605),(5607)


SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='184512' AND NumberRegister=385 AND ReportYear=2013

INSERT @tCase
        ( id, guid_Case )
SELECT c.id,c.GUID_Case
from t_File f inner join t_RegistersCase r on
			f.id=r.rf_idFiles
				  inner join t_RecordCase rc on
			r.id=rc.rf_idRegistersCase
				  inner join t_Case c on
			rc.id=c.rf_idRecordCase		
					INNER JOIN @t t ON
			c.idRecordCase=t.idNumber		  
where f.id=@idFile	

SELECT a.Account,f.CodeM,c.idRecordCase
from AccountOMS.dbo.t_File f inner join AccountOMS.dbo.t_RegistersAccounts a on
				f.id=a.rf_idFiles
						inner join AccountOMS.dbo.t_RecordCasePatient r on
				a.id=r.rf_idRegistersAccounts
						inner join AccountOMS.dbo.t_Case c on
				r.id=c.rf_idRecordCasePatient
						INNER JOIN @tCase c1 ON
				c.GUID_Case=c1.guid_Case
go