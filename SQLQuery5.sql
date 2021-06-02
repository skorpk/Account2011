USE AccountOMS
GO
if(OBJECT_ID('t_AdditionalAccounts',N'U')) is not null
	drop table dbo.t_AdditionalAccounts
go
create table dbo.t_AdditionalAccounts
(
	DateRegistration DATETIME NOT NULL,
	rf_idMO char(6) not null,
	rf_idSMO char(5) NOT null,
	ReportYear smallint not null CONSTRAINT CheckYear CHECK(ReportYear>YEAR(GETDATE())-1 and ReportYear<=YEAR(GETDATE())),
	ReportMonth tinyint not null CONSTRAINT CheckMonth CHECK(ReportMonth>0 and ReportMonth<13),
	NumberRegister tinyint not null,
	DateAccount date not null ,	
	AmountPayment decimal(15,2) null
) 