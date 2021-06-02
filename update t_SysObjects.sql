use RegisterCases
declare @text varchar(8000)
set 
@text='create proc usp_InsertFilesZP1
			@file varchar(26),
			@countRec int,
			@table as nvarchar(max)
as
declare @id int
insert ZP1LOG(FILENAME,NREC) values(@file,@countRec) 
set @id=SCOPE_IDENTITY()
declare @tableCaseZPID as table(rf_idRefCaseIteration bigint, zpid int)
insert dbo.ZP1(ZID,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS)
	output cast(inserted.RECID as bigint),inserted.ID into @tableCaseZPID
select @id,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS
from #tmpPerson
insert into ERPMSG(TP,LPUID,DT,DTO) 
select ''ZP1'',zpid,getdate(),zp.DOUT
from @tableCaseZPID t inner join dbo.ZP1 zp on
			t.zpid=zp.ID
select t.rf_idRefCaseIteration,t.zpid from @tableCaseZPID t'
go
select @text

--update t_SysObjects set objText=@text

select * from t_SysObjects