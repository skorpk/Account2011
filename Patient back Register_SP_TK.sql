USE RegisterCases
GO
DECLARE @idFileBack int
SELECT @idFileBack=idFileBack
FROM dbo.vw_getFileBack WHERE ReportYear=2014 AND NumberRegister=1 AND PropertyNumberRegister=0 AND CodeM='121125'
SELECT @idFileBack
--EXEC dbo.usp_RegisterSP_TK @idFileBack 

select upper(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO
		,p.OKATO as SMO_OK,rc.idRecord as N_ZAP
		--включить с 01.01.2013
		,isnull(p.AttachCodeM,'000000') as MO_PR,recb.rf_idCase,p.rf_idRecordCaseBack
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
where rf_idFilesBack=@idFileBack AND p.rf_idSMO NOT IN ('34','34001','34002','00000')
--group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
--		,case when rtrim(p.rf_idSMO)='' then '00' else ISNULL(rtrim(p.rf_idSMO),'00') end 
--		,p.OKATO ,rc.idRecord
--		,isnull(p.AttachCodeM,'000000') 
order by N_ZAP
