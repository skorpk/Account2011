--��������� PolicyRegisterTest ��� ������������ ������� ������ �� ����������� ���.������. �� �� ���
USE PolicyRegister
GO
--��������� ����� ��������� �� ������� ��� ��������� ���� ���
if OBJECT_ID('usp_InsertFilesZP1',N'P') is not null
	drop proc usp_InsertFilesZP1
GO
create proc usp_InsertFilesZP1
			@file varchar(26),
			@countRec int,
			@table as nvarchar(max)
as
declare @id int
insert ZP1LOG(FILENAME,NREC) values(@file,@countRec) 
set @id=SCOPE_IDENTITY()

--��������� ������� ������ � ������� ��� ���� ��� �� ��������� ������ � �� ��� �� ����������� ��������� ��������������
declare @tableCaseZPID as table(rf_idRefCaseIteration bigint, zpid int)

-- ������� � ������� ZP1
insert dbo.ZP1(ZID,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS)
	output cast(inserted.RECID as bigint),inserted.ID into @tableCaseZPID
select @id,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS
from #tmpPerson

insert into ERPMSG(TP,LPUID,DT,DTO) 
select 'ZP1',zpid,getdate(),zp.DOUT
from @tableCaseZPID t inner join dbo.ZP1 zp on
			t.zpid=zp.ID

select t.rf_idRefCaseIteration,t.zpid from @tableCaseZPID t

go
----------------------------------------------------------------------------------
--------------�� �� ���������� �.�. ��� �� �����-----------------------------

--��������� ����� ��������� �� ������� ��� ��������� ���� ���
if OBJECT_ID('usp_InsertFilesZP1LPOG',N'P') is not null
	drop proc usp_InsertFilesZP1LPOG
GO

/*create proc usp_InsertZP1
			@table as nvarchar(max),
			@ZID int			
as
--��������� ������� ������ � ������� ��� ���� ��� �� ��������� ������ � �� ��� �� ����������� ��������� ��������������
declare @tableCaseZPID as table(rf_idRefCaseIteration bigint, zpid int)

declare @t xml
select @t=CAST(@table as xml)
declare @idoc int
EXEC sp_xml_preparedocument @idoc OUTPUT, @table

-- ������� � ������� ZP1
insert dbo.ZP1(ZID,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS)
	output cast(inserted.RECID as bigint),inserted.ID into @tableCaseZPID
select @ZID,RECID,Fam,Im,Ot,DR,W,OPDOC,SPOL,NPOL,DOUT,DOCTP,DOCS,DOCN,SS
FROM OPENXML (@idoc, 'PATIENT/CASE',2)
	with
		(
			RECID bigint,
			FAM nvarchar(25),
			IM nvarchar(20),
			OT nvarchar(20),
			DR date ,
			W tinyint,
			OPDOC nvarchar(1),
			SPOL nvarchar(20),
			NPOL nvarchar(20),
			DOUT datetime,
			DOCTP nvarchar(2),
			DOCS nvarchar(20),
			DOCN nvarchar(20),
			SS nvarchar(14)
		) 
exec sp_xml_removedocument @idoc
-- ������� � ������� ERPMSG
insert into ERPMSG(TP,LPUID,DT,DTO) 
select 'ZP1',zpid,getdate(),zp.DOUT
from @tableCaseZPID t inner join dbo.ZP1 zp on
			t.zpid=zp.ID

select t.rf_idRefCaseIteration,t.zpid from @tableCaseZPID t
*/

go