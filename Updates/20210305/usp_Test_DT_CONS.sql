USE RegisterCases
GO
if(OBJECT_ID('usp_Test_DT_CONS',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_DT_CONS
go
CREATE PROC dbo.usp_Test_DT_CONS
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,'006F.00.0600'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'				
			  JOIN t_Consultation con ON
		c.id=con.rf_idCase	
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND con.DateCons>c.DateEnd

GO
GRANT EXECUTE ON usp_Test_DT_CONS TO db_RegisterCase