USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_RegisterSP_TK2019]    Script Date: 21.04.2020 8:40:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter proc [dbo].[usp_RegisterSP_TK2019]
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
/* 
т.к совершил ошибку и уходили случай на определение страховой принадлежности в ФФОМС, когда они были отданы в реестре СП и ТК с №1
решил исключить такие случаи
*/	
-----------------------------------------------------------------------------
DECLARE @step TINYINT

SELECT @step=PropertyNumberRegister FROM dbo.t_RegisterCaseBack WHERE rf_idFilesBack=@idFileBack
CREATE TABLE #t(rf_idRecordCase int)
IF @step=2
BEGIN 
		INSERT #t( rf_idRecordCase )
		SELECT DISTINCT recb.rf_idRecordCase
		FROM dbo.t_FileBack f INNER join t_RegisterCaseBack rcb ON
					f.id=rcb.rf_idFilesBack
						inner join t_RecordCaseBack recb on
					rcb.id=recb.rf_idRegisterCaseBack
									inner join t_RecordCase rc on
					recb.rf_idRecordCase=rc.id
		where f.rf_idFiles=@idFile AND PropertyNumberRegister=1
end
-----------------------------------------------------------------------------
select rc.idRecord as N_ZAP
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
group by  rc.idRecord
order by N_ZAP
 /*
 Разделил выбор т.к код МО при диспансеризации и всякое другое .... не возвращается на 2 и 4 итерации, но если мы нашли человека на 1 итерации, то учитываем тот код МО.
 */
SELECT DISTINCT  upper(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		--,case WHEN p.OKATO<>'18000' THEN ISNULL(p.CodeSMO34,'34') ELSE ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO
		,case WHEN p.OKATO<>'18000' THEN ISNULL(p.rf_idSMO,'34') ELSE ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO--убрал вывод кода смо по иногородним по требованию начальства
		,p.OKATO as SMO_OK,rc.idRecord as N_ZAP		
		,isnull(p.AttachCodeM,'000000') as MO_PR,p.ENP,recb.IdStep AS [IDENTITY]
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack							
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT * FROM dbo.t_RefCaseAttachLPUItearion2 WHERE rf_idFiles=@idFile AND rf_idCase=recb.rf_idCase)
		AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
--group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
--		,case WHEN p.OKATO<>'18000' THEN ISNULL(p.rf_idSMO,'34') ELSE ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00')
--		,p.OKATO ,rc.idRecord,isnull(p.AttachCodeM,'000000'),p.ENP,recb.IdStep 
UNION
SELECT DISTINCT upper(rc.ID_Patient) as ID_PAC,p.rf_idF008 as VPOLIS,
		case when rtrim(p.SeriaPolis)='' then null else rtrim(p.SeriaPolis) end as SPOLIS
		,rtrim(p.NumberPolis) as NPOLIS
		--,case WHEN p.OKATO<>'18000' THEN ISNULL(p.CodeSMO34,'34') ELSE ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO
		,case WHEN p.OKATO<>'18000' THEN ISNULL(p.rf_idSMO,'34') ELSE ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end as SMO --убрал вывод кода смо по иногородним по требованию начальства
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
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
--group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
--		,case WHEN p.OKATO<>'18000' THEN ISNULL(p.CodeSMO34,'34') ELSE ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end 
--		,p.OKATO ,rc.idRecord		  
--		,CASE WHEN p.OKATO<>'18000' THEN '000000' ELSE att.AttachLPU end,p.ENP,recb.IdStep 
order by N_ZAP

SELECT  t.IDCASE ,t.ID_C ,MAX(t.OPLATA) AS OPLATA,t.N_ZAP ,t.COMENTSL
FROM (
select cc.idRecordCase as IDCASE,upper(cc.GUID_ZSL) as ID_C ,cd.TypePay as OPLATA,rc.idRecord as N_ZAP,null as COMENTSL
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							INNER JOIN dbo.t_CompletedCase cc ON --new
				rc.id=cc.rf_idRecordCase                          
							inner join t_Case c on
				recb.rf_idCase=c.id
							inner JOIN t_CaseBack cd on
				recb.id=cd.rf_idRecordCaseBack
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
group by cc.idRecordCase,cc.GUID_ZSL,cd.TypePay,rc.idRecord
) t
GROUP BY t.IDCASE ,t.ID_C ,t.N_ZAP ,t.COMENTSL
order by N_ZAP

select upper(cc.GUID_ZSL) as ID_C,cast(e.ErrorNumber as VARCHAR(12)) as REFREASON
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
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
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
where rf_idFilesBack=@idFileBack AND recb.IdStep=1 AND NOT EXISTS(SELECT 1 FROM #t t WHERE t.rf_idRecordCase=recb.rf_idRecordCase)
-----------------------------------------------------------------------------------------------------
DROP TABLE #t
