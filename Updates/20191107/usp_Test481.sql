USE [RegisterCases]
GO
create PROC [dbo].[usp_Test481]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,481
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20191101'
				INNER JOIN dbo.t_PatientSMO ps ON
        r.id=ps.ref_idRecordCase				
where a.rf_idFiles=@idFile AND (ps.ENP IS NULL AND ps.ST_OKATO<>'18000' ANd c.rf_idV006<4)
	AND EXISTS(
					SELECT 1 FROM dbo.vw_PatientDocument p WHERE p.rf_idRecordCase=r.id AND p.rf_idFiles=@idFile AND (p.DOCDATE IS NULL OR p.DOCORG IS NULL)
				)


GO
GRANT EXECUTE ON usp_Test481 TO db_RegisterCase
go

