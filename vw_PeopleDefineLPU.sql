USE RegisterCases
go
IF OBJECT_ID('vw_PeopleDefineLPU',N'V') IS NOT NULL
DROP VIEW vw_PeopleDefineLPU
GO
CREATE VIEW vw_PeopleDefineLPU
AS
select ID,left(LPU,6) as LPU,cast(LPUDT AS date) as LPUDT from PolicyRegister.dbo.PEOPLE
union all
select PID,left(LPU,6),cast(LPUDT AS date) as LPUDT  from PolicyRegister.dbo.HISTLPU
go