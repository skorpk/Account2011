USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test485',N'P')) is not null
	drop PROCEDURE dbo.usp_Test485
go
CREATE PROC [dbo].[usp_Test485]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,485
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				
				INNER JOIN dbo.t_ONK_SL s ON
		c.id=s.rf_idCase		             
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND s.DS1_T IN(3,4) AND c.rf_idV006<>3
GO
GRANT EXECUTE ON usp_Test485 TO db_RegisterCase
go

