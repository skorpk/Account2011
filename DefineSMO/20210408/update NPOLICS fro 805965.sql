USE RegisterCases
GO
DECLARE @idFileBack int

SELECT @idFileBack=idFileBack FROM dbo.vw_getFileBack WHERE ReportYear=2021 AND NumberRegister=80 AND CodeM='805965' AND PropertyNumberRegister=1

CREATE TABLE #tPol(N_ZAP INT,VPOLIS TINYINT,NPOLIS VARCHAR(20))

INSERT #tPol(N_ZAP,VPOLIS,NPOLIS)
VALUES(3293,2,'164559599'),(3292,2,'164559599'),(3291,2,'164559599'),(3290,2,'164559599'),(3289,2,'164559599')
,(1687,3,'3458630841000545'),(1686,3,'3458630841000545'),(1685,3,'3458630841000545')

SELECT DISTINCT  p.rf_idRecordCaseBack,UPPER(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		,rc.idRecord as N_ZAP		
		,pol.VPOLIS AS VPOLIS_OLD,pol.NPOLIS AS NPOLIS_OLD		
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack		
							JOIN #tPol pol ON
			rc.idRecord=pol.N_ZAP					
where rf_idFilesBack=@idFileBack AND rc.idRecord IN(1685,1686,1687,3289,3290,3291,3292,3293)

--BEGIN TRANSACTION

--UPDATE p SET p.rf_idF008=pol.VPOLIS, p.NumberPolis=pol.NPOLIS
--from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
--			rcb.id=recb.rf_idRegisterCaseBack
--							inner join t_RecordCase rc on
--			recb.rf_idRecordCase=rc.id
--							inner join t_PatientBack p on
--			recb.id=p.rf_idRecordCaseBack		
--							JOIN #tPol pol ON
--			rc.idRecord=pol.N_ZAP					
--where rf_idFilesBack=@idFileBack AND rc.idRecord IN(1685,1686,1687,3289,3290,3291,3292,3293)

--SELECT DISTINCT  p.rf_idRecordCaseBack,UPPER(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
--		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
--		,rtrim(p.NumberPolis) as NPOLIS
--		,rc.idRecord as N_ZAP		
--		,pol.VPOLIS AS VPOLIS_OLD,pol.NPOLIS AS NPOLIS_OLD		
--from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
--			rcb.id=recb.rf_idRegisterCaseBack
--							inner join t_RecordCase rc on
--			recb.rf_idRecordCase=rc.id
--							inner join t_PatientBack p on
--			recb.id=p.rf_idRecordCaseBack		
--							JOIN #tPol pol ON
--			rc.idRecord=pol.N_ZAP					
--where rf_idFilesBack=@idFileBack AND rc.idRecord IN(1685,1686,1687,3289,3290,3291,3292,3293)
--commit
GO
DROP TABLE #tPol