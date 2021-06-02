USE oms_nsi
GO
SELECT * FROM dbo.sprCombinedSurgery WHERE CombinedSurgeryId IN(4,6)

CREATE TABLE #t(id INT, MUSurgery VARCHAR(20))
INSERT #t(id, MUSurgery)VALUES(   1,'A16.12.009'),(1,'A06.12.015'),(2,'A16.12.009.001')
,(3,'A16.12.009.001'),(3,'À16.12.026.018'),(3,'A16.12.038.006')

SELECT r.CombinedSurgeryId, id
FROM (SELECT DISTINCT id,MUSurgery FROM #t ) t INNER JOIN (SELECT CombinedSurgeryId ,Sur1 FROM dbo.sprCombinedSurgery 
					  UNION ALL
					  SELECT CombinedSurgeryId,Sur2 FROM dbo.sprCombinedSurgery ) r ON
         t.MUSurgery=r.Sur1
GROUP BY id,r.CombinedSurgeryId
HAVING COUNT(*)>1

GO
DROP TABLE #t