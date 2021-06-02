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
VALUES ( 1,'������'),( 2,'�������'),( 3,'����'),( 4,'������'),( 5,'���'),( 6,'����'),( 7,'����'),( 8,'������'),( 9,'��������'),
		( 10,'�������'),( 11,'������'),( 12,'�������')
		
SELECT t.id,t.NAME,c.ControlDate2
FROM dbo.sprCalendarPR_NOV0 c INNER JOIN @tMM t ON
				c.ReportMonth=t.id
WHERE c.ReportYear=@reportYear
ORDER BY t.id
go