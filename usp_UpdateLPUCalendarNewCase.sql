USE RegisterCases
go
IF OBJECT_ID('usp_UpdateLPUCalendarNewCase',N'P') IS NOT NULL
DROP PROC usp_UpdateLPUCalendarNewCase
GO
CREATE PROCEDURE usp_UpdateLPUCalendarNewCase		
				@doc XML,
				@reportYear SMALLINT
AS
DECLARE @idoc int,
        @err int        

DECLARE @t AS TABLE(ReportMonth SMALLINT,ControlDate DATE)
EXEC  @err = sp_xml_preparedocument @idoc OUTPUT, @doc

insert @t
select ReportMonth,ControlDate
from OPENXML(@idoc, '/ROWS/ROW', 2)
          WITH (ReportMonth INT,ControlDate CHAR(8))

 EXEC sp_xml_removedocument @idoc
 SET XACT_ABORT ON
 
begin transaction
begin try
 UPDATE s SET s.ControlDate1=t.ControlDate,s.ControlDate2=t.ControlDate
 from dbo.sprCalendarPR_NOV0 s INNER JOIN @t t ON
		s.ReportMonth=t.ReportMonth
 WHERE s.ReportYear=@reportYear
 
 INSERT t_UserAction(WinLogin,DateAction,XmlAction) VALUES(ORIGINAL_LOGIN(),GETDATE(),@doc)

end try
begin catch
	select ERROR_MESSAGE()
	select 'Error'
	if @@TRANCOUNT>0
	rollback transaction
goto Exit1--выходим из обработки данных
end catch
if @@TRANCOUNT>0
	commit transaction
	
Exit1:
GO