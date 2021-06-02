use RegisterCases
go
if(OBJECT_ID('t_XSD',N'U')) is not null
	drop table dbo.t_XSD
go
create table dbo.t_XSD
(
	FileNameXSD varchar(60) NOT NULL,
	DateEdit DATETIME DEFAULT GETDATE() NOT NULL,	
	xsdDate XML
)
GO
--------------------------------------general file--------------------------------------
INSERT dbo.t_XSD( FileNameXSD, DateEdit, xsdDate )
SELECT 'schemaType',GETDATE(),CONVERT(xml, BulkColumn, 2) 
FROM OPENROWSET(Bulk 'c:\xsd\schemaType.xsd', SINGLE_BLOB) [rowsetresults]
--------------------------------------RegisterCases files--------------------------------------
INSERT dbo.t_XSD( FileNameXSD, DateEdit, xsdDate )
SELECT 'schemaRegisterOfCase_v1.2',GETDATE(),CONVERT(xml, BulkColumn, 2) 
FROM OPENROWSET(Bulk 'c:\xsd\schemaRegisterOfCase_v1.2.xsd', SINGLE_BLOB) [rowsetresults]

INSERT dbo.t_XSD( FileNameXSD, DateEdit, xsdDate )
SELECT 'schemaRegisterOfCasePeople_v1.2',GETDATE(),CONVERT(xml, BulkColumn, 2) 
FROM OPENROWSET(Bulk 'c:\xsd\schemaRegisterOfCasePeople_v1.2.xsd', SINGLE_BLOB) [rowsetresults]
GO
SELECT * FROM t_XSD
GO
use AccountOMS
go
if(OBJECT_ID('t_XSD',N'U')) is not null
	drop table dbo.t_XSD
go
create table dbo.t_XSD
(
	FileNameXSD varchar(60) NOT NULL,
	DateEdit DATETIME DEFAULT GETDATE() NOT NULL,
	xsdDate XML
)
GO
--------------------------------------general file--------------------------------------
INSERT dbo.t_XSD( FileNameXSD, DateEdit, xsdDate )
SELECT 'schemaType',GETDATE(),CONVERT(xml, BulkColumn, 2) 
FROM OPENROWSET(Bulk 'c:\xsd\schemaType.xsd', SINGLE_BLOB) [rowsetresults]
--------------------------------------AccountOMS files--------------------------------------
INSERT dbo.t_XSD( FileNameXSD, DateEdit,xsdDate )
SELECT 'schemaAccount_v1.1.xsd',GETDATE(),CONVERT(xml, BulkColumn, 2) 
FROM OPENROWSET(Bulk 'c:\xsd\schemaAccount_v1.1.xsd', SINGLE_BLOB) [rowsetresults]

INSERT dbo.t_XSD( FileNameXSD, DateEdit,xsdDate )
SELECT 'schemaAccountPeople_v1.1',GETDATE(),CONVERT(xml, BulkColumn, 2) 
FROM OPENROWSET(Bulk 'c:\xsd\schemaAccountPeople_v1.1.xsd', SINGLE_BLOB) [rowsetresults]
go
SELECT * FROM t_XSD