USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_DefineSMOIteration2_4]    Script Date: 24.12.2020 14:15:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_DefineSMOIteration2_4]
			@id int,---23.05.2012
			@iteration tinyint,
			@file varchar(26)
			
as
SET xact_abort ON;

--В таблицу ZP1LOG добовляю записи о файле. В качестве имени файла @iteration+@file
declare @count int,
		@fileName varchar(27)=CAST(@iteration as CHAR(1))+@file
---23.05.2012
select @count=count(r.rf_idCase) 
from t_RefCasePatientDefine r 
where rf_idFiles=@id and NOT EXISTS(SELECT * FROM t_CasePatientDefineIteration WHERE rf_idRefCaseIteration=r.id)

--объявляю переменную для того что бы передать ее в удаленную процедуру
declare @xml nvarchar(max)
-- добавляю данные в таблицу PolicyRegister.dbo.ZP1
create table #tmpPerson
(
			RECID bigint,
			FAM varchar(25),
			IM varchar(20),
			OT varchar(20),
			DR date ,
			W tinyint,
			OPDOC varchar(1),
			SPOL varchar(20),
			NPOL varchar(20),
			DOUT datetime,
			DOCTP varchar(2),
			DOCS varchar(20),
			DOCN varchar(20),
			SS varchar(14)
)

if @iteration=2
begin
insert #tmpPerson
select distinct t.id as RECID, left(rtrim(p.Fam),25) as FAM, left(rtrim(p.Im),20) as IM, left(rtrim(p.Ot),20) as OT, p.BirthDay as DR,ISNULL(p.rf_idV005_A,p.rf_idV005) as W, rc.rf_idF008 as OPDOC,
		rtrim(rc.SeriaPolis) as SPOL,rtrim(rc.NumberPolis) as NPOL,cc.DateEnd as DOUT,pd.rf_idDocumentType as DOCTP ,rtrim(pd.SeriaDocument) as DOCS,
		rtrim(pd.NumberDocument) as DOCN, pd.SNILS as SS
from (
		select r.id, r.rf_idCase,r.rf_idRegisterPatient
		from t_RefCasePatientDefine r 
	    where rf_idFiles=@id and (IsUnloadIntoSP_TK is null)
	 ) t inner join t_Case c on
					t.rf_idCase=c.id 		
		inner join vw_RegisterPatient p on
					t.rf_idRegisterPatient=p.id
		inner join t_RecordCase rc on
					p.rf_idRecordCase=rc.id
					and rc.id=c.rf_idRecordCase
		inner join dbo.t_CompletedCase cc ON----добавил
					c.rf_idRecordCase=cc.rf_idRecordCase 
		left join t_RegisterPatientDocument pd on
					p.id=pd.rf_idRegisterPatient

end	
if @iteration=4 AND @count>0
begin
insert #tmpPerson
select distinct t.id as RECID, left(rtrim(p.Fam),25) as FAM, left(rtrim(p.Im),20) as IM, left(rtrim(p.Ot),20) as OT, p.BirthDay as DR,
		ISNULL(p.rf_idV005_A,p.rf_idV005) as W, rc.rf_idF008 as OPDOC,
		rtrim(rc.SeriaPolis) as SPOL,rtrim(rc.NumberPolis) as NPOL,cc.DateEnd as DOUT,pd.rf_idDocumentType as DOCTP ,rtrim(pd.SeriaDocument) as DOCS,
		rtrim(pd.NumberDocument) as DOCN, pd.SNILS as SS
from (--получаем список записей которые не определены
		select r.id, r.rf_idCase,r.rf_idRegisterPatient
		from t_RefCasePatientDefine r 
	    where rf_idFiles=@id and NOT EXISTS(SELECT * FROM t_CasePatientDefineIteration WHERE rf_idRefCaseIteration=r.id)	    
	 ) t inner join t_Case c on
					t.rf_idCase=c.id 
		inner join vw_RegisterPatient p on
					t.rf_idRegisterPatient=p.id
		inner join t_RecordCase rc on
					p.rf_idRecordCase=rc.id
					and rc.id=c.rf_idRecordCase
		inner join dbo.t_CompletedCase cc ON--добавил
					c.rf_idRecordCase=cc.rf_idRecordCase 
		left join t_RegisterPatientDocument pd on
					p.id=pd.rf_idRegisterPatient
	
end
if(select @@SERVERNAME)!='TSERVER' AND @count>0
begin
	insert t_CaseDefineZP1(rf_idRefCaseIteration,rf_idZP1) exec PolicyRegister.dbo.usp_InsertFilesZP1 @fileName,@count,@xml
end
