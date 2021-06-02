USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_DefineSMOIteration2_4]    Script Date: 01/22/2012 13:35:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_DefineSMOIteration2_4]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_DefineSMOIteration2_4]
GO

USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_DefineSMOIteration2_4]    Script Date: 01/22/2012 13:35:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[usp_DefineSMOIteration2_4]
			@idRecordCase TVP_CasePatient READONLY,
			@iteration tinyint,
			@file varchar(26)
			
as
SET xact_abort ON;

-- id вставленных записях в таблицу t_RefCaseIteration
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int) 

--id вставленной записи в таблицу ZP1LOG
declare @ZID int 
--begin try
--дабовляю в таблицу t_RefCaseIteration сведения с итерацией №2 или №4
insert @idTable
select rf.id, t.rf_idCase,t.ID_Patient
from @idRecordCase t inner join t_RefCasePatientDefine rf on
		t.rf_idCase=rf.rf_idCase and
		t.ID_Patient=rf.rf_idRegisterPatient

--В таблицу ZP1LOG добовляю записи о файле. В качестве имени файла @iteration+@file
declare @count int,
		@fileName varchar(27)=CAST(@iteration as CHAR(1))+@file
				
select @count=COUNT(t.rf_idCase) from @idRecordCase t


--объявляю переменную для того что бы передать ее в удаленную процедуру
declare @xml nvarchar(max)
-- добавляю данные в таблицу PolicyRegister.dbo.ZP1
if @iteration=2
begin

set @xml=( select t.id as RECID,
				   rtrim(p.Fam) as FAM,
				   rtrim(p.Im) as IM,
				   rtrim(p.Ot) as OT,
				   p.BirthDay as DR,
				   p.rf_idV005 as W,
				   rc.rf_idF008 as OPDOC,
				   rtrim(rc.SeriaPolis) as SPOL,
				   rtrim(rc.NumberPolis) as NPOL,
				   c.DateEnd as DOUT,
				   pd.rf_idDocumentType as DOCTP ,
				   rtrim(pd.SeriaDocument) as DOCS,
				   rtrim(pd.NumberDocument) as DOCN,
				   pd.SNILS as SS
			from @idTable t inner join t_Case c on
					t.rf_idCase=c.id 
							inner join vw_RegisterPatient p on
					t.rf_idRegisterPatient=p.id
							inner join t_RecordCase rc on
					p.rf_idRecordCase=rc.id
							left join t_RegisterPatientDocument pd on
					p.id=pd.rf_idRegisterPatient
			FOR XML PATH('CASE'),ROOT('PATIENT')
		 )

end	
if @iteration=4
begin
set @xml=(  select t.id as RECID,
				   rtrim(p.Fam) as FAM,
				   rtrim(p.Im) as IM,
				   rtrim(p.Ot) as OT,
				   p.BirthDay as DR,
				   p.rf_idV005 as W,
				   rc.rf_idF008 as OPDOC,
				   rtrim(rc.SeriaPolis) as SPOL,
				   rtrim(rc.NumberPolis) as NPOL,
				   null as DOUT,
				   pd.rf_idDocumentType as DOCTP ,
				   rtrim(pd.SeriaDocument) as DOCS,
				   rtrim(pd.NumberDocument) as DOCN,
				   pd.SNILS as SS
			from @idTable t inner join t_Case c on
					t.rf_idCase=c.id 
							inner join vw_RegisterPatient p on
					t.rf_idRegisterPatient=p.id
							inner join t_RecordCase rc on
					p.rf_idRecordCase=rc.id
							left join t_RegisterPatientDocument pd on
					p.id=pd.rf_idRegisterPatient
			FOR XML PATH('CASE'),ROOT('PATIENT')
		)
end
if(select @@SERVERNAME)!='TSERVER'
begin
--перед развертыванием не обходимо изменить PolicyRegisterTest на PolicyRegister
insert t_CaseDefineZP1(rf_idRefCaseIteration,rf_idZP1) exec PolicyRegister.dbo.usp_InsertFilesZP1LPOG @fileName,@count,@xml
end

GO

