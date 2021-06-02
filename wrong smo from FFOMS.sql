USE RegisterCases
GO
SELECT z.*,p.*,c.id,reg.rf_idSMO
FROM t_Case c INNER JOIN dbo.t_RefCasePatientDefine r ON
		c.id=r.rf_idCase
			INNER JOIN dbo.t_CasePatientDefineIteration i ON
		r.id=i.rf_idRefCaseIteration
			INNER JOIN dbo.t_CaseDefineZP1Found z ON
		r.id=z.rf_idRefCaseIteration
			INNER JOIN dbo.t_RecordCase r1 ON
		c.rf_idRecordCase=r1.id
			INNER JOIN dbo.t_PatientSMO p ON
		r1.id=p.ref_idRecordCase
			inner join t_RegistersCase reg on
		r1.rf_idRegistersCase=reg.id			
WHERE c.GUID_Case IN ('E2DDAB04-6AA0-C4F6-BCDC-15FBE1CCEE43','AF45E837-8AF0-E772-D51C-13CFE1C9E530','4427B876-2546-3103-820B-4868E1B823CB')

DECLARE @t AS TABLE (rf_idCase bigint)


INSERT @t( rf_idCase )
SELECT DISTINCT recb.rf_idCase
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack	
WHERE p.OKATO='18000' AND p.rf_idSMO='34' AND recb.TypePay=1 AND rcb.ReportYear=2015


SELECT z.*--,p.*,c.id,reg.rf_idSMO
FROM @t c INNER JOIN dbo.t_RefCasePatientDefine r ON
		c.rf_idCase=r.rf_idCase
			INNER JOIN dbo.t_CasePatientDefineIteration i ON
		r.id=i.rf_idRefCaseIteration
			INNER JOIN dbo.t_CaseDefineZP1Found z ON
		r.id=z.rf_idRefCaseIteration
		
			
			

select upper(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO
		,p.OKATO as SMO_OK,rc.idRecord as N_ZAP
		--включить с 01.01.2013
		,isnull(p.AttachCodeM,'000000') as MO_PR
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack							
where recb.rf_idCase=45405887 AND NOT EXISTS(SELECT * FROM dbo.t_RefCaseAttachLPUItearion2 WHERE rf_idCase=recb.rf_idCase)
group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end 
		,p.OKATO ,rc.idRecord,isnull(p.AttachCodeM,'000000') 
UNION ALL
select upper(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO
		,p.OKATO as SMO_OK,rc.idRecord as N_ZAP
		,CASE WHEN p.OKATO<>'18000' THEN '000000' ELSE att.AttachLPU end as MO_PR
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack							
							INNER JOIN dbo.t_RefCaseAttachLPUItearion2 att on
			att.rf_idCase=recb.rf_idCase
WHERE recb.rf_idCase=45405887
group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end 
		,p.OKATO ,rc.idRecord		  
		,CASE WHEN p.OKATO<>'18000' THEN '000000' ELSE att.AttachLPU end 
order by N_ZAP