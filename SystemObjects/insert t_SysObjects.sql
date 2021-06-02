use RegisterCases
go
truncate table t_SysObjects
declare @text as nvarchar(50)='create proc usp_InsertFilesZP1
			@file varchar(26),
			@countRec int,
			@table as nvarchar(max)
as
declare @id int
insert ZP1LOG(FILENAME,NREC) values(@file,@countRec) 
set @id=SCOPE_IDENTITY()

--процедура вставки данных в таблицы для того что бы отправить данные в ЦС ЕРС на определение страховой принадлежности
declare @tableCaseZPID as table(rf_idRefCaseIteration bigint, zpid int)

-- вставка в таблицу ZP1
insert dbo.ZP1(ZID,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS)
	output cast(inserted.RECID as bigint),inserted.ID into @tableCaseZPID
select @id,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS
from #tmpPerson

insert into ERPMSG(TP,LPUID,DT,DTO) 
select ''ZP1'',zpid,getdate(),zp.DOUT
from @tableCaseZPID t inner join dbo.ZP1 zp on
			t.zpid=zp.ID

select t.rf_idRefCaseIteration,t.zpid from @tableCaseZPID t'
select @text
insert t_SysObjects(objName,objType ,DateCreate,LoginName,objText,DBName ) values('usp_InsertFilesZP1','P',GETDATE(),ORIGINAL_LOGIN(),@text,'PolicyRegister')

select * from RegisterCases.dbo.t_SysObjects 