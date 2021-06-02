USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test309',N'P')) is not null
	drop PROCEDURE dbo.usp_Test309
go
CREATE PROC dbo.usp_Test309
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError
SELECT c.id,309
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200320'					
where a.rf_idFiles=@idFile AND f.TypeFile='F' 
--отклоняем все случаи диспансерного наблюдения, кроме случаев выставленных вокод
INSERT #tError
SELECT c.id,309
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200320'			
			  INNER JOIN dbo.t_PurposeOfVisit p ON
		c.id=p.rf_idCase		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND p.rf_idV025='1.3' AND f.CodeM NOT in('103001','103002','103003')

GO
GRANT EXECUTE ON usp_Test309 TO db_RegisterCase