USE RegisterCases
GO
if(OBJECT_ID('usp_Test_PROFIL_NOVOR',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_PROFIL_NOVOR
go
CREATE PROC dbo.usp_Test_PROFIL_NOVOR
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
----------------------NPR_DATE--------------------------
INSERT #tError
SELECT DISTINCT c.id,'006F.00.0390'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'	
where a.rf_idFiles=@idFile AND c.rf_idV002=158 AND r.NewBorn<>'0'

GO
GRANT EXECUTE ON usp_Test_PROFIL_NOVOR TO db_RegisterCase