USE RegisterCases
GO
if(OBJECT_ID('usp_Test_D_PROT',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_D_PROT
go
CREATE PROC dbo.usp_Test_D_PROT
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT DISTINCT c.id,'006F.00.0510'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'				
			 JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase
			  JOIN t_Contraindications con ON
		sl.id=con.rf_idONK_SL
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND con.DateContraindications>c.DateEnd

GO
GRANT EXECUTE ON usp_Test_D_PROT TO db_RegisterCase