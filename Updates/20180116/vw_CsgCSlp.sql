USE RegisterCases
go
alter VIEW vw_CsgCSlp
as
SELECT tCSG.CSGroupId, tCSG.code, tCSG.name,tCSG.rf_CSGTypeId,t1.NAME AS TypeName,noKSLP, tCSG.dateBeg,tCSG.dateEnd
		,l.code AS CodeSLP, CAST(sc.coefficient AS DECIMAL(3,2)) AS VAL_C,sc.dateBeg AS DateBegCoefficient,sc.dateEnd AS DateEndCoefficient
FROM oms_NSI.dbo.tCSGroup tCSG INNER JOIN oms_NSI.dbo.tCSGType t1 ON
				tCSG.rf_CSGTypeId=t1.CSGTypeId
								left JOIN oms_nsi.dbo.tCSGroupSLP slp ON
				tcsg.CSGroupId=slp.rf_CSGroupId                              
									left JOIN oms_nsi.dbo.tSLP l ON
				slp.rf_SLPId=l.SLPId
									LEFT JOIN oms_nsi.dbo.tSLPCoefficient sc ON
				l.SLPId=sc.rf_SLPId                                  
WHERE tCSG.dateEnd>='20180101'

GO
GRANT SELECT ON vw_CsgCSlp TO db_RegisterCase