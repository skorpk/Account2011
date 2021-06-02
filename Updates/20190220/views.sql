USE RegisterCases
go
if OBJECT_ID('vw_MeduslugiBodyParts',N'V') is not NULL
	DROP VIEW vw_MeduslugiBodyParts
GO
CREATE VIEW vw_MeduslugiBodyParts
as
SELECT mm.rf_idCase,mm.MUSurgery,mm.Comments
FROM dbo.t_Meduslugi mm INNER JOIN oms_nsi.dbo.sprNomenclMUBodyParts b ON
			mm.MUSurgery=b.codeNomenclMU
WHERE mm.Comments IS NOT NULL AND DATALENGTH(mm.Comments)>0
go
if OBJECT_ID('vw_MeduslugiCSLP_12',N'V') is not NULL
	DROP VIEW vw_MeduslugiCSLP_12
GO
CREATE VIEW vw_MeduslugiCSLP_12
as
SELECT m.rf_idCase
FROM (
		SELECT DISTINCT rf_idCase,MUSurgery
		FROM dbo.t_Meduslugi m
		WHERE MUSurgery IN('A11.20.017','A11.20.025.001') 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=m.rf_idCase AND MUSurgery is not null and MUSurgery NOT IN ('A11.20.017','A11.20.025.001') )
	) m
GROUP BY rf_idCase
HAVING COUNT(*)=2
UNION ALL
SELECT m.rf_idCase
FROM (
		SELECT DISTINCT rf_idCase,MUSurgery
		FROM dbo.t_Meduslugi m 
		WHERE MUSurgery IN('A11.20.017','A11.20.025.001','A11.20.036') 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=m.rf_idCase AND MUSurgery is not null and MUSurgery NOT IN ('A11.20.017','A11.20.025.001','A11.20.036') )
	) m
GROUP BY rf_idCase
HAVING COUNT(*)=3
UNION ALL
SELECT m.rf_idCase
FROM (
		SELECT DISTINCT rf_idCase,MUSurgery
		FROM dbo.t_Meduslugi  m
		WHERE MUSurgery IN('A11.20.017','A11.20.025.001','A11.20.028') 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=m.rf_idCase AND MUSurgery is not null and MUSurgery NOT IN ('A11.20.017','A11.20.025.001','A11.20.028') )
	) m
GROUP BY rf_idCase
HAVING COUNT(*)=3 
go
if OBJECT_ID('vw_MeduslugiCSLP_13_14',N'V') is not NULL
	DROP VIEW vw_MeduslugiCSLP_13_14
GO
CREATE VIEW vw_MeduslugiCSLP_13
as
SELECT m.rf_idCase,13 AS ID_SL
FROM (
		SELECT DISTINCT rf_idCase,MUSurgery
		FROM dbo.t_Meduslugi m
		WHERE MUSurgery IN('A11.20.017','A11.20.031') 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=m.rf_idCase AND MUSurgery is not null and MUSurgery NOT IN ('A11.20.017','A11.20.031') )
	) m
GROUP BY rf_idCase
HAVING COUNT(*)=2
UNION ALL
SELECT m.rf_idCase,14 AS ID_SL
FROM (
		SELECT DISTINCT rf_idCase,MUSurgery
		FROM dbo.t_Meduslugi m
		WHERE MUSurgery IN('A11.20.017','A11.20.030.001') 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi WHERE rf_idCase=m.rf_idCase AND MUSurgery is not null and MUSurgery NOT IN ('A11.20.017','A11.20.030.001') )
	) m
GROUP BY rf_idCase
HAVING COUNT(*)=2
go

GRANT SELECT ON  vw_MeduslugiBodyParts TO db_RegisterCase;
GRANT SELECT ON  vw_MeduslugiCSLP_12 TO db_RegisterCase;
GRANT SELECT ON  vw_MeduslugiCSLP_13 TO db_RegisterCase;

