USE PolicyRegister
GO
declare @id int

insert ZP1LOG(FILENAME,NREC) values('Test_Define_1',1) 

set @id=SCOPE_IDENTITY()

declare @tableCaseZPID as table(rf_idRefCaseIteration bigint, zpid int)

insert dbo.ZP1(ZID,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS)
	output cast(inserted.RECID as bigint),inserted.ID into @tableCaseZPID
SELECT distinct @id,RECID,Fam,Im,'НЕТ',DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS
FROM dbo.ZP1 
WHERE fam='Султанахмедова' AND IM='Патимат'	AND RECID=108261412

insert into ERPMSG(TP,LPUID,DT,DTO) 
select 'ZP1',zpid,getdate(),zp.DOUT
from @tableCaseZPID t inner join dbo.ZP1 zp on
			t.zpid=zp.ID
select t.rf_idRefCaseIteration,t.zpid from @tableCaseZPID t
GO