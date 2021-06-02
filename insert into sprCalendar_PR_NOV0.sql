USE RegisterCases
go
SET NOCOUNT ON
--insert sprCalendarPR_NOV1(ReportYear,ControlDateDay) values(2013,5)
INSERT dbo.sprCalendarPR_NOV0
        ( ReportMonth ,
          ReportYear ,
          ReportDate1 ,
          ReportDate2 ,
          ControlDate1 ,
          ControlDate2
        )
SELECT ReportMonth,2021 AS reportYear
		,'2021'+RIGHT('0'+CAST(MONTH(ReportDate1) AS VARCHAR(2)),2)+RIGHT('0'+CAST(DAY(ReportDate1) AS VARCHAR(2)),2)
		,'2021'+RIGHT('0'+CAST(MONTH(ReportDate2) AS VARCHAR(2)),2)+RIGHT('0'+CAST(DAY(ReportDate2) AS VARCHAR(2)),2)
		,'2021'+RIGHT('0'+CAST(MONTH(ControlDate1) AS VARCHAR(2)),2)+RIGHT('0'+CAST(DAY(ControlDate1) AS VARCHAR(2)),2)
		,'2021'+RIGHT('0'+CAST(MONTH(ControlDate2) AS VARCHAR(2)),2)+RIGHT('0'+CAST(DAY(ControlDate2) AS VARCHAR(2)),2)
FROM sprCalendarPR_NOV0 WHERE ReportYear=2020
go
SELECT * FROM sprCalendarPR_NOV0 WHERE ReportYear=2021