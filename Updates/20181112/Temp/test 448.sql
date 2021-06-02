CREATE TABLE #tmp
(
	id INT IDENTITY(1,1) NOT NULL,
	CommentSL VARCHAR(250),
	XMLNum AS (CONVERT([xml],replace(('<Root><Num num="'+REPLACE(REPLACE(REPLACE(CommentSL,':',''),';',''),'/',':') )+'" /></Root>',':','" /><Num num="'),0)) 
)

INSERT #tmp(  CommentSL )
VALUES  ( ':2,A75.1,G34,2018-01-01/1,I45,,2018-11-23;'),( ':1,A52.1,K34.5,2018-01-01/1,I45,M45,2018-11-23;'),( ':4,A75.1,G34,;')

SELECT * FROM #tmp

;WITH cte
AS(
SELECT s.id,m.c.value('@num[1]','varchar(30)') AS Comment
FROM #tmp s CROSS APPLY s.XMLNum.nodes('/Root/Num') AS m(c)
)
SELECT *, LEFT(comment,1) AS X
		,SUBSTRING(comment,3,CHARINDEX(',', comment, CHARINDEX(',', comment)+1)-3) AS DS
		,SUBSTRING(comment, CHARINDEX(',', comment, CHARINDEX(',', comment)+1)+1, CHARINDEX(',', comment, CHARINDEX(',', comment,CHARINDEX(',', comment)+1)+1)-CHARINDEX(',', comment, CHARINDEX(',', comment)+1)-1) AS DS1
		,CAST(REPLACE(REVERSE(substring(REVERSE(comment),0,CHARINDEX(',',REVERSE(comment),0))),'-','') AS DATE) AS Date1
		,REVERSE(substring(REVERSE(comment),0,CHARINDEX(',',REVERSE(comment),0)))
		
FROM cte
go

DROP TABLE #tmp