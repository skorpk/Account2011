USE RegisterCases
GO
ALTER VIEW vw_sprCSG_KIRO
as
SELECT B.code as KSG,
       C.code as KIRO,
       D.dateBeg as dateBegKIRO,
       D.dateEnd as dateEndKIRO,
       CAST(E.coefficient AS DECIMAL(3,2)) as COEF,
       E.dateBeg as dateBegCoef,
       E.dateEnd as dateECoef
FROM oms_NSI.dbo.tCSGroup B LEFT JOIN oms_NSI.dbo.tCSGroupKIRO A ON 
			A.rf_CSGroupId = B.CSGroupId
							LEFT JOIN oms_NSI.dbo.tKIRO C ON 
			C.KIROId = A.rf_KIROId
							LEFT JOIN oms_NSI.dbo.tKIROPeriods D ON 
			D.rf_KIROId = C.KIROId
							LEFT JOIN oms_NSI.dbo.tKIROCoefficient E ON 
			E.rf_KIROId = C.KIROId and E.flag = 'A'
WHERE B.dateBeg >= '20180101'
go
GRANT SELECT ON vw_sprCSG_KIRO TO db_RegisterCase
