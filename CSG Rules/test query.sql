
CREATE TABLE #tab(idRow tinyint,Val1 VARCHAR(5), Val2 TINYINT NOT null, Val3 VARCHAR(20), Val4 TINYINT)

CREATE TABLE #spr(id tinyint,Col1 VARCHAR(5), Col2 TINYINT NOT null, Col3 VARCHAR(20), Col4 TINYINT)

INSERT #tab(idRow,Val1,Val2,Val3,Val4) VALUES(1,'CCC',1,NULL,null)
INSERT #tab(idRow,Val1,Val2,Val3,Val4) VALUES(2,'AA',1,'bla',null)
INSERT #tab(idRow,Val1,Val2,Val3,Val4) VALUES(2,'AA',1,NULL,3)

INSERT #spr(id,Col1,Col2,Col3,Col4) VALUES(1,'CCC',1,NULL,null)
INSERT #spr(id,Col1,Col2,Col3,Col4) VALUES(2,'AA',1,NULL,3)


SELECT *
FROM #tab t INNER JOIN #spr s ON
		t.Val2=s.Col2
		AND t.val1=s.Col1
WHERE s.Col3 IS NULL AND s.col4 IS null

SELECT *
FROM #tab t INNER JOIN #spr s ON
		t.Val2=s.Col2
		AND t.val1=s.Col1
		AND t.Val3=s.Col3
WHERE s.Col4 IS null
SELECT *
FROM #tab t INNER JOIN #spr s ON
		t.Val2=s.Col2
		AND t.val1=s.Col1
		AND t.Val3=s.Col3
		AND t.Val4=s.Col4

SELECT *
FROM #tab t INNER JOIN #spr s ON
		t.Val2=s.Col2
		AND t.val1=s.Col1
		AND t.Val4=s.Col4
WHERE Col3 IS NULL
GO
DROP TABLE #spr
GO
DROP TABLE #tab
