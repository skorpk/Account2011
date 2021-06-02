USE [RegisterCases]
GO
create PROC [dbo].[usp_Test482]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,482
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20191101'
			INNER JOIN dbo.t_CompletedCase cc ON
		cc.rf_idRecordCase = r.id				
where a.rf_idFiles=@idFile 
	AND EXISTS(
					SELECT 1 FROM dbo.vw_PatientDocument p WHERE p.rf_idRecordCase=r.id AND p.rf_idFiles=@idFile AND p.DOCDATE >cc.DateEnd 
				)


GO
GRANT EXECUTE ON usp_Test482 TO db_RegisterCase
go

