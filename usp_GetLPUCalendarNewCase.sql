USE RegisterCases
go
IF OBJECT_ID('usp_GetLPUCalendarNewCase',N'P') IS NOT NULL
DROP PROC usp_GetLPUCalendarNewCase
GO
CREATE PROCEDURE usp_GetLPUCalendarNewCase		
				@reportYear smallint
AS
DECLARE @tMM AS TABLE (id TINYINT,NAME VARCHAR(15))
INSERT @tMM
        ( id, NAME )
VALUES ( 1,'Январь'),( 2,'Февраль'),( 3,'Март'),( 4,'Апрель'),( 5,'Май'),( 6,'Июнь'),( 7,'Июль'),( 8,'Август'),( 9,'Сентябрь'),
		( 10,'Октябрь'),( 11,'Ноябрь'),( 12,'Декабрь')
		
SELECT t.id,t.NAME,c.ControlDate2
FROM dbo.sprCalendarPR_NOV0 c INNER JOIN @tMM t ON
				c.ReportMonth=t.id
WHERE c.ReportYear=@reportYear
ORDER BY t.id
go