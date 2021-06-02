USE RegisterCases
go
if OBJECT_ID('vw_sprErrorTC',N'V') is not null
drop view vw_sprErrorTC
go
create view vw_sprErrorTC
as
select Code,DescriptionError,e.Reason from oms_NSI.dbo.sprAllErrors e
go
if OBJECT_ID('vw_sprErrorFLC',N'V') is not null
drop view vw_sprErrorFLC
go
create view vw_sprErrorFLC
as
select id as Code,Description as DescriptionError from oms_NSI.dbo.sprF012 e
go
IF OBJECT_ID('usp_Errors', N'P') IS NOT NULL
	DROP PROC usp_Errors
GO
