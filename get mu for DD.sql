USE RegisterCases
GO
SELECT c.MU,
	cast(replace('<Root><Num num="'+LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(MUName,'Законченный случай диспансеризации по профилю терапия',''),'Законченный случай диспансеризации женщин (в возрасте',''),' лет), 1 этап',''),', 2 этап ',''),'Законченный случай диспансеризации мужчин (в возрасте ',''),'Законченный случай диспансеризации мужчин  (',''),'Законченный случай диспансеризации мужчин (в возрсте ',''),'лет) без гематологических исследований, 1 этап',''),'в возрасте ',''),'года) без гематологических исследований, 1 этап',''),'), 1 этап (иссл.1 раз в 2 года)',''),' года), 1 этап',''),' года) без исследования кала, 1 этап',''),' лет) без гематологических исследований, без исследования кала, 1 этап',''),' лет) без исследования кала, 1 этап',''),' года) без гематологических исследований, без исследования кала, 1 этап',''),'  лет) без маммографии,  без цитологического исследования, 1 этап',''),' лет) без маммографии, 1 этап',''),' лет) без гематологических исследований, без маммографии, 1 этап',''),' лет) без цитологического исследования, 1 этап без гематологических исследований',''),' лет) без цитологического исследования, 1 этап',''),' без гематологических исследований',''),' лет),  без цитологического исследования, 1 этап',''),' лет) без маммографии,  без цитологического исследования, 1 этап',''),' лет), без маммографии,  без цитологического исследования, 1 этап',''),' лет) без исследования кала,  без цитологического исследования, 1 этап',''),' лет) без исследований кала, 1 этап',''),' лет) без маммографии, без цитологического исследования, 1 этап',''),' лет), без исследования кала,  без цитологического исследования, 1 этап',''),' лет), без цитологического исследования, 1 этап','')))+'" /></Root>',',','" /><Num num="') as xml) AS MUNAme
INTO #t
FROM dbo.vw_sprMUCompletedCase c 			
WHERE MUGroupCode=70 AND MUUnGroupCode=3 AND EXISTS(SELECT 1 FROM dbo.t_AgeMU2 a WHERE c.mu=a.MU)

--SELECT * FROM #t

;WITH cte
AS(
SELECT s.MU,m.c.value('@num[1]','smallint') AS Age
FROM #t s CROSS APPLY s.MUName.nodes('/Root/Num') as m(c)
)
SELECT *
FROM cte c WHERE NOT EXISTS(SELECT * FROM dbo.t_AgeMU2 a WHERE a.MU=c.MU AND a.age=c.age)

SELECT c.MU,MUName	
FROM dbo.vw_sprMUCompletedCase c 			
WHERE MUGroupCode=70 AND MUUnGroupCode=3 AND not EXISTS(SELECT 1 FROM dbo.t_AgeMU2 a WHERE c.mu=a.MU)

go

DROP TABLE #t