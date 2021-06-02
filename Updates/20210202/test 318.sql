CREATE TABLE #t(id TINYINT, rf_idAddCretiria VARCHAR(20))
/*
INSERT #t(id,rf_idAddCretiria) VALUES(1,'mt002'),(1,'fr08-10'),(2,'mt004'),(3,'fr08-10'),(3,'sha10'),(4,'fr08-10')

;WITH cte
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY id ORDER BY rf_idAddCretiria) AS idRow,id,rf_idAddCretiria
FROM #t
)
SELECT c1.*,c2.*
FROM cte c1 INNER JOIN cte c2 ON
		c1.id = c2.id
		AND c1.idRow <> c2.idRow
WHERE (c1.rf_idAddCretiria LIKE 'mt%' OR c1.rf_idAddCretiria LIKE 'fr%') AND (c2.rf_idAddCretiria NOT LIKE 'fr%' and c2.rf_idAddCretiria NOT LIKE 'mt%')
*/
INSERT #t(id,rf_idAddCretiria) VALUES(1,'sh002'),(1,'sha10'),(2,'sh004'),(3,'fr08-10'),(3,'sha10'),(4,'fr08-10')

;WITH cte
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY id ORDER BY rf_idAddCretiria) AS idRow,id,rf_idAddCretiria
FROM #t
)
SELECT c1.*,c2.*
FROM cte c1 INNER JOIN cte c2 ON
		c1.id = c2.id
		AND c1.idRow <> c2.idRow
WHERE c1.rf_idAddCretiria LIKE 'sh%'  AND c2.rf_idAddCretiria NOT LIKE 'sh%'

GO
DROP TABLE #t