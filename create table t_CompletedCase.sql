USE RegisterCases
GO
if(OBJECT_ID('t_CompletedCase',N'U')) is not null
	drop table dbo.t_CompletedCase
go
CREATE TABLE dbo.t_CompletedCase(
	id int IDENTITY(1,1) NOT NULL,
	rf_idRecordCase	INT NOT NULL,
	idRecordCase bigint NOT NULL,
	GUID_ZSL uniqueidentifier NOT NULL,	
	DateBegin date NOT NULL,
	DateEnd date NOT NULL,
	VB_P TINYINT NULL,
	HospitalizationPeriod SMALLINT NULL,
	AmountPayment DECIMAL(15,2),	
PRIMARY KEY CLUSTERED 
(
	id ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON RegisterCases
) ON RegisterCases
GO 
ALTER TABLE dbo.t_CompletedCase  WITH CHECK ADD  CONSTRAINT FK_CompCases_Patient FOREIGN KEY(rf_idRecordCase)
REFERENCES dbo.t_RecordCase (id)
ON DELETE CASCADE
GO

ALTER TABLE dbo.t_CompletedCase CHECK CONSTRAINT FK_CompCases_Patient
GO




