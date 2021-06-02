USE RegisterCases
go

CREATE VIEW vw_DentalMU
AS
SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=57 
UNION ALL
SELECT MU FROM dbo.vw_sprMU WHERE MUGroupCode=2 AND MUUnGroupCode=60
UNION ALL
SELECT code FROM OMS_NSI.dbo.sprDentalMU 
go