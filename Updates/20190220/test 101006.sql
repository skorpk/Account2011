USE RegisterCases
GO
DECLARE @idFileBack INT,
		@idFile int

SELECT @idFileBack=idFileBack, @idFile=rf_idFiles FROM dbo.vw_getFileBack WHERE CodeM='106001' AND ReportYear=2019 AND NumberRegister=12 AND PropertyNumberRegister=1

select c.idRecordCase as IDCASE,upper(cc.GUID_ZSL) as ID_C ,MAX(cd.TypePay) as OPLATA,rc.idRecord as N_ZAP,null as COMENTSL
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							inner join t_Case c on
				recb.rf_idCase=c.id
							inner join t_CaseBack cd on
				recb.id=cd.rf_idRecordCaseBack
							INNER JOIN dbo.t_CompletedCase cc ON
				rc.id=cc.rf_idRecordCase                          
where rf_idFilesBack=@idFileBack AND rc.ID_Patient='49951703-E924-A4E7-243C-A2342F33CD7B' 
group by c.idRecordCase,cc.GUID_ZSL,rc.idRecord
order by N_ZAP




select upper(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO
		,p.OKATO as SMO_OK,rc.idRecord as N_ZAP
		--включить с 01.01.2013
		,isnull(p.AttachCodeM,'000000') as MO_PR,p.ENP,recb.IdStep AS [IDENTITY] ,1 AS IdSt
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack							
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT * FROM dbo.t_RefCaseAttachLPUItearion2 WHERE rf_idFiles=@idFile AND rf_idCase=recb.rf_idCase)
	AND rc.ID_Patient='49951703-E924-A4E7-243C-A2342F33CD7B'
group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end 
		,p.OKATO ,rc.idRecord,isnull(p.AttachCodeM,'000000'),p.ENP,recb.IdStep 

select upper(cc.GUID_ZSL) as ID_C,cast(e.ErrorNumber as int) as REFREASON
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							inner join t_Case c on
				recb.rf_idCase=c.id						
							inner join t_ErrorProcessControl e on
				recb.rf_idCase=e.rf_idCase
				AND e.rf_idFile=@idFile
							INNER JOIN dbo.t_CompletedCase cc ON
				rc.id=cc.rf_idRecordCase
where rf_idFilesBack=@idFileBack AND ID_Patient='49951703-E924-A4E7-243C-A2342F33CD7B'
group by cc.GUID_ZSL,e.ErrorNumber