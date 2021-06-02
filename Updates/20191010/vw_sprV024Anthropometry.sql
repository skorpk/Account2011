USE RegisterCases
go
create VIEW vw_sprV024Anthropometry
as
SELECT v24.IDDKK,a.isAnthropometry
FROM oms_nsi.dbo.sprV024 v24 INNER JOIN oms_nsi.dbo.sprDrugTherapyScheme a ON
			v24.IDDKK=a.schemeCode
WHERE a.isAnthropometry IS NOT null