use RegisterCases
go
--тип данных для определения страхователя на ЕРЗ
if exists(select * from sys.types where name='TVP_CasePatient' )
	drop type TVP_CasePatient
go
CREATE TYPE dbo.TVP_CasePatient AS TABLE( rf_idCase bigint NOT NULL,ID_Patient int)
GO
if exists(select * from sys.types where name='TVP_Error' )
	drop type TVP_Error
go
CREATE TYPE dbo.TVP_Error AS TABLE( ErrorNumber int NOT NULL,ErrorTag varchar(50),ErrorValue varchar(40) null, [ErrorFile] varchar(26),ErrorParentTag varchar(50))
GO
if exists(select * from sys.types where name='TVP_Insurance' )
	drop type TVP_Insurance
go
CREATE TYPE dbo.TVP_Insurance AS TABLE(
										id bigint,
										ENP varchar(16),
										FAM varchar(40),
										IM varchar(40),
										OT varchar(40),
										DR datetime,
										MR varchar(100),
										SS varchar(16),
										DOCS  varchar(20),
										DOCN varchar(20),
										OKATO varchar(11),
										DateEnd date
										)
GO