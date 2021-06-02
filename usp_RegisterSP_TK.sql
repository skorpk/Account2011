use RegisterCases
go
if OBJECT_ID('usp_RegisterSP_TK',N'P') is not null
	drop proc usp_RegisterSP_TK
go
create proc usp_RegisterSP_TK
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
		,isnull(p.AttachCodeM,'000000') as MO_PR
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack							
where rf_idFilesBack=@idFileBack AND NOT EXISTS(SELECT * FROM dbo.t_RefCaseAttachLPUItearion2 WHERE rf_idFiles=@idFile AND rf_idCase=recb.rf_idCase)
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
			att.rf_idFiles=@idFile 
			AND att.rf_idCase=recb.rf_idCase
where rf_idFilesBack=@idFileBack 
group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis
		,case WHEN p.OKATO<>'18000' THEN '34'else ISNULL(REPLACE(rtrim(p.rf_idSMO),'','00'),'00') end 
		,p.OKATO ,rc.idRecord		  
		,CASE WHEN p.OKATO<>'18000' THEN '000000' ELSE att.AttachLPU end 
order by N_ZAP

select c.idRecordCase as IDCASE,upper(c.GUID_Case) as ID_C ,cd.TypePay as OPLATA,rc.idRecord as N_ZAP,null as COMENTSL
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							inner join t_Case c on
				recb.rf_idCase=c.id
							inner join t_CaseBack cd on
				recb.id=cd.rf_idRecordCaseBack
where rf_idFilesBack=@idFileBack
group by c.idRecordCase,c.GUID_Case,cd.TypePay,rc.idRecord
order by N_ZAP

select upper(c.GUID_Case) as ID_C,cast(e.ErrorNumber as int) as REFREASON
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							inner join t_Case c on
				recb.rf_idCase=c.id						
							inner join t_ErrorProcessControl e on
				recb.rf_idCase=e.rf_idCase
				AND e.rf_idFile=@idFile
where rf_idFilesBack=@idFileBack
group by c.GUID_Case,e.ErrorNumber
GO