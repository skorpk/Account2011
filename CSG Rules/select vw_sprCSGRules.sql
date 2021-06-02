USE RegisterCases
GO
DECLARE @csg VARCHAR(15)='ds37.011'

SELECT * FROM vw_sprCSGRules WHERE code=@csg --AND ds1='B34.9'

--SELECT * FROM dbo.sprBitCSGRules WHERE CodeCSG=@csg

