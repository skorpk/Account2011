USE RegisterCases
GO
SELECT v.ReportYear,v.ReportMonth,CAST(DATEADD(DAY,-2,CAST(v.CotrolDate AS DATETIME)) AS DATE) AS ControlDate
INTO #Date
FROM (VALUES (2020,1,43866),(2020,2,43894),(2020,3,43924),(2020,4,43959),(2020,5,43985),(2020,6,44015),(2020,7,44048),(2020,8,44077),(2020,9,44107),(2020,10,44139),(2020,11,44168),(2020,12,44207)) v(ReportYear,ReportMonth,CotrolDate)

BEGIN TRANSACTION
;WITH cteDate
AS(
SELECT ReportMonth,
       ReportYear+1 AS ReportYear,
       DATEADD(YEAR,1,ReportDate1) AS ReportDate1,
       DATEADD(YEAR,1,ReportDate2) AS ReportDate2
FROM dbo.sprCalendarPR_NOV0 
WHERE ReportYear=2019
)
INSERT dbo.sprCalendarPR_NOV0(ReportMonth,ReportYear,ReportDate1,ReportDate2,ControlDate1,ControlDate2)
SELECT c.ReportMonth,c.ReportYear,c.ReportDate1,c.ReportDate2,d.ControlDate,d.ControlDate
FROM cteDate c INNER JOIN #Date d ON
		c.ReportMonth=d.ReportMonth
		AND d.ReportYear = c.ReportYear

SELECT * FROM dbo.sprCalendarPR_NOV0 WHERE ReportYear=2020

commit
GO

DROP TABLE #Date