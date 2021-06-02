USE [RegisterCases]
GO

if OBJECT_ID('usp_RegisterSP_TK2019',N'P') is not NULL
	DROP PROCEDURE usp_RegisterSP_TK2019
GO

CREATE proc dbo.usp_RegisterSP_TK2019
			@idFileBack int
as
DECLARE @idFile INT 

update t_FileBack set IsUnload=1 where id=@idFileBack and IsUnload=0

SELECT @idFile=rf_idFiles FROM dbo.t_FileBack WHERE id=@idFileBack

select FileVersion as [VERSION],cast(DateCreate as date) as DATA,FileNameHRBack as [FILENAME]
from t_FileBack
where id=@idFileBack

select id as CODE, ref_idF003 as CODE_MO,cast(ReportYear as int) as [YEAR],cast(ReportMonth as int) as [MONTH],
		CAST(NumberRegister as varchar(8))+'-'+CAST(PropertyNumberRegister as char(1)) as NSCHET,
		DateCreate as DSCHET
from t_RegisterCaseBack
where rf_idFilesBack=@idFileBack
	
select rc.idRecord as N_ZAP
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
where rf_idFilesBack=@idFileBack
group by  rc.idRecord
order by N_ZAP
 /*
 Разделил выбор т.к код МО при диспансеризации и всякое другое .... не возвращается на 2 и 4 итерации, но если мы нашли человека на 1 итерации, то учитываем тот код МО.
 */
select upper(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO
		,p.OKATO as SMO_OK,rc.idRecord as N_ZAP
		--включить с 01.01.2013
		,isnull(p.AttachCodeM,'000000') as MO_PR,p.ENP,recb.IdStep AS [IDENTITY]
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack							
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT * FROM dbo.t_RefCaseAttachLPUItearion2 WHERE rf_idFiles=@idFile AND rf_idCase=recb.rf_idCase)
group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end 
		,p.OKATO ,rc.idRecord,isnull(p.AttachCodeM,'000000'),p.ENP,recb.IdStep 
UNION ALL
select upper(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO
		,p.OKATO as SMO_OK,rc.idRecord as N_ZAP
		,CASE WHEN p.OKATO<>'18000' THEN '000000' ELSE att.AttachLPU end as MO_PR
		,p.ENP
		,recb.IdStep AS IdStep
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack							
							INNER JOIN dbo.t_RefCaseAttachLPUItearion2 att on
			att.rf_idFiles=@idFile 
			AND att.rf_idCase=recb.rf_idCase
where rf_idFilesBack=@idFileBack 
group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end 
		,p.OKATO ,rc.idRecord		  
		,CASE WHEN p.OKATO<>'18000' THEN '000000' ELSE att.AttachLPU end,p.ENP,recb.IdStep 
order by N_ZAP
---случай
select cc.idRecordCase as IDCASE,upper(cc.GUID_ZSL) as ID_C ,cd.TypePay as OPLATA,rc.idRecord as N_ZAP,null as COMENTSL
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							INNER JOIN dbo.t_CompletedCase cc ON --new
				rc.id=cc.rf_idRecordCase                          
							inner join t_Case c on
				recb.rf_idCase=c.id
							inner join t_CaseBack cd on
				recb.id=cd.rf_idRecordCaseBack
where rf_idFilesBack=@idFileBack
group by cc.idRecordCase,cc.GUID_ZSL,cd.TypePay,rc.idRecord
order by N_ZAP

select upper(cc.GUID_ZSL) as ID_C,cast(e.ErrorNumber as int) as REFREASON
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							INNER JOIN dbo.t_CompletedCase cc ON --new
				rc.id=cc.rf_idRecordCase 
							inner join t_Case c on
				recb.rf_idCase=c.id						
							inner join t_ErrorProcessControl e on
				recb.rf_idCase=e.rf_idCase
				AND e.rf_idFile=@idFile
where rf_idFilesBack=@idFileBack
group by cc.GUID_ZSL,e.ErrorNumber
-------------------------------Correction Information----------------------------------------------------------------------

SELECT DISTINCT upper(rc.ID_Patient) as ID_PAC,CASE WHEN cor.TypeEquale=1 then cor.FAM ELSE NULL END AS Fam
		,CASE WHEN cor.TypeEquale=2 then isnull(cor.IM,'') ELSE NULL END AS Im
		,CASE WHEN cor.TypeEquale=3 then isnull(cor.OT,'') ELSE NULL END AS Ot
		,CASE WHEN cor.TypeEquale=4 then cor.BirthDay ELSE NULL END AS DR
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							INNER JOIN dbo.t_RefCasePatientDefine rf ON
			recb.rf_idCase=rf.rf_idCase
							INNER JOIN dbo.t_CaseDefine cd ON
			rf.id=cd.rf_idRefCaseIteration
							INNER JOIN dbo.t_Correction cor ON
			cor.rf_idCaseDefine=cd.id                          
where rf_idFilesBack=@idFileBack AND recb.IdStep=1
-----------------------------------------------------------------------------------------------------

GO
GRANT EXECUTE ON usp_RegisterSP_TK2019 TO db_RegisterCase

